# EXL-01, EXL-02: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

The Library tab reuses the picker's search path (`parseSearchTerms` → `ExerciseQuery` →
FTS catalog search) and its filter widgets, extracted so both screens share them; the picker
keeps its behaviour (AC9). With an empty query the tab shows "Recent" (from finished sets) above
the A–Z list. A detail route reads the exercise from the catalog, the user's history from the
session repository and pictures through a cached network image keyed to the pinned catalog
source. Add to workout appends to a template through the template repository.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/library/presentation/library_screen.dart` | changed | screen 04: search field, filters, Recent + All exercises, no-match state (AC1–AC4) |
| `lib/features/library/presentation/exercise_filters.dart` | new | muscle group chips + equipment sheet button, extracted from the picker (AC3, AC9) |
| `lib/features/library/presentation/exercise_search.dart` | new | `runSearch(repo, text, group, equipment, l10n)` extracted from the picker (AC2, AC9) |
| `lib/features/library/presentation/exercise_picker_screen.dart` | changed | uses the two extracts; no behaviour change (AC9) |
| `ExerciseRow` in `library_screen.dart` | new | name, equipment, main muscles; tap → detail (AC4) |
| `lib/features/library/presentation/exercise_detail_screen.dart` | new | screen 14: pictures, muscles, equipment, level, type, steps, history, Add to workout (AC5–AC8) |
| `lib/features/library/presentation/add_to_workout_sheet.dart` | new | pick a workout; added / already in / no workouts → new workout (AC8) |
| `lib/features/library/data/exercise_images.dart` | new | `exerciseImageUrl(path)` (pinned source commit) and `exerciseImageProvider` (`CachedNetworkImageProvider`, overridable) (AC6) |
| `lib/features/library/data/providers.dart` | changed | `exerciseByIdProvider(id)` |
| `lib/features/logger/domain/session_repository.dart` | changed | `recentExerciseIds(limit)`, `exerciseLog(exerciseId, limit)` (AC1, AC7) |
| `lib/features/logger/data/drift_session_repository.dart` | changed | the two reads (indexed on `session_sets_exercise`) |
| `lib/features/logger/data/providers.dart` | changed | `recentExercisesProvider`, `exerciseLogProvider(id)`, `exerciseBestE1rmProvider(id)` |
| `lib/features/workout/domain/template_rules.dart` | changed | `addToTemplate(template, exerciseId)` → added / already / full (AC8) |
| `lib/app/router.dart` | changed | `/library/exercise/:id` under the Library branch (AC4) |
| `lib/app/l10n/app_en.arb` | changed | library and detail strings |
| `docs/architecture.md` | changed | image cache note |

## Data

- No schema change. Recent: `SELECT exercise_id, MAX(ended_at)` over finished, not deleted
  sessions' sets, grouped by exercise, newest first, `LIMIT 10`.
- Exercise log: per finished session with that exercise (newest first, `LIMIT 5`), its date and
  sets; the best set ranks by Epley (also past 12 reps, ranking only), else most reps /
  seconds. Recent is a watched query, so an open Library updates after Finish.
- Best e1RM: `core/metrics` `bestE1rm` over `history(exerciseId)` (existing).
- Pictures: `https://raw.githubusercontent.com/yuhonas/free-exercise-db/<commit>/exercises/<path>`,
  commit = the seed's pinned source, cached on disk by `cached_network_image`.

## Key decisions

- **Shared search (AC2, AC9).** Extract, don't fork, the picker's search and filters; the
  picker's tests stay green unchanged (AC9 proof).
- **Recent (AC1).** Recent ids resolved through `byId`; ids missing from the catalog (custom
  later, or retired) are skipped. Shown only when text is blank and no filter is set.
- **Lazy list (NFR-01).** One `ListView.builder` over [header, recent…, header, all…].
- **Pictures (AC6, edges).** `exerciseImageProvider` is a Riverpod provider returning an
  `ImageProvider` per path, so tests override it with a memory or failing image. Error and
  loading both show the same placeholder text ("Pictures need a connection the first time").
  No picture area when `images` is empty. A failed load is not cached, so the next open retries.
- **History (AC7).** e1RM from `core/metrics` only. Dates via `DateFormat.MMMEd`, weights via
  the logger's `shortSetText` in the display unit.
- **Add to workout (AC8).** `addToTemplate` returns `added | already | full`; `added` saves
  through `TemplateRepository.save` (outbox in the same transaction). Full (template at its
  exercise limit) shows the limit message. No workouts → "New workout" opens the template
  builder via `Routes.workoutNew`.

## Packages

- `cached_network_image` (already in architecture.md): disk-cached network images (AC6).

## Error handling

- Exercise id not in the catalog: detail says "Exercise not found" with back.
- History read fails: the history section says "Couldn't load your history"; the rest shows.
- Template save fails: snackbar "Couldn't add to workout"; nothing changed.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1, AC7 reads | `test/features/logger/data/drift_session_repository_test.dart` "EXL-01 …", "EXL-02 …" | unit |
| AC8 rule | `test/features/workout/domain/template_rules_test.dart` "EXL-02 …" | unit |
| AC6 URL | `test/features/library/data/exercise_images_test.dart` | unit |
| AC1–AC4, NFR-06 | `test/features/library/presentation/library_screen_test.dart` | widget |
| AC5–AC8, edges, NFR-06 | `test/features/library/presentation/exercise_detail_screen_test.dart` | widget |
| AC9 | existing `exercise_picker_screen_test.dart`, unchanged | widget |
| AC2 speed | existing `exercise_search_test.dart` "AC6 desktop smoke" (same query path) | unit |

## Risks

- Pictures depend on GitHub's raw host staying up; the pinned commit keeps URLs stable.
- `cached_network_image` brings sqflite + path_provider; iOS build unverified (no Mac).
