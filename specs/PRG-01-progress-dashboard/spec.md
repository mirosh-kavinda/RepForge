# PRG-01: Progress dashboard

Status: Approved
Phase: P2 · Priority: MVP · Screens: 06 Progress

## Why

Numbers in a log don't show whether training is working. A few clear charts — strength per
lift, weekly volume and body trends — answer "am I getting stronger, and is my body changing?"

## User stories

- As a lifter, I pick an exercise and see my estimated 1RM over time and my best sets.
- As a lifter, I see how much I lift each week and how my weight and body fat move.

## Acceptance criteria

- **AC1** — Given the Progress tab, then above the Body card there is a range switch (4 weeks,
  3 months, 1 year, All; default 3 months) that applies to every chart on the tab.
- **AC2** — Given finished workouts, then a Strength section shows one exercise (first time:
  the exercise I've logged most sets of) with a line of its best estimated 1RM per workout in
  the range, and a summary: best e1RM, best set (heaviest weight × reps) and its change from
  the range's first workout. Change exercise opens a list of exercises I have logged.
- **AC3** — Given finished workouts, then a Volume section shows a bar per week (Monday start,
  the phone's weeks) of total weight × reps of weighted sets in the range, with this week's
  total in text.
- **AC4** — Given body snapshots, then a Body trends section shows weight and body fat % as two
  labelled line charts over the range (units differ, so no shared axis; body fat from
  snapshots that have it, estimated or from the scale), each with the latest value and the
  change over the range in text.
- **AC5** — Given too little data for a chart (no workouts with the exercise, fewer than 2
  points, or nothing in the range), then it shows a short text instead ("Log this lift in 2
  workouts to see a trend"), never an empty or one-dot chart.
- **AC6** — Given my display unit, then every weight on the tab (axes, summaries) is in it.
- **AC7** — Given a chart, when I touch a point or bar, then its date and value show; each
  chart also has a text summary for screen readers, so nothing is shown only as a picture.
- **AC8** — Given no network, then everything works from the phone.

## Edge cases

- Bodyweight and timed sets have no e1RM; an exercise logged only that way shows best reps
  (or time) per workout instead of e1RM.
- Sets over 12 reps give no e1RM; a workout whose sets all do counts only for best set.
- A week with no workouts shows an empty bar (0), not a gap.
- Deleted workouts and deleted snapshots are left out.
- Custom exercises (EXL-03) work like catalog ones; a deleted one still shows by name.

## Constraints (NFRs that apply)

- NFR-01: the tab opens in < 500 ms with 2 years of data; charts stay at 60 fps when scrolling.
- NFR-02: offline. NFR-04: no body data in analytics.
- NFR-06: text summaries and labels for every chart; 200 % text; tabular figures; colour never
  the only cue (lines are labelled).
- Formulas (e1RM, volume) only from `lib/core/metrics`.

## Non-goals

- Adherence and streaks (PRG-02); muscle heat map (PRG-03); goals (GOL-01).
- Comparing two exercises on one chart; exporting charts.
- Lean mass, FFMI or calorie charts.

## Data touched

- Read only: finished workouts and sets, body snapshots, exercise names, units.
- The last exercise shown is remembered on the phone.

## Open questions

- None.
