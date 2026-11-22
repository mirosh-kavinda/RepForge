# LOG-05: Finish summary

Status: Approved
Phase: P2 · Priority: MVP · Screens: 16 Workout summary, 03 (date sheet)

## Why

Finishing a workout today just drops you back on Home. A short summary of what you did, the
records you set and how it compares with last time is the payoff that keeps people coming back.

## User stories

- As a lifter, when I finish I see how long I trained, how much I lifted and my PRs.
- As a lifter, I see whether I did more or less than last time I did this workout.
- As a lifter, I can add a note to the workout and share the summary as an image.
- As a lifter, I can open a past workout's summary from the calendar.

## Acceptance criteria

- **AC1** — Given at least one logged set, when I tap Finish, then the workout is saved as
  today (WKT-02 AC9) and the summary opens; Done returns to Home showing today done. Back from
  the summary also goes to Home, never back into the logger.
- **AC2** — Given the summary, then it shows the workout name and date, the duration (start to
  end, h:mm or m:ss), the number of sets logged, and total volume (kg × reps of weighted sets,
  in the user's display unit).
- **AC3** — Given the summary, then each exercise done shows its sets (weight × reps, reps or
  time), and its volume; a bodyweight exercise shows total reps and a timed one total time
  instead of volume.
- **AC4** — Given sets that earned a PR (as LOG-02 AC6), then the summary lists them at the top
  ("PR · Bench Press 100 kg × 5") with a count, in text; with none, the section is not shown.
- **AC5** — Given a previous finished session of the same workout, then duration, sets and
  volume each show the change from it ("+1,250 kg", "−3 min", "same"), and each exercise shows
  its volume change from the last time that exercise was done. With no previous session it says
  "First time — nothing to compare yet".
- **AC6** — Given the summary, when I add or change a note and leave, then the note is saved
  with the workout and shown when the summary is opened again.
- **AC7** — Given the summary, when I tap Share, then a summary image (name, date, duration,
  volume, PRs; no body data) is made and the phone's share sheet opens with it.
- **AC8** — Given a done date in the calendar, when I open its sheet and tap View summary, then
  the same summary opens for that workout, with its note, read-only except the note.
- **AC9** — Given no network, then everything above works; the note is stored on the phone at
  once and the workout still goes to the cloud as one write.

## Edge cases

- Only bodyweight or timed sets: total volume shows "—", sets and time still shown.
- A workout over 24 h (left open): duration shows hours (e.g. 26:05 h), no cap.
- An exercise in the workout with no logged sets is left out of the summary.
- The previous session's template was edited since: the comparison is by workout, not by
  identical exercises; exercises not done last time show no change.
- An exercise removed from the library shows by its saved name.
- Imperial users see lb throughout, rounded as elsewhere; stored values stay kg.
- Share is cancelled: nothing happens, the summary stays.

## Constraints (NFRs that apply)

- NFR-01: the summary opens in < 300 ms after Finish with 2 years of data.
- NFR-02: offline. NFR-04: no body data in the shared image or analytics.
- NFR-06: 48 dp controls, 200 % text, semantics labels; changes read as text ("up 1,250 kg"),
  never colour alone; numbers in tabular figures.
- NFR-10: the note is part of the workout's one cloud write; a later note edit is one more
  write for that workout, never per keystroke.

## Non-goals

- Editing sets after Finish (sessions are append-only).
- Rating, mood or RPE for the workout; set notes (LOG-04).
- Progress charts, PR history (PRG-01); streaks (PRG-02).
- Sharing to a specific social network, or a public link.

## Data touched

- Finished workout: gains an optional note. Read: its sets, the previous finished workout of
  the same template, each exercise's last finished sets, PRs as LOG-02.

## Open questions

- None.
