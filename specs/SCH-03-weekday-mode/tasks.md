# SCH-03: tasks

Plan: ./plan.md · One commit `SCH-03: …` after T10 (no per-task commits).

- [x] T1 `cycles.mode` column (default rolling), schema v5 → v6; `CycleMode`, `Cycle.mode`; repository maps it — test: `app_database_test.dart` "v5 → v6", `drift_cycle_repository_test.dart` "SCH-03 mode round-trips; old cycles read as Rolling" (AC1, AC10)
- [x] T2 `weekdayRow`, `canUseWeekdays`, `SaveProblem.notSevenDays`, rotate + display↔stored index helpers, mode-switch re-anchor — test: `cycle_rules_test.dart` "SCH-03 …" (Monday-first and Sunday-first) (AC2–AC4, AC9) (parallel with T1)
- [x] T3 Weekday branch in `rollForward` / `toSettle` — test: `rolling_test.dart` "SCH-03 weekdays" (today = weekday row, no waiting, missed once per date, rest never missed, clock back read-only, done by row) (AC5, AC7, edges) (parallel with T1)
- [x] T4 `weekday_labels.dart`: locale weekday names and first day of week — test: `test/features/schedule/presentation/weekday_labels_test.dart` (en_GB Monday, en_US Sunday) (NFR-11, edge locale)
- [x] T5 Editor controller: `setMode`, add / remove blocked in Weekdays, display-order actions map to stored rows, copy keeps mode, `todayIndex` / `toCycle` for Weekdays and mode switch — test: `cycle_editor_screen_test.dart` "SCH-03 controller …" via the screen (AC1–AC4, AC9)
- [x] T6 Builder UI: Rolling / Weekdays segmented choice, "Weekday mode needs exactly 7 days", weekday-labelled rows in locale order, no Remove / Today is day n, weekday preview — test: `cycle_editor_screen_test.dart` "SCH-03 AC1 …" … "AC4 …", "NFR-06 weekdays at 200 %" (AC1–AC4, NFR-06)
- [x] T7 Tile weekday label; Schedule card "Weekdays", rows in locale order, today / Done — test: `schedule_screen_test.dart` "SCH-03 AC8 …" (AC8)
- [x] T8 Make active on a Weekdays cycle skips Today is day n; Rolling ↔ Weekdays switch on the active cycle re-anchors to today's weekday row — test: `schedule_screen_test.dart` "SCH-03 edge make active …", `cycle_editor_screen_test.dart` "SCH-03 AC9 …" (AC9, edge)
- [x] T9 Home card: "Monday · Push", weekday rest variant, no missed line in Weekdays; deleted workout still markable; docs/architecture.md Schedule row note — test: `today_card_test.dart` "SCH-03 AC6 …", "AC7 …", "edge deleted workout …" (AC6, AC7)
- [x] T10 Run spec-reviewer against spec.md; fix gaps
