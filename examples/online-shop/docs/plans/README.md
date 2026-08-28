---
id: plans-index
title: Fragments — how they work
status: active
owner: rafi
last-verified: 2026-08-28
---

# Fragments

One fragment = one **self-contained** piece of work. Size it to a single
sitting: leavable at any moment, resumable by another person or another agent
**without the conversation that produced it.**

If a fragment can only be continued by whoever wrote it, it is written wrong.

## Rules

- Numbered, never reused.
- `status`: `todo` → `in-progress` → `done` | `parked`. **Only one**
  `in-progress` in the whole repo, and it must match its row in `../STATE.md`.
- Checkboxes are ticked when the work is **finished and checked**, not when the
  code is written. The guard rejects `status: done` with a box still unticked.
- `Session log` is append-only. Do not rewrite what happened.
- Abandoned work is not deleted: `status: parked` plus the reason.

## Creating one

```bash
cp docs/plans/00-template.md docs/plans/03-short-name.md
```

Then add it to the queue in `../STATE.md` and to the index in `../README.md`.
`scripts/docs-check.sh` will complain if you forget.
