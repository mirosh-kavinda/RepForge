# SCH-05: Calendar and cycle view

Status: Approved
Phase: P2 · Priority: MVP · Screens: 03 Schedule (rolling cycle + calendar)

## Why

The cycle card shows where today is, but not the shape of the month: what was done, missed or
skipped, and what is coming. A month calendar makes adherence and the plan visible at a glance.

## User stories

- As a lifter, I can switch Schedule between my cycle and a month calendar.
- As a lifter, I can see each past date's outcome and each coming date's plan.
- As a lifter, I can tap a date to see what it was or will be.

## Acceptance criteria

- **AC1** — Given Schedule, then a Cycle / Calendar choice is shown at the top (default Cycle).
  When I choose Calendar, the current month opens with today marked "today" in text.
- **AC2** — Given the calendar, then weeks start on the phone's first day of the week and weekday
  names come from its locale; I can go to the previous and next month and back to this month.
- **AC3** — Given a past date with history in any cycle, then its cell shows the outcome in text
  or an icon with a label: done, missed, rest, skipped, unplanned rest or moved. A date with no
  history shows nothing.
- **AC4** — Given today and future dates and an active cycle, then each cell shows the planned
  workout or rest: Rolling projects forward from today assuming each training day is done;
  Weekdays uses each date's weekday; a moved-in workout replaces that date's plan. Planned cells
  are told apart from history in text ("planned"), not by colour alone.
- **AC5** — Given today has a day action (SCH-04), then today's cell shows it ("Skipped",
  "Swapped: Pull" …) the same way Home does.
- **AC6** — Given any date, when I tap it, then a read-only sheet shows the date, the cycle, the
  workout (or rest) and the status, with the swapped / moved details when there are any. Past
  dates cannot be changed from here.
- **AC7** — Given two years of history, when a month is shown, then it appears within 300 ms,
  and moving between months stays as fast.
- **AC8** — Given no network, then the calendar works fully from local data.

## Edge cases

- No active cycle: past history still shows; future dates show nothing and the calendar says no
  cycle is active.
- A date with records in two cycles (switched cycle that day): show the record of the cycle that
  is active now if it has one, else the latest updated; the sheet lists both.
- Dates before the first record and months with no history show empty cells, no error.
- A workout since deleted shows "Workout deleted".
- Changing the phone's locale changes the week start and names only.
- Today changes at midnight while the calendar is open: the "today" mark and plan move.

## Constraints (NFRs that apply)

- NFR-01 / requirement: month in < 300 ms with 2 years of data.
- NFR-02: offline. NFR-06: 48 dp cells, 200 % text (cells may show icons with labels and the
  sheet carries full text), semantics label per cell ("Tuesday 24 November, Legs, done").
- NFR-11: locale weekday names, month names and week start.

## Non-goals

- Changing past or future dates from the calendar (SCH-04 is today only).
- Streak and adherence numbers (PRG-02), workout details and sets (LOG-xx).
- A year or week view.

## Data touched

- Reads day history for all cycles by date range; reads cycles and workouts. No new data.

## Open questions

- None.
