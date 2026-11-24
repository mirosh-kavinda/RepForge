# LOG-02: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Three pure rules in `lib/features/logger/domain/ghost.dart`: the suggested target from last
session's sets, prefill ordering (target first), and whether a set is a PR given the exercise's
history. The repository gains one read: every finished set of an exercise. The set row shows the
ghost and target lines. PR badges are computed on screen from history plus this workout, so
edits and deletes re-evaluate them for free (AC7). Finish stores each set's PR flag for later
slices.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/logger/domain/ghost.dart` | new | `targets(row, lastSets, units)` (AC2–AC4), `prSets(row sets, history)` (AC6, AC7) using `core/metrics/strength.dart` `e1rm` |
| `lib/features/logger/domain/logger_rules.dart` | changed | `prefill` takes the target first, then in-workout, then the template (AC5) |
| `lib/features/logger/domain/session_repository.dart` | changed | `history(exerciseId)`: all finished sets of an exercise; `finish` stores PR flags |
| `lib/features/logger/data/drift_session_repository.dart` | changed | implements it via the `session_sets_exercise` index; PR flags written in Finish's transaction |
| `lib/data/local/app_database.dart` | changed | `session_sets.is_pr` bool default false; schema v9 → v10 |
| `lib/features/logger/data/providers.dart` | changed | `exerciseHistoryProvider(exerciseId)` |
| `lib/features/logger/presentation/set_row.dart` | changed | ghost line "Last: …" and "Target: …" in muted text; PR chip on a logged row; both in semantics (AC1, AC5, AC6, NFR-06) |
| `lib/features/logger/presentation/logger_screen.dart` | changed | passes last sets, targets and PR set ids to each row |
| `lib/app/l10n/app_en.arb` | changed | "Last: {set}", "Target: {set}", "PR" |

## Data

- `session_sets.is_pr` (bool, default false). Schema v9 → v10 adds it with `addColumn`. It is
  set only by Finish. During a workout the flag is computed, not stored.

## Key decisions

- **Targets per exercise, not per set (AC2).** "Every set reached the top" looks at last time's
  sets of that row. If true, every set number with a ghost gets weight + step at the bottom of
  the range. Otherwise each set gets its own weight and min(reps + 1, repMax). Step comes from
  `weightStep(units)` and is converted to kg. In lb the result is rounded to the 5 lb step (edge).
- **Timed (AC3).** If last time's seconds reached the template's seconds, add 5 s; else the
  same seconds.
- **Bodyweight (AC4).** A 0 kg last set on a bodyweight row gets reps + 1, with no cap and no
  weight.
- **Prefill order (AC5).** Target, then the last set logged in this row now, then the template.
  LOG-01's "last time" step becomes the target, since a target always exists when last time
  does.
- **PR (AC6).** For a logged set with reps ≤ 12, kg > 0 and not timed: PR if its `e1rm` beats
  the best `e1rm` of the history and of earlier sets of that exercise in this workout. Otherwise
  (timed, bodyweight, > 12 reps): PR if its reps (or seconds) beat the best ever at a weight ≥
  its own. An empty history means no PR. "Earlier" follows logged order in this workout.
- **History read (NFR-01).** One indexed query per exercise when the logger opens, cached by
  the provider. It never runs on a set write.
- **Wording (NFR-06).** The ghost and target lines are text, and the PR chip says "PR". The
  logged row's semantics label appends ", PR".

## Packages

None new.

## Error handling

- A failed history read shows rows without ghost or target (LOG-01 behaviour); logging still
  works.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2–AC7, edges | `test/features/logger/domain/ghost_test.dart` | unit |
| AC5 prefill order | `test/features/logger/domain/logger_rules_test.dart` "LOG-02 …" | unit |
| history, PR flags on Finish, schema | `drift_session_repository_test.dart` "LOG-02 …", `app_database_test.dart` "v9 → v10" | unit |
| AC1, AC5, AC6, AC7, NFR-06 | `test/features/logger/presentation/logger_screen_test.dart` "LOG-02 …" | widget |

## Risks

- History grows over the years. The query is indexed by exercise, and only kg / reps / seconds
  are read.
- PR on screen versus stored at Finish could differ if history changes mid-workout (another
  device). Finish recomputes, so the stored flag wins.
