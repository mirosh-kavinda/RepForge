# FND-03: plan

Spec: ./spec.md (Approved)
Status: Approved

## Approach

A Dart build script turns a pinned copy of Free Exercise DB into `assets/exercises/seed.json`,
and the mapping logic is pure and unit-tested. The app opens one Drift database (`AppDatabase`)
with the catalog table, a muscle join table, an FTS5 name index, app metadata and the outbox. On
first launch an importer loads the seed in one transaction off the UI isolate; later launches
compare catalog versions and upsert only changed rows. User-owned tables get shared base
columns, and every write to them goes through one helper that adds the outbox row in the same
transaction.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `tool/seed/source/exercises.json` + `SOURCE.md` | new | pinned Free Exercise DB copy (commit SHA, Unlicense) so builds are reproducible (AC1) |
| `tool/seed/seed_builder.dart` | new | pure `buildSeed(source, catalogVersion)`: trim, taxonomy, equipment mapping, content hash per exercise; throws `SeedError(exercise, field, value)` (AC1, AC2) |
| `tool/build_exercise_seed.dart` | new | CLI: reads the source, writes `assets/exercises/seed.json` (sorted, stable JSON) (AC1) |
| `assets/exercises/seed.json` | new | generated seed, committed (AC1, AC3) |
| `lib/core/ids.dart` | new | `newId()` = UUID v7 (AC7) |
| `lib/data/local/app_database.dart` (+ `.g.dart`) | new | Drift DB: `CatalogExercises`, `ExerciseMuscles`, FTS5 `exercise_fts`, `AppMeta`, `Outbox`; migrations; `openAppDatabase()` via `drift_flutter` (AC3–AC9) |
| `lib/data/local/base_columns.dart` | new | `SyncedTable` mixin: id, updatedAt, deletedAt, syncState; `selectActive(table)` is the default read and skips soft-deleted rows (AC7) |
| `lib/data/sync/synced_writer.dart` | new | `SyncedWriter.run/softDelete`: entity write, `updatedAt` + `syncState=pending` stamp and outbox row in one transaction; delete = set deletedAt (AC7, AC8) |
| `lib/features/library/domain/exercise.dart` | new | `Exercise` entity + taxonomy enums (pure Dart) (AC1, AC4, AC5) |
| `lib/features/library/domain/exercise_query.dart` | new | `ExerciseQuery(text, muscles, equipment, levels, categories)` (AC4, AC5) |
| `lib/features/library/domain/exercise_catalog_repository.dart` | new | repository interface: `search`, `byId`; catalog status is the `catalogImportProvider` AsyncValue, not on the interface (AC4, AC5, AC10) |
| `lib/features/library/data/catalog_importer.dart` | new | first import + version upgrade, one transaction, JSON parsed with `Isolate.run` (AC3, AC9, AC10) |
| `lib/features/library/data/drift_exercise_catalog_repository.dart` | new | FTS prefix search, filters, ranking (AC4–AC6) |
| `lib/features/library/data/providers.dart` (+ `.g.dart`) | new | `appDatabaseProvider`, `catalogImportProvider` (AsyncValue = loading/ready), `exerciseCatalogProvider` (AC10) |
| `lib/main.dart` | changed | starts the import after `runApp`, never awaited (AC10) |
| `pubspec.yaml` | changed | packages below; `assets/exercises/seed.json` |
| `integration_test/fnd03_search_perf_test.dart` | new | p95 search time on a real device (AC6) |

## Data

- `catalog_exercises`: id (source id, PK), name, equipment, category, level, mechanic?, force?,
  instructions (JSON text), images (JSON text), contentHash, retiredAt? — catalog data, not
  user-owned, so no base columns or outbox.
- `exercise_muscles`: exerciseId, muscle, isPrimary; PK (exerciseId, muscle); index on muscle.
- `exercise_fts`: FTS5 (name) with `content='catalog_exercises'`, `tokenize='unicode61
  remove_diacritics 2'`, kept in step by the importer.
- `app_meta`: key, value (`catalogVersion`).
- `outbox`: seq (autoincrement), entity, entityId, op (create/update/delete), createdAt.
- Schema version 1. Later slices add user tables that use `SyncedTable`.

## Key decisions

- Stable exercise id = the source id (e.g. `Barbell_Bench_Press_-_Medium_Grip`). History rows
  can then point at catalog exercises across catalog updates (AC1, AC9).
- Seed JSON is sorted by id with sorted keys, so the same source always gives the same bytes. A
  test rebuilds the seed from the pinned source and compares it with the committed asset (AC1).
- Taxonomy and equipment mapping live in one table in `seed_builder.dart`; anything unmapped
  throws, naming the exercise and value (AC2).
- The import runs in ONE transaction and writes `catalogVersion` last, so a killed import leaves
  nothing and simply reruns (AC3, edge case).
- Upgrade: rows whose `contentHash` differs are upserted, ids missing from the seed get
  `retiredAt` set, and search excludes retired rows (AC9).
- Search: each typed word becomes an FTS5 prefix term (`"bench"* AND "pr"*`), after
  lower-casing and removing punctuation. Filters are ANDed across facets and IN within a facet.
  The muscle filter joins `exercise_muscles` and orders by `max(isPrimary) DESC`, then FTS
  rank, then name (AC4, AC5).
- Empty text and no filters returns everything A–Z (edge case).
- Drift runs on a background isolate through `drift_flutter`, and the seed JSON is parsed in
  `Isolate.run`. `main` starts the import without awaiting it, so the first frame is not blocked
  (AC10, NFR-01).
- `SyncedWriter` is the only write path for user-owned tables. It wraps `transaction()` and
  inserts the outbox row after the entity write; any throw rolls back both (AC8). It stamps
  `updatedAt` and `syncState` itself, so callers cannot forget them. Feature repositories read
  user-owned tables through `selectActive`, so soft-deleted rows stay hidden by default (AC7). In this slice
  it is proven on a test-only table, and LOG/SCH slices are its first real users.
- IDs: `uuid` `v7()` behind `newId()`, so ids sort by creation time (AC7).
- Photos: only the source image paths are stored (spec decision).

## Packages

- `drift`, `drift_flutter`: local DB, already chosen in docs/architecture.md. `drift_flutter`
  opens the file DB on a background isolate.
- `drift_dev` (dev): Drift code generation.
- `uuid`: UUID v7 ids (CLAUDE.md rule).
- SQLite itself comes from `sqlite3` 3.x through Dart build hooks (FTS5 included).
  `sqlite3_flutter_libs` is end-of-life and not used.

## Error handling

- Seed build: any unmapped value → `SeedError`, exit code 1, nothing written.
- Import failure (corrupt asset, disk full): the transaction rolls back, the catalog status is
  an error, and the next launch retries (Riverpod's in-session retry is off for the import, or
  the status would stay loading forever). No partial catalog is ever visible.
- Search input is escaped (quotes stripped) so user text can never break the FTS query.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1, AC2 | `test/tool/seed_builder_test.dart`: mapping, trimming, nulls, determinism, committed seed = rebuild | unit |
| AC3, AC9, edge | `test/features/library/data/catalog_importer_test.dart`: in-memory DB, once-only, crash mid-import, version upgrade, retire | unit |
| AC4, AC5, edge | `test/features/library/data/exercise_search_test.dart`: real seed, prefix words, punctuation, filters, primary-first, empty query | unit |
| AC6 | same file, a desktop timing smoke test; `integration_test/fnd03_search_perf_test.dart` p95 on the phone | unit + integration |
| AC7 | `test/core/ids_test.dart`; `test/data/sync/synced_writer_test.dart` (base columns, soft delete hidden via `selectActive`) | unit |
| AC8 | `test/data/sync/synced_writer_test.dart`: outbox row per write (create, update, delete), central stamping, rollback when either fails | unit |
| AC10 | `test/features/library/data/catalog_status_test.dart`: status loading → ready; failed import → error, no rows, next launch imports; app pumps while the import is pending. Cold start re-measured on the phone | widget + device |

## Risks

- `sqlite3` build hooks need a working native toolchain or a prebuilt download on CI (ubuntu,
  macOS). The first task proves FTS5 works under `flutter test` locally and on CI.
- The 95th-percentile target is for a mid-range Android, and the desktop test is only a smoke
  check. The real number comes from the integration test on the Note10.
- A FTS5 table with external content can drift from the catalog if something writes outside the
  importer. Only the importer writes the catalog, and a test checks that FTS row count equals
  the active catalog row count.
- Committing a 1 MB source copy grows the repo once. It's accepted for reproducible builds.
