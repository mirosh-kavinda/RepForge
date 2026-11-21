# RepForge — project constitution

Offline-first Flutter gym app: rolling training cycles, two-tap set logging with Ghost Sets,
Body Snapshot metrics, goals, Firebase backup. Product detail lives in `docs/`, not here.

## How we work: spec-driven development

The spec is the source of truth. If code and spec disagree, fix the code. If a requirement
changes, change the spec first.

1. **Spec** — `specs/<ID>-<slug>/spec.md`: what and why. User story, acceptance criteria as
   Given / When / Then, edge cases, non-goals. No tech choices.
2. **Plan** — `specs/<ID>-<slug>/plan.md`: how. Files touched, data, packages, decisions, each
   pointing back to an AC.
3. **Tasks** — `specs/<ID>-<slug>/tasks.md`: numbered, small, each names the test that proves it.
4. **Build** — in a fresh session, one task at a time: write the failing test, make it pass,
   tick the task, commit.
5. **Review** — run the `spec-reviewer` agent against `spec.md` before opening a PR.

Rules:
- Never start code for a requirement without an approved `spec.md` (status: Approved).
- Spec one vertical slice at a time. Do not write plans or tasks for slices not yet started.
- Requirement IDs (AUTH-01, SCH-02, LOG-02 …) are the shared vocabulary: use them in specs,
  test names, commit messages and PR titles. Index: `docs/requirements.md`.
- When a slice ships, update its row in `docs/requirements.md`.

## Commands

- Analyze: `flutter analyze` (must be clean)
- Test: `flutter test` · coverage: `flutter test --coverage`
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Integration: `flutter test integration_test`

## Architecture rules (detail: docs/architecture.md)

- Feature-first Clean Architecture: `lib/features/<feature>/{domain,data,presentation}`.
  `domain/` has no Flutter or Firebase imports.
- Offline-first: the UI never waits on the network. Every write goes to Drift first and adds
  an outbox row in the same transaction. Firestore is backup and cross-device copy only.
- State and DI: Riverpod (`riverpod_generator`). Do not introduce another state library.
- Navigation: `go_router`. Models: `freezed` + `json_serializable`. Local DB: `drift`.
- Store metric units only (kg, cm); convert for display.
- IDs are UUID v7 made on device; every record has `updatedAt`, `deletedAt`, `syncState`.
- Sessions are append-only; one Firestore write per finished workout (never per set).
- Body/fitness formulas live only in `lib/core/metrics/`, pure Dart, 100% unit-tested.

## UI rules (detail: docs/design.md)

- All colour, type, radius and spacing come from `lib/app/theme/` (`RfColors` ThemeExtension).
  No hard-coded hex values or font sizes in widgets.
- Dark and light themes share token names; default theme mode is System.
- Touch targets ≥ 48 dp, text scales to 200 %, semantics labels on every control,
  status never shown by colour alone. Numbers use tabular figures.

## Never

- Never edit `*.g.dart`, `*.freezed.dart` or `*.drift.dart`; regenerate them.
- Never put health or body data in analytics events.
- Never commit `google-services.json`, `GoogleService-Info.plist` secrets, keystores or `.env`.
- Never widen Firestore rules beyond `users/{uid}/**` (owner) and read-only `catalog/**`.
