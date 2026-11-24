# GOL-01: Personal goals with projected finish date

Status: Approved
Phase: P2 · Priority: MVP · Screens: 07 Goals, 19 New goal, 01 Home

## Why

A target with no date feels far away. Projecting a finish date from my own recent trend tells
me whether I'm on pace, and keeps the goal in front of me.

## User stories

- As a lifter, I set a target estimated 1RM for a lift and see when I'll likely reach it.
- As a user, I set a target body weight (up or down) and see my progress and projected date.
- As a user, I pin one goal to Home so I see it every day.

## Acceptance criteria

- **AC1** — Given the Progress tab, when I open Goals, then I see my active goals and an
  Achieved list; with none, "No goals yet" and New goal.
- **AC2** — Given New goal, when I pick Strength, then I choose one of the lifts I have an
  estimated 1RM for, see its current value, and enter a target above it; when I pick Body
  weight, I see my latest weight and enter a target above or below it. An optional deadline
  can be set. Save is disabled until the target is valid.
- **AC3** — Given New goal with a target entered, then before saving it shows the projected
  finish date from my last 8 weeks, or "Not enough data yet: log it 3 times over 2 weeks" or
  "Not on track at your current trend".
- **AC4** — Given an active goal, then its row shows type and name, start → current → target,
  progress as a percentage and a bar (start = value when created, clamped 0–100 %), and the
  projected finish date or the reason there isn't one.
- **AC5** — Given a goal with a deadline and a projected date, then it reads "On pace" when the
  projection is on or before the deadline, else "Behind"; a passed deadline reads "Deadline
  passed". Always in words, never colour alone.
- **AC6** — Given new data (a finished workout or a body snapshot), when the current value
  reaches the target, then the goal moves to Achieved with the date reached.
- **AC7** — Given an active goal, when I choose Mark achieved, then it moves to Achieved with
  today's date.
- **AC8** — Given an active goal, when I edit it, then I can change the target and deadline (the
  start value stays); the new target follows the AC2 rules.
- **AC9** — Given any goal, when I delete it, then it disappears with an Undo snackbar that
  brings it back.
- **AC10** — Given an active goal, when I pin it, then Home shows its card (name, current →
  target, %, projected date) and tapping it opens Goals; only one goal is pinned at a time.
  With none pinned, Home shows the newest active goal; with no active goals, a "Set a goal"
  link to New goal.
- **AC11** — Given my display unit, then every weight on these screens is in it, and targets
  are entered in it.
- **AC12** — Given no network, then goals can be created, changed and deleted on the phone and
  are backed up when online.

## Edge cases

- Strength uses only sets that give an estimated 1RM (≤ 12 reps, with weight); a lift with
  none can't be chosen.
- Body weight needs at least one snapshot (the onboarding weight counts).
- A target equal to the current value is rejected ("You're already there").
- Achieving a pinned goal unpins it; Home falls back as in AC10.
- Data that later drops below the target doesn't un-achieve a goal.
- A custom exercise that is deleted keeps its goal, shown by name.

## Constraints (NFRs that apply)

- NFR-01: Goals and Home stay within their open-time budgets.
- NFR-02: offline first; backed up like other records. NFR-04: no goal or body values in
  analytics.
- NFR-06: 200 % text; tabular figures; 48 dp targets; semantics labels; status in words.
- Projection and e1RM formulas only from `lib/core/metrics`.

## Non-goals

- Body fat, consistency, measurement or calorie goals; check-ins and drift alerts (GOL-02).
- Goal notifications (NTF-01); sharing goals; restarting a goal's start value.

## Data touched

- Goals (new): type, exercise, start, target, deadline, pinned, achieved date; synced.
- Read: finished sets, body snapshots, exercise names, units.

## Open questions

- None.
