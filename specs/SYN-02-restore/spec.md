# SYN-02: Restore on a new phone

Status: Approved
Phase: P3 · Priority: MVP · Screens: 09b Account (restore card), 24 Backup and sync

## Why

A new or reset phone should feel like my old one within seconds: same plan, same history,
same goals, without typing anything again.

## User stories

- As a returning user on a new phone, I sign in and get my training back.
- As a user, I can choose to start this phone fresh instead.
- As a user who tried the app as a guest first, I keep what I logged and get my backup too.

## Acceptance criteria

- **AC1** — Given I sign in to an account with a backup, then the Account screen shows a
  restore card: "Backup from {date}" with "{n} workouts" under it, and Restore and Start fresh.
- **AC2** — Given the card, when I tap Restore, then my profile, cycle, workout templates and
  goals arrive first and Home works within a few seconds; older history (workouts, schedule
  days, body snapshots) keeps loading while I use the app.
- **AC3** — Given a restore in progress, then Backup and sync shows "Restoring: {done} of
  {total}" and Home shows a small "Restoring your history" line; both go when it finishes.
- **AC4** — Given 2 years of data and a 4G connection, then the whole restore finishes in under
  30 seconds.
- **AC5** — Given the backup has a profile, then onboarding is skipped and the restored units,
  goal and body data are used; without one, onboarding runs as usual.
- **AC6** — Given the card, when I tap Start fresh, then nothing is downloaded; the backup stays
  in the cloud untouched, and what I do on this phone backs up alongside it.
- **AC7** — Given this phone already has data (guest use) and the account has a backup, when I
  restore, then both are kept: the phone's records upload and the backup's download; for the
  same record the later change wins (SYN-01).
- **AC8** — Given a restore that stops (app closed, connection lost), when the app is open and
  online again, then it carries on where it stopped, without duplicates.
- **AC9** — Given a restored phone, then stats, personal records, streaks and progress are
  rebuilt on the phone from the restored data and match the old phone.
- **AC10** — Given the card was shown and the network is gone, then the card says Restore needs
  a connection, and Start fresh still works. (With no network at first sign-in the phone can't
  know about a backup yet; the card appears once it is online.)

## Edge cases

- An account with no backup: no card; the phone starts as usual.
- A backup whose workouts are all deleted: the count excludes deleted ones.
- Body data held back on the old phone (AUTH-01 switch off) isn't in the backup; the restored
  profile then lacks it and the Body screens ask for it as on a fresh install.
- Choosing Start fresh is remembered; the card doesn't come back for this account here until
  sign-out (which clears the phone).
- Signing out mid-restore stops it; nothing from the old account stays on the phone.

## Constraints (NFRs that apply)

- NFR-01: Home usable within a few seconds of Restore; whole restore < 30 s for 2 years on 4G.
- NFR-02: the UI never waits on the network beyond the first essentials.
- NFR-04: owner-only access; no health data in analytics.

## Non-goals

- Picking which records to restore; restoring from a file (SYN-03); photos (BOD-02).
- Deleting the cloud backup (NFR-05 account deletion).

## Data touched

- Every synced collection (read); local tables (write); restore progress on the phone.

## Open questions

- None.
