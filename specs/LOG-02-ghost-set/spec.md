# LOG-02: Ghost Set, suggested target and PR badge

Status: Approved
Phase: P2 · Priority: MVP · Screens: 02 Workout logger

## Why

Progressive overload only works if you know what you did last time and what to beat today.
Showing last session's set and a suggested next step on every row takes the guesswork out, and a
PR badge makes the progress visible the moment it happens.

## User stories

- As a lifter, I see last session's weight × reps under each set while I log.
- As a lifter, each set is prefilled with a sensible next step, so one tap logs progress.
- As a lifter, I see a PR badge when a set beats my best ever for that exercise.

## Acceptance criteria

- **AC1** — Given an exercise with a finished session before, then each set row shows a ghost
  line "Last: 60 kg × 8" (or "Last: 40 s", "Last: Bodyweight × 12") for the same set number of
  that session. A set number not done last time shows no ghost line.
- **AC2** — Given last time every set of that exercise reached the top of its rep range, then
  every set's suggested target is last time's weight + 2.5 kg (5 lb when imperial) at the bottom
  of the range. Otherwise each set's target is the same weight with one more rep than last time,
  up to the top of the range.
- **AC3** — Given a timed exercise, then the target is last time's seconds + 5 s once last time
  reached the template's seconds, else the same seconds again.
- **AC4** — Given a bodyweight exercise logged at 0 kg, then the target adds a rep (no cap) and
  never adds weight.
- **AC5** — Given a set row with a target, then it is prefilled with the target and shows
  "Target: 62.5 kg × 6" next to the ghost line, so one tap on Log logs the progression. Steppers
  change it as in LOG-01. With no history the row behaves as in LOG-01, with no ghost or target.
- **AC6** — Given I log a set, when its estimated 1RM beats every earlier set of that exercise
  (all finished sessions plus earlier sets in this workout), then the row shows a "PR" badge in
  text. For sets over 12 reps, timed sets and bodyweight sets, a PR is more reps (or seconds)
  than ever at that weight or heavier. The first time an exercise is done gives no PR.
- **AC7** — Given a PR set is edited or deleted, then the PR badges of that exercise in this
  workout are worked out again.
- **AC8** — Given no network, then ghost, target and PR all come from data on the phone.

## Edge cases

- An exercise done twice in the last session: the ghost uses its first appearance (as LOG-01).
- A swapped-in exercise uses its own history, not the replaced one's.
- A last session with fewer sets than planned: extra sets get no ghost and use LOG-01's
  in-workout prefill.
- The template's rep range changed since last time: the rule uses today's range.
- Units: the ghost and target display in the user's unit; lb targets round to the stepper's
  5 lb step.

## Constraints (NFRs that apply)

- NFR-01: ghost and target ready when the logger opens; a set write stays < 50 ms.
- NFR-02: offline. NFR-06: ghost, target and PR read in text and semantics, not colour alone;
  200 % text.

## Non-goals

- A smallest-plate setting or per-equipment steps (SET-01 later); warm-up sets (LOG-04).
- PR history screens and records lists (PRG-01); the finish summary of PRs (LOG-05).
- Deload or RPE-based suggestions.

## Data touched

- Reads finished sessions' sets per exercise. Each logged set records whether it was a PR.

## Open questions

- None. (Roadmap question "Ghost Set step" settled: fixed 2.5 kg / 5 lb for now.)
