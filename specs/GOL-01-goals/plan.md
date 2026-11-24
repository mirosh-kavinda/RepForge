# GOL-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

A new synced `goals` table (Drift + outbox, like custom exercises) holds what the user set; the
current value, progress, projection and pace are worked out on read by pure rules in
`lib/features/goals/domain/`, using `lib/core/metrics` (`bestE1rm`, `projectGoal`). A settler
provider (like the SCH-02 cycle settler) marks goals achieved when data reaches the target. New
routes `/progress/goals`, `/progress/goals/new`, `/progress/goals/:id/edit`; a Goals entry on
Progress and a goal card on Home.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/local/app_database.dart` | changed | `goals` table; schema v14 → v15 (AC12) |
| `lib/features/goals/domain/goal.dart` | new | `Goal` (freezed): id, type (strength / bodyWeight), exerciseId?, startValue, target, deadline?, pinned, createdAt, achievedAt? |
| `lib/features/goals/domain/goal_repository.dart` | new | port: `watchAll`, `save`, `pin`, `achieve`, `delete`, `restore` |
| `lib/features/goals/domain/goal_rules.dart` | new | `goalHistory` (per-workout best e1RM / snapshot weights), `goalStatus` (current, %, projection, pace), `validateTarget`, `reachedOn`, `homeGoal` (AC2–AC7, AC10, edges) |
| `lib/features/goals/data/drift_goal_repository.dart` | new | Drift + `SyncedWriter`; pin clears the others in one transaction (AC7–AC10, AC12) |
| `lib/features/goals/data/providers.dart` | new | repository, goals stream, per-goal status, `goalSettler`, home goal |
| `lib/features/goals/presentation/goals_screen.dart` | new | active list + Achieved list, row actions (pin, edit, mark achieved, delete + Undo) (AC1, AC4, AC5, AC7, AC9) |
| `lib/features/goals/presentation/goal_form_screen.dart` | new | new / edit: type, lift picker, target in display unit, deadline, live projection, validation (AC2, AC3, AC8, AC11) |
| `lib/features/goals/presentation/goal_card.dart` | new | Home card / "Set a goal" link (AC10) |
| `lib/features/goals/presentation/goal_text.dart` | new | projection / pace / progress wording shared by list, form and card |
| `lib/features/home/presentation/home_screen.dart` | changed | goal card under the today card; listens to `goalSettler` |
| `lib/features/progress/presentation/progress_screen.dart` | changed | Goals entry (AC1) |
| `lib/app/router.dart` | changed | goal routes |
| `lib/app/l10n/app_en.arb` | changed | strings |
| `docs/architecture.md` | changed | Goal entity row (pinned, achievedAt) and note |

## Data

- `goals`: id, type (text), exercise_id (nullable), start_value, target_value (metric: kg),
  deadline (nullable, UTC midnight), pinned (bool), achieved_at (nullable) + `SyncedTable`
  columns (updatedAt, deletedAt, syncState). Outbox entity `goal`; Firestore
  `users/{uid}/goals/{id}` (path already in architecture.md). Covered by `LocalDataWiper`.

## Key decisions

- **History (AC3, AC4, edges).** Strength: one point per finished workout = best e1RM of its
  sets (`bestE1rm`, so > 12 reps and no-weight sets give none), via `exerciseLog(limit: null)`.
  Body weight: every live snapshot with a weight, onboarding included.
- **Current value (AC2, AC4).** The latest point. Start value = current when the goal is saved.
- **Direction (AC2, edges).** Strength target must be above current; weight above or below;
  equal → "You're already there". Direction is fixed at creation (target vs start).
- **Progress (AC4).** (current − start) ÷ (target − start), clamped 0–100 %.
- **Projection (AC3, AC4).** `projectGoal(history, target, today)`: OnTrack → date;
  NotEnoughData / NotOnTrack → their sentences.
- **Pace (AC5).** Deadline set: passed and not achieved → "Deadline passed"; projected ≤
  deadline → "On pace"; projected later or NotOnTrack → "Behind"; NotEnoughData → no pace.
- **Achieving (AC6, edges).** `goalSettler` watches goals and their histories; for an active
  goal, the first point after `createdAt` that reaches the target writes `achievedAt` = that
  point's date and unpins it. Achieved stays achieved.
- **Mark achieved (AC7).** `achievedAt` = today, unpinned.
- **Edit (AC8).** Target and deadline only; validated against the current value.
- **Pin and Home (AC10).** Pinning sets this goal and clears every other pinned one in one
  transaction. Home goal = pinned active, else newest active by `createdAt`, else "Set a goal".
- **Units (AC11).** Stored kg; entered and shown in the display unit (`kgToLb` / `lbToKg`).
- **Deleted lifts (edge).** Name from the combined catalog `byId`, which finds deleted custom
  exercises.

## Packages

- None new.

## Error handling

- A failed save / delete shows a snackbar and leaves the screen as it was. A failing history
  shows "Not enough data yet" for that goal; Home's card never blocks the today card.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2–AC7, AC10, edges | `test/features/goals/domain/goal_rules_test.dart` | unit |
| AC7–AC10, AC12, schema | `test/features/goals/data/drift_goal_repository_test.dart`, `app_database_test.dart` "v14 -> v15" | unit |
| AC6 settler | `test/features/goals/data/goal_settler_test.dart` | unit |
| AC1, AC4, AC5, AC7, AC9 | `test/features/goals/presentation/goals_screen_test.dart` | widget |
| AC2, AC3, AC8, AC11 | `test/features/goals/presentation/goal_form_screen_test.dart` | widget |
| AC10, NFR-06 | `test/features/goals/presentation/goal_card_test.dart` | widget |

## Risks

- The settler reads every active strength goal's whole lift history on each change; few goals,
  so cheap, but it reuses the two-query `exerciseLog`.
- A goal created offline on two phones before SYN-01 can both be pinned; SYN-01's conflict
  policy keeps the latest `updatedAt`.
- Review follow-ups: edits write only target and deadline (`updateTarget`) and keep the goal's
  direction; Undo restores a goal unpinned; targets are compared at display precision. A goal
  on a deleted custom exercise relies on the combined catalog's `byId` finding it (EXL-03
  test "AC7 delete hides it but byId still finds it"); there is no GOL-01 widget test for it.
