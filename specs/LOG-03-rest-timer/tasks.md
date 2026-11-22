# LOG-03: tasks

Plan: ./plan.md · One commit `LOG-03: …` after T7 (no per-task commits).

- [x] T1 `SessionExercise.restSec` / `superset` (copied at start, JSON defaults), `workout_sessions.rest`, schema v10 → v11, `setRest`; Finish / discard clear it — test: `app_database_test.dart` "v10 → v11", `drift_session_repository_test.dart` "LOG-03 …" (AC1, AC3, AC6, AC8)
- [x] T2 `rest_timer.dart`: restAfterLog (superset, 0 rest), nextUp, left, adjust, pause / resume, over — test: `test/features/logger/domain/rest_timer_test.dart` (AC1–AC4, edges) (parallel with T1)
- [x] T3 `RestAlarm` port + `LocalRestAlarm` (flutter_local_notifications, timezone, app_settings); main init; Android manifest; iOS delegate; provider + fake — test: none beyond analyze (platform code); fake used in T4–T6
- [x] T4 Logger wiring: Log starts / restarts / cancels rest and alarm; Finish / Discard cancel — test: `rest_bar_test.dart` "AC1 …", "AC2 …", "AC3 …", "AC8 …" (AC1–AC3, AC8)
- [x] T5 Rest bar: countdown, Next, ±15, Pause / Resume, Skip, Rest over + vibrate, Dismiss, notifications-off line + Open settings; resume after leaving — test: `rest_bar_test.dart` "AC4 …", "AC5 …", "AC6 …", "AC7 …" (AC4–AC7)
- [ ] T6 NFR-06 at 200 %, announcements; docs/architecture.md; manual lock-screen check on device (recorded in roadmap notes) — test: `rest_bar_test.dart` "NFR-06 …" (NFR-06) — done except the manual lock-screen check on a real phone (needs a person; debug APK builds)
- [x] T7 Run spec-reviewer against spec.md; fix gaps — fixed: rest starts at log time before the permission dialog, "Next only" bar between superset members, SCHEDULE_EXACT_ALARM, reminder category, settings re-check on resume, no second vibrate on return; added the missing AC2/AC3/AC5/AC6/edge/NFR-06 tests
