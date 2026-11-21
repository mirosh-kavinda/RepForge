# Specs

One folder per requirement ID: `specs/<ID>-<slug>/`.

| File | Written when | Contains |
|---|---|---|
| `spec.md` | Slice is next up | What + why: story, Given/When/Then ACs, edge cases, non-goals. No tech. |
| `plan.md` | After spec is Approved | How: files, data, packages, decisions → each cites an AC |
| `tasks.md` | After plan is Approved | Ordered checklist; each task names its test |

Lifecycle (`Status:` line at the top of `spec.md`): `Draft` → `Approved` → `Done`.

Workflow in Claude Code:

1. `/spec <ID>` — Claude interviews you, then writes `spec.md` from `_templates/spec.md`.
2. Review and set `Status: Approved`.
3. `/plan-feature <ID>` in plan mode — writes `plan.md`. Push back until it is right.
4. `/tasks <ID>` — writes `tasks.md`.
5. New session: "Implement specs/<ID>-<slug>/tasks.md one task at a time. Test first, tick, commit."
6. Run the `spec-reviewer` agent, then open the PR titled `<ID>: <summary>`.

Acceptance tests live at `test/<area>/<ID>_test.dart` and quote the AC number in each test name,
e.g. `test('AC2: autosave fires within 1 s', ...)`.

Keep each spec readable in two minutes. If it grows past ~80 lines, split the slice.
