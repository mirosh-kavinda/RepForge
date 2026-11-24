# SCH-05: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

The month is built by a pure function from three inputs: the day records of all cycles in the
visible date range, the active cycle and its rolled today (SCH-02 `CycleToday`), and the locale's
first day of the week. Past dates come from history, today and later from a projection. The
repository gains one range query over a new date index. Schedule gets a Cycle / Calendar choice.
The calendar is a 7-column grid of status cells, and tapping a cell opens a read-only sheet.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/local/app_database.dart` | changed | index `schedule_days_date` on `date`; schema v7 → v8 creates it (AC7) |
| `lib/features/schedule/domain/day_record_repository.dart` | changed | `watchRange(from, to)`: live records of all cycles, ordered by date then last update (AC3, AC7) |
| `lib/features/schedule/data/drift_day_record_repository.dart` | changed | implements it with the index |
| `lib/features/schedule/domain/calendar.dart` | new | `monthDates(month, firstDay)` (whole weeks); `CalendarDay` (date, kind history / planned / empty, status, workout, the cycle row's workout, all records); `buildMonth(...)` incl. projection and the two-cycle rule (AC2–AC5, edges) |
| `lib/features/schedule/data/providers.dart` | changed | `rangeRecordsProvider(from, to)` |
| `lib/features/schedule/presentation/calendar_view.dart` | new | month header with previous / this month / next, weekday row, grid of cells (icon + label semantics), "No active cycle" line (AC1–AC5, NFR-06, NFR-11) |
| `lib/features/schedule/presentation/calendar_day_sheet.dart` | new | read-only details: date, cycle name(s), workout or rest, status, swapped / moved lines (AC6) |
| `lib/features/schedule/presentation/schedule_screen.dart` | changed | `RfSegmented` Cycle / Calendar at the top (default Cycle) (AC1) |
| `lib/app/l10n/app_en.arb` | changed | view names, status words, "planned", month navigation labels, sheet labels |

## Data

- New index `schedule_days_date (date)`; schema v8 adds it with `CREATE INDEX IF NOT EXISTS`. No
  new columns. Firestore unchanged.

## Key decisions

- **History vs plan by date (AC3, AC4).** Dates before today show history only. Today shows its
  record if any (as Home), else the plan. Future dates show the projection, overridden by a
  `planned` moved-in record of the active cycle.
- **Projection (AC4).** Rolling: from today's rolled index, date today + k is row
  `(index + k) % n`. If today is an unplanned rest the walk waits, so tomorrow starts at the
  same index. Weekdays: `weekdayRow(date)`. Projection only needs the active cycle and
  `CycleToday`, which is already loaded.
- **Two cycles on one date (edge).** The active cycle's record wins. Otherwise the last one by
  update time, which `watchRange` returns last. The cell keeps all of them for the sheet.
- **Whole weeks (AC2).** The grid runs from the week start on or before the 1st to the week end
  on or after the last day. Days outside the month are dimmed and also say so in their semantics
  label. The query covers exactly those dates.
- **Cells (NFR-06).** Each cell is at least 48 dp, with the day number and one status icon whose
  shape differs per status (done, missed, rest, skipped, unplanned rest, moved, planned training,
  planned rest). Every cell has a full semantics label ("Tuesday 24 November, Legs, done"). The
  sheet carries the full text. At 200 % text the grid scrolls vertically and keeps 7 columns.
- **Speed (AC7).** One indexed range query per visible month, about 42 rows at most, plus pure
  mapping. No per-cell queries.
- **Default and memory (AC1).** The choice starts on Cycle every time Schedule opens. It is not
  persisted.

## Packages

None new (`intl` for month and weekday names).

## Error handling

- A failed range read shows "Couldn't load your calendar." in place of the grid.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2–AC5, edges (two cycles, no cycle, empty months, unplanned-rest shift) | `test/features/schedule/domain/calendar_test.dart` | unit |
| AC7, schema | `test/features/schedule/data/drift_day_record_repository_test.dart` "SCH-05 …" (2 years, 3 cycles, month < 300 ms), `app_database_test.dart` "v7 → v8" | unit |
| AC1–AC6, AC8, NFR-06, locale week start, midnight | `test/features/schedule/presentation/calendar_view_test.dart` | widget |

## Risks

- Seven 48 dp columns need 336 dp. That fits a 360 dp phone with 12 dp margins, but nothing
  wider. Cells use the full width with no gutter.
- Timing tests can flake on slow CI. The 300 ms check runs on the repository query and mapping,
  not the frame.
