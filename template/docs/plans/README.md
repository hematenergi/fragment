---
id: plans-index
title: Fragments — how they work, and the phase gates
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Fragments

One fragment = one **self-contained** unit of work. Size it to a reasonable session: leavable at any moment, resumable by another person or model **without the conversation that produced it**.

If a fragment can only be continued by whoever wrote it, it is written wrong.

## Rules

- Numbered, never reused. New fragment = next number, even if worked on first.
- `status`: `todo` → `in-progress` → `done` | `parked`. **Only one** `in-progress` in the whole repo.
- `depends-on` filled in honestly. Do not take a fragment whose dependencies are not `done`.
- Checkboxes are ticked when work is **finished and validated**, not when the code is written.
- `Session log` is append-only. Do not rewrite history.
- Cancelled fragments are not deleted: `status: parked` plus the reason. Six months from now that is the most useful file in the folder.

## Creating one

```bash
cp docs/plans/00-template.md docs/plans/07-short-name.md
```

Then add it to the queue in `../STATE.md` and to the index in `../README.md`. `scripts/docs-check.sh` will complain if you forget.

## Phase gates

Phases do not advance on dates — they advance when a gate passes. **A gate that does not pass is a valid outcome, not a failure.**

| Phase | Fragments | Gate to advance |
|---|---|---|
| <name> | | <A condition someone else can check without asking you> |
