# SET-01: tasks

Plan: ./plan.md · One commit `SET-01: …` after T9 (no per-task commits).

- [x] T1 Plate solver `plates.dart` — test: `test/features/settings/domain/plates_test.dart` (AC6, AC7) (parallel)
- [x] T2 Reminder days `reminder_rules.dart` — test: `test/features/settings/domain/reminder_rules_test.dart` (AC8, edges) (parallel)
- [x] T3 Profile columns, schema v15 → v16; `TrainingSettings`; settings repository (synced columns + `app_meta` prefs) + fake; units provider and theme read it — test: `app_database_test.dart` "v15 -> v16", `test/features/settings/data/drift_settings_repository_test.dart` (AC2–AC5, AC11)
- [x] T4 Template rows take the default rest — test: `template_rules_test.dart` "SET-01 default rest" (AC4)
- [x] T5 `WorkoutReminder` port + local impl + fake; `reminderScheduler` provider; tap → Home — test: `test/features/settings/data/reminder_scheduler_test.dart` (AC8, AC9)
- [x] T6 Profile screen Settings list: units, theme, default rest, plates, reminder entries — test: `test/features/settings/presentation/profile_screen_test.dart` (AC1–AC4, NFR-06)
- [x] T7 Plates screen and reminder screen — test: `plates_screen_test.dart`, `reminder_screen_test.dart` (AC5, AC8, AC10, edge)
- [x] T8 Logger Plates button + sheet — test: `test/features/logger/presentation/plates_sheet_test.dart` (AC6, AC7, NFR-06)
- [ ] T9 Run spec-reviewer against spec.md; fix gaps; docs/architecture.md; set SET-01 Done (manual: reminder fires and its tap opens Home on a phone) — done except the manual phone check (needs a person, cold and warm tap); review fixes: default rest read from the repository stream (unwatched providers are paused), serial reminder replaces, reschedule on resume (time zone), plugin started in main, init retried, theme rolled back on a failed save, exact scheduling when allowed
