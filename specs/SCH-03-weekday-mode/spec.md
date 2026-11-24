# SCH-03: Optional weekday-locked mode

Status: Approved
Phase: P2 · Priority: MVP · Screens: 18 Cycle builder, 03 Schedule (cycle card), 01 Home

## Why

Rolling cycles suit lifters whose week is flexible. Others train around a fixed week (Monday is
always Push because of work or a class). For them the plan should follow the calendar week, and a
missed day should simply pass rather than push everything back.

## User stories

- As a lifter with a fixed week, I can set a 7-day cycle to Weekdays so each day of the week has
  its own workout.
- As that lifter, I see today's weekday workout on Home, and a missed day does not shift the week.
- As a user, I can switch a cycle between Rolling and Weekdays.

## Acceptance criteria

- **AC1** — Given the cycle builder, then it offers a Rolling / Weekdays choice (default Rolling),
  saved with the cycle.
- **AC2** — Given a cycle that is not exactly 7 days long, then Weekdays cannot be chosen and the
  builder says "Weekday mode needs exactly 7 days". Given Weekdays is chosen, then adding or
  removing a day is disabled with the same reason.
- **AC3** — Given Weekdays, then each day row is labelled with its weekday name instead of a day
  number, rows are listed from the first day of the week for the phone's locale, the
  "Today is day n" choice is hidden, and the preview shows the next 8 dates by weekday.
- **AC4** — Given Weekdays, when I reorder or change rows, then each workout moves to the weekday
  of its new row; Save keeps that mapping.
- **AC5** — Given the active cycle is in Weekdays, when I open Home on any date, then today is
  that date's weekday row, whatever was done or missed before.
- **AC6** — Given AC5 on a training day, then Home shows "Monday · Push" (today's weekday and
  workout), "Mark done" / "Done" + "Undo" and "Next: <tomorrow's workout>" as in SCH-02. Given a
  rest day, then the rest-day variant shows "Rest day", the weekday and "Next: …".
- **AC7** — Given Weekdays and a training day not marked done, when the next calendar day starts,
  then that date is recorded as missed once, Home shows the next weekday's workout, and no
  "missed" carry-over line is shown. Rest days are recorded as rest, never missed.
- **AC8** — Given the Schedule card for a Weekdays cycle, then it says "Weekdays" in text, rows
  show weekday names, and today's row is marked "today" (and "Done" when done).
- **AC9** — Given the active cycle is switched from Weekdays to Rolling and saved, then rolling
  starts today on today's weekday row; history is kept. Given Rolling to Weekdays, then today
  becomes today's weekday row.
- **AC10** — Given no network, then choosing the mode, saving, marking done and recording missed
  days all work and are stored locally and queued for sync in the same step.

## Edge cases

- Changing the phone's locale (week starts Sunday vs Monday) changes the order rows are listed
  in, not which workout belongs to which weekday.
- Time zone or clock changes: today is the phone's current calendar date's weekday; SCH-02's
  clock-moved-back rule (no Undo or Mark done on a past day) applies.
- A Weekdays cycle whose workout was deleted still shows "Workout deleted" and Mark done works.
- Copying a Weekdays cycle keeps Weekdays; making it active needs no "Today is day n".
- Weekdays with all seven days Rest cannot be saved (SCH-01 needs one training day).

## Constraints (NFRs that apply)

- NFR-02: works fully offline. NFR-03: writes are local at once.
- NFR-06: 48 dp targets, 200 % text, semantics labels; mode, today, done, rest in text.
- NFR-11: weekday names come from the phone's locale.

## Non-goals

- Picking training weekdays and filling them from a longer cycle; cycles other than 7 days in
  weekday mode.
- Catch-up: doing a missed weekday's workout on another day (SCH-04).
- Weekday versions of the onboarding starter plans.
- Calendar view (SCH-05), streaks and adherence (PRG-02), reminders (NTF-01).

## Data touched

- Cycle: mode (rolling / weekdays); the weekday each row belongs to.
- Day history per calendar date (from SCH-02): done / missed / rest.

## Open questions

- None.
