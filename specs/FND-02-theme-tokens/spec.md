# FND-02: Theme and brand tokens

Status: Done
Phase: P1 · Priority: MVP · Screens: canvas "Design tokens → Flutter", "Light theme tokens"

## Why

Every screen draws from one set of tokens so the dark-first brand stays consistent, light mode
comes for free, and accessibility rules (contrast, target size) are enforced in one place.

## User stories

- As a user, the app follows my system light/dark setting by default.
- As a developer, I get colours, type, radius and spacing from the theme, never hard-coded,
  and I build screens from shared buttons, steppers, chips and day tiles.

## Acceptance criteria

- **AC1** — Given the dark theme, when any colour token is read, then it equals the dark column
  of docs/design.md (base tokens, semantic table and "Colour tokens (light)" table).
- **AC2** — Given the light theme, when the same token names are read, then they equal the light
  column of docs/design.md; both themes expose exactly the same token names.
- **AC3** — Given every text/background pair the rules allow (text colours on bg and surface,
  inks on bg and surface, on-tint on its tint, onSolid on each fill), when contrast is computed,
  then it is ≥ 4.5:1 in both themes; state borders and icons are ≥ 3:1.
- **AC4** — Given a fresh install, when the app starts, then theme mode is System and the app
  follows an OS light/dark switch without restart; when the mode is set to Light or Dark in code,
  then the app switches immediately.
- **AC5** — Given the type scale, when each style is read, then font, weight and size match
  docs/design.md, and every style renders digits with tabular figures.
- **AC6** — Given no network on first launch, when text renders, then Space Grotesk and Inter
  are used (bundled), not a system fallback.
- **AC7** — Given the spacing and radius scales, when read, then they equal docs/design.md
  (4, 8, 12, 16, 20, 24, 32; xs 4, sm 8, md 12, lg 16, pill).
- **AC8** — Given RfButton (primary, secondary, ghost; sizes lg 52 and md 44), when it is
  pressed, disabled or loading, then it shows the design.md state (pressed −8 % lightness,
  disabled 40 % opacity, loading spinner with label kept) and does not fire while disabled or
  loading.
- **AC9** — Given RfStepper with a step, min and max, when I tap − or +, then the value changes
  by one step, never past min/max, shows without float noise (62.5, not 62.4999), gives a
  haptic tick, and is announced to screen readers; when I long-press, then it repeats until
  release or a bound.
- **AC10** — Given RfChip, when it is a filter chip, then off is outlined and on is Ember;
  when it is a status chip, then it uses the role's tint with on-tint text.
- **AC11** — Given RfDayTile in each state (done, today, rest, missed, planned), when rendered,
  then it shows the design.md styling and a text label for the state, so state is never shown
  by colour alone.
- **AC12** — Given RfButton, RfStepper, RfChip and RfDayTile, when rendered, then every hit area
  is ≥ 48 × 48 dp, each control has a semantics label, and at 200 % text scale nothing
  overflows in either theme.

## Edge cases

- Text on a tint always uses that role's on-tint; text on a fill always uses onSolid.
- Disabled controls are exempt from contrast (WCAG) but still carry a semantics label.
- Stepper at a bound: the blocked button is disabled and says so to screen readers.
- Theme switch mid-screen keeps widget state (no rebuild from scratch, no lost input).

## Constraints

- NFR-06 accessibility in both themes (48 dp, 200 % text, semantics, AA contrast).
- NFR-02 offline: fonts work with no network.

## Non-goals

- The Settings theme toggle and persisting the choice (SET-01).
- RfSetRow (LOG-01), illustrations, app icon and logo assets.

## Data touched

- Theme mode preference, in memory only (persisted in SET-01).

## Decisions (2026-11-21)

- Dark success on-tint is Volt #C8F560 (#3A4A1E failed at 1.6:1).
- Text on solid fills is Graphite #0E0F12 in both themes.
- Light values missing from the canvas and the success border are set in docs/design.md.
- The claude.ai design canvas is the design source (Figma no longer needed).
