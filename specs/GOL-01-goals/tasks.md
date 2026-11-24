# GOL-01: tasks

Plan: ./plan.md · One commit `GOL-01: …` after T8 (no per-task commits).

- [x] T1 `goals` table, schema v14 → v15; `Goal` model; `GoalRepository` port + `DriftGoalRepository` (save, pin clears others, achieve, delete / restore, outbox) + fake — test: `app_database_test.dart` "v14 -> v15", `test/features/goals/data/drift_goal_repository_test.dart` (AC7–AC10, AC12)
- [x] T2 `goal_rules.dart`: history, current, validateTarget, progress, projection, pace, reachedOn, homeGoal — test: `test/features/goals/domain/goal_rules_test.dart` (AC2–AC7, AC10, edges) (parallel with T1)
- [x] T3 Providers: goals, per-goal status, `goalSettler` (auto-achieve + unpin), home goal — test: `test/features/goals/data/goal_settler_test.dart` (AC6, AC10)
- [x] T4 Routes + Goals screen: active and Achieved lists, rows with progress / projection / pace, pin, mark achieved, delete + Undo; Goals entry on Progress — test: `test/features/goals/presentation/goals_screen_test.dart` (AC1, AC4, AC5, AC7, AC9)
- [x] T5 Goal form (new / edit): type, lift picker, target in display unit, deadline, live projection, validation — test: `test/features/goals/presentation/goal_form_screen_test.dart` (AC2, AC3, AC8, AC11)
- [x] T6 Home goal card / "Set a goal" link — test: `test/features/goals/presentation/goal_card_test.dart` (AC10, NFR-06)
- [x] T7 NFR-06 pass on the goal screens (200 %, 48 dp, semantics); docs/architecture.md — test: NFR-06 cases in the T4–T6 files
- [x] T8 Run spec-reviewer against spec.md; fix gaps; set GOL-01 Done
