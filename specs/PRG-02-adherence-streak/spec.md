# PRG-02: Adherence stats + cycle streak

Status: Approved
Phase: P2 · Priority: MVP · Screens: 01 Home, 06 Progress

## Why

A rolling cycle only works if I keep showing up. A streak that rest days never break, and an
honest adherence figure, reward consistency without punishing planned recovery.

## User stories

- As a lifter, I see my current streak on Home so I keep it going.
- As a lifter, I see on Progress how often I trained when planned, and which days I missed.

## Acceptance criteria

- **AC1** — Given a schedule history, then Home shows a streak chip ("12-day streak"); tapping
  it opens the Progress tab. With a streak of 0 the chip reads "Start a streak today".
- **AC2** — Given the streak, then done and rest days extend it; skipped, moved and unplanned
  rest days neither extend nor break it; a missed training day ends it; today not yet done
  never breaks it.
- **AC3** — Given the Progress tab, then an Adherence card (above Strength) shows, for the
  PRG-01 range: adherence % (done ÷ planned training days) and "18 of 20 training days".
  Skipped and missed days count as planned but not done; rest, moved, unplanned rest and
  today-not-yet-done are not counted.
- **AC4** — Given the Adherence card, then it shows the current streak and the best streak
  ever (all history, not limited by the range).
- **AC5** — Given the range, then the card shows a bar per week (Monday start) of that week's
  adherence %; a week with no planned training days shows no bar and is labelled "No training
  planned", not 0 %.
- **AC6** — Given missed or skipped training days in the range, then the card lists them newest
  first with date, the planned workout's name and "Missed" or "Skipped" in words; it shows
  the latest 5 with "Show all" for the rest. With none it reads "No missed days".
- **AC7** — Given no planned training days in the range, then adherence reads "Not enough data"
  instead of a percentage, and no bars are drawn.
- **AC8** — Given a bar, when I touch it, then its week and value show; the card has a text
  summary for screen readers, and nothing is shown only by colour.
- **AC9** — Given no network, then everything works from the phone; Home and Progress update
  as soon as a day's status changes (finish, skip, move, rest).

## Edge cases

- Days before my first cycle started don't count, and don't end the streak.
- Editing the cycle (SCH-01/04) changes future days only; past statuses stay as recorded.
- A day with a finished workout counts as done even if it was planned as rest.
- A workout finished just after midnight counts for the day it was started.
- Best streak equals the current streak when the current one is the longest.

## Constraints (NFRs that apply)

- NFR-01: Home and Progress stay within their open-time budgets with 2 years of history.
- NFR-02: offline. NFR-04: no schedule or streak values in analytics events.
- NFR-06: 200 % text; tabular figures; status in words, not colour alone; semantics labels.
- Adherence and streak formulas only from `lib/core/metrics` (FND-04 AC8).

## Non-goals

- Streak notifications and the weekly report (NTF-01, screen 22).
- Muscle heat map (PRG-03); goals (GOL-01).
- Streak freezes, badges or rewards; adherence per exercise or per template.

## Data touched

- Read only: schedule day history and statuses, cycle start, finished workouts, template names.

## Open questions

- None.
