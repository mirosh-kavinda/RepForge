# LOG-03: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

The rest is a small state stored on the in-progress workout row: an end time, or the time left
while paused, plus what comes next. Pure rules decide whether a log starts a rest (supersets)
and how the controls change it. A `RestAlarm` port schedules one local notification at the end
time and cancels it on every change. The logger shows a rest bar that ticks once a second from
the clock. Because the state is an end time on disk, leaving or killing the app changes nothing
(AC6).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/logger/domain/rest_timer.dart` | new | `Rest` (endsAt or pausedLeft, next row + set), `restAfterLog` (rest seconds or none for a non-last superset member, 0 = none), `nextUp`, `left`, `adjust ±15`, `pause`, `resume`, `isOver` (AC1–AC4, edges) |
| `lib/features/logger/domain/workout_session.dart` | changed | `SessionExercise.restSec`, `superset`; `WorkoutSession.rest` (AC1, AC3) |
| `lib/features/logger/domain/logger_rules.dart` | changed | `sessionFromTemplate` copies rest and superset |
| `lib/features/logger/domain/rest_alarm.dart` | new | port: `schedule(at, title, body)`, `cancel()`, `permission()`, `requestPermission()`, `openSettings()` (AC5, AC7) |
| `lib/features/logger/data/local_rest_alarm.dart` | new | `flutter_local_notifications` + `timezone` implementation; Android channel "Rest timer" |
| `lib/features/logger/domain/session_repository.dart` | changed | `setRest(sessionId, Rest?)` |
| `lib/features/logger/data/drift_session_repository.dart` | changed | stores rest as JSON in `workout_sessions.rest`; Finish and discard clear it |
| `lib/data/local/app_database.dart` | changed | `workout_sessions.rest` text null; schema v10 → v11 |
| `lib/features/logger/data/providers.dart` | changed | `restAlarmProvider` |
| `lib/features/logger/presentation/rest_bar.dart` | new | countdown m:ss, Next, −15 / +15, Pause / Resume, Skip; "Rest over" + Dismiss; notifications-off line + Open settings; vibrates at zero (AC1, AC4, AC5, AC7, NFR-06) |
| `lib/features/logger/presentation/logger_screen.dart` | changed | on Log: start / restart / cancel the rest and the alarm; Finish / Discard cancel (AC2, AC3, AC8) |
| `lib/features/logger/data/local_rest_alarm.dart` | — | initialises the plugin on first use; schedules in UTC, so no device time zone lookup |
| `android/app/src/main/AndroidManifest.xml` | changed | `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED` and the plugin receivers |
| `ios/Runner/AppDelegate.swift` | changed | notification delegate set-up for foreground alerts |
| `lib/app/l10n/app_en.arb` | changed | rest strings |
| `docs/architecture.md` | changed | rest state on the workout row; alarm port |

## Data

- `workout_sessions.rest` (text JSON, null = no rest): `{endsAt?, pausedLeftMs?, rowId, setNo}`.
  Schema v10 → v11 adds it. It is local only: like the rest of an in-progress workout, it is not
  synced, and Finish clears it.
- `SessionExercise` JSON gains `restSec` (default 120 when missing) and `superset` (null).

## Key decisions

- **End time, not ticks (AC6, edges).** Time left = `endsAt − now`, read from `clockProvider`.
  The bar ticks with a 1 s `Timer`. Pause stores the time left and clears `endsAt`. Resume sets
  `endsAt = now + left`. A clock change mid-rest only shifts the in-app display. The scheduled
  alarm keeps its original end time.
- **Supersets (AC3).** Rows sharing a `superset` id form a group in workout order. Logging a
  member that isn't the group's last cancels any rest and stores a "Next only" rest (no end
  time, no paused time), so the bar shows "Next: <member>, set n" with no countdown or alarm.
  Logging the last member starts the rest with the last member's rest time.
- **What's next (AC1, AC5).** The next unlogged set: in the same row, else the next row's
  first unlogged set, else nothing ("Last set done"). The alarm text is "Rest over · Next: Bench
  Press, set 3". Only the exercise name and set number appear, no body data (NFR-04).
- **One alarm (AC2, AC4, AC8).** Every rest change cancels the alarm and schedules a new one, or
  none when paused, skipped, over or finished. A failed schedule never blocks logging.
- **Permission (AC7).** The first rest asks for notification permission once per app launch
  (Android 13+ and iOS; the OS itself stops re-asking after a denial). The rest is written with
  the log time before the dialog, so the countdown never waits on it; the alarm is scheduled
  after. The off line is re-checked when the app resumes from settings. If it is denied, the bar shows the notifications-off line. Open settings uses
  `app_settings` (notification settings on both platforms).
- **Alert in the app (AC5).** At zero with the logger open, the bar vibrates
  (`HapticFeedback.vibrate`) and shows "Rest over". The scheduled notification fires too and is
  shown by the system, also in the foreground.
- **Android scheduling.** The manifest declares `SCHEDULE_EXACT_ALARM` (granted by default on
  Android 12–13; the user can grant it on 14+). `exactAllowWhileIdle` when exact alarms are
  allowed, else `inexactAllowWhileIdle`, which can be over a minute late — listed as a risk.
  Category `reminder`, not `alarm`, so Do Not Disturb is respected (edge).
- **Logging speed (NFR-01).** Log writes the set first. The rest write and alarm schedule
  follow without being awaited by the Log button's spinner.

## Packages

- `flutter_local_notifications`: scheduled local notification that fires while locked or in
  the background. Already listed in architecture.md.
- `timezone`: required by its zoned scheduling. Already listed.
- `app_settings`: opens the phone's notification settings on Android and iOS for AC7.
  (`url_launcher` can't open Android app settings.)

## Error handling

- A failed rest write or alarm call is ignored for the set (the set is already saved). A failed
  write means no rest for that set (the bar reads the stored rest); a failed alarm call still
  leaves the in-app countdown.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1–AC4, edges (0 rest, −15 past zero, pause / resume, superset, next up) | `test/features/logger/domain/rest_timer_test.dart` | unit |
| AC6, AC8, schema | `drift_session_repository_test.dart` "LOG-03 …", `app_database_test.dart` "v10 → v11" | unit |
| AC1–AC8, NFR-06 (fake alarm, controllable clock) | `test/features/logger/presentation/rest_bar_test.dart` | widget |
| Device: alert while locked | manual on the Note10, noted in tasks | manual |

## Risks

- Inexact Android alarms (exact-alarm access off on Android 14+) can be over a minute late. Checked on a real phone before calling it done.
- Plugin set-up differs per platform. The port keeps it out of the domain and out of tests.
- iOS can't be checked without a Mac (as in FND-01). iOS set-up is written but not run.
