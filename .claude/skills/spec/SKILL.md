---
name: spec
description: Interview the user and write specs/<ID>-<slug>/spec.md for a RepForge requirement ID. Use when starting a new slice, e.g. "/spec SCH-02".
---

Argument: a requirement ID from docs/requirements.md (or a new FND-xx).

1. Read docs/requirements.md (row for the ID), docs/product.md, and the screen rows in
   docs/design.md for the screens it lists. Read any existing `specs/<ID>-*/spec.md`.
2. Interview the user, a few questions at a time, until you could write testable acceptance
   criteria: behaviour, edge cases, what is out of scope, open questions from docs/roadmap.md
   that block this slice.
3. Write `specs/<ID>-<slug>/spec.md` from `specs/_templates/spec.md`. Rules:
   - What and why only. No packages, classes or file names.
   - Every AC is Given / When / Then and observable enough to write a test for.
   - Under ~80 lines; if bigger, propose splitting the slice.
   - `Status: Draft`.
4. Update the Status column for the ID in docs/requirements.md to `Spec`.
5. Ask the user to review and set `Status: Approved`.
