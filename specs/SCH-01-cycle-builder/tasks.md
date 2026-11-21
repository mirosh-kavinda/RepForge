# SCH-01: tasks

Plan: ./plan.md · Batched commit with WKT-01 and the next slices (user preference).

- [x] T1 Domain: `Cycle`, rules (limits, save problem, counts, edits, calendar day, today index, re-anchor, preview) — test: `test/features/schedule/domain/cycle_rules_test.dart` (AC1–AC4, AC7, AC8, edges)
- [x] T2 Starter plans + `buildPlan` — test: `starter_plans_test.dart` (AC10, edge)
- [x] T3 `cycles` table v4; `DriftCycleRepository` (save, one active, delete guard, restore, outbox); clock provider — test: `drift_cycle_repository_test.dart`, `app_database_test.dart` "v3 → v4" (AC5, AC9, AC13)
- [x] T4 Builder: controller, screen 18, day tile, workout pick sheet, discard — test: `cycle_editor_screen_test.dart` (AC1–AC5, AC8, AC11, AC12, NFR-06)
- [x] T5 Schedule screen 03, My cycles, Home day line, routes — test: `schedule_screen_test.dart` (AC6, AC7, AC9)
- [x] T6 Onboarding step 3 + step 2 Continue — test: `onboarding_flow_test.dart` (AC10, ONB-01 AC6/AC7)
- [ ] T7 Run spec-reviewer against spec.md; fix gaps
