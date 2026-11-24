# SYN-02: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Restore is the SYN-01 pull, run deliberately: essentials first, history after, in pages, with
the pull cursor saved after each page so it resumes where it stopped. A per-account restore
state in `app_meta` decides whether the scheduler may pull at all, so nothing downloads before
the user picks Restore or Start fresh. The Account screen gets the restore card; Home and
Backup and sync show progress. Stats need no work: they are derived on the phone from the
restored rows (PR flags travel with the sets).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/sync/remote_store.dart` | changed | `summary(uid)` → newest `syncedAt` + live workout count; `count(uid, collection)`; `changedSince` gets a page `limit` (AC1, AC3, AC8) |
| `lib/data/remote/firestore_remote_store.dart` | changed | the above with Firestore `count()` aggregates and `limit` |
| `lib/data/sync/restore.dart` | new | `RestoreState` (none / offered / restoring / done / fresh) per uid in `app_meta`; `RestoreProgress` (done, total) (AC1, AC3, AC6, AC8) |
| `lib/data/sync/sync_engine.dart` | changed | pull in a fixed order (profile, cycles, templates, goals, custom exercises, then schedule days, sessions, body snapshots), page by page, counting applied docs; `startFresh(uid)` sets every cursor to the backup's newest `syncedAt` (AC2, AC6, AC8) |
| `lib/data/sync/sync_scheduler.dart` | changed | pulls only when the restore state is restoring / done / fresh; push once the first pull has looked for a backup (AC6, AC7) |
| `lib/data/sync/providers.dart` | changed | restore state, summary, progress providers; `RestoreController` (restore, startFresh) |
| `lib/features/auth/presentation/restore_card.dart` | new | card: "Backup from {date}: {n} workouts", Restore / Start fresh, offline message; Restore waits for essentials, marks onboarding done when a profile arrived (AC1, AC2, AC5, AC10) |
| `lib/features/auth/presentation/account_screen.dart` | changed | shows the card (AC1) |
| `lib/features/onboarding/…` | changed | `markDone()` for a restored profile (AC5) |
| `lib/features/home/presentation/home_screen.dart` | changed | "Restoring your history" line (AC3); the restore card again while undecided, so a choice skipped on Account can still be made (AC1) |
| `lib/features/settings/presentation/backup_screen.dart` | changed | "Restoring: {done} of {total}" (AC3) |
| `lib/app/l10n/app_en.arb` | changed | strings |
| `docs/architecture.md` | changed | restore order, states, paging |

## Data

- `app_meta`: `restore.<uid>` = offered | restoring | done | fresh; `restore.total.<uid>`,
  `restore.done.<uid>` (progress). Cursors stay `sync.pulledAt.<uid>.<collection>` (SYN-01).
- No schema change; nothing new in Firestore.

## Key decisions

- **Offer (AC1, edges).** After sign-in, if the state is unset: `summary(uid)`; no live data
  → state `done` (nothing to restore, normal sync); data → `offered` and the card shows.
- **Restore (AC2, AC8).** State `restoring`; pull essentials (5 small collections), then the
  history collections in pages of 200, cursor saved per page; when all pages are empty →
  `done`. Re-running after a stop continues from the saved cursors; applying is idempotent
  (newer-wins), so no duplicates.
- **Essentials and onboarding (AC2, AC5).** The card's Restore awaits the essentials only
  (spinner on the button), then writes `onboarding.done` if a profile arrived and leaves the
  screen; history continues in the scheduler's background run.
- **Start fresh (AC6, edge).** Cursors set to the backup's newest `syncedAt`, state `fresh`;
  later pulls see only new changes. Nothing is deleted in the cloud. Remembered per account.
- **Merge (AC7).** Push waits only until the first pull has looked for a backup (records sent
  before that would look like a backup themselves); after that, offered or not, the phone's
  queued records upload whatever the choice; restore uses SYN-01's newer-wins apply.
- **Progress (AC3).** Total = sum of `count()` for the history collections at Restore; done
  counts applied or already-current docs; Home and Backup read one stream.
- **Cursor (AC8).** One batch stamps up to 500 docs with the same server time, so the
  cursor is (syncedAt, doc id) and pages resume strictly after it; time alone could loop.
- **Speed (AC4).** Pages of 200 with one Drift transaction per page; a unit test applies 2
  years (≈ 1,100 workouts with sets, 730 days, 100 snapshots) from the fake store under a
  time budget; the 4G part is checked by hand.
- **Sign-out (edge).** The SYN-01 `current()` check stops the run; the wiper clears
  `restore.*` with the rest of `app_meta`.

## Packages

- None new.

## Error handling

- A failed page leaves its cursor where it was; the scheduler's backoff retries. The card shows
  "Couldn't reach your backup" with Try again; Start fresh always works.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2, AC6, AC8, edges | `test/data/sync/restore_test.dart` (engine + fake store: order, paging, resume, fresh cursors, no duplicates) | unit |
| AC4 | same: 2 years applied under a budget | unit |
| AC6, AC7 | `sync_scheduler_test.dart` "pull waits for the choice; push doesn't" | unit |
| AC1, AC2, AC5, AC10 | `test/features/auth/presentation/restore_card_test.dart` | widget |
| AC3 | `backup_screen_test.dart`, home test "Restoring your history" | widget |
| AC9 | `restore_match_test.dart`: old phone pushes, new phone restores; history, streak, adherence, strength and volume equal | unit |
| AC6 | `restore_match_test.dart`: after Start fresh the phone's records upload, the backup is untouched | unit |

## Risks

- Firestore `count()` aggregates cost one read per 1,000 docs; fine on the free tier.
- Two phones restoring the same account at once: both pull, both push; newer-wins keeps them
  consistent.
