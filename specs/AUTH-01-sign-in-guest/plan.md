# AUTH-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A pure-Dart `AuthRepository` in `features/auth/domain` hides Firebase Auth, Google and Apple.
The UI and the router depend only on that interface, so every AC except the rules test (AC11)
and the attestation check (AC12) is tested with a fake. Whether the user has chosen sign-in or
guest is stored in Drift, not read from Firebase, so the first route is known at once, offline
and without waiting for Firebase (AC1, NFR-01). Firebase starts after `runApp`.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/auth/domain/auth_user.dart` | new | `AuthUser(uid, kind: anonymous/localGuest/provider, email?, emailVerified, providers)`; `canBackUp` getter (AC5, AC6) |
| `lib/features/auth/domain/auth_failure.dart` | new | sealed: `cancelled`, `offline`, `wrongPassword`, `weakPassword`, `invalidEmail`, `accountExists(pending)`, `useProvider(name)`, `unknown` (AC3, AC8, AC9, edges) |
| `lib/features/auth/domain/auth_repository.dart` | new | interface: `userChanges`, `signInWithGoogle/Apple`, `signUpEmail`, `signInEmail`, `sendPasswordReset`, `resendVerification`, `refresh`, `continueAsGuest`, `completeExistingAccount(pending, keepGuestData)`, `signOut` |
| `lib/features/auth/domain/email_rules.dart` | new | email shape + password ≥ 8, checked before any network call (edge) |
| `lib/features/auth/data/firebase_auth_repository.dart` | new | Firebase implementation: link-if-anonymous, error-code mapping (AC2–AC9) |
| `lib/features/auth/data/provider_credentials.dart` | new | thin wrappers over `google_sign_in` / `sign_in_with_apple`, so they can be faked |
| `lib/features/auth/data/auth_local_store.dart` | new | Drift `app_meta` keys: `auth.choiceMade`, `auth.localGuestId`, `auth.pendingMergeFrom` (AC1, AC6, AC8) |
| `lib/features/auth/data/providers.dart` (+ `.g.dart`) | new | `authRepositoryProvider`, `authGateProvider` (choiceMade), `currentUserProvider` |
| `lib/features/auth/presentation/sign_in_screen.dart` | new | screen 09: Google, Apple (iOS only), Email, Continue as guest; offline banner (AC2, AC6, AC9) |
| `lib/features/auth/presentation/email_sign_in_screen.dart` | new | sign up / sign in / forgot password form (AC3, AC4) |
| `lib/features/auth/presentation/existing_account_dialog.dart` | new | Keep / Discard / Cancel (AC8) |
| `lib/features/auth/presentation/verify_email_banner.dart` | new | shown on Home, with Resend (AC5) |
| `lib/features/auth/presentation/account_section.dart` | new | Sign out, or "Sign in to back up" for guests (AC10, edge) |
| `lib/features/auth/presentation/sign_in_controller.dart` | new | Riverpod notifier: busy/error state, connectivity check (AC9) |
| `lib/data/local/local_data_wiper.dart` | new | deletes every table except the catalog tables, `exercise_fts` and the catalog version (AC8 discard, AC10) |
| `lib/app/firebase_bootstrap.dart` | new | `Firebase.initializeApp` from dart-define options, App Check activation per flavor (AC12) |
| `lib/app/flavor.dart` | new | `Flavor.dev/prod` from `--dart-define FLAVOR`; `appCheckProviderFor(flavor)` (AC12) |
| `lib/app/router.dart` | changed | `/sign-in`, `/sign-in/email` routes; redirect on `authGateProvider` (AC1) |
| `lib/main.dart` | changed | start the Firebase bootstrap after `runApp`, never awaited (NFR-01) |
| `lib/features/home/presentation/home_screen.dart` | changed | hosts `VerifyEmailBanner` (AC5) |
| `lib/features/settings/presentation/profile_screen.dart` | changed | hosts `AccountSection` until SET-01 (AC10) |
| `lib/app/l10n/app_en.arb` | changed | all new strings |
| `android/app/build.gradle.kts` | changed | `dev` / `prod` product flavors; dev gets `.dev` application id suffix |
| `config/example.json` | new | dart-define keys template; real `config/dev.json`, `config/prod.json` are gitignored |
| `firestore.rules`, `firebase.json`, `.firebaserc` | new | owner-only rules (AC11); emulator config; dev/prod project aliases (ids are not secret) |
| `test/firestore_rules/` (`package.json`, `rules.test.mjs`) | new | `@firebase/rules-unit-testing` against the emulator (AC11) |
| `.github/workflows/ci.yml` | changed | `rules` job: Node 22 + Java, `firebase emulators:exec` runs the rules test |
| `.gitignore` | changed | `config/*.json` except `example.json` |

## Data

- No new tables. Auth state lives in Firebase Auth. App choice and guest state use three
  `app_meta` keys (above). The local DB has a single owner, the current identity; records carry no
  uid, so linking a guest keeps every row as is (AC7).
- `auth.pendingMergeFrom` = the guest uid whose data was kept for SYN-01 to merge (AC8).
- No Firestore writes in this slice (UserProfile arrives with ONB-01 / SYN-01).

## Key decisions

- **Gate from Drift, not Firebase (AC1, NFR-01).** The redirect reads `auth.choiceMade` from
  `app_meta`. Firebase restores its session in the background; Home never waits for it.
- **Anonymous first, link on sign-in (AC6, AC7).** Online guest → `signInAnonymously`. A sign-in
  while anonymous calls `linkWithCredential`, so the uid stays the same and nothing local moves.
  Offline guest → a local UUID v7 in `auth.localGuestId`; on the first online `userChanges`
  tick it is upgraded to anonymous and the key is cleared.
- **Existing account (AC8).** `credential-already-in-use` / `email-already-in-use` on link →
  `AuthFailure.accountExists(pending)` carrying the credential. Keep → set `pendingMergeFrom`,
  sign in with the pending credential. Discard → `LocalDataWiper`, then sign in. Cancel → nothing.
- **Offline (AC9).** `connectivity_plus` is checked before a provider sign-in and when Email is
  tapped (`AuthRepository.isOnline`), and `network-request-failed` also maps to `offline`. The
  message shows inline under the buttons; guest always stays enabled.
- **Local guests sign in as anonymous first (AC7, AC8).** Before any sign-in, a local guest is
  upgraded to anonymous; if that fails the sign-in stops with `offline`, so nobody signs in past
  guest data without the keep/discard choice.
- **Guest + existing email + wrong password (AC3, AC8).** Firebase can only check the password
  by signing in, which would drop the guest session, so the keep/discard dialog comes first and
  the wrong-password error shows after it. Nothing is wiped or flagged unless sign-in succeeds.
- **Email (AC3–AC5).** Sign up sends verification at once. Forgot password always shows the same
  confirmation (`user-not-found` swallowed). `refresh()` reloads the user on launch and resume;
  `canBackUp` is false for unverified password accounts and for guests.
- **Wrong provider (edge).** `account-exists-with-different-credential` names the other provider
  (Apple tried → Google, Google tried → Apple). With email enumeration protection a Google-only
  email looks like a wrong password, so that message names Google and the email screen offers a
  Continue with Google button.
- **Apple (AC2).** The button is built only when `defaultTargetPlatform == iOS`. Android tests
  assert it is absent; on-device iOS checks are recorded as pending until a Mac is available.
- **Sign out (AC10).** Confirm dialog → wipe local user data → Firebase and Google sign-out →
  clear `choiceMade` → the redirect lands on Sign in. Guests get "Sign in to back up" instead.
- **Flavors and config (constraint, never-commit rule).** Firebase options come from
  `--dart-define-from-file=config/<flavor>.json` (gitignored), so no generated options file or
  `google-services.json` is committed and CI needs no secrets. Android has real product
  flavors; iOS flavor schemes need Xcode and wait for a Mac (iOS uses the dev config meanwhile).
- **App Check (AC12).** Dev → debug provider (token registered in the dev console). Prod →
  Play Integrity / App Attest with DeviceCheck fallback. Enforcement stays off until SYN-01.
- **Analytics (NFR-04).** No auth events this slice; nothing about identity leaves via analytics.

## Packages

- `firebase_core`, `firebase_auth`, `firebase_app_check` — listed in architecture.md.
- `google_sign_in` (7.x) — Google credential for Firebase on Android and iOS.
- `sign_in_with_apple` — Apple credential on iOS (App Store rule when Google is offered).
- `connectivity_plus` — listed in architecture.md; offline check for AC9.
- Dev, Node only: `@firebase/rules-unit-testing`, `firebase-tools` (rules test, not in the app).

## Error handling

- Every Firebase / provider exception maps to an `AuthFailure`; the UI shows one inline message
  per failure type and never a raw code. `cancelled` shows nothing (edge).
- If Firebase is not ready yet (bootstrap still running), provider buttons show busy and wait for it;
  guest offline mode never waits.
- Wipe and sign-out run in one Drift transaction; if the Firebase sign-out fails afterwards the
  local state is already clean and the gate still returns to Sign in.
- App killed mid-sign-in: `choiceMade` is written only after the sign-in completes (edge).

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1 | `test/app/router_auth_gate_test.dart`: fresh DB → Sign in; choiceMade → Home | widget |
| AC2, AC6, AC9, edges | `test/features/auth/presentation/sign_in_screen_test.dart` with a fake repo: Google, guest online/offline, offline message, cancel silent, Apple absent on Android | widget |
| AC3, AC4, edges | `test/features/auth/presentation/email_sign_in_screen_test.dart`: sign up, sign in, wrong password keeps email, reset confirmation, weak password / bad email | widget |
| AC3–AC9 mapping | `test/features/auth/data/firebase_auth_repository_test.dart`: mocktail FirebaseAuth/User; link-if-anonymous, error-code mapping, local guest upgrade | unit |
| AC5, AC6 | `test/features/auth/domain/auth_user_test.dart` (`canBackUp`); `verify_email_banner_test.dart` | unit + widget |
| AC7, AC8, AC10 | `test/data/local/local_data_wiper_test.dart` (counts kept on link, catalog survives wipe); `existing_account_dialog_test.dart`; `account_section_test.dart` | unit + widget |
| AC7, AC8 real | `integration_test/auth01_emulator_test.dart`: Auth emulator, anonymous → link keeps uid; credential in use → accountExists | integration (device) |
| AC11 | `test/firestore_rules/rules.test.mjs`: own path allowed, other uid denied, catalog read-only, unauthenticated denied | emulator (CI job) |
| AC12 | `test/app/flavor_test.dart` (provider per flavor) + manual: App Check metrics show verified requests in dev | unit + manual |
| NFR-01 | cold start re-measured on the Note10 (profile, dev flavor), noted in docs/roadmap.md | device |

## Risks

- **Node locally.** Upgraded to 26.13.1 through nvm (firebase-tools 15 needs ≥ 20); CI pins Node 22.
- **Firebase projects don't exist yet.** You create `repforge-dev` / `repforge-prod`, enable the
  Google, Email and Anonymous providers, add the Android app (SHA-1 of the debug and release keys for Google),
  and fill `config/*.json`. This blocks on-device tasks, not the fake-based ones.
- **google_sign_in 7 API** (singleton, `authenticate()`) differs from older docs; wrapper isolates it.
- **iOS unverified** (Apple sign-in, the Google Sign-In URL scheme in Info.plist, schemes per
  flavor) until a Mac is available; CI's
  no-codesign iOS build must keep compiling with the new plugins (raises iOS min to 15 if needed,
  matching NFR-07).
- **Riverpod retry** (seen in FND-03): auth providers that fail must surface errors, so failures
  are returned as `AuthFailure` values, not thrown through providers.
