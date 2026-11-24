# SCH-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

One synced table holds each cycle, its days as JSON (like WKT-01 templates), plus an active flag
and an anchor (start date + start day index). Where today falls, re-anchoring after edits,
previews and validation are pure functions in `schedule/domain` (AC4, AC7, AC8). The builder
mirrors the WKT-01 editor; Schedule becomes a real screen; onboarding gains step 3 (AC10).

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/schedule/domain/cycle.dart` | new | freezed `Cycle`, `CycleDay` (AC1, AC5) |
| `lib/features/schedule/domain/cycle_rules.dart` | new | limits, `saveProblem`, counts, add/move/remove/setWorkout, `calendarDay`, `dayIndexOn`, `reanchor`, `preview` (AC1–AC4, AC7, AC8, edges) |
| `lib/features/schedule/domain/starter_plans.dart` | new | PPL + Rest, Upper / Lower, Full Body + Rest by starter workout name; `buildPlan` (AC10) |
| `lib/features/schedule/domain/cycle_repository.dart` | new | `watchAll`, `watchActive`, `byId`, `save`, `delete`, `restore` |
| `lib/data/local/app_database.dart` | changed | `Cycles` table, schema v4 |
| `lib/features/schedule/data/drift_cycle_repository.dart` | new | save deactivates other active cycles in the same transaction (AC5, AC9, AC13) |
| `lib/features/schedule/data/providers.dart` | new | repository, `cyclesProvider`, `activeCycleProvider` |
| `lib/core/clock.dart` | new | `clockProvider` (today, overridable in tests) |
| `lib/features/workout/data/providers.dart` | changed | `workoutMusclesProvider(id)` for day rows |
| `lib/features/schedule/presentation/cycle_editor_controller.dart` | new | draft, dirty, save rules per new / copy / edit (AC2, AC5, AC8, AC12) |
| `lib/features/schedule/presentation/cycle_editor_screen.dart` | new | screen 18 (AC1–AC4, AC11, AC12) |
| `lib/features/schedule/presentation/workout_pick_sheet.dart` | new | pick a workout for a day (AC1, AC3, AC11) |
| `lib/features/schedule/presentation/cycle_day_tile.dart` | new | numbered day row shared by builder and Schedule (AC1, AC6, AC11) |
| `lib/features/schedule/presentation/starter_plan_cards.dart` | new | plan cards shared by onboarding and empty Schedule (AC6, AC10) |
| `lib/features/schedule/presentation/schedule_screen.dart` | changed | screen 03 cycle card, empty state, links (AC6) |
| `lib/features/schedule/presentation/cycles_screen.dart` | new | My cycles: activate, edit, duplicate, delete + Undo (AC9) |
| `lib/features/onboarding/presentation/plan_screen.dart` | new | screen 12 step 3 (AC10) |
| `lib/features/onboarding/presentation/{about_you_screen,onboarding_controller,step_header,goal_level_screen}.dart` | changed | step 2 Continue + `validate`, 3 steps |
| `lib/features/home/presentation/home_screen.dart` | changed | "Day n of N · …" line (AC7) |
| `lib/app/router.dart` | changed | `/onboarding/plan`, `/schedule/cycles`, `/new[?copyOf=]`, `/:id` |
| `lib/app/l10n/app_en.arb` | changed | strings |

## Data

- `cycles`: id, name, days (JSON `[{id, workoutId|null}]`), is_active, start_date (UTC midnight of
  the phone's calendar day, as body snapshots), start_day_index + base columns. Schema v3 → v4.
- Outbox entity `cycle`. Activating writes the newly active cycle and each one it deactivates.

## Key decisions

- **Today (AC7).** `dayIndexOn = (startDayIndex + days(startDate → today)) mod length`, with a
  non-negative mod; days counted between UTC-midnight calendar days, so DST and zone changes
  never move it (edge). SCH-02 replaces the formula, not the anchor fields.
- **Re-anchor on edit (AC8).** On saving the active cycle: today's row id in the old days → its
  index in the new days, else the old index clamped; anchor becomes (today, that index).
- **Save by origin (AC5, edge).** New → active from today at the chosen day. Copy → inactive.
  Edit → keeps its active flag; active ones re-anchor. Activating (AC9) = anchor (today, n − 1).
- **One active (AC5, AC9).** `save` of an active cycle clears `is_active` on others in the same
  transaction, each with its own outbox row.
- **Deleted workouts (AC11).** Days keep the workout id; a day whose id is not among active
  workouts shows "Workout deleted". It still counts as training, so Save rules are unchanged.
- **Onboarding (AC10, ONB-01 AC6/AC7).** Step 2 button becomes Continue (validates only). Step 3
  Start training saves the chosen plan's cycle, then completes onboarding (flag last); Skip and
  "Build my own" complete onboarding first. Taps: Continue, Continue, Start training = 3.
- **Starter plans (AC10, edge).** Built from active workouts with the starter names; a plan with a
  missing workout is not offered. Reading through `templatesProvider` seeds starters first.
- **Builder "Today is day n" (AC4).** Shown for a new cycle only; edits show the re-anchored
  preview. Clamped to length.
- **Design gap.** My cycles list uses the My workouts pattern; no canvas screen.

## Packages

None new.

## Error handling

- Save failure keeps the draft, "Couldn't save. Try again." (as WKT-01).
- Deleting the active cycle is refused in the repository and explained in the UI (AC9).

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1–AC4, AC7, AC8, edges | `test/features/schedule/domain/cycle_rules_test.dart` | unit |
| AC10 plans | `test/features/schedule/domain/starter_plans_test.dart` | unit |
| AC5, AC9, AC13, schema | `test/features/schedule/data/drift_cycle_repository_test.dart`, `app_database_test.dart` "v3 → v4" | unit |
| AC1–AC5, AC8, AC11, AC12 | `test/features/schedule/presentation/cycle_editor_screen_test.dart` | widget |
| AC6, AC7, AC9 | `test/features/schedule/presentation/schedule_screen_test.dart` (app + router) | widget |
| AC10 | `test/features/onboarding/presentation/onboarding_flow_test.dart` | widget |

## Risks

- Changing onboarding to 3 steps rewrites ONB-01 flow tests; ONB-01 spec notes this move.
