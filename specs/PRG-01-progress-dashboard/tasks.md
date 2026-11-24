# PRG-01: tasks

Plan: ./plan.md · One commit `PRG-01: …` after T5 (no per-task commits).

- [x] T1 `progress_rules.dart`: ranges, strength series + summary, weekly volume, body trends — test: `progress_rules_test.dart` (AC1–AC5, edges)
- [x] T2 Session reads `exerciseSetCounts`, `finishedSetsSince`, `exerciseLog(limit: null)` + fake — test: `drift_session_repository_test.dart` "PRG-01 …"
- [x] T3 Providers (range, remembered exercise, series) — test: covered by T4 widget tests
- [x] T4 Progress screen: range switch, Strength / Volume / Body trends sections, Change exercise, text summaries — test: `progress_screen_test.dart` (AC1–AC7, NFR-06)
- [x] T5 Run spec-reviewer against spec.md; fix gaps
