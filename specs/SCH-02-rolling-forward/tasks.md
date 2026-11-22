# SCH-02: tasks

Plan: ./plan.md · One commit `SCH-02: …` after T10 (no per-task commits).

- [x] T1 `schedule_days` table, schema v4 → v5, unique (cycle_id, date); wiper covers it — test: `app_database_test.dart` "v4 → v5", `drift_day_record_repository_test.dart` "sign-out wipes day records" (AC13)
- [x] T2 `DayRecord`, `DayStatus`; `rollForward` walk (index, doneToday, missedDays, next) — test: `test/features/schedule/domain/rolling_test.dart` (AC4–AC8, AC11, edges: one-day cycle, clock back, before anchor, rest never missed) (parallel with T1)
- [x] T3 `toSettle` (missed / rest for passed dates without a record) — test: `rolling_test.dart` "settle" (AC6, AC7, edge) (parallel with T1)
- [x] T4 `DayRecordRepository` + Drift impl: `watchSince`, `markDone` upsert, `undo` soft delete, re-mark restores, `writeSettled`; outbox per write — test: `drift_day_record_repository_test.dart` (AC3, AC6, AC7, AC13)
- [x] T5 `todayProvider` (midnight timer, resume) — test: `test/core/clock_test.dart` (AC4–AC6) (parallel with T4)
- [x] T6 Replace calendar `dayIndexOn`; `reanchor` takes the rolled index; `cycleTodayProvider`, `cycleSettlerProvider`; rewrite SCH-01 tests that assumed calendar days — test: `cycle_rules_test.dart`, `rolling_test.dart` "AC12 edit keeps done by row", existing SCH-01 suites green (AC12)
- [x] T7 Home `TodayCard`: Mark done / Done + Undo, Next, missed line, rest-day variant, save-failure snackbar; settler listened on Home — test: `test/features/home/presentation/today_card_test.dart` (AC1–AC3, AC5, AC6, AC8, AC9, NFR-06)
- [x] T8 Schedule card and builder preview follow the rolled position; tile "Done" label; make active starts fresh — test: `schedule_screen_test.dart` "AC10 …", "AC11 …", `cycle_editor_screen_test.dart` "AC12 …" (AC10–AC12)
- [x] T9 Update `docs/architecture.md` ScheduleDay row (per-cycle key) — test: none (docs)
- [x] T10 Run spec-reviewer against spec.md; fix gaps
