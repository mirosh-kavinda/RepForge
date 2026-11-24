# PRG-02: plan

Spec: ./spec.md (must be Approved)
Status: Approved

## Approach

Past days are already settled into day records (SCH-02 settler: done, missed, rest, skipped,
unplanned rest, moved). A pure rule turns every record plus today's rolled state into one
status per date, mapped onto `core/metrics` `DayStatus`; `adherence` and `cycleStreak` (plus a
new `bestCycleStreak`) do the maths. A provider streams this from Drift, so Home's chip and the
Progress Adherence card update as soon as a record is written.

## Files

| Path | New / changed | Purpose |
|---|---|---|
| `lib/core/metrics/adherence.dart` | changed | add `DayStatus.unplannedRest` (neutral, not planned); `bestCycleStreak` (AC2, AC4) |
| `lib/features/progress/domain/adherence_rules.dart` | new | `dayHistory` (records + today → dated statuses), `adherenceSummary` for a range: %, done/planned, weekly %, missed list (AC2–AC7, edges) |
| `lib/features/progress/data/providers.dart` | changed | `statusHistoryProvider` (stream), `streakProvider`, `adherenceProvider` (range from PRG-01 switch) |
| `lib/features/progress/presentation/adherence_section.dart` | new | Adherence card: %, "18 of 20", current / best streak, weekly bars, missed list with Show all (AC3–AC8) |
| `lib/features/progress/presentation/progress_charts.dart` | changed | bar chart accepts weeks with no value: no rod, tooltip "No training planned" (AC5, AC8) |
| `lib/features/progress/presentation/progress_screen.dart` | changed | Adherence card above Strength (AC3) |
| `lib/features/home/presentation/streak_chip.dart` | new | "12-day streak" / "Start a streak today"; tap → `/progress` (AC1) |
| `lib/features/home/presentation/home_screen.dart` | changed | chip above the today card (AC1) |
| `lib/app/l10n/app_en.arb` | changed | strings |
| `docs/architecture.md` | changed | adherence/streak note: unplanned rest, today, two cycles |

## Data

- No schema change. Reads `day_records` for every cycle from the first record to today via the
  existing `watchRange` (indexed on date), the active cycle + `cycleToday`, and template names.

## Key decisions

- **One status per date (edges).** Records from every cycle; on a date with two, the active
  cycle's wins, else the latest update (same rule as the SCH-05 calendar). Dates with no record
  (before the first cycle, or between cycles) are absent, so they neither count nor break the
  streak.
- **Mapping (AC2, AC3).** done → done; missed → missed; rest → rest; skipped → skipped;
  moved → moved; unplannedRest → new `unplannedRest` (neutral for streak, not planned for
  adherence); planned → pending.
- **Today (AC2, AC3).** Today's record if any; else a training row is `pending` (neutral) and a
  rest row is `rest`, so a planned rest day extends the streak on the day itself.
- **Done on a rest day (edge).** Already a `done` record (`markDone` writes over no record) →
  counts as done and planned; nothing extra needed.
- **After midnight (edge).** A session's date is the day it started and `markDone` uses it
  (LOG-01); covered by an existing test, cited rather than re-built.
- **Best streak (AC4).** `bestCycleStreak` = longest run over the whole history with the same
  rules (`max(current, longest past run)`), in `core/metrics` so formulas stay there.
- **Range and weeks (AC3, AC5, AC7).** Range start from PRG-01 `rangeStart`; weeks Monday start
  via `weekStart`; each week's % uses `adherence`; `NotEstimable` → week with no bar, labelled
  "No training planned"; range with 0 planned → "Not enough data", no bars.
- **Missed list (AC6).** Missed + skipped in range, newest first; name = record's `workoutId`
  else the cycle row's workout, looked up in templates; a deleted one → "Workout". First 5, then
  "Show all" expands in place (no new screen).
- **Accessibility (AC8).** Card summary for screen readers ("Adherence, 3 months: 90 %, 18 of 20
  training days; streak 12 days, best 21"); statuses as words; bars reuse the PRG-01 pattern.

## Packages

- None new (`fl_chart` already used).

## Error handling

- A failing stream shows the card's "Not enough data" text and hides the Home chip; nothing
  blocks Home's today card.

## Test strategy

| AC | Test file | Kind |
|---|---|---|
| AC2, AC4 metrics | `test/core/metrics/adherence_test.dart` (unplannedRest, best streak) | unit |
| AC2–AC7, edges | `test/features/progress/domain/adherence_rules_test.dart` | unit |
| AC1, AC9 | `test/features/home/presentation/streak_chip_test.dart` | widget |
| AC3–AC8, NFR-06 | `test/features/progress/presentation/adherence_section_test.dart` | widget |
| AC9 live update | provider test: skipping today changes the streak/adherence stream | unit |

## Risks

- Whole-history stream for best streak: ~730 rows for 2 years, cheap, but rebuilt on every
  record change; keep the rule O(n) and the provider shared by Home and Progress.
- Today's status depends on the rolled state; using `cycleToday` keeps Home and the card
  consistent with the today card.
- Known gap (review G4): settled missed records carry no `workoutId`, so after a cycle edit a
  past missed day's name follows the new row. Statuses stay as recorded. Fixing it means
  storing the row's workout on settled records, which touches SCH-04 undo and the SCH-05 swap
  display; left for a schedule slice.
