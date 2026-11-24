# SET-01: Settings — units, theme, rest default, plate calculator, reminders

Status: Approved
Phase: P2 · Priority: MVP · Screens: 23 Profile and settings, 02 Workout logger

## Why

The app should fit how and where I train: my units, my look, my usual rest, the plates in my
gym, and a nudge on days I'm meant to lift.

## User stories

- As a user, I change units, theme and default rest in one place.
- As a lifter, I see which plates to load for a weight, using the plates my gym has.
- As a lifter, I get a reminder on training days so I don't forget.

## Acceptance criteria

- **AC1** — Given Profile, then below the account section a Settings list shows Units, Theme,
  Default rest, Plates and Workout reminder, each with its current value in words.
- **AC2** — Given Units, when I pick Metric or Imperial, then every weight and length in the
  app shows in it at once (stored values unchanged), and it stays after restart.
- **AC3** — Given Theme, when I pick System, Light or Dark, then the app switches at once and
  keeps it after restart; System is the default.
- **AC4** — Given Default rest, when I set a time (0:00–10:00 in 15 s steps), then exercises I
  add to templates from then on start with it; existing template rows keep their rest.
- **AC5** — Given Plates, then I see the bar weight and the plates I own in my unit
  (defaults: 20 kg bar with 25, 20, 15, 10, 5, 2.5, 1.25 kg; 45 lb bar with 45, 35, 25, 10,
  5, 2.5 lb), can change the bar and turn plates on or off; at least one plate stays on.
- **AC6** — Given the logger with a weight in a set, when I tap Plates, then a sheet shows the
  plates per side, heaviest first ("Each side: 20, 10, 2.5 kg"), using only plates I own.
- **AC7** — Given a weight the plates can't make exactly, then the sheet shows the closest
  lighter load and how much is missing ("2.5 kg short"); below the bar it says "Lighter than
  the bar".
- **AC8** — Given Workout reminder on with a time, then on each day my cycle plans a workout
  I get one notification at that time ("Push day today"); none on rest days, none once
  today's workout is done or the day is skipped, moved or rested.
- **AC9** — Given the reminder, when I tap it, then the app opens on Home.
- **AC10** — Given notifications are off for the app, when I turn the reminder on, then
  Settings says reminders need notifications, with Open settings.
- **AC11** — Given no network, then every setting works and is kept on the phone; units,
  default rest and plates are also backed up with my profile.

## Edge cases

- Changing the cycle, swapping or moving a day reschedules the coming reminders.
- Weekday-locked cycles (SCH-03) remind on their training weekdays.
- Switching units keeps each unit's own plate list; it doesn't convert plates.
- A weight entered in the logger in one unit uses the plate list of the display unit.
- No active cycle: the reminder can be on but nothing fires; Settings says "No cycle yet".

## Constraints (NFRs that apply)

- NFR-02: offline; reminders are local notifications. NFR-04: no settings values in analytics.
- NFR-06: 200 % text; 48 dp targets; semantics labels; values in words.
- Store metric (kg) for the bar and plates; convert only for display.

## Non-goals

- Data export and account deletion (NFR-05) — a later slice.
- Separate weight and length units; per-weekday reminder times; quiet hours (NTF-01).
- Collars, plate counts or colour-coded plates; dumbbell or machine loading.

## Data touched

- Profile: units, default rest, bar weight, plate lists per unit (synced).
- On the phone only: theme, reminder on/off and time.
- Read: active cycle and day records, templates (for the reminder text).

## Open questions

- None.
