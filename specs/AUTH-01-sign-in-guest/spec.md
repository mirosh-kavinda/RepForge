# AUTH-01: Sign in with Google, Apple, email, or continue as guest

Status: Draft
Phase: P1 · Priority: MVP · Screens: 09 Sign in

## Why

Users should be able to start training immediately without an account, and later sign in to
back up — without losing anything they logged as a guest.

## User stories

- As a new user, I can continue as guest and use every offline feature.
- As a user, I can sign in with Google, Apple or email + password.
- As a guest who signs in, all my data moves to my account.

## Acceptance criteria

- **AC1** — Given the Sign in screen, when I tap Google, Apple (iOS; Android if configured) or
  Email, then I am authenticated with Firebase Auth and land on the next onboarding step or Home.
- **AC2** — Given the Sign in screen, when I tap "Continue as guest", then I enter the app with
  an anonymous Firebase user (or local-only identity when offline) and no data leaves the device.
- **AC3** — Given a guest with local data, when they sign in for the first time, then the
  anonymous account is linked to the new credential and every local record is kept and
  re-owned by the new uid; record counts before and after are equal.
- **AC4** — Given a guest signs in to an account that already has data, when linking fails
  because the credential is in use, then the user is asked to choose: merge guest data into that
  account, or discard guest data — never silently dropped.
- **AC5** — Given no network, when I tap a sign-in provider, then I see a clear offline message
  and the guest option stays available.
- **AC6** — Given Firestore rules, when a user reads or writes another uid's path, then it is
  denied (rules unit test with the emulator).

## Edge cases

- User cancels the provider sheet → back on Sign in, no error toast.
- Email already registered with Google → offer the existing provider.
- Sign out while outbox has unsynced rows → warn first (full behaviour in SYN-01).

## Constraints

- NFR-04 owner-only rules, App Check enabled, no health data in analytics.
- NFR-06 accessible buttons (48 dp, labels).

## Non-goals

- Account deletion and data export (SET-01 / NFR-05).
- Password reset UI beyond Firebase's default email.

## Data touched

- Firebase Auth user; `UserProfile` (users/{uid}); ownership of all local records.

## Open questions

- Firebase project IDs for dev / prod, and whether to use flavors from the start.
