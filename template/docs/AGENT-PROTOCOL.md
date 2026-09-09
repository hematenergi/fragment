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
1. Read **`STATE.md`** and the source selected for this session. Search decisions before reopening a settled question.
2. Read the active fragment or task specification in full. If no work is active, select authorised work whose dependencies are satisfied; do not invent work to fill the board.
3. Read contracts needed for that work. Check relevant claims against code or other evidence before using them; an old date alone proves neither error nor correctness.
4. Establish the session's Git range, paths and affected handoff destinations. Do not attribute all dirty files to this session when work is shared.

## Source roles — adapt this table to the project's existing workflow

| Role | Default home | Update when |
|---|---|---|
| Session direction | Source chosen by the user: conversation, daily, ticket or brief | Its workflow calls for session results |
| Project position | `STATE.md` | Active work, blockers or next step changes |
| Work detail and evidence | Fragment or existing task spec | Progress or acceptance evidence changes |
| Durable decisions | Existing ADR/design record | A decision must survive the session |
| Operational contract | Relevant runbook/API/release record | Its contract changes |
| History | Completed tasks and prior daily notes | Normally retained as history |

One document may hold several roles. Each fact has one primary home; other
documents link or summarise only what they need. Record authority and read/write
permissions for selected sources. Newest-file-wins is not an authority rule.
Use [continuity.md](continuity.md) for daily selection, partial writes and
portability; no external service or extra daily is required for repo-only work.

### Work
- **One fragment at a time.** Found other work? Write a new fragment in the queue; do not do it now.
- Small diffs a human can review. No mass refactor riding along.
- **Never claim something is done without running the fragment's validation commands** and pasting the result. `status: done` is machine-checked: every checkbox ticked, and the commands you ran recorded in the file. A fragment that is deliberately unfinished is `parked` with a reason, not `done`.

### Close — do not skip, however small the work was
1. Review the session's outcomes, evidence, decisions and open next steps. Determine which source-role destinations are affected.
2. Update only the relevant parts, using each destination's format and permissions. Tick completed task criteria and record validation where the task keeps it.
3. Keep STATE's position consistent with the task. When STATE is the handoff destination, a useful default is `date · agent · fragment · what changed · what is next`; other formats work too.
4. If a handoff is involved, label it (see `HOW-WE-WORK.md`).
5. Just fixed a non-obvious, recurrence-prone bug? Write one file in `lessons/` (**Symptom → Root cause → Rule**) and list it in `README.md`.
6. `bash scripts/docs-check.sh` must be green.

Report saved and pending destinations honestly. If a required write failed,
provide the ready-to-copy entry and say the handoff is partial. GREEN checks
checkout structure and body changes; the agent still checks meaning and external
write results. Once required updates are confirmed, close without another ritual question.

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

- **Frontmatter on managed working documents**: `id`, `title`, `status`, `owner`, `last-verified`, with real values. Historical documents need no bulk migration. Review relevant claims when using a document; update review dates only after review. `--inventory` exposes date/size clues without warning-budget penalties.
- **One file, one topic.** New topic = new file + one line in the index.
- **Point at code with `file.ext:123`**, never a vague description.
- **Write in the language your team actually speaks.** Documents about cost, authority, or how to stop the system must be readable by non-engineers on their own.
- Superseded documents get `status: superseded` and a pointer to the replacement. **Do not delete them** — a labeled stale file costs less than a missing trail.

## Adding a front door for another tool

A new tool does **not** get a copy of the rules. Create its convention file, write three lines, point here. Rules change in exactly one place.

## Commands

```bash
bash scripts/docs-check.sh
bash scripts/docs-check.sh --inventory
```

Rules that are true only for this repo go in `scripts/docs-check.local.sh` (see
`scripts/docs-check.local.sh.example`), never in `docs-check.sh` itself — the
shared guard has to stay updatable.

<Add your project's real commands here. Leave a command out rather than promise one that does not work.>
