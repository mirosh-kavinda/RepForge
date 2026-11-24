# WKT-02 + LOG-01: Start today's workout and log sets in two taps

Status: Approved
Phase: P2 · Priority: MVP · Screens: 01 Home, 02 Workout logger

## Why

The plan is only useful if training starts from it in one tap and logging a set is faster than a
notebook. Today's workout should open ready to go, with each set already filled in from last time.

## User stories

- As a lifter, I tap Start on Home and today's workout opens, ready to log.
- As a lifter, I log a set with at most two taps, already filled in from last time.
- As a lifter, I fix a wrong set, add an extra one, or add or swap an exercise mid-workout.
- As a lifter, my workout survives leaving the app, and Finish records today as done.

## Acceptance criteria

- **AC1 (WKT-02)** — Given today has a workout on Home (planned, swapped, moved-in or Train
  today) and it is not done, when I tap Start workout, then the logger opens with that workout's
  exercises in template order, each with its planned number of sets. One tap from Home.
- **AC2** — Given the logger, then each set row shows weight and reps (or seconds for a timed
  exercise) prefilled from the same set number of the last finished session of that exercise.
  With no history, it shows the template's target weight (or empty) and the bottom of the rep range.
- **AC3 (LOG-01)** — Given a set row, when I tap Log, then the set is saved with the shown values
  at once (one tap). When I first change weight or reps with a stepper and then tap Log, that is
  two taps. Weight steps 2.5 kg, or 5 lb when the profile uses imperial; reps and seconds step 1.
- **AC4** — Given a set is logged, then its row shows "Done" in text with its values, and the
  next set gets the values just logged when it had no history of its own.
- **AC5** — Given a logged set, when I tap it, then I can change its weight and reps or delete it.
- **AC6** — Given an exercise, when I tap + Set, then one more set is added after its last set,
  prefilled like AC4.
- **AC7** — Given the logger, when I choose Add exercise or Swap exercise and pick one from the
  library, then it is added at the end (3 sets, template defaults) or replaces that exercise's
  sets not yet logged. Logged sets stay.
- **AC8** — Given a workout in progress, when I leave the logger or the app is closed, then
  every logged set is kept on the phone; Home shows "Resume workout" in place of Start until the
  workout is finished or discarded. Discard asks to confirm and removes the workout.
- **AC9** — Given at least one logged set, when I tap Finish, then the workout is saved with its
  start and end time and every logged set, queued for sync as one write, today is marked done
  (as Mark done in SCH-02, keeping a swap), and I return to Home showing Done. With no logged sets
  Finish says "Log at least one set" instead.
- **AC10** — Given no network, then everything above works and is stored on the phone at once.

## Edge cases

- The workout's template was deleted after starting: the logger keeps working from its copy.
- An exercise removed from the library still shows by its saved name.
- A bodyweight exercise logs 0 kg and shows "Bodyweight", not 0.
- Starting a workout while another is in progress resumes the existing one.
- Today changes at midnight mid-workout: Finish marks the day the workout started on.
- Units: kg stored, lb shown when chosen; a lb value round-trips to the same lb shown.

## Constraints (NFRs that apply)

- NFR-01: a set write < 50 ms. NFR-02 / NFR-03: offline; each set stored at once.
- NFR-06: 48 dp, 200 % text, semantics on every control; Done in text.
- NFR-10: one cloud write per finished workout, never per set.

## Non-goals

- Ghost line, suggested target and PR badges (LOG-02); rest timer (LOG-03); warm-up / drop sets,
  failure flags and notes (LOG-04); finish summary screen (LOG-05).
- Reordering exercises; editing the template from the logger.
- Starting a workout on a past date.

## Data touched

- Workout session (start, end, template, sets: exercise, set number, kg, reps or seconds).
- Day history: today marked done on Finish.

## Open questions

- None.
