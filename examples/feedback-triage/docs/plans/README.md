---
id: plans-index
title: Fragments — how they work
status: active
owner: priya
last-verified: 2026-08-24
---

# Fragments

One fragment = one **self-contained** unit of work. Size it to a reasonable
session: leavable at any moment, resumable by another person or model **without
the conversation that produced it.**

If a fragment can only be continued by whoever wrote it, it is written wrong.

## Rules

- Numbered, never reused.
- `status`: `todo` → `in-progress` → `done` | `parked`. **Only one**
  `in-progress` in the whole repo, and it must match the row in `../STATE.md`.
- Checkboxes are ticked when work is **finished and validated**, not when the
  code is written. The guard rejects `status: done` with an unticked box.
- `Session log` is append-only. Do not rewrite history.
- Cancelled fragments are not deleted: `status: parked` plus the reason.

## Creating one

```bash
cp docs/plans/00-template.md docs/plans/03-short-name.md
```

Then add it to the queue in `../STATE.md` and the index in `../README.md`.
`scripts/docs-check.sh` will complain if you forget.
