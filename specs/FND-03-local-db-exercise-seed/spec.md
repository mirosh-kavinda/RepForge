# FND-03: Local database, outbox and exercise catalog seed

Status: Draft
Phase: P1 · Priority: MVP · Screens: none yet (data for 04 Exercise library, 14 Exercise detail)
Covers the data half of: EXL-01, EXL-02

## Why

Offline-first means the local database is the app's real store from day one, and the exercise
library must be searchable with no network on first launch.

## User stories

- As a user with no signal, I can search 800+ exercises by name, muscle, equipment or level
  right after install.
- As the developer, every repository write automatically records a sync intent (outbox), so
  sync can be added later without changing feature code.

## Acceptance criteria

- **AC1** — Given a build script run, when `dart run tool/build_exercise_seed.dart` executes on
  Free Exercise DB `exercises.json`, then it writes `assets/exercises/seed.json` with names
  normalised and muscles/equipment/category/level/mechanic/force mapped to the taxonomy in the
  source spec §4, and images converted to WebP.
- **AC2** — Given a fresh install, when the app first launches offline, then all seed exercises
  load into the Drift `exercises` table with an FTS5 index, once (not on later launches).
- **AC3** — Given the seeded table, when searching by name, muscle, equipment or level (alone or
  combined), then results return in < 100 ms on a mid-range Android.
- **AC4** — Given any user-owned table, then it has `id` (UUID v7), `updatedAt`, `deletedAt`,
  `syncState` columns.
- **AC5** — Given a repository write (insert/update/soft-delete), when it commits, then an outbox
  row `(entity, id, op, createdAt)` is written in the same transaction; if either fails, neither
  is saved.
- **AC6** — Given a seed with a higher `catalogVersion` than the stored one, when the app starts,
  then only changed exercises are upserted (prepares Firestore `catalog/meta` updates).

## Edge cases

- Exercises with missing images or unknown muscles (map to nearest or omit, never crash).
- Duplicate names in source data.
- App killed mid-seed: next launch resumes or restarts the seed cleanly.

## Constraints

- NFR-02 offline, NFR-03 no data loss, NFR-01 seeding must not block cold start > 2 s
  (seed in background isolate; library shows a loading state).

## Non-goals

- Library and detail UI (EXL-01/EXL-02 UI slices in P2), custom exercises (EXL-03).
- Sync engine that drains the outbox (SYN-01).

## Data touched

- `exercises` (+ FTS), `outbox`, `app_meta` (catalogVersion, seedDone).

## Open questions

- Ship images inside the app bundle (size) or download on demand after install?
