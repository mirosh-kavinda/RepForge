# FND-03: tasks

Plan: ./plan.md · One commit for the slice once integrated (user preference).

- [x] T1 Add drift, drift_flutter, uuid, drift_dev; spike: an in-memory Drift DB creates an FTS5 table under `flutter test` — test: `test/data/local/fts5_smoke_test.dart` (risk check)
- [x] T2 `newId()` UUID v7 — test: `test/core/ids_test.dart` "AC7 v7, unique, time-ordered" (AC7)
- [x] T3 Pin the source in `tool/seed/source/` with SOURCE.md; `seed_builder.dart` mapping + errors — test: `test/tool/seed_builder_test.dart` "AC1 …", "AC2 …" (AC1, AC2)
- [x] T4 `tool/build_exercise_seed.dart` CLI; generate and commit `assets/exercises/seed.json` — test: seed_builder_test "AC1 committed seed equals rebuild" (AC1)
- [x] T5 Domain: `Exercise`, taxonomy enums, `ExerciseQuery`, repository interface — test: `test/features/library/domain/exercise_test.dart` (AC4, AC5)
- [x] T6 `AppDatabase` schema (catalog, muscles, FTS5, app_meta, outbox) + `SyncedTable` mixin; codegen — test: `test/data/local/app_database_test.dart` "schema v1" (AC7)
- [x] T7 `SyncedWriter` (write, soft delete, outbox in one transaction) with a test-only table — test: `test/data/sync/synced_writer_test.dart` "AC7 …", "AC8 …" (AC7, AC8)
- [x] T8 `CatalogImporter` first import + crash safety + version upgrade/retire — test: `test/features/library/data/catalog_importer_test.dart` "AC3 …", "AC9 …" (AC3, AC9)
- [x] T9 `DriftExerciseCatalogRepository` search + filters + ranking — test: `test/features/library/data/exercise_search_test.dart` "AC4 …", "AC5 …", "AC6 desktop smoke" (AC4, AC5, AC6)
- [x] T10 Providers + non-blocking import from `main`; catalog status — test: `test/features/library/data/catalog_status_test.dart` "AC10 …"; shell tests still green (AC10)
- [x] T11 On device: `integration_test/fnd03_search_perf_test.dart` p95 < 100 ms; cold start re-measured on profile build, noted in docs/roadmap.md (AC6, AC10, NFR-01)
- [x] T12 Run spec-reviewer against spec.md; fix gaps; spec Status: Done; update docs/requirements.md
