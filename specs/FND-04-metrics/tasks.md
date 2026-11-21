# FND-04: tasks

Plan: ./plan.md · One commit for the slice once integrated (user preference).

- [x] T1 `Estimate`, reasons, ranges — test: `test/core/metrics/estimate_test.dart` (AC5)
- [x] T2 Body: age, BMI, Navy BF %, LBM, FFMI, unset-sex mean — test: `body_test.dart` (AC1, AC4, AC5)
- [x] T3 Energy: BMR (Mifflin / Katch), TDEE, calorie targets, protein — test: `energy_test.dart` (AC2, AC3, AC4) (parallel)
- [x] T4 Strength: e1RM, best e1RM, volume — test: `strength_test.dart` (AC6, AC7) (parallel)
- [x] T5 Adherence + cycle streak — test: `adherence_test.dart` (AC8) (parallel)
- [x] T6 Goal projection — test: `projection_test.dart` (AC9) (parallel)
- [x] T7 Display rounding + unit conversion — test: `display_test.dart`, `units_test.dart` (AC10, AC11) (parallel)
- [x] T8 `check_coverage --only=`; CI gate metrics at 100 % — test: `test/tool/check_coverage_test.dart` (constraint)
- [x] T9 Run spec-reviewer against spec.md; fix gaps; spec Status: Done; update docs/requirements.md
