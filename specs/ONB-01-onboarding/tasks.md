# ONB-01: tasks

Plan: ./plan.md · Commits are batched across slices (user preference).

- [x] T1 `UnitSystem` + region default — test: `test/core/metrics/units_test.dart` "AC4 …" (AC4)
- [x] T2 Domain: answers, goal/level enums, validation — test: `answer_validation_test.dart` (AC3–AC5)
- [x] T3 Tables `user_profiles`, `body_snapshots`; schema v2 + migration — test: `app_database_test.dart` "v1 → v2" (AC6)
- [x] T4 Repository: Finish transaction, done flag, watch — test: `drift_onboarding_repository_test.dart` (AC6, edge)
- [x] T5 Gate + routes + providers; test helpers learn the onboarded gate — test: `router_auth_gate_test.dart` (AC1, AC2)
- [x] T6 Welcome screen — test: `welcome_screen_test.dart` (AC1)
- [x] T7 Controller + goal/level screen — test: `onboarding_flow_test.dart` (AC3, AC7, AC8)
- [x] T8 About-you screen (units, sex, birth year, height, weight, Finish) — test: `onboarding_flow_test.dart` (AC4–AC6, AC9, NFR-06)
- [x] T9 Run spec-reviewer against spec.md; fix gaps; spec Status: Done; update docs/requirements.md
