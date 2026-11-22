# SCH-04: tasks

Plan: ./plan.md · One commit `SCH-04: …` after T10 (no per-task commits).

- [x] T1 `schedule_days.workout_id`, `linked_date`, schema v6 → v7; `DayStatus` + planned, skipped, unplannedRest, moved; `DayRecord.workoutId`, `linkedDate`; repository maps them — test: `app_database_test.dart` "v6 → v7", `drift_day_record_repository_test.dart` "SCH-04 new fields round-trip" (AC11)
- [x] T2 Walk and settle: skipped moves on, unplanned rest waits without missed, passed planned counts missed; `CycleToday.record`; read-only only for missed / rest; settle converts passed planned (missed / rest) — test: `rolling_test.dart` "SCH-04 …" (Rolling and Weekdays) (AC3–AC6, AC8, edges) (parallel with T1)
- [x] T3 `day_actions.dart`: `availableActions`, `moveTargets` (locale week, free dates, none on last day), shown workout for today — test: `test/features/schedule/domain/day_actions_test.dart` (AC1, AC7, AC8, edges) (parallel with T1)
- [x] T4 Repository: `plan`, `skip`, `restToday`, `move` (both dates, one transaction), `markDone` keeps a planned workout, one-step `undo` (incl. Move target), `writeSettled` replaces planned; outbox per write — test: `drift_day_record_repository_test.dart` "SCH-04 …"; fake repository updated (AC2, AC4–AC9, AC11)
- [x] T5 Day actions sheet (screen 17): options with hints, Swap via picker excluding the planned workout, Move date list by weekday — test: `today_card_test.dart` "SCH-04 AC1 …" (AC1, AC7, edge no other workouts)
- [x] T6 Home card: Day actions button; swapped / Train today / moved-in headings; Skipped, unplanned rest, Moved to … variants with Undo; failure snackbar — test: `today_card_test.dart` "SCH-04 AC2 …" … "AC9 …", "edge deleted workout …", "edge failed action …" (AC2, AC4–AC9)
- [x] T7 Rest-day card Train today — test: `today_card_test.dart` "SCH-04 AC8 …" (AC8)
- [x] T8 Tile action note; Schedule today row shows action text and moved-in workout — test: `schedule_screen_test.dart` "SCH-04 AC10 …" (AC10)
- [x] T9 NFR-06 at 200 % for sheet and variants; docs/architecture.md ScheduleDay fields and streak rule — test: `today_card_test.dart` "SCH-04 NFR-06 …" (NFR-06)
- [x] T10 Run spec-reviewer against spec.md; fix gaps
