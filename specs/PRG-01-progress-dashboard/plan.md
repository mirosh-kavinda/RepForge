# PRG-01: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Pure rules in `lib/features/progress/domain/progress_rules.dart` turn finished workouts and body
snapshots into chart series and summaries for a range, using `lib/core/metrics` for e1RM and
volume. Two new session reads feed them. The Progress tab becomes a scroll of: range switch,
Strength, Volume, Body trends, Body card. Charts use `fl_chart` with tokens from `RfColors`,
touch tooltips and a text summary each.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/features/progress/domain/progress_rules.dart` | new | `ProgressRange` + start date; `strengthSeries`, `weeklyVolume`, `bodyTrends` (AC1–AC5, edges) |
| `lib/features/logger/domain/session_repository.dart` | changed | `exerciseSetCounts()`, `finishedSetsSince(from)`; `exerciseLog` takes `limit: null` for all (AC2, AC3) |
| `lib/features/logger/data/drift_session_repository.dart` | changed | the reads (indexed joins) |
| `lib/features/progress/data/providers.dart` | new | range state, chosen exercise (remembered in `app_meta`), series providers |
| `lib/features/progress/presentation/progress_screen.dart` | changed | range switch + sections + Body card |
| `lib/features/progress/presentation/progress_sections.dart` | new | Strength (line, summary, Change exercise), Volume (weekly bars), Body trends (weight and body fat lines) (AC2–AC7) |
| `lib/features/progress/presentation/progress_charts.dart` | new | line / bar chart widgets with tooltips and semantics summaries; section frame; unit formatting (AC6, AC7) |
| `lib/app/l10n/app_en.arb` | changed | strings |
| `docs/architecture.md` | changed | progress note |

## Key decisions

- **Ranges (AC1).** 28 days, 91 days, 365 days, or all, counted back from today (phone's day).
- **Strength (AC2, edges).** Per workout: best e1RM (`core/metrics` `bestE1rm`); if none
  (bodyweight, timed, or > 12 reps only) the exercise falls back to best reps / seconds per
  workout. Best set = heaviest weight, then most reps. Change = last point − first point.
- **Default exercise (AC2).** The one with most finished sets; the chosen one is saved in
  `app_meta` (`progress.exercise`).
- **Volume (AC3).** `core/metrics` `volume` per ISO week (Monday start, local days), every week
  in the range present, zeros included.
- **Body (AC4).** Weight from all snapshots with weight; body fat from saved results (scale or
  tape) where estimable.
- **Enough data (AC5).** A line needs 2 points in the range; bars need 1 week with volume.
- **Accessibility (AC7).** Each chart is `ExcludeSemantics` with a `Semantics` label summary
  ("Estimated 1RM, 3 months: 100 to 110 kilograms, up 10"); lines carry text legends.

## Packages

- `fl_chart` (already in architecture.md): line and bar charts with touch tooltips.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC1–AC5, edges | `test/features/progress/domain/progress_rules_test.dart` | unit |
| reads | `drift_session_repository_test.dart` "PRG-01 …" | unit |
| AC1–AC7, NFR-06 | `test/features/progress/presentation/progress_screen_test.dart` | widget |

## Risks

- `fl_chart` touch tooltips are hard to drive in widget tests; tests check the semantics
  summaries and that charts render, and the tooltip builder is unit-tested.
