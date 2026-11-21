# AUTH-01: tasks

Plan: ./plan.md · One commit for the slice once integrated (user preference).

- [x] T1 Add firebase_core, firebase_auth, firebase_app_check, google_sign_in, sign_in_with_apple, connectivity_plus; analyze, test and the no-codesign iOS build still pass — test: existing suite + `flutter build apk --debug` (risk check)
- [x] T2 Domain: `AuthUser` + `canBackUp`, `AuthFailure`, `AuthRepository`, `email_rules` — test: `test/features/auth/domain/auth_user_test.dart`, `email_rules_test.dart` (AC5, AC6, edge)
- [x] T3 `AuthLocalStore` on `app_meta` (choiceMade, localGuestId, pendingMergeFrom) — test: `test/features/auth/data/auth_local_store_test.dart` (AC1, AC6, AC8)
- [x] T4 `LocalDataWiper`: wipes user tables, keeps catalog, FTS and catalog version — test: `test/data/local/local_data_wiper_test.dart` (AC8, AC10) (parallel)
- [x] T5 `Flavor` + `appCheckProviderFor`; `firebase_bootstrap` from dart-defines; `config/example.json`, gitignore; Android dev/prod flavors — test: `test/app/flavor_test.dart` (AC12)
- [x] T6 `FirebaseAuthRepository` guest paths: anonymous online, local guest offline, upgrade on first online tick — test: `firebase_auth_repository_test.dart` "AC6 …" (AC6)
- [x] T7 Provider sign-in with link-if-anonymous; Google/Apple wrappers; error mapping (cancelled, offline, useProvider, accountExists) — test: same file "AC2/AC7/AC8/AC9 …" (AC2, AC7, AC8, AC9)
- [x] T8 Email: sign up + verification, sign in, reset (silent user-not-found), resend, refresh — test: same file "AC3/AC4/AC5 …" (AC3, AC4, AC5)
- [x] T9 `completeExistingAccount` keep/discard; `signOut` wipe + clear choice — test: same file "AC8/AC10 …" (AC8, AC10)
- [x] T10 Providers + router gate (`/sign-in`, `/sign-in/email`, redirect); main starts bootstrap after runApp — test: `test/app/router_auth_gate_test.dart` (AC1)
- [x] T11 Sign in screen + controller (Google, Apple iOS-only, Email, guest, offline banner) — test: `test/features/auth/presentation/sign_in_screen_test.dart` (AC2, AC6, AC9, edges, NFR-06)
- [x] T12 Email screen (sign up / in / forgot; inline errors) — test: `email_sign_in_screen_test.dart` (AC3, AC4, edges)
- [x] T13 Existing-account dialog, verify-email banner on Home, account section on Profile — test: `sign_in_screen_test.dart` "AC8 existing account …", `account_widgets_test.dart` (AC5, AC8, AC10)
- [x] T14 `firestore.rules`, `firebase.json`, `.firebaserc`; rules test on the emulator; CI `rules` job — test: `test/firestore_rules/rules.test.mjs` (AC11)
- [ ] T15 On device — test written, run pending a phone (+ Firebase projects for App Check): `integration_test/auth01_emulator_test.dart`; App Check verified in console; cold start re-measured, noted in docs/roadmap.md (AC7, AC8, AC12, NFR-01)
- [ ] T16 Run spec-reviewer against spec.md; fix gaps; spec Status: Done; update docs/requirements.md
