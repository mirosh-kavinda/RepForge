# ONB-01: 60-second onboarding

Status: Done (amended 2026-11-21 to match the design canvas: goal names, waist, activity)
Phase: P2 · Priority: MVP · Screens: 08 Welcome, 10 Goal + level, 11 About you
(12 Starter plan moves to SCH-01)

## Why

A few answers up front let every later screen show numbers in the right units and give
meaningful body and training estimates, without slowing a new user down.

## User stories

- As a new user, I see what the app does, sign in or go guest, then answer a few questions.
- As a user in a hurry, I can skip everything except units and be training in under a minute.

## Acceptance criteria

- **AC1** — Given a fresh install, when the app opens, then Welcome shows the tagline, the three
  feature lines (rolling cycles, Ghost Sets, Body Snapshot), "Get started" and "I already have
  an account"; either button opens Sign in.
- **AC2** — Given I finished Sign in (and, for an account, Account 09b) or skipped it, and have
  not completed onboarding, then step 1 shows; given onboarding is complete, then Home shows and
  onboarding never returns.
- **AC3** — Given step 1, then I can pick one goal, each with its one-line meaning (Build muscle,
  Get stronger, Lose fat, Stay consistent) and one experience level (Beginner, Intermediate,
  Advanced); either may be left unpicked.
- **AC4** — Given step 2, then units (kg · cm or lb · in) are required and preselected from the
  phone's region (Imperial for US, Liberia, Myanmar); sex (Male, Female, Prefer not to say), birth
  year, height, weight, waist and activity outside the gym (the five FND-04 levels) are optional,
  lengths and weights entered in the chosen units.
- **AC5** — Given a height, weight, waist or birth year outside the plausible ranges (age 13–100,
  height 100–250 cm, weight 25–350 kg, waist 40–250 cm, converted when Imperial), when I
  continue, then an inline error names the field and nothing is saved.
- **AC6** — Given I tap Finish, then my profile (with activity level) is saved on the phone in
  metric units, a weight or waist (if given) becomes my first body snapshot dated today, both are
  queued for backup, and Home shows. Switching units later never changes stored values.
- **AC7** — Given step 1, when I skip goal and level and accept the preselected units, then I
  reach Home in at most 3 taps.
- **AC8** — Given step 2, when I go back to step 1 and forward again, then my answers are kept.
- **AC9** — Given no network, then the whole flow works and saves.

## Edge cases

- App killed before Finish → nothing saved; the next launch resumes at step 1.
- Sex "Prefer not to say" is stored as not set (FND-04 then averages).
- Imperial height is feet + inches; weight is lb; both convert exactly (FND-04).
- Signing in on a new phone to an account that already has a profile: onboarding shows until
  restore exists (SYN-02 replaces the local profile on restore).

## Constraints (NFRs that apply)

- NFR-02 offline; NFR-06 48 dp targets, 200 % text, labels, choices not shown by colour alone.
- NFR-04 / CLAUDE.md: answers never go to analytics; stored metric only.
- NFR-01: Welcome is the first frame on a fresh install; no added cold-start cost after.

## Non-goals

- Starter plan / first cycle (SCH-01; the progress bar shows 2 steps until then). Editing answers
  later (SET-01). Measurements other than weight and waist (BOD-01). Onboarding illustrations
  (they land with the illustration set).

## Data touched

- User profile (goal, level, units, sex, birth year, height cm, activity level); first body
  snapshot (date, weight kg, waist cm); onboarding-complete flag; outbox rows for both.

## Open questions

- None blocking.
