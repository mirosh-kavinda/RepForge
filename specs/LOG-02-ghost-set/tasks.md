# LOG-02: tasks

Plan: ./plan.md · One commit `LOG-02: …` after T6 (no per-task commits).

- [x] T1 `session_sets.is_pr`, schema v9 → v10; `history(exerciseId)`; Finish stores PR flags; fake updated — test: `app_database_test.dart` "v9 → v10", `drift_session_repository_test.dart` "LOG-02 …" (AC6, AC8)
- [x] T2 `ghost.dart`: targets (reps, weight step by units, timed, bodyweight, range changed) and PR rule (e1RM, rep PR, first time, order in workout) — test: `test/features/logger/domain/ghost_test.dart` (AC2–AC4, AC6, AC7, edges) (parallel with T1)
- [x] T3 Prefill takes the target first — test: `logger_rules_test.dart` "LOG-02 AC5 …" (AC5)
- [x] T4 Set row ghost and target lines, PR chip, semantics; logger wires history and targets — test: `logger_screen_test.dart` "LOG-02 AC1 …", "AC5 …", "AC6 …", "AC7 …" (AC1, AC5–AC7)
- [x] T5 NFR-06 at 200 % with ghost and PR — test: `logger_screen_test.dart` "LOG-02 NFR-06 …" (NFR-06)
- [ ] T6 Run spec-reviewer against spec.md; fix gaps
