# SYN-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A sync engine in `lib/data/sync/` drains the existing outbox to Firestore behind a
`RemoteStore` port and pulls changes back, applying the documented rules (batches ≤ 500,
backoff, pull on sign-in / resume / 6 h, last-write-wins by `updatedAt`, sessions append-only).
Each synced table gets a codec (row ↔ document). The engine runs only while
`AuthUser.canBackUp`; guests and unverified accounts keep queuing, so signing in uploads
everything (AC6, AC8). A Backup and sync screen reads its status.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `pubspec.yaml` | changed | `cloud_firestore` |
| `lib/data/sync/remote_store.dart` | new | port: `commit(uid, writes)` (≤ 500), `changedSince(uid, collection, since)` |
| `lib/data/remote/firestore_remote_store.dart` | new | Firestore impl; `users/{uid}/{collection}/{id}`; server time not used for ordering (AC5) |
| `lib/data/sync/sync_codecs.dart` | new | per entity: collection, read row by id, row → doc, doc → upsert; session doc embeds its sets (AC3); body fields of the profile split out (AC7) |
| `lib/data/sync/sync_engine.dart` | new | `push()`: coalesce outbox by (entity, id), skip body entities when backup is off, commit in 500s, clear sent rows and mark synced; `pull()`: per collection `updatedAt > lastPulledAt`, apply unless a newer local pending change exists, sessions insert-only, deletes applied (AC1–AC5, AC7, AC11, edges) |
| `lib/data/sync/sync_status.dart` | new | status (last backed up, waiting count, error kind) in `app_meta` (AC9, AC10) |
| `lib/data/sync/sync_scheduler.dart` | new | triggers: outbox change (debounced 5 s), connectivity regained, resume, 6 h timer, sign-in; exponential backoff 30 s → 1 h on failure (AC1, AC2, AC4, AC10) |
| `lib/data/sync/providers.dart` | new | engine, status stream, scheduler started from `main.dart` |
| `lib/features/settings/presentation/backup_screen.dart` | new | screen 24: last backed up, waiting count, Back up now, error line (AC9, AC10) |
| `lib/features/settings/presentation/profile_screen.dart` | changed | Backup and sync row |
| `lib/features/auth/…` (preferences) | changed | turning body backup on queues the body records again (AC7) |
| `lib/app/router.dart`, `lib/main.dart`, `lib/app/l10n/app_en.arb` | changed | route, start scheduler, strings |
| `firestore.rules`, `test/firestore_rules/` | changed | owner-only paths per collection; session docs create-only (AC5) |
| `docs/architecture.md` | changed | codecs, pending-wins rule, status keys |

## Data

- Collections under `users/{uid}`: `profile` (doc `main`), `bodySnapshots`, `workoutTemplates`,
  `cycles`, `scheduleDays`, `sessions` (with `sets` array), `customExercises`, `goals`. Each
  doc carries `updatedAt` (ms) and `deletedAt` (ms or null).
- `app_meta`: `sync.pulledAt.<collection>`, `sync.backedUpAt`, `sync.error`.
- No schema change: `syncState` and the outbox exist (FND-03).

## Key decisions

- **Coalescing (edge).** Outbox rows for the same (entity, id) are sent once, as the current
  row; a delete wins. Rows are removed only after Firestore confirms the batch (AC2).
- **Order (AC2).** Batches go oldest-first by outbox `seq`; a batch is one Firestore
  `WriteBatch`, so it lands whole or not at all.
- **Conflicts (AC5, edge).** Pull applies a remote doc only if its `updatedAt` is newer than
  the local row's, or the local row has no pending change; sessions are written once and
  never replaced (rules enforce create-only).
- **Body data (AC7).** With body backup off, `bodySnapshot` rows stay queued and the profile
  is sent without sex, birth year, height and activity. Turning it on adds outbox rows for
  every snapshot and the profile.
- **Who syncs (AC6, AC8).** Only when `canBackUp`; signing in to an account with data on the
  phone pushes the queue as is (writes already queued since first launch).
- **Workout in progress (edge).** The session row exists only after Finish adds its outbox
  row (LOG-05), so nothing partial is sent.
- **Errors (AC10).** Kinds: offline, signedOut, server (incl. permission / quota). Backoff
  doubles from 30 s to 1 h; Back up now resets it.

## Packages

- `cloud_firestore` — Firestore is the backend in architecture.md; offline persistence off
  (Drift is the local store).

## Error handling

- Any failure leaves the outbox untouched and records the error kind; nothing in the UI waits.
  A doc that can't be decoded on pull is skipped and logged, not fatal.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1–AC3, AC5, AC7, AC11, edges | `test/data/sync/sync_engine_test.dart` (in-memory Drift + fake remote) | unit |
| AC2 | same: "30 days offline" — 30 days of writes queued, then one push; all present remotely, in order | unit |
| AC4, AC5 | same: pull applies newer, keeps pending local, sessions never replaced | unit |
| AC1, AC4, AC10 | `test/data/sync/sync_scheduler_test.dart` (fake clock, connectivity) | unit |
| codecs | `test/data/sync/sync_codecs_test.dart` (round trip per entity) | unit |
| AC9, AC10 | `test/features/settings/presentation/backup_screen_test.dart` | widget |
| rules | `test/firestore_rules/` emulator tests (owner-only, sessions create-only) | integration |

## Review follow-ups

- Pull cursor is the server's `syncedAt` (not device `updatedAt`), per account; dates read
  back as UTC; a refused document is set aside instead of blocking the queue; a failed pull
  never stops the push; turning body backup on queues the profile in the preferences save
  itself; status refreshes on `app_meta` changes; the synced mark compares the stored value;
  commits time out (30 s) as offline; a run stops writing when the account changes.
- As built: the profile document id is the profile row id (not `main`); status lives in
  `sync_engine.dart` (no separate `sync_status.dart`).
- Still open: a manual check against a real Firebase project (T6).

## Risks

- Firestore emulator tests need Node and the emulator; they run in CI, not `flutter test`.
- Clock skew between phones can pick the wrong winner (accepted in the spec).
- A first push for a long-time guest can be large; 500-write batches keep each commit safe.
