# SYN-01: tasks

Plan: ./plan.md · One commit `SYN-01: …` after T9 (no per-task commits).

- [x] T1 `RemoteStore` port + in-memory fake — test: used by T3–T5 (no own test)
- [x] T2 Codecs for every synced entity (profile with body split, sessions with sets) — test: `test/data/sync/sync_codecs_test.dart` round trips (AC3, AC7)
- [x] T3 Engine push: coalesce, order by seq, batches ≤ 500, clear on success, keep on failure, body-off skip — test: `test/data/sync/sync_engine_test.dart` "push …", "30 days offline" (AC1–AC3, AC7, AC11, edges)
- [x] T4 Engine pull: per collection since last pull, newer-wins, pending local kept, sessions insert-only, deletes — test: `sync_engine_test.dart` "pull …" (AC4, AC5, AC11)
- [x] T5 Status in `app_meta` + scheduler (debounce, connectivity, resume, 6 h, sign-in, backoff 30 s → 1 h, canBackUp gate) — test: `test/data/sync/sync_scheduler_test.dart` (AC1, AC4, AC6, AC8, AC10)
- [x] T6 Firestore impl + `cloud_firestore`; start in `main.dart`; body backup switch re-queues body records — test: analyze; manual with a test project (AC7) — manual check with a real Firebase project still open
- [x] T7 Backup and sync screen + Profile row — test: `test/features/settings/presentation/backup_screen_test.dart` (AC9, AC10, NFR-06)
- [x] T8 Firestore rules per collection, sessions create-only — test: `test/firestore_rules/` emulator (NFR-04, AC5)
- [ ] T9 Run spec-reviewer against spec.md; fix gaps; docs/architecture.md; set SYN-01 Done — reviewed; gaps fixed (see plan "Review follow-ups"); Done waits on the T6 manual check with a real Firebase project
