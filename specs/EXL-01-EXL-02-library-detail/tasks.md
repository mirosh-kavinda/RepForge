# EXL-01, EXL-02: tasks

Plan: ./plan.md · One commit `EXL-01, EXL-02: …` after T7 (no per-task commits).

- [x] T1 Session repository `recentExerciseIds`, `exerciseLog`; providers incl. best e1RM; fake — test: `drift_session_repository_test.dart` "EXL-01 AC1 …", "EXL-02 AC7 …" (AC1, AC7)
- [x] T2 `addToTemplate` rule — test: `template_rules_test.dart` "EXL-02 AC8 …" (AC8) (parallel with T1)
- [x] T3 `cached_network_image`; `exercise_images.dart` URL + overridable provider — test: `exercise_images_test.dart` (AC6) (parallel with T1)
- [x] T4 Extract search + filters from the picker; picker unchanged — test: existing `exercise_picker_screen_test.dart` stays green (AC9)
- [x] T5 Library screen: Recent + A–Z, search, filters, no match, rows → detail route — test: `library_screen_test.dart` "AC1 …"–"AC4 …", "NFR-06 …" (AC1–AC4, NFR-06)
- [x] T6 Detail screen: info, steps, pictures (cached / placeholder / none), history, Add to workout sheet; docs/architecture.md — test: `exercise_detail_screen_test.dart` "AC5 …"–"AC8 …", edges, "NFR-06 …" (AC5–AC8)
- [x] T7 Run spec-reviewer against spec.md; fix gaps — fixed: Recent is a watched query (updates after Finish), name as a wrapping heading in the body, failed template read shows no workouts, limit in the full message, Epley ranking for best set, date example; added tests for loaded / failed pictures, long names, history failure, full workout, filter-only, swapped row
