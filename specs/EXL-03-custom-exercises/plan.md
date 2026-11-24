# EXL-03: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Custom exercises live in a new synced table and reach every screen through the existing
`exerciseCatalogProvider`, which now returns a combined repository: catalog search (FTS) plus
the user's custom exercises matched in Dart (≤ a few hundred rows), and `byId` that finds both,
including deleted custom ones so old workouts keep working (AC7). `Exercise` gains `custom` and
`notes`. A form screen creates and edits; the detail screen adds Edit / Delete for custom ones.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/local/app_database.dart` | changed | `custom_exercises` (SyncedTable: name, equipment, primary / secondary muscles JSON, notes); schema v12 → v13 (AC1, AC8) |
| `lib/features/library/domain/exercise.dart` | changed | `Exercise.custom` (default false), `notes` (AC3, AC5) |
| `lib/features/library/domain/custom_exercise_repository.dart` | new | port: `watchAll`, `save`, `delete`, `restore`, `nameClash(name, {exceptId})` (AC1, AC2, AC6, AC7) |
| `lib/features/library/domain/custom_rules.dart` | new | `cleanExerciseName`, `canSaveCustom`, `matchesQuery(exercise, query)` (word-prefix, muscles, equipment), `nameKey` (AC2, AC3) |
| `lib/features/library/data/drift_custom_exercise_repository.dart` | new | Drift + `SyncedWriter` (entity `exercise`); `nameClash` also checks `catalog_exercises` (AC1, AC2, AC7, AC8) |
| `lib/features/library/data/combined_catalog.dart` | new | `ExerciseCatalogRepository` over catalog + custom: merge A–Z when browsing, custom matches first when searching (AC3) |
| `lib/features/library/data/providers.dart` | changed | `customExerciseRepositoryProvider`, `customExercisesProvider` (stream); `exerciseCatalogProvider` returns the combined one |
| `lib/features/library/presentation/custom_exercise_form.dart` | new | name, equipment, main / other muscle chips, notes with counter; Save rules and clash messages (AC1, AC2, AC6) |
| `lib/features/library/presentation/library_screen.dart` | changed | New exercise action; reruns search when custom exercises change; "Custom" in row meta (AC1, AC3) |
| `lib/features/library/presentation/exercise_picker_screen.dart` | changed | "Custom" in row meta; no results → New exercise prefilled; rerun after save (AC3, AC4) |
| `lib/features/library/presentation/exercise_detail_screen.dart` | changed | custom: "Custom", notes, Edit, Delete + Undo; no pictures / steps (AC5–AC7) |
| `lib/features/library/presentation/muscle_groups.dart` | changed | `exerciseMeta` prefixes "Custom" (AC3) |
| `lib/app/router.dart` | changed | `/library/new`, `/library/exercise/:id/edit` |
| `lib/app/l10n/app_en.arb` | changed | strings |
| `docs/architecture.md` | changed | local note on the combined catalog (Firestore path already listed) |

## Data

- `custom_exercises`: id (UUID v7), name, equipment (key), primary_muscles / secondary_muscles
  (JSON key lists), notes?, updated_at, deleted_at, sync_state. Firestore later:
  `users/{uid}/customExercises/{id}` (as in architecture.md; inside the owner path).
- Every write goes through `SyncedWriter` (outbox row in the same transaction). Delete is a
  soft delete; restore clears `deleted_at` (AC7).
- Templates and sessions keep referring by exercise id; sessions already copy the name at start,
  so finished workouts keep the logged name (AC6).

## Key decisions

- **One catalog port (AC3).** Wrapping `exerciseCatalogProvider` means picker, Library, template
  builder, Home's muscle summary and the logger see custom exercises with no other change.
- **Custom search in Dart (AC3, NFR-01).** Same word-prefix rule as `ftsQuery` on the name;
  muscles match main or other muscles; equipment exact. 200 rows filter in well under 1 ms.
- **Ordering (AC3).** Browsing (no text, no muscle): one A–Z list. With text or muscles: custom
  matches (A–Z) first, then catalog in its rank order.
- **Names (AC2).** `nameKey` = lower-case, inner spaces collapsed, trimmed. Clash checked against
  active custom exercises (except the one being edited) and active catalog exercises.
- **Deleted (AC7).** `search` skips deleted; `byId` still returns them, so templates and the
  logger keep their names. Undo calls `restore` from the snackbar.
- **Freshness.** Library and picker listen to `customExercisesProvider` and rerun their search
  when it changes; `exerciseByIdProvider` watches it too, so the detail reflects edits.
- **Timed vs reps.** Unchanged: chosen per workout row in the template builder, as for catalog
  exercises. "Body only" logs as Bodyweight (existing rule on equipment).

## Packages

- None.

## Error handling

- Save / delete / restore failures: snackbar ("Couldn't save the exercise", "Couldn't delete
  it"); the form keeps its input.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2, AC3 rules | `test/features/library/domain/custom_rules_test.dart` | unit |
| AC1, AC2, AC6–AC8, schema | `test/features/library/data/drift_custom_exercise_repository_test.dart`, `app_database_test.dart` "v12 → v13" | unit |
| AC3, AC7, NFR-01 | `test/features/library/data/combined_catalog_test.dart` | unit |
| AC1, AC2, AC6 form | `test/features/library/presentation/custom_exercise_form_test.dart` | widget |
| AC3, AC5, AC7 | `library_screen_test.dart`, `exercise_detail_screen_test.dart` "EXL-03 …" | widget |
| AC4 | `exercise_picker_screen_test.dart` "EXL-03 …" | widget |

## Risks

- Two catalogs to keep consistent; the combined repository is the only merge point.
- Name clash against the catalog uses its current names; a future catalog update could add a
  name equal to a custom one. Allowed (no rename forced); both show, the custom one marked.
