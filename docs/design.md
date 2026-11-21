# Design reference

Design canvas (all 25 screens, dark + light, clickable prototype):
https://claude.ai/artifact/RnzVTCHaMYxjH9wdqWWgcT

Dark-first, high contrast so numbers read under gym lighting. Light theme uses the same token
names. Tokens ship as `ThemeExtension<RfColors>` in `lib/app/theme/rf_tokens.dart` (FND-02).

## Colour tokens (dark)

| Token | Hex | Use |
|---|---|---|
| bg (Graphite) | #0E0F12 | App background; text on solid fills |
| navBar | #15171C | Bottom navigation |
| surface | #1A1C22 | Cards, sheets |
| divider | #23262D | Dividers |
| border | #2A2D35 | Outlines |
| textPrimary | #F4F5F7 | Primary text |
| textSecondary | #C9CED8 | Secondary text |
| textMuted (Steel) | #8A93A6 | Captions, ghost-set row |

Semantic (solid / tint / on-tint):

| Role | Solid | Tint | On-tint |
|---|---|---|---|
| action · Ember | #FF6B2C | #2A1A12 | #FF8A55 |
| success / PR · Volt | #C8F560 | #20241A | #C8F560 |
| rest · Rest Blue | #5AA9FF | #13233A | #8CC4FF |
| missed · Alert | #FF5D5D | #4A1E1E | #FF9A9A |

Rules: tints are only for status-chip and calendar-cell backgrounds; text on a tint uses the
on-tint colour; text and icons on a solid fill use `onSolid` (Graphite #0E0F12 in both themes). Light theme keeps bright Ember/Volt fills on buttons
and chips, but text/icons switch to darker inks — Ember-ink #C2410C, Volt-ink #3F6212 — for AA
on white.

## Colour tokens (light)

| Token | Dark | Light |
|---|---|---|
| bg | #0E0F12 | #F3F4F6 |
| surface / navBar | #1A1C22 | #FFFFFF |
| divider | #23262D | #E6E8EC |
| border | #2A2D35 | #D9DCE2 |
| textPrimary | #F4F5F7 | #12141A |
| textSecondary | #C9CED8 | #3D4350 |
| textMuted (ghost) | #8A93A6 | #5E6678 |
| action fill | #FF6B2C | #FF6B2C |
| action ink (text) | #FF8A55 | #C2410C |
| action tint | #2A1A12 | #FFE4D5 |
| action on-tint | #FF8A55 | #9A3412 |
| success fill | #C8F560 | #C8F560 |
| success ink (text) | #C8F560 | #3F6212 |
| success tint | #20241A | #D5EDA6 |
| success on-tint | #C8F560 | #3F6212 |
| success border (done row) | #5C7A2A | #5E8A18 |
| rest fill | #5AA9FF | #5AA9FF |
| rest ink (text) | #8CC4FF | #1D5FB0 |
| rest tint | #13233A | #DCEBFF |
| rest on-tint | #8CC4FF | #144A8C |
| missed fill | #FF5D5D | #FF5D5D |
| missed ink (text) | #FF9A9A | #B91C1C |
| missed tint | #4A1E1E | #FFDADA |
| missed on-tint | #FF9A9A | #8F1A1A |
| onSolid (text on fills) | #0E0F12 | #0E0F12 |

Values not on the canvas (light action tint/on-tint, rest/missed ink and on-tint, success
border, onSolid) were set in the FND-02 spec (2026-11-21) and checked for AA contrast. The
earlier dark success on-tint #3A4A1E (1.6:1 on its tint) was replaced by Volt #C8F560.

## Logo and voice

Mark: Ember rounded square (radius 22 on 88) with three rising Graphite bars and an up-right
arrow — progressive overload. Wordmark "Rep" + "Forge" in Ember, Space Grotesk 700.
Voice: short, direct, coach-like, numbers first ("+2.5 kg today. You've got this.").

## Type, shape, spacing

| Style | Font | Size |
|---|---|---|
| Stat XL | Space Grotesk 700 | 30 |
| Title | Space Grotesk 700 | 26 |
| Heading / input value | Space Grotesk 700 | 20 |
| Button | Inter 600 | 16 |
| Body | Inter 400 | 15 |
| Label | Inter 400/500 | 13 |
| Overline / caption | Inter 600 | 12 |

Numbers always use `FontFeature.tabularFigures()`.
Radius: xs 4 · sm 8 · md 12 (buttons) · lg 16 (cards) · pill. Spacing: 4-pt base (4, 8, 12, 16, 20, 24, 32).

## Core components

- **RfButton** — primary (Ember) / secondary (outline) / ghost; height lg 52, md 44; states default,
  pressed (−8 % lightness), disabled (40 % opacity), loading (spinner, label kept).
- **RfStepper** — value in Grotesk 20, −/+ buttons 44×44 (48 dp hit area); steps 2.5 kg, 1 rep,
  0.1 kg body, 0.5 cm; long-press repeats; haptic tick per step.
- **RfSetRow** — pending (surface), done (Volt tint + border), PR (adds PR chip); ghost line in
  textMuted; swipe left delete; long-press notes / RPE.
- **RfChip / RfDayTile** — filter chip (outline → Ember when on), status chip (tint + on-tint);
  day tile states done, today (Ember 2 px), rest, missed, planned (dashed); always a text label.

## Screen inventory

| # | Screen | Requirements |
|---|---|---|
| 01 | Home | WKT-02, SCH-02, PRG-02, GOL-01 |
| 02 | Workout logger (Ghost Set, rest timer) | LOG-01, LOG-02, LOG-03 |
| 03 | Schedule (rolling cycle + calendar) | SCH-01, SCH-03, SCH-05 |
| 04 | Exercise library | EXL-01 |
| 05 | Body Snapshot | BOD-01 |
| 06 | Progress | PRG-01, PRG-02 |
| 07 | Goals | GOL-01, GOL-02 |
| 08 | Welcome | ONB-01 |
| 09 | Sign in (Google, Apple, email, guest) | AUTH-01 |
| 10–12 | Onboarding: goal + level, about you, starter plan | ONB-01, SCH-01 |
| 13 | Edit workout (template, supersets) | WKT-01 |
| 14 | Exercise detail | EXL-02 |
| 15 | Rest day (Home variant) | SCH-02, NTF-01 |
| 16 | Workout summary (PRs) | LOG-05 |
| 17 | Day actions sheet (swap, move, skip) | SCH-04 |
| 18 | Cycle builder | SCH-01 |
| 19 | New goal (with projection) | GOL-01 |
| 20 | Progress photos (compare) | BOD-02 |
| 21 | Notifications centre | NTF-01 |
| 22 | Weekly report | NTF-01, PRG-02, PRG-03 |
| 23 | Profile and settings | SET-01 |
| 24 | Backup and sync | SYN-01, SYN-02, SYN-03 |
| 25 | Add progress photo (camera) | BOD-02 |

## Illustrations

Original SVGs in `assets/illustrations/`, rendered with flutter_svg and recoloured per theme:
15 pose figures (squat, bench, deadlift, RDL, curl, press, pull-up, row, lunge, leg press, fly,
plank, stretch, run, dip), front muscle map, body outline with measuring lines, hero art for
Welcome, rest day and PR. Each library exercise maps to its nearest pose.
