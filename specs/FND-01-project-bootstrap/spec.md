# FND-01: Project bootstrap and CI

Status: Draft
Phase: P1 · Priority: MVP · Screens: none (app shell only)

## Why

Every later slice needs a running app, the agreed folder layout and a CI gate, so quality rules
are enforced from the first commit instead of retrofitted.

## User stories

- As the developer, I can clone the repo, run one command and see the app on an Android
  emulator and an iOS simulator.
- As the developer, every push and PR is checked automatically for analysis errors, failing
  tests and coverage drops.

## Acceptance criteria

- **AC1** — Given a fresh clone, when I run `flutter pub get` then `flutter run`, then the app
  launches on Android (API 26+) and iOS (15+) and shows a placeholder shell titled "RepForge".
- **AC2** — Given the repo, when I list `lib/`, then it matches the layout in
  docs/architecture.md (app, core, data/{local,remote,sync}, features/*).
- **AC3** — Given any push or PR to `main`, when CI runs, then it executes `flutter analyze`,
  `flutter test --coverage` and fails if analysis has any issue or any test fails.
- **AC4** — Given CI, when coverage for `lib/core/**` and `lib/features/*/domain/**` is below
  80 %, then the job fails (gate enabled, initially over an empty set).
- **AC5** — Given the app, when it starts, then strings come from ARB files (`lib/app/l10n/`),
  English only, with Sinhala and Tamil files present but empty.
- **AC6** — Given the bottom navigation shell, when I tap Home, Schedule, Library, Progress or
  Profile, then the matching placeholder screen shows and the tab state is kept.

## Edge cases

- Package name and bundle ID chosen once and not changed later (store identity).
- CI must not need Firebase secrets to pass.

## Constraints

- NFR-07 Android 8+ / iOS 15+.
- NFR-08 coverage gate.
- NFR-11 ARB localisation.
- NFR-01 cold start < 2 s measured on a profile build (record baseline only).

## Non-goals

- Firebase project wiring (AUTH-01), theme tokens (FND-02), database (FND-03).
- Release signing and store listings.

## Data touched

- None.

## Open questions

- Bundle ID / application ID (proposal: `com.repforge.app`).
- Org name for `flutter create --org`.
