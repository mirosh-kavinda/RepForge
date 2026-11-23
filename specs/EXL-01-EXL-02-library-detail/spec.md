# EXL-01, EXL-02: Exercise library and detail

Status: Approved
Phase: P2 · Priority: MVP · Screens: 04 Exercise library, 14 Exercise detail

## Why

Picking a lift is easy inside the template builder, but there is no place to browse the 800+
exercises, learn how one is done, or see how you have done on it. The Library tab is still a
placeholder.

## User stories

- As a lifter, I can search and filter every exercise from the Library tab, even offline.
- As a lifter, I can open an exercise to see how to do it, which muscles it works and pictures.
- As a lifter, I can see my recent results on an exercise and add it to one of my workouts.

## Acceptance criteria

- **AC1** — Given the Library tab with nothing typed and no filter, then it lists the
  exercises I have logged, most recently done first (up to 10, under "Recent"), then every
  exercise A–Z (under "All exercises"). With no history only the A–Z list shows.
- **AC2** — Given I type in search, then results update as I type (name words, muscles and
  equipment, as in the template builder's picker), in < 100 ms offline with the full catalog.
  "Recent" hides while searching or filtering.
- **AC3** — Given the muscle group and equipment filters (the same groups and equipment as the
  picker), when I set one or both, then only matching exercises show; with text too, both apply.
  Clear filters resets them. Nothing matching shows "No exercises match" with Clear filters.
- **AC4** — Given a result row, then it shows the name, equipment and main muscles; tapping it
  opens the exercise detail.
- **AC5** — Given the detail, then it shows the name, main and other muscles, equipment, level,
  type (e.g. strength) and the numbered steps, all from the phone with no network.
- **AC6** — Given the detail is opened with a network for the first time, then its pictures
  load and are kept on the phone; opened later offline, the kept pictures show. Pictures never
  loaded show a placeholder saying they need a connection once; the rest of the screen works.
- **AC7** — Given finished workouts with this exercise, then the detail shows my best estimated
  1RM and the last 5 times (date in the phone's format and best set, e.g. "Mon, Nov 16 ·
  100 kg × 5"), newest first. With none it says "Not done yet". Weights use my display unit.
- **AC8** — Given the detail, when I tap Add to workout and pick one of my workouts, then the
  exercise is added at the end of that workout with the usual defaults and saved (synced as any
  workout edit), and a message names the workout. If it is already in that workout the message
  says so and nothing is added. With no workouts, the sheet offers to create one.
- **AC9** — Given the exercise picker in the template builder, then nothing about it changes.

## Edge cases

- An exercise with no pictures in the catalog shows no picture area at all.
- A picture download fails or is slow: the placeholder stays; no error dialog; retried on the
  next open.
- An exercise logged under a row that was later swapped counts under the exercise it was
  logged as.
- Search text with only spaces counts as empty (AC1 list).
- Very long names wrap; nothing is cut off at 200 % text.

## Constraints (NFRs that apply)

- NFR-02: everything except first picture download works offline.
- NFR-01: search < 100 ms on the full catalog; the list scrolls at 60 fps (built lazily).
- NFR-06: 48 dp controls, 200 % text, semantics labels on rows, filters, pictures (exercise
  name and step) and actions; tabular figures for numbers.
- NFR-04: no exercise or history data in analytics.

## Non-goals

- Custom exercises (EXL-03); editing catalog exercises; favourites.
- Videos or animations; a full-size picture viewer.
- Level / type filters; sorting options.
- Progress charts for the exercise (PRG-01).

## Data touched

- Read: exercise catalog; finished workouts and their sets (recent list, history).
- Write: a workout template (Add to workout). Pictures kept in the phone's cache.

## Open questions

- None.
