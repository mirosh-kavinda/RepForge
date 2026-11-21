# RepForge

> Beat your last set.

Offline-first Flutter gym app: a rolling training cycle that survives missed days, two-tap set
logging with last session's "ghost" set, Body Snapshot metrics, goals with projected finish
dates, and Firebase backup.

**Status:** planning — Phase 1 (Foundations) specs drafted. No app code yet.

## Docs

| | |
|---|---|
| [docs/product.md](docs/product.md) | Problem, user, differentiators |
| [docs/requirements.md](docs/requirements.md) | All requirement IDs, phases, status (traceability) |
| [docs/architecture.md](docs/architecture.md) | Layers, packages, folders, data model, sync, formulas |
| [docs/design.md](docs/design.md) | Tokens, components, screen inventory |
| [docs/roadmap.md](docs/roadmap.md) | Phases, slice order, release gate, open questions |
| [specs/](specs/) | One folder per requirement: spec → plan → tasks |

## How this repo is built

Spec-driven development with Claude Code — see [CLAUDE.md](CLAUDE.md) and
[specs/README.md](specs/README.md). Short version: `/spec <ID>` → approve → `/plan-feature <ID>`
→ `/tasks <ID>` → build in a fresh session, test first → `spec-reviewer` → PR named `<ID>: …`.

## Stack

Flutter · Riverpod · go_router · Drift (SQLite + FTS5) · freezed · Firebase (Auth, Firestore,
Storage, Messaging, Crashlytics, App Check) · fl_chart · workmanager.

## Running

Android has `dev` and `prod` flavors. Firebase settings come from a gitignored dart-define file:

```sh
cp config/example.json config/dev.json   # fill in from the repforge-dev console
flutter run --flavor dev --dart-define-from-file=config/dev.json
```

Without a config file the app still runs, local-only: guests work, sign-in reports offline.
Firestore rules test: `firebase emulators:exec --only firestore --project demo-repforge "npm --prefix test/firestore_rules test"`
(after `npm ci --prefix test/firestore_rules`).
