---
id: agent-protocol
title: Agent Protocol — the working contract
status: active
owner: priya
last-verified: 2026-08-24
---

# Agent Protocol

**This is the single source of truth for how work happens in this repo** —
identical for Claude Code, Codex, Cursor, or a human. `CLAUDE.md` and
`AGENTS.md` at the root are thin front doors that point here. Never copy this
file's contents into them; point instead.

## Invariants

1. **No customer email address, name, or message body ever enters this
   repository.** Not in a test fixture, not in a bug report, not in a comment.
   Reference an item by its id.
2. **Nothing is deleted from the raw ingest log.** De-duplication marks; it never
   removes. We learned this the expensive way — see `lessons/`.
3. **A model never decides routing.** Routing is rules a human can read and a
   support lead can overrule. See `decisions/0001`.
4. **Every filter logs what it rejected, and why.** A filter that drops silently
   is indistinguishable from a filter that is broken.
5. **The dashboard is the only trusted count.** Numbers computed by hand across
   three channels are not evidence.

Breaking one of these means: revert first, discuss after.

## Session ritual — mandatory

Work here runs as **fragments**: one self-contained unit of work that can be left
at any moment and picked up by someone else — without the conversation that
produced it.

### Open
1. Read **`STATE.md`** — it says which fragment is active.
2. Read that fragment in `plans/NN-*.md` **in full**, including its `Session log`.
3. Read whatever its **"Read first"** section points at.

### Work
- **One fragment at a time.** Found other work? Write a new fragment in the
  queue; do not do it now.
- Small diffs a human can review.
- **Never claim something is done without running the fragment's validation
  commands** and pasting the result. `status: done` is machine-checked: every
  checkbox ticked, and the commands recorded in the file.

### Close — do not skip, however small the work was
1. Tick the checkboxes. For anything unticked, write why, there.
2. Add **one line** to that fragment's `Session log`.
3. Update `STATE.md`. Its status for the fragment must match the fragment's own
   `status:`. The session log line is a handoff, not a tick:
   `date · agent · fragment · what changed · what is next`.
4. Fixed a non-obvious, recurrence-prone bug? Write one file in `lessons/`
   (**Symptom → Root cause → Rule**) and list it in `README.md`.
5. `bash scripts/docs-check.sh` must be green.

## Source-of-truth hierarchy

1. The running service and its dashboard — reality beats documents
2. This document — invariants and ritual
3. `decisions/` → `plans/` → everything else

## Document map

| If you want to… | Read |
|---|---|
| know where the work stands | `STATE.md` |
| pick up or continue work | `plans/README.md`, then the fragment |
| see every document | `README.md` |
| know why something is the way it is | `decisions/` |
| operate the service | `runbooks/` |
| know the team rhythm | `HOW-WE-WORK.md` |
| look up a term | `GLOSSARY.md` |
| onboard from zero | `../START-HERE.md` |

## Writing rules

- **Frontmatter required** on every `.md` under `docs/`: `id`, `title`,
  `status`, `owner`, `last-verified`. Values, not just keys.
- **One file, one topic.** New topic = new file + one line in the index.
- **Point at code with `file.ext:123`**, never a vague description.
- Superseded documents get `status: superseded` and a pointer. Do not delete them.

## Commands

```bash
bash scripts/docs-check.sh
npm test
npm run triage:dry -- --since 24h
```

Rules that are true only for this repo go in `scripts/docs-check.local.sh`,
never in `docs-check.sh` itself — the shared guard has to stay updatable.
