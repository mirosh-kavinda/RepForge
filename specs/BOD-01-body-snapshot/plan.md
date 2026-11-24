# BOD-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A pure `computeBodyResults` in the body feature's domain calls only `lib/core/metrics` and
returns one `Estimate<double>` per metric. Saving a snapshot stores the inputs and those
results (as JSON) together, replacing today's row if there is one, and saves the activity level
to the profile, all in one transaction with outbox rows. The Progress tab gets a Body card;
the form, history and a read-only snapshot view are new routes under `/progress`.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/local/app_database.dart` | changed | `body_snapshots` + neck_cm, hip_cm, scale_body_fat_pct, activity, results (JSON); schema v13 → v14 (AC3, AC4) |
| `lib/features/body/domain/body_snapshot.dart` | new | `BodySnapshot` (inputs, activity, results), `BodyProfile` (sex, birth year, height, activity), `BodyMetric` enum (AC3) |
| `lib/features/body/domain/body_rules.dart` | new | `computeBodyResults(input, profile, today)`: scale BF% wins, else tape, else missing; BMI, LBM, FFMI, BMR, TDEE, targets, protein (AC3–AC5, edges) |
| `lib/features/body/domain/body_repository.dart` | new | port: `watchProfile`, `watchAll`, `byId`, `saveToday`, `delete`, `restore` (AC1, AC3, AC6, AC7) |
| `lib/features/body/data/drift_body_repository.dart` | new | Drift + `SyncedWriter`; results JSON codec; replace by date; activity to profile in the same transaction (AC3, AC6, AC8) |
| `lib/features/body/data/providers.dart` | new | repository, profile, snapshots providers |
| `lib/features/body/presentation/body_card.dart` | new | latest snapshot or empty state, New snapshot (AC1) |
| `lib/features/body/presentation/body_form_screen.dart` | new | inputs in the display unit, hip for women, activity, range check, Save (AC2, AC3, edges) |
| `lib/features/body/presentation/body_history_screen.dart` | new | list newest first; delete with Undo (AC7) |
| `lib/features/body/presentation/body_results.dart` | new | results list with "—" and reason text, "from scale", approximate mark (AC4, AC5) |
| `lib/features/progress/presentation/progress_screen.dart` | changed | Body card |
| `lib/app/router.dart` | changed | `/progress/body`, `/progress/body/new`, `/progress/body/:id` |
| `lib/app/l10n/app_en.arb` | changed | strings |

## Data

- Results JSON: `{metric: {"v": number, "a": bool}}` or `{metric: {"r": reason, "f": field?}}`
  for every `BodyMetric` (bmi, bodyFat, leanMass, ffmi, bmr, tdee, cut, maintain, gain,
  proteinMin, proteinMax).
- Onboarding snapshots have no results; history shows their weight and works results out on
  view with the current profile (never stored back).
- Firestore later: `users/{uid}/bodySnapshots/{id}` (already in architecture.md).

## Key decisions

- **One per day (AC6).** `saveToday` looks up an active row with today's date (UTC midnight of
  the phone's day, as ONB-01) and updates it; else inserts.
- **Body fat (AC4).** Scale value (range-checked) → tape (`bodyFatNavy`) → `missing` with the
  first missing tape field. LBM / FFMI / BMR take that estimate.
- **Reasons (AC5).** Presentation maps `(reason, field)` to text; never shows a number for a
  `NotEstimable`.
- **Units (AC2).** Inputs typed in kg / cm or lb / in, converted to kg / cm before saving.

## Packages

- None.

## Error handling

- Save / delete failures: snackbar; the form keeps its input.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC3–AC5, edges | `test/features/body/domain/body_rules_test.dart` | unit |
| AC3, AC6–AC8, schema | `test/features/body/data/drift_body_repository_test.dart`, `app_database_test.dart` "v13 -> v14" | unit |
| AC1–AC7, NFR-06 | `test/features/body/presentation/body_screens_test.dart` | widget |

## Risks

- Results saved with the profile of the day; a corrected height later doesn't fix old rows (by
  spec).
