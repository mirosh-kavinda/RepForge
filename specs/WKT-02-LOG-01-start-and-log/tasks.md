# WKT-02 + LOG-01: tasks

Plan: ./plan.md · One commit `WKT-02, LOG-01: …` after T9 (no per-task commits).

- [x] T1 `workout_sessions`, `session_sets`, schema v8 → v9; `WorkoutSession`, `SessionExercise`, `LoggedSet` — test: `app_database_test.dart` "v8 → v9" (AC8, AC9)
- [x] T2 `logger_rules.dart`: prefill order, weight / reps steps by units, kg ↔ display round-trip, add / swap exercise on the copy, + Set — test: `test/features/logger/domain/logger_rules_test.dart` (AC2–AC4, AC6, AC7, edges) (parallel with T1)
- [x] T3 Session repository: start (copy), watchActive, log / update / delete set, add set / exercise, swap, lastSets, discard, finish (session + one outbox row + today done, one transaction); wipe — test: `test/features/logger/data/drift_session_repository_test.dart` incl. "NFR-01 set write < 50 ms", "NFR-10 one outbox row on Finish" (AC5–AC10)
- [x] T4 Route `/workout`; Home Start workout / Resume workout — test: `today_card_test.dart` "WKT-02 AC1 …", "AC8 …" (AC1, AC8)
- [x] T5 Logger screen: exercise cards, set rows prefilled, steppers, Log in one tap, Done in text — test: `test/features/logger/presentation/logger_screen_test.dart` "LOG-01 AC2 …" … "AC4 …" (AC2–AC4)
- [x] T6 Edit / delete a logged set; + Set; add / swap exercise via picker — test: `logger_screen_test.dart` "AC5 …", "AC6 …", "AC7 …" (AC5–AC7)
- [x] T7 Finish (needs a set; marks today done; back to Home Done); Discard with confirm; failure snackbar — test: `logger_screen_test.dart` "AC9 …", "AC8 discard …", "edge …" (AC8, AC9)
- [x] T8 NFR-06 at 200 %; bodyweight, lb display; docs/architecture.md session tables — test: `logger_screen_test.dart` "NFR-06 …", "edge bodyweight …", "edge lb …" (NFR-06, edges)
- [x] T9 Run spec-reviewer against spec.md; fix gaps
