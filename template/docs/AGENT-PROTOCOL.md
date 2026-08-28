---
id: agent-protocol
title: Agent Protocol — the working contract
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Agent Protocol

**This is the single source of truth for how work happens in this repo** — identical for Claude Code, Codex, Cursor, or a human. `CLAUDE.md` and `AGENTS.md` at the root are thin front doors that point here. Never copy this file's contents into them; point instead.

Deliberately short: **invariants, the session ritual, and where to read.** Details live in other files under `docs/`.

> If this file grows past ~150 lines, that is a bug — move the content into its own document.
> A fat contract is a contract nobody reads, and then it rots.

## Invariants

<Replace with yours. Keep the number small — five to ten. Every one should be something you would revert a change over.>

1. **<Safety rule that has no exceptions.>**
2. **<Rule about what never enters the repo — secrets, credentials, customer data.>**
3. **<Rule about what the system must never do automatically.>**
4. **<Rule about which numbers are trusted for decisions.>**

Breaking one of these means: revert first, discuss after.

## Session ritual — mandatory

Work here runs as **fragments**: one self-contained unit of work that can be left at any moment and picked up by someone else — without the conversation that produced it.

### Open
1. Read **`STATE.md`** — it says which fragment is active.
2. Read that fragment in `plans/NN-*.md` **in full**, including its `Session log`.
3. Read whatever its **"Read first"** section points at.
4. If no fragment is active: take the top of the queue in `STATE.md` whose dependencies are `done`, and set it to `in-progress`.

### Work
- **One fragment at a time.** Found other work? Write a new fragment in the queue; do not do it now.
- Small diffs a human can review. No mass refactor riding along.
- **Never claim something is done without running the fragment's validation commands** and pasting the result. `status: done` is machine-checked: every checkbox ticked, and the commands you ran recorded in the file. A fragment that is deliberately unfinished is `parked` with a reason, not `done`.

### Close — do not skip, however small the work was
1. Tick the checkboxes in the fragment. For anything unticked, write why, there.
2. Add **one line** to that fragment's `Session log`.
3. Update `STATE.md`: active fragment, queue, blocked. Its status for the fragment must match the fragment's own `status:` — the guard fails when the two disagree. The session log line is a handoff, not a tick: `date · agent · fragment · what changed · what is next`.
4. If a handoff is involved, label it (see `HOW-WE-WORK.md`).
5. Just fixed a non-obvious, recurrence-prone bug? Write one file in `lessons/` (**Symptom → Root cause → Rule**) and list it in `README.md`.
6. `bash scripts/docs-check.sh` must be green.

A session that ends without steps 1–3 is **not finished**, no matter how much code got written.

## Source-of-truth hierarchy

When two sources disagree, the higher one wins. If the higher one turns out to be wrong, **fix the higher one** — do not quietly follow the lower.

1. The running code and its records — reality beats documents
2. `<AGREEMENT or charter file, if any>`
3. This document — invariants and ritual
4. `decisions/` → `architecture/` → `plans/` → everything else

## Document map

| If you want to… | Read |
|---|---|
| know where the work stands | `STATE.md` |
| pick up or continue work | `plans/README.md`, then the fragment |
| see every document | `README.md` (the index) |
| know why something is the way it is | `decisions/` |
| understand cross-cutting design | `architecture/` |
| operate the system | `runbooks/` |
| know the team rhythm and labels | `HOW-WE-WORK.md` |
| look up a term | `GLOSSARY.md` |
| onboard from zero | `../START-HERE.md` |

## Writing rules

- **Frontmatter required** on every `.md` under `docs/`: `id`, `title`, `status`, `owner`, `last-verified`. Values, not just keys — the guard rejects an empty `owner` and a `last-verified` that is not a real date, and warns when a document has changed since the date it claims to have been verified.
- **One file, one topic.** New topic = new file + one line in the index.
- **Point at code with `file.ext:123`**, never a vague description.
- **Write in the language your team actually speaks.** Documents about cost, authority, or how to stop the system must be readable by non-engineers on their own.
- Superseded documents get `status: superseded` and a pointer to the replacement. **Do not delete them** — a labeled stale file costs less than a missing trail.

## Adding a front door for another tool

A new tool does **not** get a copy of the rules. Create its convention file, write three lines, point here. Rules change in exactly one place.

## Commands

```bash
bash scripts/docs-check.sh
```

Rules that are true only for this repo go in `scripts/docs-check.local.sh` (see
`scripts/docs-check.local.sh.example`), never in `docs-check.sh` itself — the
shared guard has to stay updatable.

<Add your project's real commands here. Leave a command out rather than promise one that does not work.>
