# SCH-02: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A new synced `schedule_days` table holds one record per (cycle, calendar date): done, missed or
rest. Where today falls is a pure walk from the cycle's existing anchor (start date + start day
index) to today: a date moves the cycle on if its day is Rest or was marked done on that row;
otherwise the cycle waits (AC4–AC7). A "settle" step writes the missed / rest records for passed
dates that have none, so history exists for SCH-05 and PRG-02 (AC6, AC7). Home gets a today card
with Mark done / Undo and the rest-day variant (AC1–AC3, AC8, AC9).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/schedule/domain/day_record.dart` | new | freezed `DayRecord` {id, cycleId, date, dayId, dayIndex, status}; `DayStatus` done / missed / rest |
| `lib/features/schedule/domain/rolling.dart` | new | `rollForward(cycle, records, today)` → `CycleToday` {index, doneToday, missedDays, next}; `toSettle(…)` → records to write (AC4–AC8, AC12, edges) |
| `lib/features/schedule/domain/cycle_rules.dart` | changed | remove calendar-day `dayIndexOn` (replaced by `rollForward`); `reanchor` takes today's rolled index (AC12) |
| `lib/features/schedule/domain/day_record_repository.dart` | new | `watchSince(cycleId, date)`, `markDone`, `undo`, `writeSettled` |
| `lib/data/local/app_database.dart` | changed | `ScheduleDays` table, unique (cycle_id, date); schema v4 → v5 |
| `lib/features/schedule/data/drift_day_record_repository.dart` | new | upsert by (cycle, date), soft-delete undo, settle in one transaction; every write via `SyncedWriter` (AC13) |
| `lib/core/clock.dart` | changed | `todayProvider`: the calendar day, re-emitted at local midnight and on app resume (AC4–AC6) |
| `lib/features/schedule/data/providers.dart` | changed | repository, `cycleTodayProvider` (active cycle + records + today → `CycleToday`), `cycleSettlerProvider` |
| `lib/features/home/presentation/today_card.dart` | new | replaces `TodayInCycle`: training card with Mark done / Done + Undo, missed line, Next; rest-day variant screen 15 (AC1–AC3, AC8, AC9) |
| `lib/features/home/presentation/home_screen.dart` | changed | uses `TodayCard`; listens to `cycleSettlerProvider` |
| `lib/features/schedule/presentation/cycle_day_tile.dart` | changed | `isDone` → "Done" label (AC10) |
| `lib/features/schedule/presentation/schedule_screen.dart` | changed | today marker and Done from `cycleTodayProvider` (AC10) |
| `lib/features/schedule/presentation/cycle_editor_controller.dart`, `cycle_editor_screen.dart` | changed | preview and re-anchor use the rolled index (AC12) |
| `lib/app/l10n/app_en.arb` | changed | Mark done, Done, Undo, Next, missed lines, Rest day |

## Data

- `schedule_days`: id (UUID v7), cycle_id, date (UTC midnight of the phone's calendar day, as
  cycles), day_id (the cycle row's id), day_index, status (`done` / `missed` / `rest`) + base
  columns. Unique (cycle_id, date). Schema v4 → v5 creates it. Outbox entity `scheduleDay`.
- Architecture lists `scheduleDays/{yyyy-MM-dd}`; per-cycle uniqueness is needed because a cycle
  switched to today has its own today (AC11). The Firestore doc id is settled in SYN-01; the
  architecture row is updated with this slice.
- No `sessionId` yet; LOG-05 adds it.
- Cycles are not rewritten as days pass: the anchor only changes on activate or edit (SCH-01), so
  rolling adds no daily cycle writes.

## Key decisions

- **The walk (AC4–AC7).** `pos = startDayIndex`; for each date from `startDate` to yesterday: if
  the row at `pos` is Rest, or that date's record is done on that row id, `pos` moves on (wrap) and
  `missedDays` resets; else `missedDays` grows. Today: `doneToday` = today's record is done on the
  row at `pos`. Pure and cheap (at most a few hundred dates since the anchor).
- **Settle (AC6, AC7, edge).** For each passed date (anchor date … yesterday) with no record,
  write `rest` or `missed` for the row the walk was on. Only missing dates are written, and the
  unique key makes repeats impossible, so it is idempotent. Runs when Home is shown and when the
  day changes. Display never waits on it: the walk gives the same answer before and after.
- **Mark done / Undo (AC2, AC3, edge).** Mark done upserts today's record (status done, today's
  row), so it is offered only on a training day with no done record for today's row. Undo is offered
  only for today's record and soft-deletes it; marking again restores the same row.
- **Clock moves back (edge).** The walk stops at today and settle only writes dates before today
  that have no record, so nothing done or missed is ever removed. If today is before the anchor
  date, today is the anchor day.
- **Clock moved back (edge, review).** The phone keeps the latest calendar day it has shown
  (device-local, not synced). While today is before it, or today already has a missed / rest
  record, the card shows the state in text with no Mark done or Undo, so a past day is never
  edited and no button does nothing.
- **Activate (AC11).** Unchanged from SCH-01: the anchor becomes (today, chosen day). The walk only
  reads the active cycle's records from its anchor date, so other cycles' history is ignored.
- **Edit (AC12).** Re-anchor takes today's rolled index instead of the calendar formula. Done
  today follows the row because it is keyed by row id; if the row was removed, today shows not
  done, and its done record stays as history without moving the cycle.
- **Day change (AC4–AC6).** `todayProvider` derives from `clockProvider`, with a timer to the next
  local midnight and an app-resume listener, so tests drive it by changing the clock and resuming.
- **Next (AC2, AC9).** The row after today's: the workout name, or "Rest".
- **Missed line (AC8).** 1 → "missed yesterday"; n > 1 → "missed n days". Shown only on training
  days with `missedDays > 0`.
- **Screen 15 (AC9).** Basic rest card: "Rest day" heading, "Day n of N", "Next: …". The
  illustration and recovery tips from the canvas are left for later; no notifications.

## Packages

None new.

## Error handling

- A failed Mark done or Undo leaves the card as it was and shows "Couldn't save. Try again."
- A failed settle is ignored and retried on the next trigger; today's display does not depend on
  it.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC4–AC8, AC11, AC12, edges | `test/features/schedule/domain/rolling_test.dart` | unit |
| AC3, AC6, AC7, AC13, schema | `test/features/schedule/data/drift_day_record_repository_test.dart`, `app_database_test.dart` "v4 → v5" | unit |
| AC4–AC6 day change | `test/core/clock_test.dart` (midnight timer, resume) | unit |
| AC1–AC3, AC5, AC6, AC8, AC9, NFR-06 | `test/features/home/presentation/today_card_test.dart` (app + router, clock moved between pumps) | widget |
| AC10, AC11 | `test/features/schedule/presentation/schedule_screen_test.dart` | widget |
| AC12 | `test/features/schedule/presentation/cycle_editor_screen_test.dart` | widget |

## Risks
- Editing the active cycle re-anchors to today, so the "missed n days" line resets after an
  edit; the day itself is still kept (AC12). Accepted for this slice.
- Settling walks from the current anchor only; dates not yet settled when a cycle is edited or
  switched are not recorded. Home stays mounted in the shell, so the settler normally runs
  first.
- Home and Schedule widget tests use a fake record store; date matching against Drift is
  covered by the repository tests (UTC dates round-trip).

- Removing calendar-day `dayIndexOn` touches SCH-01 tests that assumed it (Home "Day 3 of 3",
  preview start). They are rewritten to the rolled rule; SCH-01 AC7 says SCH-02 replaces it.
- Settle writes a record and an outbox row per passed date. After a long absence that is a batch
  of tiny rows, not a cost risk (NFR-10 is per Firestore write; SYN-01 can batch them).
- A midnight timer while the app is open can be missed if the OS suspends the app; the resume
  listener covers that.
