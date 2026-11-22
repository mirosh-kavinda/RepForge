# SCH-04: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Every day action is a record on today's date in the SCH-02 day history, so it is local,
synced, undoable and read back by the same walk. The history record gains the workout actually
planned for that date and a linked date for a Move, plus new statuses. A not-yet-done Swap,
Train today or moved-in workout is a `planned` record that Mark done turns into `done`. The
rolling walk learns which statuses move the cycle on, and settle turns a passed `planned` record
into what that date ended as. Home opens a Day actions sheet (screen 17). Home and Schedule show
the action in text.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/schedule/domain/day_record.dart` | changed | `DayStatus` + `planned`, `skipped`, `unplannedRest`, `moved`; `workoutId`, `linkedDate` (AC2, AC4–AC8) |
| `lib/features/schedule/domain/rolling.dart` | changed | walk: skipped moves on, unplanned rest waits without counting missed; `CycleToday.record` (today's action); `readOnly` only for missed / rest; settle converts passed `planned` (AC3–AC6, edge) |
| `lib/features/schedule/domain/day_actions.dart` | new | pure rules: which actions today offers (`availableActions`), Move targets in the locale week (`moveTargets`), the workout today shows (AC1, AC7, AC8, edges) |
| `lib/features/schedule/domain/day_record_repository.dart` | changed | `plan` (swap / train today), `skip`, `restToday`, `move`, `markDone` keeps a planned workout, `undo` one step back; `writeSettled` may replace `planned` (AC2–AC9) |
| `lib/features/schedule/data/drift_day_record_repository.dart` | changed | implements the above; Move writes both dates in one transaction, one outbox row each (AC7, AC11) |
| `lib/data/local/app_database.dart` | changed | `schedule_days.workout_id`, `linked_date` nullable; schema v6 → v7 |
| `lib/features/schedule/presentation/day_actions_sheet.dart` | new | screen 17: Swap workout / Train today, Skip, Unplanned rest, Move (Weekdays) with one-line explanations; Move date list by weekday (AC1, AC7, AC8) |
| `lib/features/schedule/presentation/workout_pick_sheet.dart` | changed | optional `exclude` so Swap hides the planned workout (edge) |
| `lib/features/home/presentation/today_card.dart` | changed | Day actions / Train today button; "Swapped from …", "Moved from …", "Skipped", unplanned rest and "Moved to …" variants, each with Undo (AC2, AC4–AC9) |
| `lib/features/schedule/presentation/cycle_day_tile.dart` | changed | optional action note in text and semantics ("Swapped: Pull", "Skipped" …) (AC10) |
| `lib/features/schedule/presentation/schedule_screen.dart` | changed | passes today's action note and the moved-in workout to today's tile (AC10) |
| `lib/app/l10n/app_en.arb` | changed | sheet titles, option names and hints, status lines |
| `docs/architecture.md` | changed | ScheduleDay fields and statuses; streak: unplanned rest neutral like skipped |

## Data

- `schedule_days.status` text gains `planned`, `skipped`, `unplannedRest`, `moved`.
- `schedule_days.workout_id` text null: the workout for that date when it is not the row's own
  (swap, train today, moved in).
- `schedule_days.linked_date` datetime null: on a `moved` record the target date, on a moved-in
  `planned` record the source date.
- Schema v6 → v7 adds both columns; existing rows read with nulls. Firestore ScheduleDay doc
  gains `workoutId`, `linkedDate` (same outbox entity).

## Key decisions

- **One record per (cycle, date) stays the key (AC9, AC11).** Each action is an upsert of today's
  record; Undo is a step back on that record. No separate "override" table.
- **Swap and Train today are `planned` with a workout (AC2, AC8).** Mark done turns `planned`
  into `done` keeping `workoutId`. The done-on-row rule from SCH-02 is unchanged, so a swapped
  done day moves the cycle on as the planned one would (AC3). On a rest row the cycle moves on
  as for rest whatever happens (AC8).
- **Undo is one step (AC9).** `done` with a workout → back to `planned`; `done` without → removed
  (SCH-02); `planned`, `skipped`, `unplannedRest` → removed; `moved` → removed and the target's
  `planned` record (linked to today) removed in the same transaction.
- **Walk rules (AC4–AC6).** Rolling: `skipped` moves on like done; `unplannedRest` keeps the
  cycle waiting but does not add to `missedDays`; a passed `planned` counts as missed. Weekdays:
  unchanged, every date passes.
- **Read-only today (edge).** Only `missed` / `rest` records or the clock-behind rule lock today;
  action statuses keep Undo available. Day actions show only when today has no record or a
  not-moved-in `planned` one (re-swap allowed).
- **Move (AC7, edges).** Targets are the dates after today up to the end of the locale's week
  (`firstDayOfWeekIndex`) with no record yet. On the last day of the week the list is empty and
  Move is hidden. The target record is `planned` with the moved workout, the target date's row id
  and `linkedDate` = today; its own plan is replaced for that date only. A moved-in day offers
  only Mark done in this slice.
- **Settle (edge).** A passed `planned` record becomes `missed` on a training row or a moved-in
  date, and `rest` on a rest row (an unused Train today). Other records are left as they are.
- **Cycle edits (edge).** A record whose `dayId` is not today's row is ignored for today's
  display, so a removed row drops its action; history stays.
- **Wording (AC10).** Statuses always appear as words on Home and in tile semantics; colour only
  repeats them.

## Packages

None new.

## Error handling

- Any action, Undo or Move that fails shows "Couldn't save. Try again." and leaves the card as it
  was (SCH-02 pattern).

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC3–AC6, settle and read-only edges | `test/features/schedule/domain/rolling_test.dart` "SCH-04 …" | unit |
| AC1, AC7, AC8 rules, Move targets (Sunday- and Monday-first) | `test/features/schedule/domain/day_actions_test.dart` | unit |
| AC2, AC4–AC9, AC11, schema | `test/features/schedule/data/drift_day_record_repository_test.dart` "SCH-04 …", `app_database_test.dart` "v6 → v7" | unit |
| AC1, AC2, AC4–AC9, edges (deleted workout, no other workouts, failure), NFR-06 | `test/features/home/presentation/today_card_test.dart` "SCH-04 …" | widget |
| AC10 | `test/features/schedule/presentation/schedule_screen_test.dart` "SCH-04 …" | widget |

## Risks

- Statuses multiply the walk's cases. They are kept in one pure function with a test per status
  in both modes.
- A moved-in date offers only Mark done; skipping it means letting it pass as missed. Revisit if
  users ask.
- Switching a Weekdays cycle with a pending Move to Rolling leaves a future `planned` record; the
  rolling walk ignores it unless its row matches, and settle records it missed. Acceptable,
  history stays honest.
