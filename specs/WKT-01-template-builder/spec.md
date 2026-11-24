# WKT-01: Workout template builder

Status: Done
Phase: P2 · Priority: MVP · Screens: 13 Edit workout, 04 Library (pick mode), new: My workouts

## Why

A cycle day is only as useful as the workout behind it. Users need to say once what they do on
"Leg Day" (exercises, order, sets, rep targets, rest, supersets) so logging can prefill it.

## User stories

- As a user, I can build, edit, duplicate and delete my workouts so my cycle days have content.
- As a new user, I start with ready-made workouts I can train from or tweak.

## Acceptance criteria

- **AC1** — Given the Schedule tab, when I open My workouts, then I see every workout I have
  (name, exercise count, set count, estimated minutes) and a "New workout" action; with none,
  an empty state offers "New workout".
- **AC2** — Given a new workout, when I enter a name (1–40 characters, trimmed) and add at least
  one exercise and tap Save, then it appears in My workouts; Save is disabled until both hold.
- **AC3** — Given the editor, when I tap "+ Add exercise", then the Library opens in pick mode:
  search by name, muscle or equipment, filter by muscle group and equipment, select several, and
  "Add (n)" appends them in the order picked, each with defaults 3 sets × 8–12 reps, no target
  weight, rest 2:00. Already-added exercises show as added but can be added again.
- **AC4** — Given an exercise row, when I tap it, then I can set: sets (1–10); Reps or Time;
  reps as a range (min ≤ max, 1–100) or a single number; time in seconds (5–600); optional target
  weight (0–500 kg, entered and shown in my units); rest 0:00–10:00 in 15 s steps. The row shows
  e.g. "4 × 5–8 · 102.5 kg · rest 3:00", "3 × 45 s · rest 1:30", "3 × 12 · rest 1:00".
- **AC5** — Given the editor, when I drag a row by its handle (or use the row's Move up / Move
  down actions), then the order changes; I can also remove an exercise from the row's actions.
- **AC6** — Given two or more adjacent exercises, when I select them and choose Superset, then
  they are linked and labelled with the next free letter (A, B, C …) in text, not colour alone.
  Unlink from any member's actions; moving a member out of the group or removing it so one is
  left also ends the link.
- **AC7** — Given a superset, then rest is taken only after its last member each round, and the
  inner members' rest is shown as "no rest (superset)" and not editable.
- **AC8** — Given the editor, then the header shows exercise count, total sets, estimated
  minutes (each set = 40 s, or its seconds if timed, plus its rest; superset inner rest skipped;
  rounded to the nearest 5, minimum 5) and the distinct primary muscles; all update live.
- **AC9** — Given unsaved changes, when I go back, then "Discard changes?" asks before leaving;
  with no changes it leaves at once.
- **AC10** — Given a workout in My workouts, when I choose Duplicate, then a copy named
  "<name> (copy)" (cut to 40 characters) opens in the editor, unsaved.
- **AC11** — Given a workout, when I choose Delete, then it leaves the list at once with an Undo
  snackbar; Undo restores it unchanged. Logged sessions keep their own record and are unaffected.
- **AC12** — Given a first run for this user on this phone, then six starter workouts exist
  (Push, Pull, Legs, Upper, Lower, Full Body), each 5–6 library exercises with sensible targets,
  editable like any other; they are seeded once and not recreated after I delete them.
- **AC13** — Given no network, then everything above works; each save, duplicate-save, delete
  and undo is stored on the phone and queued for backup in the same step.

## Edge cases

- Weight stored in kg; a lb entry converts and rounds to 0.01 kg; display rounds to the plate
  step (0.5 kg / 1 lb). Switching units never changes stored values.
- Reorder inside a superset keeps it linked; dragging a non-member between members ends it.
- Two workouts may share a name. Max 30 exercises per workout ("Add" disabled past it, says why).
- Range written max-first (12–8) is swapped on save; equal min and max shows as one number.
- App killed while editing: unsaved changes are lost; the saved version is intact.

## Constraints (NFRs that apply)

- NFR-02 offline; NFR-06 48 dp targets, 200 % text, labels on every control, drag has a
  non-drag alternative; NFR-01 picker search < 100 ms (EXL-01 target) on the full catalog.

## Non-goals

- Assigning workouts to cycle days and starter plans (SCH-01). Per-set targets, warm-up or drop
  sets (LOG-04). Custom exercises (EXL-03). Exercise detail page (EXL-02). Library browse mode
  as a tab (EXL-01). Folders, tags, sharing. Per-hand dumbbell notation.

## Data touched

- Workout template (name, ordered exercises with sets, reps or seconds, weight kg, rest,
  superset group); starter-seeded flag; outbox rows. Reads the exercise catalog.

## Open questions

- Design canvas has no My workouts list or exercise target sheet: draw them on the canvas first,
  or build from tokens and existing patterns? (blocks UI tasks, not the plan)
- SYN-02 restore must not duplicate starter workouts on a new phone (note for SYN-02).
