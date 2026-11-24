# SCH-02: Cycle rolls forward from the last completed day

Status: Approved
Phase: P2 · Priority: MVP · Screens: 01, 15

## Why

Weekday plans break the moment you miss a day. A rolling cycle should wait for you: a missed
training day is still up next, and rest days pass on their own, so the plan never falls apart.

## User stories

- As a lifter, I can mark today's training day done so that my cycle moves on.
- As a lifter who missed a day, I see the same workout again instead of skipping it.
- As a lifter on a rest day, I see that today is rest and what comes next.

## Acceptance criteria

- **AC1** — Given today is a training day not yet done, when I open Home, then it shows the day
  ("Day n of N · Push") and a "Mark done" action.
- **AC2** — Given AC1, when I tap "Mark done", then today shows as done (in text, not colour only),
  "Mark done" is replaced by "Undo", and Home shows what is next ("Next: Pull").
- **AC3** — Given I marked today done, when I tap "Undo" on the same calendar day, then today is
  not done again and the cycle position is as before.
- **AC4** — Given I marked day n done on a date, when the next calendar day starts, then today is
  day n+1 (wrapping after the last day).
- **AC5** — Given today is a rest day, when that calendar day passes, then it counts as done with
  no tap and the next day is day n+1.
- **AC6** — Given today is a training day and I do not mark it done, when the next calendar day
  starts, then today is still the same day, and the passed date is recorded as missed.
- **AC7** — Given I was away several days on an undone training day, when I return, then today is
  still that day and each passed date is recorded as missed (once per date).
- **AC8** — Given AC6 or AC7, then Home says the day is carried over ("Push · missed
  yesterday" or "· missed 3 days"), in text.
- **AC9** — Given today is a rest day, then Home shows the rest-day variant (screen 15): a "Rest
  day" heading, the day ("Day n of N"), and "Next: <workout>", with no "Mark done".
- **AC10** — Given the Schedule card (SCH-01 AC6), then its "today" marker follows the rolled
  position, and a done today is labelled "Done".
- **AC11** — Given I make a cycle active (new, switched, or onboarding), then rolling starts from
  the chosen day today; history of other cycles is kept but does not move the new one.
- **AC12** — Given I edit the active cycle, then today stays on the same day row as in SCH-01 AC8,
  and today's done state is kept if that row survives.
- **AC13** — Given no network, then marking done, undo and rolling all work; each done, undo and
  missed record is stored locally and queued for sync in the same step.

## Edge cases

- Only one completion per calendar day: after "Mark done" the next training day is tomorrow.
- "Undo" is offered only on the day it was marked; past done days are not editable here.
- The clock moving back (time zone, manual change) never un-does a done day or un-misses a date.
- A one-day cycle: done today means the same day again tomorrow.
- The done day's workout was deleted: Home still shows "Workout deleted" (SCH-01 AC11) and
  "Mark done" still works.
- Rest days are never recorded as missed.

## Constraints (NFRs that apply)

- NFR-02: works fully offline.
- NFR-03: each done / undo is written locally at once.
- NFR-06: 48 dp targets, 200 % text, semantics labels; done, missed and rest shown in text.

## Non-goals

- Finishing a workout marks the day done (comes with LOG-05; it uses the same completion).
- Swap, skip, move a day, unplanned rest (SCH-04). Weekday-locked mode (SCH-03).
- Calendar view of history (SCH-05). Streak and adherence (PRG-02). Notifications (NTF-01).
- Editing past days.

## Data touched

- Active cycle (position anchor).
- Day history per calendar date: cycle, planned day, status (done / missed / rest).

## Open questions

- None.
