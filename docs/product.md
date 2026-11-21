# RepForge — product brief

> Beat your last set.

Source documents (authoritative, kept in claude.ai):
- Requirements & Architecture Spec — https://claude.ai/artifact/WkQfM7Mq6V5jz1TdctnjyX
- Brand & App UI design canvas — https://claude.ai/artifact/RnzVTCHaMYxjH9wdqWWgcT

This repo holds the working copy of those decisions, split into small files the agent can read.

## Problem

- Schedules are tied to weekdays; a 3-on / 1-off split doesn't fit a 7-day week, so one missed
  day breaks the plan.
- Logging a set takes too many taps; people stop logging mid-workout.
- Last session's weight is hidden on another screen, so progressive overload is guesswork.
- Body metrics (BMI, body fat, BMR, TDEE, lean mass) are scattered or paywalled.
- Exercise libraries are hard to search by muscle or machine.

## Target user

Intermediate gym-goer, trains 3–5 days a week on a fixed split, wants to beat last session's
numbers, often trains with poor signal (so the app must work fully offline).

## Differentiators

| Feature | What it does | Requirements |
|---|---|---|
| Rolling Cycle Scheduler | N-day train/rest cycle that rolls forward; a missed day shifts the cycle instead of breaking it; streak counts cycle adherence | SCH-01…05, PRG-02 |
| Ghost Set | Each set shows last session's weight × reps and a suggested target; beating it fires a PR | LOG-01, LOG-02 |
| Body Snapshot | One form → BMI, body fat %, LBM, FFMI, BMR, TDEE, calorie targets, charted over time | BOD-01 |
| Goal Engine | Strength / weight / body-fat / consistency goals with a projected finish date from the user's own trend | GOL-01, GOL-02 |

## Platforms and release

- Android 8+ (API 26), iOS 15+, phone first (tablet in v1.1).
- MVP in ~10 weeks (solo, part-time), store release after closed beta, v1.1 by week 14.
  See [roadmap.md](roadmap.md).
