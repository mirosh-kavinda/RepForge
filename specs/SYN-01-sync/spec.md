# SYN-01: Offline-first sync to the cloud

Status: Approved
Phase: P3 · Priority: MVP · Screens: 24 Backup and sync

## Why

Everything is saved on the phone first, but a lost or broken phone shouldn't mean lost
training history. A quiet backup, and a copy on my other phone, without ever waiting on the
network.

## User stories

- As a signed-in user, my changes back up by themselves whenever I'm online.
- As a user with two phones, changes made on one appear on the other.
- As a user, I can see when I was last backed up and whether anything is waiting.

## Acceptance criteria

- **AC1** — Given a signed-in, verified account and a connection, when I change anything, then
  it is backed up within a minute without me doing anything, and the app never waits for it.
- **AC2** — Given no connection, when I keep using the app (up to 30 days), then nothing is
  lost: every change is backed up, in order, once I'm online again.
- **AC3** — Given a finished workout, then it is backed up as one record with all its sets
  (never set by set).
- **AC4** — Given a change on my other phone, when this phone signs in, comes back to the app
  or has been open for 6 hours, then it shows that change.
- **AC5** — Given the same record changed on two phones, then the later change wins on both;
  a finished workout is never overwritten or lost.
- **AC6** — Given a guest, then nothing leaves the phone; when the guest signs in, everything
  already on the phone is backed up to the new account.
- **AC7** — Given "Back up body metrics" is off (AUTH-01), then body snapshots and body data
  in my profile stay on the phone; turning it on backs them up.
- **AC8** — Given an email account not yet verified, then nothing is backed up until it is.
- **AC9** — Given Profile → Backup and sync, then I see "Backed up 5 min ago" (or "Not backed
  up yet"), how many changes are waiting, and Back up now.
- **AC10** — Given a backup that fails, then the screen says "Can't back up right now: will
  try again" with the reason in words (no connection, signed out, server busy), and it
  retries by itself, waiting longer each time.
- **AC11** — Given a deleted record, then the deletion is backed up too, and the record
  disappears on my other phone.

## Edge cases

- Signing out after unsynced changes: the AUTH-01 sign-out warning already covers it.
- A record changed again before its first backup is sent once, in its latest state.
- A pulled change older than my unsent local change doesn't overwrite it.
- The clock on one phone is wrong: ordering uses the time the change was made on that phone;
  accepted as a limitation.
- Workouts in progress are never backed up until finished.

## Constraints (NFRs that apply)

- NFR-02: offline first; the UI never waits on the network.
- NFR-04: owner-only access (`users/{uid}/**`); no health data in analytics.
- NFR-10: one cloud write per finished workout; batches of up to 500.
- Free tier for now (roadmap decision 2026-11-24): no photos in the cloud yet.

## Non-goals

- Restore on a new phone with progress (SYN-02); export (SYN-03); photos (BOD-02).
- Showing conflicts to the user; Wi-Fi-only; choosing what to back up beyond AUTH-01's
  body-metrics switch.

## Data touched

- Every synced table and the outbox; a per-collection "last pulled" time on the phone.
- Cloud: `users/{uid}/…` collections per architecture.md.

## Open questions

- None.
