# SET-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Profile (screen 23) becomes a real screen: the AUTH-01 account section, then a Settings list.
Synced settings (units, default rest, bar and plates) are new columns on `user_profiles`,
written through `SyncedWriter`; phone-only ones (theme, reminder on/time) live in `app_meta`.
A pure plate solver in `lib/features/settings/domain/` backs the logger's Plates sheet. A
reminder scheduler (local notifications, like the LOG-03 rest alarm) keeps the next 14 planned
training days scheduled, re-run whenever the cycle, day records or reminder settings change.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/data/local/app_database.dart` | changed | `user_profiles` + default_rest_sec, bar_kg_metric, bar_kg_imperial, plates_metric, plates_imperial (JSON kg); schema v15 → v16 (AC4, AC5, AC11) |
| `lib/features/settings/domain/settings.dart` | new | `TrainingSettings` (units, restSec, bar + plates per unit, defaults) (AC2, AC4, AC5) |
| `lib/features/settings/domain/settings_repository.dart` | new | port: `watch`, `setUnits`, `setDefaultRest`, `setPlates`; phone prefs: theme, reminder |
| `lib/features/settings/domain/plates.dart` | new | `loadPlates(weight, bar, plates)` → per side, heaviest first, or closest lighter + shortfall / below bar (AC6, AC7) |
| `lib/features/settings/domain/reminder_rules.dart` | new | `reminderDays(cycle, records, today, …)` → next 14 dates + workout to remind for (AC8, edges) |
| `lib/features/settings/domain/workout_reminder.dart` | new | port: `allowed`, `request`, `replaceAll(dates, time, texts)`, `cancelAll`, `openSettings` (AC8–AC10) |
| `lib/features/settings/data/drift_settings_repository.dart` | new | profile columns via `SyncedWriter`; `app_meta` for theme and reminder (AC2–AC5, AC11) |
| `lib/features/settings/data/local_workout_reminder.dart` | new | flutter_local_notifications, channel "Workout reminder", ids 4000–4013; tap → Home (AC8, AC9) |
| `lib/features/settings/data/providers.dart` | new | repository, settings stream, `reminderScheduler` (re-schedules on change) |
| `lib/app/theme/theme_mode.dart` | changed | load / save the theme via the settings repository (AC3) |
| `lib/features/onboarding/data/providers.dart` | changed | `unitSystemProvider` reads the settings stream (AC2) |
| `lib/features/workout/domain/template_rules.dart` | changed | new rows take the default rest (AC4) |
| `lib/features/settings/presentation/profile_screen.dart` | changed | account section + Settings list with values in words (AC1) |
| `lib/features/settings/presentation/plates_screen.dart` | new | bar and plate toggles for the display unit (AC5) |
| `lib/features/settings/presentation/reminder_screen.dart` | new | switch, time, notifications-off line, "No cycle yet" (AC8, AC10, edge) |
| `lib/features/logger/presentation/plates_sheet.dart` | new | per-side breakdown sheet (AC6, AC7) |
| `lib/features/logger/presentation/set_row.dart` | changed | Plates button next to the weight stepper (AC6) |
| `lib/app/router.dart` | changed | `/profile/plates`, `/profile/reminder` |
| `lib/main.dart` | changed | notification tap → Home; scheduler started with the app (AC9) |
| `lib/app/l10n/app_en.arb` | changed | strings |
| `docs/architecture.md` | changed | settings storage note; UserProfile row columns |

## Data

- `user_profiles` (synced, outbox entity `userProfile`): `default_rest_sec` int default 120,
  `bar_kg_metric` / `bar_kg_imperial` real nullable, `plates_metric` / `plates_imperial` text
  nullable (JSON list of kg). Null = the defaults from AC5. Migration v15 → v16 adds them.
- `app_meta`: `settings.theme` (system / light / dark), `settings.reminderOn`,
  `settings.reminderTime` (HH:mm). Not synced (spec: on the phone only).

## Key decisions

- **Units (AC2).** One `units` column already exists (ONB-01); `setUnits` updates it, and
  `unitSystemProvider` keeps streaming it, so every screen follows at once.
- **Theme (AC3).** `AppThemeMode` builds from `app_meta` (System until read) and saves on set.
- **Default rest (AC4).** 0–600 s in 15 s steps; read by the template editor when it adds a row;
  existing rows untouched.
- **Plates (AC5–AC7).** Stored in kg; each unit's list kept separately (edge). The solver works
  in the display unit (kg values converted and rounded to 0.01) so 45 lb plates stay exact.
  Per side = (weight − bar) ÷ 2; a small dynamic programme over 0.01 steps picks the heaviest
  load ≤ target with unlimited plates of each size, fewest plates on ties; result heaviest
  first, plus shortfall when not exact; weight < bar → "Lighter than the bar".
- **Reminder days (AC8, edges).** From the active cycle and its records, the SCH-05 calendar
  plan logic (`buildMonth`) gives each coming date's planned workout; today counts only if its
  time hasn't passed and it isn't done, skipped, moved or rested. Weekday mode works the same
  way. Text: "{workout} day today", template name from the templates stream.
- **Scheduling (AC8).** `reminderScheduler` provider watches the cycle, records, templates and
  reminder settings, and replaces all 14 scheduled notifications on any change (idempotent).
  Listened from the app shell so it runs whenever the app is open.
- **Permission (AC10).** Turning it on asks once (like LOG-03); if refused or off, the screen
  shows the line and Open settings; the switch stays on.

## Packages

- None new (flutter_local_notifications, timezone, app_settings already in for LOG-03).

## Error handling

- A failed settings write shows a snackbar and keeps the old value. Scheduling failures are
  swallowed and retried on the next change; the reminder screen never blocks.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC6, AC7 | `test/features/settings/domain/plates_test.dart` | unit |
| AC8, edges | `test/features/settings/domain/reminder_rules_test.dart` | unit |
| AC2–AC5, AC11, schema | `drift_settings_repository_test.dart`, `app_database_test.dart` "v15 -> v16" | unit |
| AC8 scheduling | `test/features/settings/data/reminder_scheduler_test.dart` (fake reminder) | unit |
| AC1–AC5, NFR-06 | `test/features/settings/presentation/profile_screen_test.dart` | widget |
| AC5 | `test/features/settings/presentation/plates_screen_test.dart` | widget |
| AC6, AC7 | `test/features/logger/presentation/plates_sheet_test.dart` | widget |
| AC8–AC10 | `test/features/settings/presentation/reminder_screen_test.dart` | widget |
| AC4 | `template_rules_test.dart` "SET-01 default rest" | unit |

## Risks

- iOS allows 64 pending local notifications; 14 reminders + 1 rest alarm fit.
- Notification tap routing can't be widget-tested end to end; the tap handler is a small
  function unit-tested with a fake router, and checked by hand on a device.
- The settler-style scheduler re-runs often; replacing 14 notifications is cheap but must not
  fire while a workout is logging (the rest alarm uses a different id range).
