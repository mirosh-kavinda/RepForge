# AUTH-01: Sign in with Google, Apple, email, or continue as guest

Status: Approved
Phase: P1 · Priority: MVP · Screens: 09 Sign in

## Why

Users should be able to start training at once without an account, and sign in later to back
up — without losing anything they logged as a guest.

## User stories

- As a new user, I can continue as guest and use every offline feature.
- As a user, I can sign in with Google, Apple (iPhone) or email + password.
- As a guest who signs in, everything I logged stays with me.

## Acceptance criteria

- **AC1** — Given a fresh install, when the app opens, then the Sign in screen shows; given any
  later launch after a sign-in or guest choice, then the app opens straight to Home.
- **AC2** — Given the Sign in screen, when I complete Google (both platforms) or Apple (iOS
  only; not shown on Android), then I am signed in and land on Home.
- **AC3** — Given the email option, when I enter a new email and a valid password, then an
  account is created and a verification email sent; when I enter an existing email and its
  password, then I am signed in; a wrong password shows an inline error and keeps the email.
- **AC4** — Given the email form, when I tap "Forgot password" with an email entered, then a
  reset email is sent and a confirmation shows, whether or not the email is registered.
- **AC5** — Given a signed-in email user who has not verified, then Home shows a "Verify your
  email" notice with Resend, and the account is marked not eligible for backup; once verified,
  the notice is gone on the next launch or resume.
- **AC6** — Given the Sign in screen online, when I tap "Continue as guest", then I enter Home
  as an anonymous account and nothing I log leaves the device; given no network, then I enter
  Home as a local-only guest, upgraded to an anonymous account the next time I am online.
- **AC7** — Given a guest with local data, when they sign in with a credential not used before,
  then the guest identity becomes that account (same user id) and every local record is kept;
  record counts before and after are equal.
- **AC8** — Given a guest with local data, when they sign in to an account that already exists,
  then they must choose "Keep my guest data" (kept, flagged to merge into that account when
  backup arrives) or "Discard guest data" (removed, exercise catalog kept); cancelling leaves
  them a guest. Data is never dropped without that choice.
- **AC9** — Given no network, when I tap Google, Apple or email, then a clear offline message
  shows and "Continue as guest" stays available.
- **AC10** — Given a signed-in user, when they tap Sign out, then a warning says data not yet
  backed up will be removed from this phone; confirming wipes local user data (catalog kept)
  and returns to Sign in; cancelling changes nothing.
- **AC11** — Given the backup rules, when a user reads or writes another user's data, then it is
  denied; their own data is allowed; the shared catalog is read-only to signed-in users.
- **AC12** — Given any build, then requests to the backend carry a device attestation token
  (a debug attestation in development builds).

## Edge cases

- User cancels the Google/Apple sheet → back on Sign in, no error shown.
- Email already registered through Google → message names Google and offers it.
- Guest sees "Sign in to back up" instead of Sign out (signing a guest out would lose all data).
- App killed mid-sign-in → next launch shows Sign in (or Home if the choice completed).
- Weak password (< 8 chars) or malformed email → inline error before any network call.

## Constraints (NFRs that apply)

- NFR-04: owner-only rules, attestation on, no identity or health data in analytics.
- NFR-06: 48 dp targets, semantics labels, 200 % text on Sign in and dialogs.
- Separate test and production backends; test builds never touch production users.
- NFR-01: cold start stays < 2 s with sign-in state restored.

## Non-goals

- Merging guest data into an existing account's cloud data (SYN-01).
- Any upload of user data (SYN-01). Account deletion, export (SET-01 / NFR-05).
- Custom password-reset UI; final placement of Sign out (SET-01); onboarding (ONB-01).
- Apple sign-in on Android. On-device iOS verification waits for a Mac.

## Data touched

- Auth identity (provider, user id, anonymous flag, email verified); sign-in choice made;
  "pending merge" flag on kept guest data; all local user records (wipe on sign-out/discard).

## Open questions

- None blocking. iOS checks (AC2 Apple, NFR-07) recorded as pending until a Mac is available.
