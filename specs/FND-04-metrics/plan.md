# FND-04: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Pure Dart in `lib/core/metrics/`, no Flutter, Firebase or Drift imports. One file per topic,
plain functions over plain values. Every fallible result is an `Estimate` (a value, or "can't
estimate" with a reason), so callers can't show NaN and must handle the miss (AC5).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/core/metrics/estimate.dart` | new | sealed `Estimate<T>`: `Estimated(value, approximate)` / `NotEstimable(reason, field)`; `EstimateReason`; plausible ranges as `Measure` + `checkRange` (AC4, AC5) |
| `lib/core/metrics/body.dart` | new | `Sex`, `ageFromBirthYear`, `bmi`, `bodyFatNavy`, `leanMass`, `ffmi` (AC1, AC4, AC5) |
| `lib/core/metrics/energy.dart` | new | `BmrFormula`, `Bmr`, `bmr`, `ActivityLevel`, `tdee`, `CalorieTargets`, `calorieTargets`, `proteinRange` (AC2, AC3, AC4) |
| `lib/core/metrics/strength.dart` | new | `LoggedSet(kg, reps, warmup)`, `e1rm`, `bestE1rm`, `volume` (AC6, AC7) |
| `lib/core/metrics/adherence.dart` | new | `DayStatus`, `adherence`, `cycleStreak` (AC8) |
| `lib/core/metrics/projection.dart` | new | `Measurement(date, value)`, sealed `Projection` (onTrack(date) / notEnoughData / notOnTrack), `projectGoal` (AC9) |
| `lib/core/metrics/display.dart` | new | display rounding per metric (AC10) |
| `lib/core/metrics/units.dart` | new | kg↔lb, cm↔in, cm↔ft + in (AC11) |
| `test/core/metrics/*_test.dart` | new | one test file per source file, reference values in each |
| `tool/check_coverage.dart` (+ test) | changed | `--only=<path prefix>` so CI can gate `lib/core/metrics` at 100 % (constraint) |
| `.github/workflows/ci.yml` | changed | second coverage step: `--only=lib/core/metrics --min=100` |
| `pubspec.yaml` | changed | `default-flavor: dev` (carried over from AUTH-01 follow-up) |

## Data

None stored. Constants: activity factors 1.2 / 1.375 / 1.55 / 1.725 / 1.9; cut 0.8, lean bulk
1.1; protein 1.6–2.2 g/kg; Epley cap 12 reps; projection window 4–8 weeks, min 3 points and
14 days, horizon 2 years.

## Key decisions

- **Estimate type (AC5).** Range and consistency checks run before any maths; `log10` only sees
  positive arguments, so NaN and infinity are impossible by construction. Tests assert
  `isFinite` on every `Estimated` value over a sweep of range-edge inputs.
- **Unset sex (AC4).** Compute both sexes and average; `approximate: true`. A female/unset BF %
  needs hip, so missing hip with unset sex → `missing(hip)`.
- **BMR formula (AC2).** Katch–McArdle when a BF % is passed (range-checked), else Mifflin;
  `Bmr.formula` reports which.
- **Adherence denominator (AC8).** Planned training days = done + missed + skipped (skipping a
  workout lowers adherence; moved days count where they land). Rest and pending-today are
  excluded. No planned days → `notEnoughData`.
- **Streak (AC8).** Walk back from today: done/rest +1, skipped/moved +0, missed stops; a
  pending today is skipped over.
- **Projection (AC9).** Ordinary least squares over the measurements in a fixed 8-week window,
  needing at least 3 points spanning 14 days. A slope under 1e-9/day counts as flat; flat or
  moving away → `notOnTrack`; the 2-year horizon is checked in days before any date maths;
  already at/over target → `onTrack(today)`.
- **Rounding (AC10).** Display functions only; nothing in the package rounds stored results.
  Halves round away from zero.
- **Units (AC11).** 1 lb = 0.45359237 kg, 1 in = 2.54 cm (exact definitions).

## Packages

None. `dart:math` only.

## Error handling

- No exceptions for user data; only programmer errors (e.g. negative reps from a bug) assert.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1, AC4, AC5 | `test/core/metrics/body_test.dart`: reference values (calculator-checked), unset sex mean, range edges, waist ≤ neck | unit |
| AC2, AC3, AC4 | `test/core/metrics/energy_test.dart`: Mifflin m/f/unset, Katch switch, TDEE per level, targets, protein | unit |
| AC5 | `test/core/metrics/estimate_test.dart` + range sweeps in body/energy tests (never NaN/∞) | unit |
| AC6, AC7 | `test/core/metrics/strength_test.dart` | unit |
| AC8 | `test/core/metrics/adherence_test.dart` | unit |
| AC9 | `test/core/metrics/projection_test.dart` | unit |
| AC10 | `test/core/metrics/display_test.dart` | unit |
| AC11 | `test/core/metrics/units_test.dart` (round-trip sweep) | unit |
| 100 % | CI coverage step `--only=lib/core/metrics --min=100`; `test/tool/check_coverage_test.dart` for the flag | unit + CI |

## Risks

- Published reference values vary by source rounding; tests use values recomputed from the
  formula definitions and cross-checked against one public calculator, with ±0.1 tolerance.
