# ONB-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Two new synced tables (profile, body snapshot) behind an onboarding repository that writes both
plus an `onboarding.done` flag in one transaction (AC6). The router gate grows from "choice made"
to choice + onboarded, so Welcome → Sign in → onboarding → Home is enforced from Drift alone,
offline (AC1, AC2, AC9). Answers live in a flow-scoped notifier until Finish (AC8, edge: killed →
nothing saved).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/core/metrics/units.dart` | changed | `UnitSystem {metric, imperial}`, `defaultUnitSystem(countryCode)` (AC4) |
| `lib/features/onboarding/domain/onboarding_answers.dart` | new | freezed answers; `TrainingGoal`, `TrainingLevel` (AC3, AC4) |
| `lib/features/onboarding/domain/answer_validation.dart` | new | field errors from FND-04 `Measure` ranges, age from birth year (AC5) |
| `lib/features/onboarding/domain/onboarding_repository.dart` | new | `complete(answers)`, `watchDone()` |
| `lib/data/local/app_database.dart` | changed | `UserProfiles`, `BodySnapshots` (SyncedTable); schema v2 + migration |
| `lib/features/onboarding/data/drift_onboarding_repository.dart` | new | one transaction: profile + optional snapshot via `SyncedWriter`, then the flag (AC6) |
| `lib/features/onboarding/data/providers.dart` (+ `.g.dart`) | new | repository, `onboardingDoneProvider`, `deviceRegionProvider` |
| `lib/app/router.dart` | changed | `/welcome`, `/onboarding`, `/onboarding/about`; `appRedirect(choice, onboarded, location)` (AC1, AC2) |
| `lib/features/onboarding/presentation/welcome_screen.dart` | new | screen 08 (AC1) |
| `lib/features/onboarding/presentation/onboarding_controller.dart` | new | flow state, kept across back/forward (AC8) |
| `lib/features/onboarding/presentation/goal_level_screen.dart` | new | screen 10 (AC3, AC7) |
| `lib/features/onboarding/presentation/about_you_screen.dart` | new | screen 11 (AC4, AC5, AC6) |
| `lib/app/l10n/app_en.arb` | changed | strings |
| tests | new / changed | see strategy; app-level test helpers also override the onboarded gate |

## Data

- `user_profiles`: id, goal?, level?, units, sex?, birth_year?, height_cm?, activity_level? + updated_at,
  deleted_at, sync_state. One live row per device owner.
- `body_snapshots`: id, date, weight_kg?, waist_cm? + base columns (BOD-01 adds measurements).
- Schema v1 → v2: `onUpgrade` creates both tables. `LocalDataWiper` already wipes any non-catalog
  table, so sign-out and discard cover them with no change.
- Outbox entities: `userProfile`, `bodySnapshot` (op create).

## Key decisions

- **Gate (AC1, AC2).** `appRedirect`: loading → stay; no choice → `/welcome` or `/sign-in/**`
  only; choice but not onboarded → `/onboarding/**` only; onboarded → start, welcome and
  onboarding go Home. Sign-in after onboarding (guest backing up) stays reachable.
- **Done flag in `app_meta` (AC2).** Written last in the Finish transaction, so a crash leaves no
  partial profile (edge). Wiped with everything else on sign-out, so a new user onboards again.
- **Store metric (AC6, CLAUDE.md).** Inputs are converted with FND-04 units at Finish; the form
  keeps what the user typed so switching units mid-form re-renders, not re-rounds.
- **Region default (AC4).** `PlatformDispatcher.locale.countryCode` through a provider (tests
  override it); US, LR, MM → imperial.
- **Taps (AC7).** Step 1 Continue → step 2 Finish → Home: two taps; no confirmation dialog.
- **Prefer not to say** → `sex = null` (FND-04 AC4 averaging).
- **Welcome art.** Text only until the illustration set lands (design.md lists it; no assets yet).

## Packages

None new.

## Error handling

- Validation errors are inline per field and block Finish (AC5).
- A failed Finish transaction leaves everything unchanged and shows a retry message.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC4 region | `test/core/metrics/units_test.dart` | unit |
| AC3–AC5 | `test/features/onboarding/domain/answer_validation_test.dart` | unit |
| AC6, edge | `test/features/onboarding/data/drift_onboarding_repository_test.dart` (rows, outbox, flag, rollback, wipe) | unit |
| schema | `test/data/local/app_database_test.dart` "v1 → v2 upgrade keeps data" | unit |
| AC1, AC2 | `test/app/router_auth_gate_test.dart` (redirect table + flow) | unit + widget |
| AC3, AC7, AC8 | `test/features/onboarding/presentation/onboarding_flow_test.dart` | widget |
| AC4–AC6, AC9 | `test/features/onboarding/presentation/onboarding_flow_test.dart` | widget |
| NFR-06 | 200 % text + labels in both screen tests | widget |

## Risks

- Drift migration from v1 is the first real migration; tested on a file DB downgraded to v1.
