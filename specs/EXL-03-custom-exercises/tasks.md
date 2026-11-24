# EXL-03: tasks

Plan: ./plan.md · One commit `EXL-03: …` after T8 (no per-task commits).

- [x] T1 `custom_exercises` table, schema v12 → v13; `Exercise.custom` / `notes` — test: `app_database_test.dart` "v12 -> v13" (AC1, AC8)
- [x] T2 `custom_rules.dart`: name cleaning / key, save rule, query matching — test: `custom_rules_test.dart` (AC2, AC3) (parallel with T1)
- [x] T3 Custom repository port + Drift impl (save, delete, restore, nameClash incl. catalog, watchAll) + fake — test: `drift_custom_exercise_repository_test.dart` (AC1, AC2, AC6–AC8)
- [x] T4 Combined catalog + providers — test: `combined_catalog_test.dart` (AC3, AC7, NFR-01)
- [x] T5 Form screen + routes — test: `custom_exercise_form_test.dart` (AC1, AC2, AC6)
- [x] T6 Library: New exercise, live rerun, "Custom" meta; detail: custom view, Edit, Delete + Undo — test: `library_screen_test.dart`, `exercise_detail_screen_test.dart` "EXL-03 …" (AC3, AC5–AC7)
- [x] T7 Picker: "Custom" meta, no results → New exercise prefilled; docs/architecture.md — test: `exercise_picker_screen_test.dart` "EXL-03 …" (AC3, AC4)
- [x] T8 Run spec-reviewer against spec.md; fix gaps — fixed: Schedule muscles follow edits, chips read "main" / "other", Undo errors reported, outbox entity `customExercise`, catalog clash uses `nameKey`; added tests for deleted / edited exercises in workouts, template builder name, notes cap, Body only, Recent, Drift-backed speed
