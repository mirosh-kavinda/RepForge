# FND-03: Local database, outbox and exercise catalog seed

Status: Approved
Phase: P1 · Priority: MVP · Screens: none yet (data for 04 Exercise library, 14 Exercise detail)
Covers the data half of: EXL-01, EXL-02

## Why

Offline-first means the device database is the app's real store from day one, and the exercise
library must be searchable with no network on first launch.

## User stories

- As a user with no signal, I can search 876 exercises by name, muscle, equipment, level or
  category right after install.
- As the developer, every write to a user-owned record also records a sync intent, so sync can
  be added later without changing feature code.

## Acceptance criteria

- **AC1** — Given the Free Exercise DB source (876 exercises), when the seed is built, then each
  exercise has a trimmed name, a stable id, primary and secondary muscles, one equipment value,
  category, level, optional mechanic and force (all from the taxonomy below), instructions and
  its image paths; the same input always produces an identical seed.
- **AC2** — Given a source value outside the taxonomy and the mapping below, when the seed is
  built, then the build fails and names the exercise and value.
- **AC3** — Given a fresh install with no network, when the app first launches, then all seed
  exercises become searchable, imported exactly once (not again on later launches).
- **AC4** — Given the imported catalog, when I search by name, then each typed word matches the
  start of a word in the name, ignoring case and punctuation ("bench pr" finds "Barbell Bench
  Press"), best name matches first, then A–Z.
- **AC5** — Given filters for muscle, equipment, level and category, when I combine them, then
  different filters narrow the results and several values of one filter widen them; a muscle
  filter matches primary and secondary muscles, with primary matches listed first.
- **AC6** — Given the full catalog on a mid-range Android, when any AC4/AC5 search runs, then it
  returns in < 100 ms (95th percentile).
- **AC7** — Given any user-owned record, then it carries a unique time-ordered id made on the
  device, updated-at and deleted-at times, and a sync state; deleting only sets deleted-at, and
  deleted records are left out of normal reads.
- **AC8** — Given a write to a user-owned record (create, update or delete), when it commits,
  then a sync-intent row (entity, id, operation, time) is saved with it; if either fails,
  neither is saved.
- **AC9** — Given an app update whose seed has a higher catalog version than the one stored,
  when the app starts, then only new or changed exercises are written and exercises dropped from
  the seed are hidden from search.
- **AC10** — Given the first launch, when the catalog import runs, then the first screen still
  appears within the NFR-01 cold-start budget and catalog reads report "loading" until the
  import completes.

## Taxonomy and mapping (from the source spec §4)

- Muscles: chest, shoulders, triceps, biceps, forearms, lats, middle back, lower back, traps,
  abdominals, quadriceps, hamstrings, glutes, calves, adductors, abductors, neck.
- Equipment: barbell, dumbbell, cable, machine, kettlebell, bands, body only, EZ bar, smith
  machine, other. Mapping: kettlebells → kettlebell; e-z curl bar → EZ bar; foam roll, medicine
  ball, exercise ball → other; missing → body only; name contains "Smith" → smith machine.
- Category: strength, powerlifting, olympic weightlifting, strongman, plyometrics, stretching,
  cardio. Level: beginner, intermediate, expert. Mechanic: compound, isolation. Force: push,
  pull, static.

## Edge cases

- Missing mechanic or force (87 and 30 exercises) stays empty; the exercise is still searchable.
- Exercises without images (3) keep an empty image list.
- App killed mid-import: the next launch finishes it with no duplicates or half-written rows.
- An empty search with no filters lists the whole catalog A–Z.

## Constraints

- NFR-02 offline, NFR-03 no data loss, NFR-01 cold start < 2 s.

## Non-goals

- Library and detail UI (EXL-01/EXL-02 UI in P2), custom exercises (EXL-03).
- Exercise photos in the app: only their paths are stored; download and caching come with EXL-02.
- Fetching catalog updates from the server (SYN-01); the sync engine that sends sync intents.

## Data touched

- Exercise catalog and its search index, sync-intent queue, app metadata (catalog version,
  import done).

## Decisions (2026-11-21)

- Photos are not bundled (1,746 JPEGs, about 66 MB); lists use the app's pose illustrations.
- Catalog updates ship with app updates for now (local catalog version only).
