# Architecture

Feature-first Clean Architecture with an offline-first data layer. The UI never waits on the
network; Firebase is the backup and cross-device copy.

```
presentation (screens, widgets, Riverpod controllers)
        │
domain   (entities, use cases, repository interfaces)  ← pure Dart
        │
data     (repository impls) ──► local: Drift (SQLite + FTS5)  ──► outbox
                                         ▲                         │
                              pull on sign-in / resume / 6 h       ▼
                                  remote: Firestore + Storage ◄── sync engine (workmanager)
```

Every write lands in Drift and adds an outbox row **in the same transaction**. The sync engine
pushes outbox rows when online and pulls remote changes on sign-in, app resume and every 6 h.
The outbox table exists from FND-03; the sync engine that drains it ships in SYN-01 (P3).

## Packages

| Concern | Package |
|---|---|
| State + DI | flutter_riverpod, riverpod_generator |
| Navigation | go_router (bottom-nav shell: Home, Schedule, Library, Progress, Profile) |
| Local DB | drift (SQLite) with FTS5 |
| Models | freezed, json_serializable |
| Firebase | firebase_auth, cloud_firestore, firebase_storage, firebase_messaging, firebase_crashlytics, firebase_analytics, firebase_app_check |
| Notifications | flutter_local_notifications, timezone |
| Share sheet | share_plus (LOG-05 summary image) |
| Background | workmanager |
| Charts | fl_chart |
| Connectivity | connectivity_plus |
| Images / SVG | cached_network_image, image_picker, flutter_svg |
| Testing | flutter_test, mocktail, integration_test |

## Folder layout

```
lib/
  app/            app.dart, router, shell, widgets (app-wide), theme (brand tokens), l10n
  core/           result types, errors, utils
    metrics/      pure Dart formulas (FND-04)
  data/
    local/        drift database, DAOs, migrations
    remote/       firestore + storage data sources
    sync/         outbox, sync engine, conflict policy
  features/
    auth/ onboarding/ schedule/ workout/ logger/ library/
    body/ progress/ goals/ notifications/ settings/
    home/                      presentation only: composes other features' providers
      <feature>/domain/        entities, use_cases, repo interface
      <feature>/data/          repo implementation
      <feature>/presentation/  screens, widgets, controllers
assets/
  exercises/seed.json         built by tool/build_exercise_seed.dart
  illustrations/*.svg
specs/            one folder per requirement ID
test/             mirrors lib/ ; acceptance tests named <ID>_test.dart
tool/             build scripts (exercise seed pipeline)
```

## Data model

Same entities locally (Drift) and in Firestore under `users/{uid}`. Every record: `id`
(UUID v7, made on device), `updatedAt`, `deletedAt` (soft delete), `syncState`.

| Entity | Firestore path | Key fields |
|---|---|---|
| UserProfile | users/{uid} | name, sex, birthYear, heightCm, units, activityLevel, goalType, timezone |
| Exercise (catalog) | catalog/exercises/{exId} (read-only) | name, primaryMuscles[], secondaryMuscles[], equipment, level, category, mechanic, force, instructions[], images[] |
| CustomExercise | users/{uid}/customExercises/{id} | same as Exercise |
| WorkoutTemplate | users/{uid}/templates/{id} | name, exercises[{exId, order, sets, repMin, repMax, targetKg, restSec, supersetGroup}] |
| Schedule | users/{uid}/schedules/{id} | name, mode (rolling/weekdays), cycle[{dayIndex, templateId or REST}], startDate, active |
| ScheduleDay | users/{uid}/scheduleDays/{id} (doc id settled in SYN-01) | cycleId, date, dayId (cycle row), dayIndex, status (done/missed/rest/planned/skipped/unplannedRest/moved), workoutId (when not the row's own), linkedDate (other date of a Move), sessionId (LOG-05) |
| WorkoutSession | users/{uid}/sessions/{id} | templateId, startedAt, endedAt, totalVolumeKg, prCount, notes, sets[{exId, setNo, kg, reps, rpe, isWarmup, isPR}] |
| BodySnapshot | users/{uid}/bodySnapshots/{id} | date, weightKg, waistCm, neckCm, hipCm, bodyFatPct, bmi, lbmKg, ffmi, bmr, tdee |
| PersonalRecord | users/{uid}/records/{exId} | bestE1rm, bestSet{kg, reps}, bestVolume, achievedAt |
| Goal | users/{uid}/goals/{id} | type, exId?, targetValue, startValue, deadline, projectedDate, status |
| NotificationPrefs | users/{uid}/settings/notifications | per-type on/off, reminderTime, quietHours, fcmTokens[] |
| ProgressPhoto | Storage users/{uid}/photos/{id}.webp + doc | date, pose, path |

Design choices:
- Sets are embedded in the session document; while a workout runs, sets live only in Drift.
  Locally (WKT-02, LOG-01): `workout_sessions` holds the workout with a JSON copy of its rows
  (ended_at null while in progress) and `session_sets` its sets. The first outbox row is the
  session's create on Finish, in the same transaction that marks the cycle day done.
- Rest timer (LOG-03): the running or paused rest is `workout_sessions.rest` (JSON end time or
  time left), local only. One local notification (`RestAlarm` port over
  flutter_local_notifications, scheduled in UTC) is replaced on every change and cancelled on
  Finish / Discard.
- Custom exercises (EXL-03): `custom_exercises` (synced, soft delete). `exerciseCatalogProvider`
  returns a combined repository (catalog FTS + custom matched in Dart), so every screen sees
  both; `byId` also finds deleted custom ones so old workouts keep their names.
- Exercise pictures (EXL-02): only paths are in the catalog; the detail loads them from the
  pinned Free Exercise DB commit on GitHub and `cached_network_image` keeps them on disk, so
  a picture needs a connection once. The Library and the picker share one search path.
- Finish summary (LOG-05): built on device from the finished workout, the previous one of the
  same template (`workout_sessions_template_ended` index) and each exercise's last sets. The
  note is `workout_sessions.note`; it rides in the queued Finish create, and once that has
  synced each changed save is one outbox `update`. Share renders the summary card to a PNG behind a `SummaryShare` port.
  One Firestore write per finished workout (NFR-10), plus one per note change after it synced.
- Records and stats are derived on device; cached in Firestore only to speed up restore.
- `scheduleDays`: one per (cycle, date), since a cycle switched to today has its own today;
  indexed by date so a month is one range query. Passed dates are written as missed / rest.
- Weekday mode (SCH-03): `cycle[]` has exactly 7 rows stored Monday first, so row i is ISO
  weekday i + 1 whatever the locale; screens only rotate the order to the locale's first day.
- Day actions (SCH-04) are today's `scheduleDays` record: `planned` is a swap, Train today or
  moved-in workout not done yet; Undo steps back one state; a Move writes both dates at once.

## Sync rules

1. Write locally + outbox row `(entity, id, op)`.
2. Online: worker pushes outbox in batches ≤ 500, clears on success, exponential backoff on failure.
3. Pull on sign-in, resume, every 6 h: `updatedAt > lastPulledAt` per collection.
4. Conflicts: last-write-wins by `updatedAt`, except sessions (append-only, never overwritten).
5. Restore on a new phone = full pull, then rebuild stats locally.

```
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
match /catalog/{document=**} {
  allow read: if request.auth != null;
  allow write: if false;
}
```

## Metrics (lib/core/metrics, FND-04)

w = weight kg, h = height cm, a = age years. All results are labelled as estimates.

- BMI = w / (h/100)²
- Body fat % (US Navy, cm) — male: 495 / (1.0324 − 0.19077·log10(waist − neck) + 0.15456·log10(h)) − 450;
  female: 495 / (1.29579 − 0.35004·log10(waist + hip − neck) + 0.22100·log10(h)) − 450
- LBM = w × (1 − BF%/100); FFMI = LBM / (h/100)²
- BMR Mifflin–St Jeor = 10w + 6.25h − 5a + s (s = +5 male, −161 female); Katch–McArdle = 370 + 21.6·LBM when BF known
- TDEE = BMR × activity (1.2 / 1.375 / 1.55 / 1.725 / 1.9); cut −20 %, maintain, lean bulk +10 %; protein 1.6–2.2 g/kg
- e1RM (Epley) = w × (1 + reps/30); sets > 12 reps excluded
- Volume = Σ weight × reps over working sets (warm-ups excluded)
- Adherence % = completed training days ÷ planned training days
- Cycle streak = walk back from today: done and rest extend it, skipped, unplanned rest and
  moved are neutral,
  a missed training day ends it; today not yet done never breaks it (FND-04 AC8)
- Goal projection = linear regression over last 4–8 weeks; finish = where the line meets target
- Ghost target = last set + 2.5 kg if all reps hit top of range, else same weight + 1 rep

## Notifications (NTF-01)

Mostly local and scheduled (works offline); FCM only for cross-device/server messages.
One Android channel per type; quiet hours default 22:00–06:00 (except rest timer); ≤ 2 nudges
a day; in-app centre keeps 30 days. Full table in the source spec, section 9.
