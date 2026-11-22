# SCH-03: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A cycle gets a `mode` (rolling / weekdays). A Weekdays cycle has exactly 7 rows stored Monday
first, so row i is ISO weekday i+1 whatever the locale; the UI only rotates the order to start on
the locale's first day of the week. Where today falls becomes a branch of the SCH-02 walk: in
Weekdays it is today's weekday row with no waiting, and settle writes missed / rest per passed
date from that same mapping. Home, Schedule and the builder show weekday names instead of day
numbers.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/schedule/domain/cycle.dart` | changed | `CycleMode { rolling, weekdays }`; `Cycle.mode` default rolling (AC1) |
| `lib/features/schedule/domain/cycle_rules.dart` | changed | `weekdayRow(date)`, `canUseWeekdays(days)`, `SaveProblem.notSevenDays`, `rotate(days, firstDay)` / display↔stored index helpers, `switchMode` re-anchor (AC2–AC4, AC9) |
| `lib/features/schedule/domain/rolling.dart` | changed | weekday branch in `rollForward` and `toSettle`: index = today's weekday row, `missedDays` 0, next = tomorrow's row (AC5, AC7) |
| `lib/data/local/app_database.dart` | changed | `cycles.mode` text column, default `rolling`; schema v5 → v6 adds it |
| `lib/features/schedule/data/drift_cycle_repository.dart` | changed | map `mode` both ways (AC10) |
| `lib/features/schedule/presentation/cycle_editor_controller.dart` | changed | `setMode`; display-order move / change / toRest map to stored rows; add / remove blocked in Weekdays; copy keeps mode; `todayIndex` and `toCycle` use `weekdayRow` in Weekdays (AC1–AC4, AC9) |
| `lib/features/schedule/presentation/cycle_editor_screen.dart` | changed | Rolling / Weekdays `RfSegmented`, "needs exactly 7 days" line, rows in locale order with weekday labels, no Remove, no "Today is day n" (AC1–AC3) |
| `lib/features/schedule/presentation/cycle_day_tile.dart` | changed | optional weekday label replaces the number badge and "Day n" in semantics (AC3, AC8) |
| `lib/features/schedule/presentation/schedule_screen.dart` | changed | "Weekdays" in the card header; rows in locale order with weekday labels (AC8) |
| `lib/features/schedule/presentation/cycles_screen.dart` | changed | make active on a Weekdays cycle skips "Today is day n" and starts on today's weekday row (edge) |
| `lib/features/schedule/presentation/weekday_labels.dart` | new | locale weekday names (`DateFormat.EEEE` / `E`) and first day of week (`MaterialLocalizations.firstDayOfWeekIndex`) (NFR-11) |
| `lib/features/home/presentation/today_card.dart` | changed | "Monday · Push" heading; rest variant shows the weekday; no missed line in Weekdays (AC6, AC7) |
| `lib/app/l10n/app_en.arb` | changed | Rolling, Weekdays, "Weekday mode needs exactly 7 days", "{weekday} · {name}" |
| `docs/architecture.md` | changed | Schedule row: `cycle[]` is Monday first in weekday mode |

## Data

- `cycles.mode`: text `rolling` / `weekdays`, not null, default `rolling`. Schema v5 → v6 adds
  the column; existing cycles read as Rolling. Synced with the cycle (same outbox entity).
- Weekdays rows: the `days` JSON list keeps its 7 rows Monday … Sunday. No per-row weekday field
  is needed because the position is the weekday.
- `schedule_days` is unchanged. Weekday records store the row id and index like rolling ones.

## Key decisions

- **Monday-first storage, locale-ordered display (AC3, AC4, edge locale).** Storing by ISO
  weekday means a locale change cannot move a workout to another day. The screens rotate by
  `firstDayOfWeekIndex`, and editor actions convert the displayed index back to the stored one,
  so a move in the list moves the workout to the weekday of the row it lands on.
- **Mode is a builder choice gated on 7 days (AC1, AC2).** Weekdays is disabled unless the
  cycle has exactly 7 days, with the reason shown. While Weekdays is on, + Training / + Rest and
  Remove are disabled or hidden with the same reason, so length cannot drift. Save also checks
  it (`SaveProblem.notSevenDays`) as a guard.
- **Today in Weekdays (AC5, AC7).** `rollForward` returns `index = weekdayRow(today)` and
  `missedDays = 0`, and `doneToday` follows the same row-id rule as SCH-02. The calendar date's
  weekday comes from the UTC-midnight calendar day, so time zone and DST behave as in SCH-02.
  `toSettle` writes missed / rest for each passed date from the anchor using that date's row.
  SCH-02's latest-day-seen read-only rule applies unchanged (edge clock).
- **Switching mode re-anchors to today (AC9).** Saving the active cycle with a new mode sets
  `startDate` to today and `startDayIndex` to today's weekday row. Rolling then continues from that
  row, and Weekdays ignores the index. Earlier records stay as history but come before the anchor.
  Editing an active Weekdays cycle without changing the mode re-anchors the same way.
- **Rolling → Weekdays row order (AC9).** The existing 7 rows are taken as Monday … Sunday in
  their current stored order. The builder shows the weekday labels as soon as Weekdays is picked,
  so the user sees the mapping before saving and can reorder.
- **Make active (edge).** A Weekdays cycle skips the "Today is day n" sheet and starts today on
  today's weekday row. A copy keeps the mode and is saved inactive, as in SCH-01.
- **Home wording (AC6).** Weekdays heading: `"{weekday} · {name}"`, using the full weekday name.
  The rest variant shows "Rest day", the weekday and "Next: …". There is no missed line because
  `missedDays` is always 0.
- **Schedule card (AC8).** The header reads "Weekdays · 7-day cycle". Tiles show the short weekday
  in the badge and the full name in semantics ("Monday, Push, today, Done, …"), and today and
  Done follow `cycleTodayProvider`.

## Packages

None new (`intl` already used for date formats).

## Error handling

- Save, make active and Mark done failures reuse "Couldn't save. Try again." as in SCH-01/02.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC5, AC7, edges (clock, all Rest) | `test/features/schedule/domain/rolling_test.dart` "SCH-03 weekdays" | unit |
| AC2–AC4, AC9 rules | `test/features/schedule/domain/cycle_rules_test.dart` "SCH-03 …" | unit |
| AC10, schema | `drift_cycle_repository_test.dart` "mode round-trips", `app_database_test.dart` "v5 → v6" | unit |
| AC1–AC4, AC9, NFR-06, edge copy | `test/features/schedule/presentation/cycle_editor_screen_test.dart` "SCH-03 …" (Monday-first and Sunday-first locale) | widget |
| AC8, edge make active | `test/features/schedule/presentation/schedule_screen_test.dart` "SCH-03 …" | widget |
| AC6, AC7, edge deleted workout | `test/features/home/presentation/today_card_test.dart` "SCH-03 …" | widget |

## Risks

- Display ↔ stored index mapping in the builder is easy to get wrong. It is kept in pure
  `cycle_rules` helpers with unit tests for both locales.
- Rolling → Weekdays takes rows in their current order, which may not match the user's intent.
  The weekday labels appear before Save, so the mapping is visible.
- A Sunday-first locale test needs a locale whose `firstDayOfWeekIndex` is 0 (e.g. `en_US`); the
  test app must list it in supported locales.
