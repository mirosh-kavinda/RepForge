# LOG-05: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A pure `buildSummary` turns a finished workout, the previous finished workout of the same
template and each exercise's last earlier sets into a `WorkoutSummary` (totals, per-exercise
lines, PRs, changes). Volume comes from `lib/core/metrics` (`volume`). A summary screen at its
own route shows it; Finish goes there instead of Home, and the calendar date sheet links to it.
The note is a new column on the finished workout, written through the outbox. Share captures the
summary's header card as a PNG and hands it to a `SummaryShare` port.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/logger/domain/summary.dart` | new | `WorkoutSummary`, `ExerciseSummary`, `Change`; `buildSummary(session, previous, lastByExercise)`: duration, sets, weighted volume (null when none), per exercise volume / total reps / total time, PR lines from stored `isPr`, changes (AC2–AC5, edges) |
| `lib/features/logger/domain/workout_session.dart` | changed | `WorkoutSession.note` (AC6) |
| `lib/features/logger/domain/session_repository.dart` | changed | `finished(id)`, `previousOf(session)`, `lastBefore(exerciseIds, before)`, `finishedOn(date)`, `setNote(id, note)` (AC5, AC6, AC8) |
| `lib/features/logger/data/drift_session_repository.dart` | changed | the reads above; `setNote` via the outbox writer as an update (AC6, AC9, NFR-10) |
| `lib/data/local/app_database.dart` | changed | `workout_sessions.note` text null; index on `(template_id, ended_at)`; schema v11 → v12 (AC6, NFR-01) |
| `lib/features/logger/domain/summary_share.dart` | new | port: `shareImage(Uint8List png, {required String name, required String text})` (AC7) |
| `lib/features/logger/data/share_plus_summary_share.dart` | new | `share_plus` implementation (`XFile.fromData`) |
| `lib/features/logger/data/providers.dart` | changed | `summaryShareProvider`, `summaryProvider(sessionId)` (loads and builds), `finishedOnProvider(date)` |
| `lib/features/logger/presentation/summary_screen.dart` | new | screen 16: header card (name, date, duration, sets, volume, changes) in a `RepaintBoundary`; PR section; exercise list; note field; Share; Done (AC1–AC8, NFR-06) |
| `lib/features/logger/presentation/summary_format.dart` | new | duration (`m:ss` under 1 h, else `h:mm`), signed changes ("+1,250 kg", "−3 min", "same"), unit-aware weights (AC2, AC5, edges) |
| `lib/features/logger/presentation/logger_screen.dart` | changed | Finish goes to the summary (AC1) |
| `lib/app/router.dart` | changed | `Routes.summary(id)` = `/summary/:id`, `?after=finish` (AC1, AC8) |
| `lib/features/schedule/presentation/calendar_day_sheet.dart` | changed | "View summary" per finished workout on that date (AC8) |
| `lib/app/l10n/app_en.arb` | changed | summary strings |
| `docs/architecture.md` | changed | share_plus row; summary and note write |

## Data

- `workout_sessions.note` (text, null = none). Schema v11 → v12 adds it plus index
  `workout_sessions_template_ended (template_id, ended_at)`.
- The note is part of the finished workout's synced document. While the Finish `create` is still
  queued, a note save adds no outbox row (it rides in that write); after it has synced, each
  changed save is one outbox `update` (NFR-10). Notes for unfinished workouts are ignored.
- No new Firestore paths.

## Key decisions

- **Finish → summary (AC1).** `context.go(Routes.summary(id, afterFinish: true))`. With
  `afterFinish`, a `PopScope` sends back to Home, so the logger can't come back. From the
  calendar it is `push`ed, so back returns to the calendar (AC8).
- **What counts (AC2, AC3, edges).** Weighted set: `kg > 0` and reps; volume via
  `core/metrics` `volume`. A row is "bodyweight" when every set is 0 kg with reps (total reps);
  timed rows show total seconds. No weighted set in the workout → total volume "—". Rows
  without logged sets are left out.
- **PRs (AC4).** Read the `isPr` flags Finish already stored (LOG-02). Not recomputed, so the
  summary of an old workout keeps the PRs it earned.
- **Comparison (AC5).** Previous = latest finished, not deleted, same `templateId`, ended
  before this one started. Workouts without a template have no comparison. Per exercise: the
  last finished session before this one that has sets of that exercise, any workout. Duration
  change in whole minutes. 0 → "same".
- **Note (AC6).** A text field. Saved when the screen is left (Done, back, app paused) and only
  if it changed, one save at a time. Trimmed; empty = null. Never per keystroke (NFR-10).
- **Layout (AC7).** The body is a non-lazy scroll view so the card stays built for Share after
  scrolling. Timed totals read as m:ss; a volume change with no weighted sets on one side reads
  "— vs last time" ("not comparable").
- **Share (AC7).** The header card sits in a `RepaintBoundary`. Share renders it at 3× to PNG
  and calls the port with the image and a one-line text. The card shows no body data (NFR-04).
  A cancelled share does nothing.
- **Calendar (AC8).** `finishedOn(date)` lists finished workouts with that `date`, so it works
  for workouts with or without a cycle day. The sheet shows "View summary" per workout.
- **Speed (NFR-01).** One read of the workout and its sets, one indexed read for the previous
  workout, one indexed read per exercise (`session_sets_exercise`). Measured in a test with 2
  years of seeded workouts.

## Packages

- `share_plus`: the phone's share sheet with an image file on Android and iOS (AC7). Not yet in
  architecture.md; added there.

## Error handling

- Summary load fails or the workout is gone: the screen says "Couldn't load this workout" with
  Done to Home.
- Note save fails: a snackbar "Couldn't save the note"; the text stays in the field.
- Share fails: a snackbar "Couldn't share"; nothing else changes.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2–AC5, edges (bodyweight / timed only, no previous, edited template, unlogged rows) | `test/features/logger/domain/summary_test.dart` | unit |
| AC2, AC5, edges (formats, lb, > 24 h) | `test/features/logger/presentation/summary_format_test.dart` | unit |
| AC5, AC6, AC8, AC9, schema, NFR-01 | `drift_session_repository_test.dart` "LOG-05 …", `app_database_test.dart` "v11 → v12" | unit |
| AC1–AC8, NFR-06 (fake share, fake repository) | `test/features/logger/presentation/summary_screen_test.dart` | widget |
| AC8 | `test/features/schedule/presentation/calendar_view_test.dart` "LOG-05 …" | widget |

## Risks

- Rendering the card to an image in widget tests needs `runAsync`; if flaky, the capture is
  behind a function the test replaces.
- `share_plus` on iOS is unverified without a Mac (as with FND-01 / LOG-03).
- Old finished workouts have no `note` and some lack `templateId`; both read as "none".
