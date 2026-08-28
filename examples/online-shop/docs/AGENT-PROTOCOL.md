---
id: agent-protocol
title: Agent Protocol — the working contract
status: active
owner: rafi
last-verified: 2026-08-28
---

# Agent Protocol

**This is the single source of truth for how work happens in this repo** —
identical for Claude Code, Codex, Cursor, or a human. `CLAUDE.md` and
`AGENTS.md` at the root are thin front doors that point here. Never copy this
file's contents into them; point instead.

## Invariants

1. **No customer's name, phone number or address ever enters this repository.**
   Not in a screenshot, not in a bug report, not in a test fixture. Refer to an
   order by its number.
2. **Test keys and live keys never sit in the same file.** We have already sent
   real money to a real card while testing — see `lessons/`.
3. **A price is read from one place only.** If you find a second place holding a
   price, that is the bug, whatever the symptom looked like.
4. **Anyone can take the shop offline, at any time, without asking.** Bringing it
   back needs both of us.
5. **Numbers used for decisions come from the orders dashboard**, never from
   counting by hand.

Breaking one of these means: revert first, discuss after.

## Session ritual — mandatory

Work here runs as **fragments**: one self-contained unit of work that can be left
at any moment and picked up by someone else — without the conversation that
produced it.

### Open
1. Read **`STATE.md`** — it says which fragment is active.
2. Read that fragment in `plans/NN-*.md` **in full**, including its `Session log`.
3. **Before asking any question, search `decisions/`.** If it was settled, it is
   in there, and asking again wastes the session it is meant to save.

### Work
- **One fragment at a time.** Found other work? Write a new fragment in the
  queue; do not do it now.
- Small changes a person can review. No tidying that nobody asked for: if you
  want to restructure something, say so first and wait.
- **Never say something is done without running the fragment's validation
  commands** and pasting the result. `status: done` is machine-checked: every
  checkbox ticked, and the commands recorded in the file.

### Close — do not skip, however small the work was
1. Tick the checkboxes. For anything unticked, write why, there.
2. Add **one line** to that fragment's `Session log`.
3. Update `STATE.md`. Its status for the fragment must match the fragment's own
   `status:`. The session log line is a handoff, not a tick:
   `date · agent · fragment · what changed · what is next`.
4. Settled something in conversation? Write it in `decisions/` before you close.
5. Fixed a non-obvious bug that could come back? One file in `lessons/`
   (**Symptom → Root cause → Rule**), listed in `README.md`.
6. `bash scripts/docs-check.sh` must be green.

## Source-of-truth hierarchy

1. The running shop and its orders dashboard — reality beats documents
2. This document — invariants and ritual
3. `decisions/` → `plans/` → everything else

## Document map

| If you want to… | Read |
|---|---|
| know where things stand | `STATE.md` |
| pick up or continue work | `plans/README.md`, then the fragment |
| see every document | `README.md` (the index) |
| know why something is the way it is | `decisions/` |
| take the shop offline | `runbooks/` |
| know how the two of us work | `HOW-WE-WORK.md` |
| look up a word | `GLOSSARY.md` |
| start from zero | `../START-HERE.md` |

## Writing rules

- **Frontmatter required** on every `.md` under `docs/`: `id`, `title`,
  `status`, `owner`, `last-verified`. Values, not just keys.
- **One file, one topic.** New topic = new file + one line in the index.
- **Point at code with `file.ext:123`**, never a vague description.
- **Write so Dina can read it.** Anything about money, or about stopping the
  shop, has to be readable by someone who does not read code.

## Commands

```bash
bash scripts/docs-check.sh
npm test
npm run dev
```

Rules that are true only for this repo go in `scripts/docs-check.local.sh`,
never in `docs-check.sh` itself — the shared guard has to stay updatable.
