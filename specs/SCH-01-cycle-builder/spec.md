# SCH-01: Rolling cycle builder

Status: Approved
Phase: P2 · Priority: MVP · Screens: 18 Cycle builder, 12 Starter plan, 03 Schedule (cycle card)

## Why

RepForge plans training as an N-day cycle, not a week. Users need to lay out that cycle once
(which workout on which day, where the rest days fall) so every later screen knows what today is.

## User stories

- As a user, I can build a 1–14 day cycle from my workouts and rest days, and see where it lands.
- As a new user, I can pick a ready-made plan in onboarding and be ready to train.
- As a user, I can keep several cycles and switch which one is active.

## Acceptance criteria

- **AC1** — Given the builder, when I add days with "+ Training day" (pick one of my workouts) or
  "+ Rest day", then each shows its number, workout name (or Rest) and the workout's muscles;
  the header shows "n days · t train, r rest". The same workout may appear on several days.
- **AC2** — Given the builder, then Save is enabled only with a name (1–40 characters, trimmed),
  1–14 days and at least one training day; otherwise a line under the days says what is missing.
  "+ Training day" and "+ Rest day" are disabled at 14 days.
- **AC3** — Given a day row, then I can change its workout, turn it into Rest or a training day,
  remove it, and reorder it by drag or by Move up / Move down.
- **AC4** — Given the builder, then a preview shows the next 8 dates from today with each date's
  day (workout name or Rest); a "Today is day [n]" choice (default 1) shifts it live.
- **AC5** — Given I save a new cycle, then it becomes the active one, starting today at the chosen
  day; any previously active cycle stays saved but inactive.
- **AC6** — Given an active cycle, then the Schedule tab shows its name, length, a line that
  missed days shift the cycle, and its days in order with today's day marked by text ("today") and
  outline; with no cycle, an empty state offers "+ New cycle" and the starter plans.
- **AC7** — Given an active cycle, then today's day = (start day + calendar days since the start
  date) wrapped by cycle length; Home shows "Day n of N · <workout>" or "Day n of N · Rest".
  (SCH-02 later replaces calendar days with rolling from the last completed day.)
- **AC8** — Given I edit and save the active cycle, then today stays on the same day row (followed
  through reorders); if that row was removed, today is the row now at that position (clamped to
  the new length). Past days and sessions are not changed.
- **AC9** — Given Schedule, when I open "My cycles", then I see all saved cycles (active marked in
  text), and can make one active (with the "Today is day [n]" choice), edit, duplicate, or delete
  an inactive one with Undo. The active cycle cannot be deleted; its Delete says to switch first.
- **AC10** — Given onboarding step 3 of 3 (Pick a starting plan), then I can choose PPL + Rest
  (Push, Pull, Legs, Rest), Upper / Lower (Upper, Lower, Rest, Upper, Lower, Rest) or Full Body
  + Rest (Full Body, Rest), each built from the starter workouts and saved as my active cycle
  starting today at day 1; "Build my own cycle" opens the builder and "Skip" finishes with none.
  PPL + Rest is preselected and marked Recommended in text.
- **AC11** — Given a day whose workout was deleted, then it shows "Workout deleted" with "Pick
  workout", counts as a training day, and shows normally again if the delete is undone.
- **AC12** — Given unsaved changes in the builder, when I go back, then "Discard changes?" asks
  first; with none it leaves at once.
- **AC13** — Given no network, then all of the above works; each save, activate, delete and undo
  is stored on the phone and queued for backup in the same step.

## Edge cases

- Starting today: the start date is the phone's calendar day; changing time zones never moves it.
- A cycle with one training day and no rest is allowed (every day the same workout).
- Starter plans need their starter workouts; if one was deleted, that plan is hidden.
- Two cycles may share a name. Duplicate names the copy "<name> (copy)", inactive, unsaved.
- "Today is day [n]" is limited to the cycle's length and resets to 1 when the length changes
  below it.

## Constraints (NFRs that apply)

- NFR-02 offline; NFR-06 48 dp, 200 % text, labels; Rest vs training never by colour alone
  (word "Rest" always shown); drag has a non-drag alternative.

## Non-goals

- Fixed weekdays mode (SCH-03; the toggle is not shown yet). Rolling from last completed day,
  missed-day shifting (SCH-02). Swap / skip / move (SCH-04). Calendar and adherence (SCH-05,
  PRG-02). Starting a workout from Home (WKT-02). Editing onboarding answers (SET-01).

## Data touched

- Cycle (name, ordered days: workout id or rest, active flag, start date, start day index);
  outbox rows. Reads workouts. Onboarding progress becomes 3 steps.

## Open questions

- My cycles list has no canvas screen: build from tokens and the My workouts pattern (as WKT-01).
