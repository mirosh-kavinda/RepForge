---
name: plan-feature
description: Write specs/<ID>-<slug>/plan.md (the technical how) from an approved RepForge spec. Use after a spec is Approved, ideally in plan mode, e.g. "/plan-feature SCH-02".
---

Argument: a requirement ID.

1. Read `specs/<ID>-*/spec.md`. If `Status` is not `Approved`, stop and say so.
2. Read CLAUDE.md, docs/architecture.md, and the code the slice will touch.
3. Write `plan.md` from `specs/_templates/plan.md`:
   - Files table with real paths following the feature-first layout.
   - Every key decision cites the AC it serves.
   - Test strategy maps every AC to a test file and kind.
   - Name new packages and why; prefer those already listed in docs/architecture.md.
4. Present the plan and its risks; revise until the user approves. Set `Status: Approved`.
5. Update the ID's Status in docs/requirements.md to `Planned` once tasks exist.
