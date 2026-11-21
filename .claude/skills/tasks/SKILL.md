---
name: tasks
description: Break an approved RepForge plan into specs/<ID>-<slug>/tasks.md, an ordered checklist of small testable tasks. Use after plan.md is approved, e.g. "/tasks SCH-02".
---

Argument: a requirement ID.

1. Read `spec.md` and `plan.md` in `specs/<ID>-*/`. Plan must be `Status: Approved`.
2. Write `tasks.md` from `specs/_templates/tasks.md`:
   - Each task is one commit-sized step (≲ 1 hour), names its test file / test name and the AC(s).
   - Order: data → domain → presentation; tests first in each task.
   - Mark tasks that can run in parallel with `(parallel)`.
   - Last task is always: run the `spec-reviewer` agent and fix gaps.
3. Set the ID's Status in docs/requirements.md to `Planned`.
4. Tell the user to start a fresh session and run:
   "Implement specs/<ID>-<slug>/tasks.md one task at a time. Test first, tick, commit."
