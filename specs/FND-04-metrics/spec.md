# FND-04: Metrics package

Status: Done
Phase: P2 · Priority: MVP · Screens: none (feeds 05 Body Snapshot, 06 Progress, 07/19 Goals, 01 Home)

## Why

Body, strength and adherence numbers appear on several screens. One tested, offline source for
every formula keeps them consistent and trustworthy, and stops slices re-deriving maths.

## User stories

- As a user, every body and strength number I see is computed the same way everywhere.
- As a user, I get an honest "can't estimate" instead of a nonsense number.

## Acceptance criteria

- **AC1** — Given weight and height, then BMI = kg / m²; given sex, waist, neck (and hip for
  female), then body fat % follows the US Navy formula; LBM and FFMI follow from them. Each
  matches published reference values to ±0.1.
- **AC2** — Given weight, height, age and sex, then BMR uses Mifflin–St Jeor; given a body-fat %
  as well, it uses Katch–McArdle instead. The result names the formula used.
- **AC3** — Given BMR and an activity level (1.2 / 1.375 / 1.55 / 1.725 / 1.9), then TDEE =
  BMR × factor; calorie targets are cut −20 %, maintain, lean bulk +10 %; protein is
  1.6–2.2 g per kg body weight.
- **AC4** — Given sex is not set, when a sex-dependent value is asked for, then the mean of the
  male and female results is returned, marked as a less precise estimate.
- **AC5** — Given any input outside its plausible range or inconsistent measurements (e.g. waist
  ≤ neck), then the result is "can't estimate" with the reason, never NaN, infinity or a crash.
- **AC6** — Given a set of w kg × r reps, then e1RM = w × (1 + r/30) for 2–12 reps, = w for 1 rep;
  warm-ups, sets over 12 reps and sets with 0 kg or 0 reps give no e1RM.
- **AC7** — Given a session's sets, then volume = Σ kg × reps over working sets (warm-ups and
  zero sets excluded).
- **AC8** — Given a run of days (planned training, done, rest, missed, skipped, moved), then
  adherence % = done ÷ planned training days; the cycle streak counts consecutive days back from
  today where done and rest extend it, skipped and moved neither extend nor break it, a missed
  training day ends it, and today not yet done does not break it.
- **AC9** — Given dated goal measurements, then the projection fits a line over the last 4–8
  weeks and returns the date it meets the target; no date ("not enough data") under 3 points or
  14 days; "not on track" when the trend moves away or the date is over 2 years out.
- **AC10** — Given a value, then display rounding is: BMI, BF %, FFMI 1 decimal; LBM, e1RM 0.5 kg
  (1 lb in lb); BMR, TDEE, calories nearest 10 kcal; protein whole grams; volume whole kg.
  Stored values are never rounded.
- **AC11** — Given kg / cm, then conversion to lb, in and ft + in (and back) round-trips within
  0.01 of the original.

## Edge cases

- Age comes from birth year: current year − birth year.
- Hip given for a male is ignored; missing hip for a female (or unset sex) → "can't estimate" BF %.
- Equal values, empty lists, a single set or a single day produce defined results, not errors.
- Projection with a flat trend (slope 0) and target not reached → "not on track".

## Constraints (NFRs that apply)

- NFR-08 / CLAUDE.md: pure, offline, 100 % unit-tested; one home for every formula.
- NFR-04: health values are never sent to analytics.
- All results are labelled as estimates wherever shown (enforced by UI slices).

## Non-goals

- Ghost Set target (LOG-02; blocked on the 2.5 kg vs smallest-plate question in roadmap.md).
- Any screen, storage or charting (BOD-01, PRG-01/02, GOL-01).

## Data touched

- None stored. Plausible input ranges: weight 25–350 kg, height 100–250 cm, age 13–100,
  waist 40–250 cm, neck 20–80 cm, hip 50–250 cm, body fat 3–60 %.

## Open questions

- None blocking.
