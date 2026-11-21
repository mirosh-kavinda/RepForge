# FND-01: tasks

Plan: ./plan.md · One commit per task: `FND-01 Tn: <summary>`

- [x] T1 `flutter create` in repo root (org com.repforge, android + ios); set minSdk 26, iOS 15 — test: `flutter run` on emulator (AC1)
- [x] T2 Add packages and `analysis_options.yaml`; `flutter analyze` clean (AC3)
- [x] T3 Create folder layout from docs/architecture.md with placeholders (AC2)
- [x] T4 l10n: `l10n.yaml`, en/si/ta ARB files, app title from ARB — test: `test/app/shell_test.dart` "AC5" (AC5)
- [x] T5 go_router shell with 5 tabs and placeholder screens — test: shell_test "AC6" (AC1, AC6)
- [x] T6 `tool/check_coverage.dart` coverage gate — test: run locally on sample lcov (AC4)
- [x] T7 `.github/workflows/ci.yml`: analyze, test --coverage, coverage gate, iOS no-codesign build (AC3, AC4)
- [x] T8 Record cold-start baseline on a profile build in docs/roadmap.md notes (NFR-01)
- [x] T9 Run spec-reviewer against spec.md; fix gaps; set spec Status: Done
