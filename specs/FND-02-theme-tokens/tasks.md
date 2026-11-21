# FND-02: tasks

Plan: ./plan.md · One commit per task: `FND-02 Tn: <summary>`

Tokens and theme (T1–T7) come first. The components (T8–T11) depend on them, and T8–T11 can
then run in parallel.

- [ ] T1 Test helpers: `test/helpers/contrast.dart` (WCAG luminance/ratio, checked against known pairs, e.g. #000/#FFF = 21) and `test/helpers/pump_themed.dart` — test: `test/helpers/contrast_test.dart` (AC3 groundwork)
- [ ] T2 `RfColors` dark + light, `RfRole` lookups, `copyWith`/`lerp` — test: `test/app/theme/rf_tokens_test.dart` "AC1 dark matches design.md", "AC2 light matches design.md", "AC2 same field set" (AC1, AC2)
- [ ] T3 Contrast proof for every allowed pair in both themes — test: `test/app/theme/contrast_test.dart` "AC3 text ≥ 4.5", "AC3 borders/icons ≥ 3" (AC3)
- [ ] T4 (parallel) `RfSpace`, `RfRadius`, `RfSize.minTarget` — test: `test/app/theme/rf_scales_test.dart` "AC7" (AC7)
- [ ] T5 (parallel) Bundle fonts and OFL licences in `assets/fonts/`, `pubspec.yaml` `fonts:`; `RfTextStyles` with weight variation and tabular figures — test: `test/app/theme/rf_typography_test.dart` "AC5 scale", "AC5 tnum", "AC6 fonts bundled and load" (AC5, AC6)
- [ ] T6 `rfTheme(Brightness)` (ColorScheme mapping, textTheme, extensions, padded targets); `AppThemeMode` notifier; wire into `app.dart`; run codegen — test: `test/app/theme/theme_mode_test.dart` "AC4 default System", "AC4 follows OS", "AC4 set light/dark", "AC4 state kept on switch" (AC4)
- [ ] T7 Guard against hard-coded styles outside `lib/app/theme/` — test: `test/app/theme/no_hardcoded_style_test.dart` (AC1 rule)
- [ ] T8 (parallel) RfButton: primary/secondary/ghost, lg/md, pressed −8 %, disabled 40 %, loading — test: `test/app/widgets/rf_button_test.dart` "AC8 …" (AC8)
- [ ] T9 (parallel) RfStepper: step math without float noise, bounds, haptics, long-press repeat, adjustable semantics; ARB strings — test: `test/app/widgets/rf_stepper_test.dart` "AC9 …" (AC9)
- [ ] T10 (parallel) RfChip filter + status — test: `test/app/widgets/rf_chip_test.dart` "AC10 …" (AC10)
- [ ] T11 (parallel) RfDayTile: five states, ARB labels, dashed planned border — test: `test/app/widgets/rf_day_tile_test.dart` "AC11 …" (AC11)
- [ ] T12 Accessibility sweep: all four components × both themes × 1.0/2.0 text scale on 360 dp; tap-target, label and contrast guidelines; no overflow — test: `test/app/widgets/a11y_test.dart` "AC12" (AC12)
- [ ] T13 Device check: profile build on the Android phone in light and dark mode; confirm font weights render and record a screenshot note in the PR (AC4, AC5, AC6)
- [ ] T14 Run spec-reviewer against spec.md; fix gaps; set spec Status: Done; update docs/requirements.md
