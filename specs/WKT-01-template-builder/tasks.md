# WKT-01: tasks

Plan: ./plan.md · Batched commit with the next slices (user preference).

- [x] T1 Domain model + rules: limits, defaults, name, supersets link/unlink/normalize, reorder, inner rest, estimate, duplicate name, range swap, weight kg/lb — test: `test/features/workout/domain/template_rules_test.dart` (AC2, AC4–AC8, AC10, edges)
- [x] T2 `workout_templates` table, schema v3 + migration — test: `test/data/local/app_database_test.dart` "WKT-01 v2 → v3" (AC13)
- [x] T3 `DriftTemplateRepository`: save create/update, delete, restore, watchAll order, outbox rows — test: `test/features/workout/data/drift_template_repository_test.dart` (AC11, AC13)
- [x] T4 Starter templates + `ensureStarters` once, flag wiped by sign-out — test: same file "AC12 …", `starter_templates_test.dart` (AC12)
- [x] T5 `watchUnits` + `unitSystemProvider` — test: `drift_onboarding_repository_test.dart` "WKT-01 watchUnits" (AC4)
- [x] T6 Row/rest/weight formatting; `RfStepper.format` — test: `template_format_test.dart`, `rf_stepper_test.dart` "format" (AC4, AC7)
- [x] T7 Exercise picker (screen 04 pick mode) — test: `test/features/library/presentation/exercise_picker_screen_test.dart` (AC3, NFR-06)
- [x] T8 Editor controller + screen 13 + targets sheet + discard prompt — test: `template_editor_screen_test.dart` (AC2, AC4–AC9, NFR-06)
- [x] T9 My workouts list, duplicate, delete + Undo, routes, Schedule entry — test: `workouts_screen_test.dart` (AC1, AC10, AC11)
- [x] T10 Run spec-reviewer against spec.md; fix gaps (typed muscle/equipment search, drag + live-header + router-back tests, not-found copy, weight field keeps stored value and blocks Done while invalid, "+ Add exercise")
