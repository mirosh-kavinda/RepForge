# AUTH-01: Sign in with Google, Apple, email, or continue as guest

Status: Approved (amended 2026-11-21: redesigned 09, new 09b)
Phase: P1 · Priority: MVP · Screens: 09 Sign in, 09b Account (backup and personalisation)

## Why

Users should be able to start training at once without an account, and sign in later to back
up — without losing anything they logged as a guest.

## User stories

- As a new user, I can skip sign-in and use every offline feature.
- As a user, I can sign in with Google (main option), Apple (iPhone) or email + password.
- As a guest who signs in, everything I logged stays with me.
- As a signed-in user, I choose what backs up and what follows me to other devices.

## Acceptance criteria

- **AC1** — Given a fresh install, then Welcome shows and Get started opens Sign in (ONB-01);
  given any later launch after a sign-in or skip, then Sign in never shows again on its own.
- **AC2** — Given Sign in (09), then "Continue with Google" is the main button and "Other
  options" offers Apple (iOS only; hidden on Android) and Email; completing any of them signs
  me in and opens Account (09b).
- **AC3** — Given the email option, when I enter a new email and a valid password, then an
  account is created and a verification email sent; when I enter an existing email and its
  password, then I am signed in; a wrong password shows an inline error and keeps the email.
- **AC4** — Given the email form, when I tap "Forgot password" with an email entered, then a
  reset email is sent and a confirmation shows, whether or not the email is registered.
- **AC5** — Given a signed-in email user who has not verified, then Home shows a "Verify your
  email" notice with Resend, and the account is marked not eligible for backup; once verified,
  the notice is gone on the next launch or resume.
- **AC6** — Given Sign in, then "Skip for now" says guest data stays on this phone only with no
  backup; tapping it online makes me an anonymous account, offline a local-only guest (upgraded
  when next online); either way nothing leaves the device and onboarding (ONB-01) follows.
- **AC7** — Given a guest with local data, when they sign in with a credential not used before,
  then the guest identity becomes that account (same user id) and every local record is kept;
  record counts before and after are equal.
- **AC8** — Given a guest with local data, when they sign in to an account that already exists,
  then they must choose "Keep my guest data" (kept, flagged to merge into that account when
  backup arrives) or "Discard guest data" (removed, exercise catalog kept); cancelling leaves
  them a guest. Data is never dropped without that choice.
- **AC9** — Given no network, when I tap Google, Apple or Email, then a clear offline message
  shows and "Skip for now" stays available.
- **AC10** — Given a signed-in user, when they tap Sign out, then a warning says data not yet
  backed up will be removed from this phone; confirming wipes local user data (catalog kept)
  and returns to Welcome; cancelling changes nothing.
- **AC11** — Given the backup rules, when a user reads or writes another user's data, then it is
  denied; their own data is allowed; the shared catalog is read-only to signed-in users.
- **AC12** — Given any build, then requests to the backend carry a device attestation token
  (a debug attestation in development builds).
- **AC13** — Given Account (09b), then it shows my name, email and photo from the provider
  (initials if none) and "Backup on" (or "Backup after you verify" for unverified email).
  Back up: workouts and goals always on; body metrics and progress photos (Wi-Fi only) are
  switches, default on. Personalise: use my provider name and photo, sync settings across
  devices, reminders on all my devices — switches, default on. Continue saves the choices on
  the phone and opens onboarding, or Home if already onboarded. Choices are changeable later
  in Settings and are applied by the backup and notification slices.
- **AC14** — Given Sign in, then it shows the three benefits (automatic backup, restore on any
  phone, personalised to you) and "We use only your name, email and photo. Health data is never
  shared."

## Edge cases

- User cancels the Google/Apple sheet → back on Sign in, no error shown.
- Email already registered through Google → message names Google and offers it.
- Guest sees "Sign in to back up" instead of Sign out (signing a guest out would lose all data).
- App killed mid-sign-in → next launch shows Sign in (or the next step if the choice completed).
- Weak password (< 8 chars) or malformed email → inline error before any network call.
- Apple with a hidden email → the relay address shows; no name → initials only.
- Turning "Use my name and photo" off → Home and Profile show initials and no name.

## Constraints (NFRs that apply)

- NFR-04: owner-only rules, attestation on, no identity or health data in analytics.
- NFR-06: 48 dp targets, semantics labels, 200 % text; switches labelled, state not colour-only.
- Separate test and production backends; test builds never touch production users.
- NFR-01: cold start stays < 2 s with sign-in state restored.

## Non-goals

- 09b "Backup found → Restore / Start fresh" card: appears with SYN-02 restore.
- Merging guest data into an existing account's cloud data; any upload (SYN-01).
- Account deletion, export (SET-01 / NFR-05); final placement of Sign out (SET-01).
- Custom password-reset UI. Apple sign-in on Android; on-device iOS checks wait for a Mac.

## Data touched

- Auth identity (provider, user id, anonymous flag, email verified, name, photo); sign-in
  choice made; "pending merge" flag; account preferences (body metrics backup, photos backup,
  use provider profile, sync settings, reminders everywhere); all local user records (wipe on
  sign-out/discard).

## Open questions

- None blocking. iOS checks (AC2 Apple, NFR-07) recorded as pending until a Mac is available.
