# Roadmap and slice order

Solo developer, part-time. Durations are estimates; adjust as slices land.
Each slice runs the full loop (spec → plan → tasks → build → review) and ends in one PR.

## Phase 1 — Foundations (weeks 1–2)

| Order | Slice | Outcome |
|---|---|---|
| 1 | FND-01 Project bootstrap + CI | App runs on Android + iOS, folder layout, lints, CI green |
| 2 | FND-02 Theme + brand tokens | `RfColors` dark/light, type scale, RfButton/RfStepper/RfChip, theme mode System |
| 3 | FND-03 Local DB + exercise seed | Drift DB, base columns, outbox table, 870-exercise seed, FTS5 search < 100 ms |
| 4 | AUTH-01 Sign-in + guest | Google / Apple / email / guest; guest data migrates on first sign-in |

Exit: a signed-in or guest user lands on an empty Home shell with working bottom nav.

## Phase 2 — Core MVP (weeks 3–8)

| Week | Slices |
|---|---|
| 3 | FND-04 Metrics package · ONB-01 Onboarding (+ starter templates) |
| 4 | WKT-01 Template builder · SCH-01 Cycle builder |
| 5 | SCH-02 Rolling forward · SCH-03 Weekday mode · SCH-04 Day actions · SCH-05 Calendar |
| 6 | WKT-02 Start from Home · LOG-01 Two-tap logging · LOG-02 Ghost Set |
| 7 | LOG-03 Rest timer · LOG-05 Finish summary · EXL-02 Detail · EXL-03 Custom exercises |
| 8 | BOD-01 Body Snapshot · PRG-01/PRG-02 Progress + adherence · GOL-01 Goals · SET-01 Settings |

Exit: the full train-log-review loop works offline on a real phone for one week of use.

## Phase 3 — Sync + beta (weeks 9–10)

| Slices | Outcome |
|---|---|
| SYN-01 Outbox sync engine | Push/pull, backoff, conflict policy; 30-days-offline test passes |
| SYN-02 Restore | 2 years of data restored in < 30 s on 4G |
| NTF-01 Notifications | Reminders, rest-timer, streak, PR, weekly report; quiet hours |
| Beta | Closed beta with 20 users, Crashlytics clean, fixes + polish |

**Release gate — store release after beta sign-off:** all MVP rows `Done` in
[requirements.md](requirements.md), NFR-01/06/08 checks pass, no P1 crash in the last 7 beta days.

## Phase 4 — v1.1 (weeks 11–14)

BOD-02 Progress photos · PRG-03 Muscle heat map · GOL-02 Goal drift alerts · LOG-04 Advanced
sets · SYN-03 CSV/JSON export · tablet layout.

## Open questions (decide before the slice that needs it)

| Question | Blocks |
|---|---|
| Free app or paid tier (photos, advanced analytics)? Changes the Firestore cost plan | SYN-01, BOD-02 |
| Ghost Set step: fixed 2.5 kg or smallest plate the user owns (1.25)? | LOG-02 |
| Health Connect / Apple Health sync: v1.1 or later? | BOD-01 (data shape) |
| Sinhala and Tamil translations at launch or after? | FND-01 (l10n setup is ready either way) |

## Notes

### NFR-01 cold-start baseline (FND-01, 2026-11-21)

Placeholder shell only (no DB, no Firebase). Profile APK, Samsung Galaxy Note10 (SM-N970F),
Android 12. `adb shell am start -W -S` after `am force-stop`, `TotalTime` in ms.

| Condition | Samples (ms) | Typical |
|---|---|---|
| First launches after a fresh install | 1303, 1287, 1300, 1319 (one outlier: 3260) | ~1.3 s |
| Steady state (later launches) | 478, 461, 459, 453, 455 | ~0.46 s |

`flutter run --profile --trace-startup`: engine enter → first frame rasterized 1063 ms
(framework init 77 ms, first frame built 96 ms).

Target is < 2 s. Re-measure the same way when FND-03 (Drift open + seed) and AUTH-01 (Firebase
init) land, since both add startup work. iOS not yet measured (needs a Mac).
