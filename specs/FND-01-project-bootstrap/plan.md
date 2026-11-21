# FND-01: plan

Spec: ./spec.md (approve the spec before building)
Status: Approved

## Approach

Create the Flutter app in the repo root with `flutter create`, add the core packages, lay out
the folders with placeholder files, wire `go_router` with a five-tab `StatefulShellRoute`, set
up `gen-l10n`, and add a GitHub Actions workflow with analysis, tests and a coverage gate.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `pubspec.yaml` | new | deps, `flutter: generate: true` (AC5) |
| `analysis_options.yaml` | new | `flutter_lints` + stricter rules (AC3) |
| `l10n.yaml`, `lib/app/l10n/app_en.arb`, `app_si.arb`, `app_ta.arb` | new | AC5 |
| `lib/main.dart` | new | `ProviderScope` + `RepForgeApp` |
| `lib/app/app.dart` | new | `MaterialApp.router`, l10n delegates |
| `lib/app/router.dart` | new | go_router shell with 5 branches (AC6) |
| `lib/features/*/presentation/*_screen.dart` | new | placeholder screens |
| `lib/{core,data/local,data/remote,data/sync}/.gitkeep` | new | AC2 layout |
| `.github/workflows/ci.yml` | new | AC3, AC4 |
| `tool/check_coverage.dart` | new | filters lcov to domain + core, fails < 80 % (AC4) |
| `test/app/shell_test.dart` | new | AC1 smoke, AC6 |

## Key decisions

- `flutter create --org com.repforge --project-name repforge --platforms android,ios .`, then set
  Android `applicationId`/`namespace` and iOS `PRODUCT_BUNDLE_IDENTIFIER` to `com.repforge.app` (AC1)
- `minSdkVersion 26` in `android/app/build.gradle`; iOS deployment target 15.0 in Podfile (AC1)
- go_router `StatefulShellRoute.indexedStack` keeps each tab's state (AC6)
- Coverage gate is a small Dart script, not a third-party action, so it runs locally too (AC4);
  passes when the filtered set is empty
- Packages added now: flutter_riverpod, riverpod_annotation, go_router, intl;
  dev: riverpod_generator, build_runner, flutter_lints, mocktail. The rest arrive with the
  slice that needs them.

## Test strategy

| AC | Test | Kind |
|---|---|---|
| AC1 | `test/app/shell_test.dart` — app pumps and shows "RepForge" | widget |
| AC2 | manual check + CI `test -d` step | CI |
| AC3, AC4 | CI run on the PR itself | CI |
| AC5 | shell test reads title via `AppLocalizations` | widget |
| AC6 | shell test taps each tab, asserts screen + preserved state | widget |

## Risks

- iOS build can't run on Windows; verify AC1 for iOS on CI (`macos-latest`, `flutter build ios --no-codesign`).
