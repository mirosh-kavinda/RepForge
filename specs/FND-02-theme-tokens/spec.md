# FND-02: Theme and brand tokens

Status: Draft
Phase: P1 · Priority: MVP · Screens: canvas "Design tokens → Flutter", "Light theme tokens"

## Why

Every screen draws from one set of tokens so the dark-first brand stays consistent, light mode
comes for free, and accessibility rules (contrast, target size) are enforced in one place.

## User stories

- As a user, the app follows my system light/dark setting by default and I can override it.
- As a developer, I get colours, type, radius and spacing from the theme, never hard-coded.

## Acceptance criteria

- **AC1** — Given the dark theme, when any token is read from `RfColors`, then its value equals
  the table in docs/design.md (bg #0E0F12 … Alert on-tint #FF9A9A).
- **AC2** — Given the light theme, when the same token names are read, then they resolve to the
  light values from the canvas, with Ember-ink #C2410C and Volt-ink #3F6212 for text/icons.
- **AC3** — Given each text/background pair the tokens define, when contrast is computed, then it
  is ≥ 4.5:1 (body) or ≥ 3:1 (≥ 24 px text and icons) in both themes.
- **AC4** — Given theme mode System (default), when the OS switches between light and dark,
  then the app follows without restart.
- **AC5** — Given the type scale, when numbers render in Stat/Title/Heading styles, then they use
  tabular figures.
- **AC6** — Given RfButton, RfStepper, RfChip and RfDayTile, when rendered, then every hit area is
  ≥ 48 × 48 dp, each has a semantics label, and RfDayTile shows a text label for its state.
- **AC7** — Given text scale 200 %, when the components render, then no overflow errors occur.

## Edge cases

- Fonts (Space Grotesk, Inter) bundled as assets so they work offline on first launch.
- RfStepper long-press repeat stops on release and at min/max bounds.

## Constraints

- NFR-06 accessibility in both themes.

## Non-goals

- The Settings screen toggle itself (SET-01); here only the provider and default.
- Illustrations (added with the screens that use them).

## Data touched

- Theme mode preference (in-memory provider now; persisted in SET-01).

## Open questions

- Light values for rest/missed solid and on-tint colours are not defined on the canvas
  (docs/design.md lists what is); choose them in planning and prove AA contrast (AC3).
