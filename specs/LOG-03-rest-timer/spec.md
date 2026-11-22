# LOG-03: Auto rest timer

Status: Approved
Phase: P2 · Priority: MVP · Screens: 02 Workout logger

## Why

Resting the right amount between sets matters, and watching a clock or setting a phone timer
breaks focus. The timer should start by itself when a set is logged and tell you when to go,
even with the phone locked in your pocket.

## User stories

- As a lifter, logging a set starts my rest countdown for that exercise.
- As a lifter, I can add or take off 15 seconds, pause, or skip the rest.
- As a lifter, my phone buzzes and notifies me when rest is over, even when locked.

## Acceptance criteria

- **AC1** — Given the logger, when I log a set, then a rest countdown starts at that exercise's
  rest time from the workout (template rest, default 2:00) and shows as a bar in the logger with
  the time left (m:ss) and what comes next ("Next: Bench Press, set 3").
- **AC2** — Given a countdown is running, when I log another set, then it restarts for that
  set's exercise. Editing or deleting a logged set does not touch it.
- **AC3** — Given an exercise in a superset (grouped in the template), when I log a set of an
  exercise that is not the group's last, then no countdown starts (a running one is cancelled
  and "Next" points to the next exercise of the group). Logging the group's last exercise starts
  the rest.
- **AC4** — Given a countdown, then +15 s and −15 s change this rest only (never below 0:00,
  the template stays), Pause holds it and Resume continues, and Skip ends it with no alert.
- **AC5** — Given the countdown reaches 0:00, then the phone vibrates and shows a notification
  "Rest over" with the next set, also when the app is in the background or the phone is locked.
  In the app the bar says "Rest over" until the next set is logged or it is dismissed.
- **AC6** — Given I leave the logger or the app is closed while resting, when I come back, then
  the bar shows the correct time left (or "Rest over"), and the alert still came at the right
  time.
- **AC7** — Given notifications are not allowed on the phone, then the timer and in-app vibrate
  still work and the bar says "Turn on notifications to be alerted when locked", with a way to
  open the phone's settings. The permission is asked the first time a rest starts, not before.
- **AC8** — Given I finish or discard the workout, then any running countdown and pending alert
  are cancelled.

## Edge cases

- A rest time of 0 for an exercise starts no countdown.
- Pausing, then leaving the app: no alert while paused; the time left is kept.
- The phone's clock changes during a rest: the alert follows the original end time as near as
  the phone allows.
- −15 s past zero ends the rest at once, with the alert.
- The device's notification sound and silent mode are respected; vibrate follows the phone's
  vibrate setting.

## Constraints (NFRs that apply)

- NFR-02: works offline. NFR-01: logging stays < 50 ms; the timer adds no wait to Log.
- NFR-06: 48 dp controls, 200 % text, semantics labels; the time left is readable by screen
  readers without announcing every second (announced at start, on change and at the end).
- NFR-04: the notification shows only the exercise name and set number, no body data.

## Non-goals

- A rest timer outside a workout, or on Home.
- Custom sounds, voice cues, or a watch app.
- Changing an exercise's default rest from the logger (that's the template builder, WKT-01).

## Data touched

- The workout copy carries each exercise's rest time and superset group. The running rest
  (end time, paused time left) is kept on the phone with the workout.

## Open questions

- None.
