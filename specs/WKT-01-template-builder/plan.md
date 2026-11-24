# WKT-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

One synced table holds each workout with its exercises as a JSON column, matching the Firestore
`templates/{id}` document, so a save is one row and one outbox entry (AC13). All editing rules
(supersets, reorder, estimate, validation, unit conversion) are pure functions in `domain/`;
an editor controller holds the draft until Save (AC9). The Library gets a pick-mode screen on the
FND-03 search (AC3). Starter workouts are seeded from a const list on first read (AC12).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/workout/domain/workout_template.dart` | new | freezed `WorkoutTemplate`, `TemplateExercise`, `TargetKind` (AC2, AC4) |
| `lib/features/workout/domain/template_rules.dart` | new | name rules, limits, defaults, link/unlink/normalize supersets, reorder, inner-member rest, estimate, duplicate name, range swap, weight conversion (AC2–AC10, edges) |
| `lib/features/workout/domain/template_repository.dart` | new | `watchAll`, `byId`, `save`, `delete`, `restore`, `ensureStarters` |
| `lib/data/local/app_database.dart` | changed | `WorkoutTemplates` (SyncedTable: name, exercises JSON); schema v3 + migration |
| `lib/features/workout/data/drift_template_repository.dart` | new | writes via `SyncedWriter` (create / update / delete) (AC11, AC13) |
| `lib/features/workout/data/starter_templates.dart` | new | six starters on catalog ids (AC12) |
| `lib/features/workout/data/providers.dart` | new | repository, `templatesProvider` (seeds then watches) |
| `lib/features/onboarding/domain/onboarding_repository.dart` (+ drift, fake) | changed | `watchUnits()` from the profile; metric when none |
| `lib/features/onboarding/data/providers.dart` | changed | `unitSystemProvider` |
| `lib/features/workout/presentation/template_format.dart` | new | row line, rest m:ss, weight display in units (AC4, AC7) |
| `lib/features/workout/presentation/workouts_screen.dart` | new | My workouts list, empty state, duplicate, delete + Undo (AC1, AC10, AC11) |
| `lib/features/workout/presentation/template_editor_controller.dart` | new | draft, dirty check, save (AC2, AC5–AC9) |
| `lib/features/workout/presentation/template_editor_screen.dart` | new | screen 13: header chips, rows, select-for-superset bar, discard prompt (AC2, AC5–AC9) |
| `lib/features/workout/presentation/exercise_targets_sheet.dart` | new | target sheet (AC4, AC7) |
| `lib/features/library/presentation/exercise_picker_screen.dart` | new | screen 04 in pick mode (AC3) |
| `lib/features/library/presentation/muscle_groups.dart` | new | Chest, Back, Shoulders, Legs, Arms, Core → muscles; muscle labels |
| `lib/features/schedule/presentation/schedule_screen.dart` | changed | "My workouts" entry on the placeholder (AC1) |
| `lib/app/router.dart` | changed | `/schedule/workouts`, `/schedule/workouts/new[?copyOf=]`, `/schedule/workouts/:id` |
| `lib/app/widgets/rf_stepper.dart` | changed | optional `format` for m:ss rest values |
| `lib/app/l10n/app_en.arb` | changed | strings |

## Data

- `workout_templates`: id, name, exercises (JSON text), + updated_at, deleted_at, sync_state.
  Exercise entry: `{id, exId, sets, kind: reps|time, repMin, repMax, seconds, targetKg?, restSec,
  superset?}` — `id` keeps rows distinct when the same exercise is added twice.
- Schema v2 → v3: `onUpgrade` creates the table. `LocalDataWiper` covers it unchanged.
- `app_meta` `workout.startersSeeded = true` — wiped on sign-out, so a new user gets starters.
- Outbox entity `workoutTemplate` (create on first save, update after, delete on delete,
  update on restore).

## Key decisions

- **JSON column, not a child table (AC13).** Exercises are always read and written with their
  workout; one row keeps the save atomic and maps 1:1 to the Firestore document.
- **Superset letter stored, not derived (AC6).** Link takes the lowest free letter; after every
  edit `normalizeSupersets` clears any group that is no longer contiguous or has < 2 members, so
  reorder inside keeps it and moving out / dropping in between / removing ends it (edge).
- **Inner rest (AC7).** A member followed by a member of the same group has effective rest 0;
  its stored rest is kept so unlinking brings it back.
- **Estimate (AC8).** Σ sets × (work + effective rest), work = 40 s or the timed seconds;
  minutes rounded to nearest 5, min 5. Same function feeds the list (AC1).
- **Weight (edges).** Stored kg; lb input → kg rounded to 0.01; display 0.5 kg / 1 lb steps via
  FND-04 `displayMass`. Valid 0–500 kg after conversion.
- **Range swap on save (edge).** Steppers are independent; save stores min ≤ max.
- **Seeding (AC12).** `templatesProvider` awaits `ensureStarters()` (flag check, insert six in
  one transaction with the flag) then watches. Starters reference catalog ids only, so seeding
  does not wait on the catalog import. Later slices (SCH-01 starter plans, WKT-02) must read
  workouts through `templatesProvider` or call `ensureStarters()` first.
- **Typed filters (AC3).** Whole words naming a muscle, group or equipment become filters
  (`search_terms.dart`); the rest goes to the FTS name search. A typed filter narrows a chip.
- **Picker (AC3, NFR-01).** Debounce-free FTS search on each keystroke (FND-03: < 100 ms);
  single muscle-group chip, single equipment filter; picks kept in order; returns ids via
  `Navigator.pop`. Capacity = 30 − current, further picks disabled with a reason.
- **Non-drag reorder (NFR-06).** Row menu has Move up / Move down / Select for superset / Unlink
  / Remove; drag uses `ReorderableListView` handles.
- **Discard prompt (AC9).** `PopScope(canPop: !dirty)`; dirty = draft ≠ loaded value.
- **Duplicate (AC10).** Editor opens with `copyOf`; draft gets the copied exercises and
  "<name> (copy)" cut to 40; nothing saved until Save.
- **Delete + Undo (AC11).** Soft delete; Undo clears `deletedAt` as an update.
- **Design gap.** My workouts list and the target sheet use existing tokens and patterns
  (cards as on 13, sheets as on 11); no canvas screen exists.

## Packages

None new.

## Error handling

- A failed save keeps the editor open with the draft and shows "Couldn't save. Try again."
- An exercise id missing from the catalog shows as "Unknown exercise" and is still editable.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2, AC4–AC8, AC10, edges | `test/features/workout/domain/template_rules_test.dart` | unit |
| AC4, AC7 formatting | `test/features/workout/presentation/template_format_test.dart` | unit |
| AC11–AC13, schema | `test/features/workout/data/drift_template_repository_test.dart`, `test/data/local/app_database_test.dart` "v2 → v3" | unit |
| units | `test/features/onboarding/data/drift_onboarding_repository_test.dart` "watchUnits" | unit |
| AC1, AC10, AC11 | `test/features/workout/presentation/workouts_screen_test.dart` | widget |
| AC2, AC4–AC9, NFR-06 | `test/features/workout/presentation/template_editor_screen_test.dart` | widget |
| AC3 | `test/features/library/presentation/exercise_picker_screen_test.dart` (real catalog, in-memory DB) | widget |
| AC12 starters valid | `test/features/workout/data/starter_templates_test.dart` (ids exist in seed) | unit |

## Risks

- `ReorderableListView` inside a page with header and footer: use slivers or put header/footer
  in the list as non-reorderable items via `header`/`footer` props.
- Riverpod family controller args (id / copyOf) must not rebuild the draft on rebuilds.
