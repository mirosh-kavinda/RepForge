# SCH-05: tasks

Plan: ./plan.md · One commit `SCH-05: …` after T7 (no per-task commits).

- [x] T1 `schedule_days_date` index, schema v7 → v8; `watchRange(from, to)` across cycles ordered by date, update time; fake updated — test: `app_database_test.dart` "v7 → v8", `drift_day_record_repository_test.dart` "SCH-05 range …", "SCH-05 AC7 a month of 2 years' data under 300 ms" (AC3, AC7)
- [x] T2 `calendar.dart`: `monthDates`, `CalendarDay`, `buildMonth` (history, today, projection Rolling / Weekdays, moved-in override, unplanned-rest shift, two-cycle rule, no cycle) — test: `test/features/schedule/domain/calendar_test.dart` (AC2–AC5, edges) (parallel with T1)
- [x] T3 `rangeRecordsProvider`; Schedule Cycle / Calendar choice — test: `calendar_view_test.dart` "SCH-05 AC1 …" (AC1)
- [x] T4 Calendar view: month header and navigation, locale weekday row, cells with icon + semantics, outside-month dimmed, no-cycle line, load error — test: `calendar_view_test.dart` "AC2 …", "AC3 …", "AC4 …", "AC5 …", "edge …" (AC2–AC5, AC8, NFR-11)
- [x] T5 Day sheet: date, cycle(s), workout / rest, status, swapped / moved lines — test: `calendar_view_test.dart` "AC6 …" (AC6)
- [x] T6 NFR-06 at 200 % and 360 dp width; midnight moves today — test: `calendar_view_test.dart` "NFR-06 …", "edge midnight …" (NFR-06, edge)
- [x] T7 Run spec-reviewer against spec.md; fix gaps
