# LOG-05: tasks

Plan: ./plan.md · One commit `LOG-05: …` after T8 (no per-task commits).

- [x] T1 `workout_sessions.note` + `(template_id, ended_at)` index, schema v11 → v12; `WorkoutSession.note`; repository `finished`, `previousOf`, `lastBefore`, `finishedOn`, `setNote` (outbox update) — test: `app_database_test.dart` "v11 → v12", `drift_session_repository_test.dart` "LOG-05 …" (AC5, AC6, AC8, AC9)
- [x] T2 `summary.dart` `buildSummary`: duration, sets, weighted volume, per-exercise volume / reps / time, PR lines, changes vs previous and per exercise — test: `test/features/logger/domain/summary_test.dart` (AC2–AC5, edges) (parallel with T1)
- [x] T3 `summary_format.dart`: duration, signed changes, unit-aware weights — test: `test/features/logger/presentation/summary_format_test.dart` (AC2, AC5, edges) (parallel with T1)
- [x] T4 `SummaryShare` port + `share_plus` implementation; providers (`summaryProvider`, `finishedOnProvider`, `summaryShareProvider`) + fakes — test: none beyond analyze (platform code); fakes used in T5–T7
- [x] T5 Summary screen + route; Finish opens it; back / Done → Home; load error state — test: `summary_screen_test.dart` "AC1 …", "AC2 …", "AC3 …", "AC4 …", "AC5 …" (AC1–AC5)
- [x] T6 Note (save on leave / pause, only if changed, error snackbar) and Share (card to PNG, cancel, error) — test: `summary_screen_test.dart` "AC6 …", "AC7 …" (AC6, AC7, AC9)
- [x] T7 Calendar "View summary"; NFR-06 at 200 %, semantics; NFR-01 timing with 2 years seeded; docs/architecture.md — test: `calendar_view_test.dart` "LOG-05 AC8 …", `summary_screen_test.dart` "NFR-06 …", `drift_session_repository_test.dart` "LOG-05 NFR-01 …" (AC8, NFR-01, NFR-06)
- [x] T8 Run spec-reviewer against spec.md; fix gaps — fixed: Share after scrolling (non-lazy body), first note rides in the queued create (NFR-10), notes only for finished workouts, one note save at a time, no change across different measures, "not comparable" volume, m:ss timed totals, plural sets; added the missing edge tests
