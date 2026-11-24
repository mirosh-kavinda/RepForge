# BOD-01: tasks

Plan: ./plan.md · One commit `BOD-01: …` after T5 (no per-task commits).

- [x] T1 Domain model + `computeBodyResults` — test: `body_rules_test.dart` (AC3–AC5, edges)
- [x] T2 Schema v13 → v14; body repository port, Drift impl (replace by date, activity to profile, results JSON), fake — test: `drift_body_repository_test.dart`, `app_database_test.dart` "v13 -> v14" (AC3, AC6–AC8)
- [x] T3 Providers, routes, Body card on Progress, form screen — test: `body_screens_test.dart` "AC1 …"–"AC6 …" (AC1–AC6)
- [x] T4 History + snapshot view with delete / Undo; NFR-06 — test: `body_screens_test.dart` "AC7 …", "NFR-06 …" (AC7)
- [x] T5 Run spec-reviewer against spec.md; fix gaps — fixed: units in words for screen readers (values and fields), Save waits for the profile, card shows nothing while loading and has an open label, "—" body fat in history rows, protein "—" with reason, Undo keeps one row per day, AC2 wording for hip
