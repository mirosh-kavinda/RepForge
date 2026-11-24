# PRG-02: tasks

Plan: ./plan.md · One commit `PRG-02: …` after T7 (no per-task commits).

- [x] T1 Metrics: `DayStatus.unplannedRest` (neutral, not planned) and `bestCycleStreak` — test: `test/core/metrics/adherence_test.dart` "PRG-02 …" (AC2, AC4)
- [x] T2 `adherence_rules.dart`: `dayHistory` (one status per date, two cycles, today pending / rest, mapping) and `adherenceSummary` (%, done of planned, weekly %, missed + skipped newest first) — test: `test/features/progress/domain/adherence_rules_test.dart` (AC2–AC7, edges)
- [x] T3 Providers: `statusHistoryProvider`, `streakProvider`, `adherenceProvider` on the PRG-01 range — test: `test/features/progress/data/adherence_providers_test.dart` "AC9 skipping today updates" (AC4, AC9)
- [x] T4 Bar chart weeks with no value (no rod, "No training planned" tooltip) — test: `test/features/progress/presentation/progress_charts_test.dart` "PRG-02 AC5 …" (AC5, AC8) (parallel)
- [x] T5 Home streak chip; tap opens Progress — test: `test/features/home/presentation/streak_chip_test.dart` (AC1, AC9, NFR-06)
- [x] T6 Adherence card above Strength: %, "18 of 20", current / best streak, weekly bars, missed list with Show all, screen-reader summary — test: `test/features/progress/presentation/adherence_section_test.dart` (AC3–AC8, NFR-06)
- [x] T7 Run spec-reviewer against spec.md; fix gaps; docs/architecture.md note; set PRG-02 Done
