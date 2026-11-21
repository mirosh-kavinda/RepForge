# Requirements index and traceability

Every requirement ID gets a spec folder `specs/<ID>-<slug>/` when its slice starts.
Update **Status** as a slice moves: `—` (not started) → `Spec` → `Planned` → `Building` → `Done`.

Phases: P1 Foundations (wk 1–2) · P2 Core MVP (wk 3–8) · P3 Sync + beta (wk 9–10) · P4 v1.1 (wk 11–14).
Screen numbers refer to the design canvas (see [design.md](design.md)).

## Foundation slices (engineering, no product ID in the source spec)

| ID | Slice | Phase | Status |
|---|---|---|---|
| FND-01 | Project bootstrap: Flutter app, folder layout, lint, CI | P1 | In review (iOS CI pending) |
| FND-02 | Theme and brand tokens (`RfColors`, type, spacing, core widgets) | P1 | Spec |
| FND-03 | Local database, outbox table, exercise catalog seed + FTS search | P1 | Spec |
| FND-04 | Metrics package (BMI, BF %, LBM, FFMI, BMR, TDEE, e1RM, volume) | P2 | — |

## Functional requirements

| ID | Requirement (short) | Priority | Phase | Screens | Status |
|---|---|---|---|---|---|
| AUTH-01 | Google / Apple / email sign-in, guest mode, guest data migrates | MVP | P1 | 09 | Spec |
| ONB-01 | 60-second onboarding (goal, level, units, sex, birth year, height, weight) | MVP | P2 | 08, 10–12 | — |
| SCH-01 | Create rolling cycle of 1–14 days, each a template or Rest | MVP | P2 | 03, 12, 18 | — |
| SCH-02 | Cycle rolls forward from last completed day | MVP | P2 | 01, 15 | — |
| SCH-03 | Optional weekday-locked mode | MVP | P2 | 03 | — |
| SCH-04 | Swap, skip, move a day; unplanned rest; history kept | MVP | P2 | 17 | — |
| SCH-05 | Calendar + cycle view, month loads < 300 ms with 2 yrs data | MVP | P2 | 03 | — |
| WKT-01 | Workout template builder (sets, rep range, target, rest, supersets) | MVP | P2 | 13 | — |
| WKT-02 | Start today's workout in one tap from Home | MVP | P2 | 01 | — |
| LOG-01 | Log a set in ≤ 2 taps, prefilled from ghost; steppers | MVP | P2 | 02 | — |
| LOG-02 | Ghost Set + suggested target; PR badge when beaten | MVP | P2 | 02 | — |
| LOG-03 | Auto rest timer, notification + vibration, survives lock | MVP | P2 | 02 | — |
| LOG-04 | Warm-up / drop sets, failure flag, notes | v1.1 | P4 | 02 | — |
| LOG-05 | Finish summary: duration, volume, PRs, vs last session | MVP | P2 | 16 | — |
| EXL-01 | 800+ exercise library, search < 100 ms offline | MVP | P1 (data) / P2 (UI) | 04 | — |
| EXL-02 | Exercise detail: instructions, muscles, equipment, images, offline | MVP | P2 | 14 | — |
| EXL-03 | Custom exercises, synced | MVP | P2 | 04, 14 | — |
| BOD-01 | Body Snapshot form, all derived metrics saved at once | MVP | P2 | 05 | — |
| BOD-02 | Progress photos with camera, ghost outline, compare | v1.1 | P4 | 20, 25 | — |
| PRG-01 | Progress dashboard: e1RM, best set, volume, body trends | MVP | P2 | 06 | — |
| PRG-02 | Adherence stats + cycle streak (rest never breaks it) | MVP | P2 | 01, 06 | — |
| PRG-03 | 7-day muscle heat map | v1.1 | P4 | 22 | — |
| GOL-01 | Personal goals with projected finish date | MVP | P2 | 07, 19 | — |
| GOL-02 | Goal check-ins and drift alerts | v1.1 | P4 | 07 | — |
| NTF-01 | Local + push notifications, per-type toggles, quiet hours | MVP | P3 | 15, 21, 22 | — |
| SYN-01 | Offline-first, sync to Firebase; no loss after 30 days offline | MVP | P3 | 24 | — |
| SYN-02 | Restore on a new phone; 2 yrs data < 30 s on 4G | MVP | P3 | 24 | — |
| SYN-03 | Export CSV / JSON | v1.1 | P4 | 23 | — |
| SET-01 | Settings: units, theme, rest default, plate calculator, reminders | MVP | P2 | 23 | — |

## Non-functional requirements

Each NFR is verified inside the slices that touch it (named in their spec's "Constraints").

| ID | Area | Requirement | Verified by |
|---|---|---|---|
| NFR-01 | Performance | Cold start < 2 s mid-range Android; 60 fps; set write < 50 ms | FND-01 perf check, LOG-01 |
| NFR-02 | Offline | 100 % of logging, schedules, library, stats offline | every slice |
| NFR-03 | Reliability | Every set written locally immediately; sync retries with backoff | LOG-01, SYN-01 |
| NFR-04 | Security | Rules: owner-only `users/{uid}/**`; App Check; no health data in analytics | AUTH-01, SYN-01 |
| NFR-05 | Privacy | Data export, account deletion (Firestore + Storage) | SET-01, SYN-03 |
| NFR-06 | Accessibility | 48 dp targets, 200 % text, semantics labels, AA contrast both themes | FND-02, every UI slice |
| NFR-07 | Platforms | Android 8+ / iOS 15+, phone first | FND-01 |
| NFR-08 | Quality | ≥ 80 % unit coverage domain + metrics; widget tests logger + scheduler; sync integration test | CI gate (FND-01) |
| NFR-09 | Observability | Crashlytics, Performance, Analytics with defined event list | FND-01 / P3 |
| NFR-10 | Cost | Free quotas to ~5k MAU: one write per finished workout | LOG-05, SYN-01 |
| NFR-11 | Localisation | English first; ARB files ready for Sinhala, Tamil | FND-01 |
