# EXL-03: Custom exercises

Status: Approved
Phase: P2 · Priority: MVP · Screens: 04 Exercise library, 14 Exercise detail

## Why

The catalog has 800+ exercises but not every gym's machine or a coach's variation. Without a
way to add their own, people log under the wrong name and their history and PRs get mixed up.

## User stories

- As a lifter, I can add my own exercise with its equipment and muscles and use it like any
  other: in workouts, the logger, history and PRs.
- As a lifter, I can fix or remove an exercise I made without losing past workouts.

## Acceptance criteria

- **AC1** — Given the Library, when I tap New exercise, enter a name, equipment and at least
  one main muscle (other muscles and notes optional) and save, then it is stored on the phone at
  once, queued for sync, and opens its detail.
- **AC2** — Given the form, then Save is disabled until the name (1–40 characters, trimmed) and
  one main muscle are set. A name equal (ignoring case and spaces) to another of my exercises
  or a catalog exercise is refused with "You already have an exercise called X" or "X is
  already in the library".
- **AC3** — Given custom exercises, then they appear in the Library and the template builder's
  picker like catalog ones: found by name words, muscle and equipment, filtered the same way,
  sorted A–Z among them, and marked "Custom" in text.
- **AC4** — Given the picker finds nothing for my search, then it offers New exercise with the
  search text as the name; saving adds it to the picker's results ready to pick.
- **AC5** — Given a custom exercise's detail, then it shows "Custom", its muscles, equipment and
  notes (no pictures, no steps section), my history and Add to workout as in EXL-02, plus Edit
  and Delete.
- **AC6** — Given I edit a custom exercise and save, then workouts that use it show the new
  name and muscles; finished workouts keep the name they were logged with. History, e1RM and PRs
  carry on, because they belong to the exercise, not the name.
- **AC7** — Given I delete a custom exercise, then it disappears from the Library and picker
  with Undo for a few seconds; workouts that use it and past workouts keep showing it by name,
  and they still start and log normally. Undo brings it back as it was.
- **AC8** — Given no network, then creating, editing, deleting and using custom exercises all
  work; each change is queued for sync.

## Edge cases

- A deleted exercise's name can be reused for a new one.
- Notes up to 1,000 characters; longer is cut off with a counter shown.
- Equipment "Body only" logs as Bodyweight like catalog ones.
- A custom exercise in the Recent list (EXL-01) opens its custom detail.
- Two phones (later, SYN-01): the latest edit wins; not handled here beyond `updatedAt`.

## Constraints (NFRs that apply)

- NFR-02: offline. NFR-01: search stays < 100 ms with 200 custom exercises added.
- NFR-06: 48 dp, 200 % text, semantics labels on every field and the muscle chips; "Custom"
  is text, not only a colour or icon.
- NFR-04: custom exercise names and notes never go to analytics.

## Non-goals

- Photos or videos for custom exercises.
- Sharing custom exercises with other people; editing or hiding catalog exercises.
- Merging a custom exercise into a catalog one, or moving history between exercises.

## Data touched

- New: my custom exercises (name, equipment, main and other muscles, notes, timestamps,
  deleted flag), synced under my account.
- Read: workout templates and workouts that refer to them by id.

## Open questions

- None.
