# SYN-02: tasks

Plan: ./plan.md · One commit `SYN-02: …` after T8 (no per-task commits).

- [x] T1 RemoteStore: `summary`, `count`, paged `changedSince` with a (syncedAt, id) cursor; fake + Firestore — test: used by T2 (fake), analyze (AC1, AC3, AC8)
- [x] T2 Engine: ordered, paged pull with per-page cursor; restore state + progress in `app_meta`; `startFresh`; `offer` — test: `test/data/sync/restore_test.dart` (AC2, AC6, AC8, edges)
- [x] T3 Pull only after the choice (gated in the engine's pull, so the scheduler is unchanged); push always — test: `sync_scheduler_test.dart` (AC6, AC7)
- [x] T4 Providers + `RestoreController` (restore essentials, start fresh) — test: `restore_test.dart` "controller …" (AC2, AC5, AC6)
- [x] T5 Restore card on Account (09b), offline message, onboarding skip — test: `test/features/auth/presentation/restore_card_test.dart` (AC1, AC2, AC5, AC10)
- [x] T6 Progress on Home and Backup and sync — test: `backup_screen_test.dart`, `restore_card_test.dart` "Home …" (AC3)
- [x] T7 AC4 time budget for 2 years; AC9 stats from restored data — test: `restore_test.dart` (AC4, AC9)
- [ ] T8 Run spec-reviewer against spec.md; fix gaps; docs/architecture.md; set SYN-02 Done (manual: 4G restore on a phone) — reviewed; gaps fixed (AC6/AC9 tests in `restore_match_test.dart`, push gate documented, spec wording for AC1, AC10, Start fresh after sign-out); Done waits on the manual 4G restore on a phone
