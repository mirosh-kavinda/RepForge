# SCH-04: Day actions: swap, skip, move, unplanned rest

Status: Approved
Phase: P2 · Priority: MVP · Screens: 17 Day actions sheet, 01 / 15 Home, 03 Schedule (cycle card)

## Why

Real weeks don't follow the plan: the squat rack is taken, a session has to be dropped, or the
body needs a day off. The user should be able to change today on purpose and keep an honest
history, without that counting as a missed day.

## User stories

- As a lifter, I can do a different workout today without changing my cycle.
- As a lifter, I can skip today's workout or take an unplanned rest day, and it isn't counted as missed.
- As a Weekdays lifter, I can move today's workout to a later day this week.
- As a lifter, I can train on a rest day anyway.
- As a user, I can undo any of these until the day ends.

## Acceptance criteria

- **AC1** — Given today is a training day that is not done or locked, when I open Day actions
  from Home's today card, then the sheet offers Swap workout, Skip, Unplanned rest and, in
  Weekdays only, Move. Each option says in text what it will do.
- **AC2** — Given AC1, when I choose Swap workout and pick another saved workout, then Home shows
  that workout for today, says "Swapped from <planned>", and Mark done records today as done.
  The cycle days themselves are unchanged.
- **AC3** — Given a swapped day is marked done, then the cycle moves on exactly as if the planned
  workout were done (Rolling: the next day comes tomorrow; Weekdays: no change).
- **AC4** — Given a Rolling cycle, when I choose Skip, then today is recorded as skipped, Home
  shows "Skipped" with Undo, and tomorrow is the next cycle day.
- **AC5** — Given a Rolling cycle, when I choose Unplanned rest, then today is recorded as an
  unplanned rest, Home shows the rest-day variant with Undo, and tomorrow is the same workout
  again. It is not counted as missed and adds nothing to the missed line.
- **AC6** — Given a Weekdays cycle, when I choose Skip or Unplanned rest, then today passes as in
  SCH-03, recorded as skipped or unplanned rest, never as missed.
- **AC7** — Given a Weekdays cycle, when I choose Move and pick a later date in the current week
  (per the phone's first day of the week), then today becomes rest (recorded as moved), and on
  that date Home shows the moved workout with "Moved from <weekday>" in place of that date's
  own plan. Move is not offered on the last day of the week.
- **AC8** — Given today is a rest day (planned), when I choose Train today on the rest-day card
  and pick a workout, then Home shows that workout with Mark done; when done, today is recorded
  as done with that workout and the cycle moves on as for a rest day.
- **AC9** — Given any action above was taken today, when I tap Undo, then today is back to how
  it was before that action: one step at a time, so Undo after marking a swap done returns to
  the swap, and Undo again to the planned day (a Move also clears it from the target date). Undo
  is offered until the calendar day ends; past days stay locked as in SCH-02.
- **AC10** — Given an action was taken, then the Schedule card shows today's row with the action
  in text ("Swapped: Pull", "Skipped", "Unplanned rest", "Moved to Thursday") and a moved-to date
  shows its moved workout when it is today.
- **AC11** — Given no network, then every action and Undo is stored locally at once and queued
  for sync in the same step.

## Edge cases

- Day actions are not offered once today is done (Undo first), or when today is read-only
  (clock moved back, already recorded).
- A swapped or moved-in workout that is later deleted shows "Workout deleted" and can still be
  marked done.
- Swap offers only saved workouts other than the planned one; with none, it says so.
- Moving onto a date that already has a Move into it is not allowed; that date is not offered.
- A moved-to date that passes without Mark done is recorded missed for the moved workout, once.
- Editing or switching the active cycle keeps today's action only if today's row still exists.

## Constraints (NFRs that apply)

- NFR-02 / NFR-03: offline, local writes at once.
- NFR-06: 48 dp targets, 200 % text, semantics labels; every status (swapped, skipped, unplanned
  rest, moved) is shown in text, not colour alone.
- NFR-11: weekday names and week start from the phone's locale.

## Non-goals

- Acting on future or past dates directly (only today; Move writes its target as a side effect).
- Swapping two cycle days or changing the cycle order (that's the builder, SCH-01).
- Move in Rolling (Unplanned rest covers it).
- Logging the actual sets (LOG-xx), streaks and adherence numbers (PRG-02), calendar (SCH-05).

## Data touched

- Day history per (cycle, calendar date): new statuses skipped, unplanned rest, moved; the
  workout actually planned or done for that date when it differs from the cycle row.

## Open questions

- None.
