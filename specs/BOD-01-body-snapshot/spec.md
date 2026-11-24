# BOD-01: Body Snapshot

Status: Approved
Phase: P2 · Priority: MVP · Screens: 05 Body Snapshot, 06 Progress (Body card)

## Why

Lifters track weight on one app, body fat on a scale and calories on a website, and the
numbers never line up. One short form should turn a few measurements into every body metric
and a calorie target, saved together so they can be compared over time.

## User stories

- As a lifter, I enter my weight (and tape measurements if I have them) and see BMI, body fat,
  lean mass, FFMI, BMR, TDEE and calorie targets at once.
- As a lifter, I see my latest numbers and my past snapshots on the Progress tab.

## Acceptance criteria

- **AC1** — Given the Progress tab, then a Body card shows the latest snapshot's date, weight
  and results, with New snapshot. With no snapshot it says "No body snapshot yet" with New
  snapshot.
- **AC2** — Given New snapshot, then the form has weight (required), waist, neck, hip (hidden
  only for men, as the estimate needs it otherwise), body fat % from a scale (optional) and activity level (remembered from last
  time; first time "Moderately active"). Units follow my setting; values are stored in kg / cm.
- **AC3** — Given a weight, when I save, then the snapshot is stored for today with every
  result worked out at once (BMI, body fat %, lean mass, FFMI, BMR, TDEE, calorie targets for
  lose / keep / gain, protein range) and queued for sync; the activity level is saved to my
  profile.
- **AC4** — Given waist and neck (and hip for women) and my height, sex and birth year, then
  body fat is the tape estimate; given a scale body fat %, that is used instead and marked
  "from scale". Lean mass and FFMI follow from whichever is used.
- **AC5** — Given a result cannot be worked out (missing height, sex, birth year or tape
  measures, or a value out of range), then it shows "—" with the reason in words ("Add your
  height in Profile", "Add waist and neck for body fat"), never a wrong number.
- **AC6** — Given a snapshot already saved today, when I save again, then today's snapshot is
  replaced, not added; the history keeps one row per date.
- **AC7** — Given the Body card, when I tap it, then my past snapshots show newest first (date,
  weight, body fat % and its source). Tapping one shows its saved results; it can be deleted
  with Undo.
- **AC8** — Given no network, then all of the above works and is stored on the phone at once.

## Edge cases

- Weight out of the metrics' accepted range (e.g. 5 kg, 500 kg): Save refuses with the range.
- Tape values that give an impossible body fat (e.g. neck ≥ waist): body fat "—" with the reason.
- The onboarding snapshot (weight, waist) shows in history like any other.
- Changing units later changes only how values show, not what is stored.
- Results are those saved at the time; a later change to height or age doesn't rewrite them.

## Constraints (NFRs that apply)

- NFR-02: offline. NFR-04: no body values in analytics, ever.
- NFR-06: 48 dp, 200 % text, labels and units in semantics ("Weight, 82.5 kilograms"); numbers
  in tabular figures; "—" read as "not available" with the reason.
- Formulas only from `lib/core/metrics` (project rule).

## Non-goals

- Charts and trends (PRG-01); goals (GOL-01); progress photos (BOD-02).
- Health Connect / Apple Health import; editing a past snapshot (delete and re-enter today).
- Editing height, sex or birth year here (Profile / SET-01).

## Data touched

- Body snapshots: gain neck, hip, scale body fat %, activity level and the saved results.
- Profile: activity level. Read: height, sex, birth year, units.

## Open questions

- None.
