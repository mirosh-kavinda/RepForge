# WKT-02 + LOG-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A workout session is a local record that starts from a copy of today's workout. In-progress
sets go in a child table, are written one by one, and are never synced while the workout runs.
Finish closes the session, queues one outbox row for it with its sets embedded, and marks today
done in the same transaction. The logger lives in `lib/features/logger`. Pure rules (prefill,
steps, units, swap) live in its `domain/`. Home's today card gains Start / Resume.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/local/app_database.dart` | changed | `workout_sessions`, `session_sets` tables; schema v8 → v9 (AC8, AC9) |
| `lib/data/local/local_data_wiper.dart` | changed | sign-out wipes both |
| `lib/features/logger/domain/workout_session.dart` | new | `WorkoutSession` (template id, name, cycle / day it was started for, started / ended), `SessionExercise` (copied targets and name), `LoggedSet` (AC1, AC7, edges) |
| `lib/features/logger/domain/logger_rules.dart` | new | `prefill` (last time → logged earlier in this session → template), `stepFor(units)`, kg ↔ display, `swapExercise`, `addExercise` (AC2–AC4, AC6, AC7, units edge) |
| `lib/features/logger/domain/session_repository.dart` | new | `watchActive`, `start`, `logSet`, `updateSet`, `deleteSet`, `addSet`, `addExercise`, `swapExercise`, `finish`, `discard`, `lastSets(exerciseId)` |
| `lib/features/logger/data/drift_session_repository.dart` | new | implements it; `finish` writes the session, one outbox row and today's done record in one transaction (AC9, NFR-10) |
| `lib/features/logger/data/providers.dart` | new | repository, `activeSessionProvider`, `lastSetsProvider` |
| `lib/features/logger/presentation/logger_screen.dart` | new | screen 02: exercise cards, set rows with steppers and Log, + Set, swap / add exercise, Finish, Discard (AC2–AC9) |
| `lib/features/logger/presentation/set_row.dart` | new | one set: pending (steppers + Log) or Done (values, tap to edit) (AC3–AC5, NFR-06) |
| `lib/features/logger/presentation/edit_set_sheet.dart` | new | change or delete a logged set (AC5) |
| `lib/features/home/presentation/today_card.dart` | changed | Start workout / Resume workout as the primary action; Mark done stays secondary (AC1, AC8) |
| `lib/app/router.dart` | changed | `/workout` full-screen route outside the shell |
| `lib/features/library/presentation/exercise_picker_screen.dart` | reused | capacity 1 for add / swap (AC7) |
| `lib/app/l10n/app_en.arb` | changed | logger strings |
| `docs/architecture.md` | changed | local session tables; outbox only on Finish |

## Data

- `workout_sessions`: id, template_id, name, exercises (JSON copy of the rows: row id, exercise
  id, exercise name, planned sets, kind, rep min / max, seconds, target kg), cycle_id, day_id,
  day_index, date (calendar day it was started for), started_at, ended_at (null = in progress),
  plus the synced columns. One in-progress row at most.
- `session_sets`: id, session_id, row_id, exercise_id, set_no, kg, reps, seconds, logged_at,
  updated_at. A local child table, never synced on its own. Finish embeds the sets in the
  session's outbox payload (architecture: sets are embedded in the session doc).
- Schema v8 → v9 creates both. Firestore `users/{uid}/sessions/{id}` as in architecture.md.

## Key decisions

- **A copy of the workout at start (AC1, edges).** The session keeps the rows and exercise names
  it started with. A template or exercise deleted later changes nothing, and add / swap / + Set
  edit the copy, never the template.
- **Prefill order (AC2, AC4, AC6).** For set n of a row: the same set number from the last
  finished session of that exercise. Then the last set logged for this row in this session. Then
  the template target (target kg or empty, bottom of the rep range, or seconds). Values come from
  the logged set when the row is pending and are applied when Log is tapped.
- **Two taps (AC3).** Log saves the row's shown values. Steppers change the shown values without
  saving. Weight step is 2.5 kg, or 5 lb for imperial, converted to kg before storing. lb shown =
  kg converted and rounded to 0.1, so a lb value round-trips (edge).
- **No sync until Finish (NFR-10, AC9).** Set writes touch only `session_sets`. Finish sets
  `ended_at`, adds one outbox row (`session`, create) and calls Mark done for the session's
  cycle / day / date, all in one transaction. Mark done keeps a swap (SCH-04).
- **Resume (AC8).** Home watches the in-progress session. Start opens it if one exists, else
  starts one for today's shown workout (`todayWorkoutId`) and today's cycle row. Discard deletes
  both tables' rows locally; nothing was queued, so nothing goes to the cloud.
- **Midnight (edge).** The session stores the date it started for, and Finish uses that date.
- **Swap (AC7).** Logged sets of the row stay under the old exercise. The row's exercise and name
  change for its unlogged sets. A row with no logged sets is replaced outright.
- **Bodyweight (edge).** Equipment "body only" with 0 kg shows "Bodyweight". The weight stepper is
  still there to add load.
- **Set write speed (NFR-01).** A set write is one insert with no outbox row and no extra reads.
  A test times it.

## Packages

None new.

## Error handling

- A failed set write or Finish shows "Couldn't save. Try again." and keeps the screen as it was.
- Finish with no logged sets shows "Log at least one set" and writes nothing.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2–AC4, AC6, AC7, units round-trip | `test/features/logger/domain/logger_rules_test.dart` | unit |
| AC5–AC10, NFR-01 set write < 50 ms, NFR-10 one outbox row, wipe, schema | `test/features/logger/data/drift_session_repository_test.dart`, `app_database_test.dart` "v8 → v9" | unit |
| AC1, AC8 Home Start / Resume | `test/features/home/presentation/today_card_test.dart` "WKT-02 …" | widget |
| AC2–AC9, edges, NFR-06 | `test/features/logger/presentation/logger_screen_test.dart` | widget |

## Risks

- Keeping a template copy means template edits don't reach an in-progress workout. That is
  intended.
- The logger screen is large. Set rows are a separate widget so they can be tested and kept
  fast.
