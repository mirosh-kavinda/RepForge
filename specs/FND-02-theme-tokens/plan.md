# FND-02: plan

Spec: ./spec.md (Approved)
Status: Approved

## Approach

All design values live in `lib/app/theme/`. Colours are a `ThemeExtension<RfColors>` with a
`dark` and a `light` const instance, and the text scale is a `ThemeExtension<RfTextStyles>`.
Spacing and radius are plain const classes. `rfTheme(Brightness)` builds `ThemeData` from them,
and a Riverpod notifier holds the theme mode (System by default). The four core components go
in `lib/app/widgets/` and read only from these tokens. Fonts are bundled as assets.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/app/theme/rf_tokens.dart` | new | `RfColors` extension: `dark`, `light`, `copyWith`, `lerp`, `RfRole` (action/success/rest/missed) with fill/ink/tint/onTint lookups (AC1, AC2, AC10, AC11) |
| `lib/app/theme/rf_scales.dart` | new | `RfSpace` (s4…s32), `RfRadius` (xs, sm, md, lg, pill), `RfSize.minTarget = 48` (AC7, AC12) |
| `lib/app/theme/rf_typography.dart` | new | `RfTextStyles` extension: statXl, title, heading, button, body, label, labelStrong, overline (AC5, AC6) |
| `lib/app/theme/rf_theme.dart` | new | `ThemeData rfTheme(Brightness)`: ColorScheme mapped from tokens, textTheme, extensions, `MaterialTapTargetSize.padded` (AC1, AC2, AC12) |
| `lib/app/theme/theme_mode.dart` (+ `.g.dart`) | new | `@riverpod class AppThemeMode`: default `ThemeMode.system`, `set(mode)` (AC4) |
| `lib/app/app.dart` | changed | `theme`/`darkTheme` from `rfTheme`, `themeMode` from the provider (AC4) |
| `lib/app/widgets/rf_button.dart` | new | primary / secondary / ghost; lg / md; pressed, disabled, loading (AC8, AC12) |
| `lib/app/widgets/rf_stepper.dart` | new | −/+ with step, min, max, formatting, haptics, long-press repeat, adjustable semantics (AC9, AC12) |
| `lib/app/widgets/rf_chip.dart` | new | `RfChip.filter` and `RfChip.status(role)` (AC10, AC12) |
| `lib/app/widgets/rf_day_tile.dart` | new | five states, text label, dashed border painter for planned (AC11, AC12) |
| `lib/app/l10n/app_en.arb` | changed | day-state labels, stepper semantics ("Decrease", "Increase", "at minimum"), loading label (AC9, AC11, AC12) |
| `assets/fonts/SpaceGrotesk[wght].ttf`, `Inter[opsz,wght].ttf`, `OFL-*.txt` | new | bundled fonts from google/fonts, with their licences (AC6) |
| `pubspec.yaml` | changed | `fonts:` families `SpaceGrotesk`, `Inter` (AC6) |
| `test/helpers/contrast.dart` | new | WCAG relative luminance and contrast ratio (test-only) (AC3) |
| `test/helpers/pump_themed.dart` | new | pumps a widget in either theme, at a given text scale and screen size (AC12) |

## Data

None. The theme mode is in memory only; SET-01 persists it.

## Key decisions

- `docs/design.md` is the only source of hex values. The token test parses its tables, so a
  doc change without a code change fails CI (AC1, AC2).
- Hex literals are allowed only in `lib/app/theme/`. A test scans `lib/**` for `Color(0x`,
  `Colors.` and `fontSize:` outside the theme folder (CLAUDE.md UI rule; AC1).
- `RfColors` field names follow docs/design.md: bg, navBar, surface, divider, border,
  textPrimary, textSecondary, textMuted, onSolid, and per role `<role>Fill`, `<role>Ink`,
  `<role>Tint`, `<role>OnTint`, plus successBorder. Both themes define every field (AC2).
- ColorScheme mapping: primary = actionFill, onPrimary = onSolid, surface = surface,
  onSurface = textPrimary, outline = border, error = missedFill. Stock Material widgets then
  match the brand (AC1, AC2).
- Fonts are the variable files as published. Every style sets `fontWeight` and
  `fontVariations: [FontVariation('wght', w)]`, because Flutter does not map weight to a
  variable axis on its own. Every style also sets `fontFeatures: [FontFeature.tabularFigures()]`
  (AC5, AC6). Both fonts were checked: each has `tnum`.
- Theme mode is a `riverpod_generator` notifier. `MaterialApp.theme`/`darkTheme` switch through
  the framework, so widget state survives a switch (AC4, edge case).
- RfButton wraps Material `ButtonStyleButton`s. A `WidgetStateProperty` gives pressed = HSL
  lightness −0.08 and disabled = 40 % opacity. Loading shows a spinner beside the kept label,
  with `onPressed` null and semantics "loading" (AC8).
- RfStepper keeps the value as an integer count of steps from min (`value = min + n·step`), and
  formats with `NumberFormat` at the step's decimal places, so no float noise. Long-press uses
  `Timer.periodic(120 ms)` after a 400 ms hold and cancels on release or at a bound. Each step
  calls `HapticFeedback.selectionClick`. `Semantics(value, increasedValue, decreasedValue,
  onIncrease, onDecrease)` makes it adjustable for TalkBack and VoiceOver (AC9).
- md buttons (44 high) and the stepper's 44 × 44 buttons get a 48 × 48 hit area through
  padded tap targets and `ConstrainedBox(minWidth/minHeight: 48)` (AC12).
- RfDayTile always renders its state word (Done, Today, Rest, Missed, Planned) from the ARB.
  Today has a 2 px Ember border, and planned has a dashed `border` drawn by a small CustomPainter
  (AC11).

## Packages

- None new. Fonts are bundled assets (not `google_fonts`, which fetches at runtime and breaks
  offline first launch, AC6). `intl` (already present) formats stepper values.

## Error handling

- RfStepper asserts `min < max`, `step > 0` and an initial value on the step grid in debug, and
  clamps in release.
- A missing font asset fails the AC6 test, not silently at runtime.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1, AC2 | `test/app/theme/rf_tokens_test.dart`: parses docs/design.md tables and compares both themes; checks the same field set | unit |
| AC1 rule | `test/app/theme/no_hardcoded_style_test.dart`: scans `lib/` outside `theme/` | unit |
| AC3 | `test/app/theme/contrast_test.dart`: every allowed pair, both themes; ≥ 4.5 text, ≥ 3 borders/icons | unit |
| AC4 | `test/app/theme/theme_mode_test.dart`: default System; `platformBrightnessTestValue` flip; `set(light/dark)`; TextField text kept across a switch | widget |
| AC5, AC6 | `test/app/theme/rf_typography_test.dart`: family, weight, size, tnum per style; font assets exist and load via `FontLoader` | unit + widget |
| AC7 | `test/app/theme/rf_scales_test.dart` | unit |
| AC8 | `test/app/widgets/rf_button_test.dart` | widget |
| AC9 | `test/app/widgets/rf_stepper_test.dart`: taps, bounds, 0.1 / 2.5 formatting, haptic channel calls, long-press with `pump(Duration)`, semantics actions | widget |
| AC10 | `test/app/widgets/rf_chip_test.dart` | widget |
| AC11 | `test/app/widgets/rf_day_tile_test.dart` | widget |
| AC12 | `test/app/widgets/a11y_test.dart`: all four components × both themes × 1.0/2.0 text scale on a 360 dp screen; `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`; no exceptions | widget |

## Risks

- Variable-font weight: if `FontVariation` is not applied, text renders at the default weight.
  The typography test asserts the `wght` variation on each style, and the first build is
  checked on the device.
- Inter's variable file adds about 0.9 MB to the app. Acceptable for now; it can be cut later
  with fontTools if size matters.
- `textContrastGuideline` cannot see through overlays or opacity. AC3's unit test is the real
  contrast proof, and the guideline is a backstop.
- Parsing docs/design.md couples the test to the table format. A rename of a table row breaks
  the test on purpose, so the doc and code stay in step.
