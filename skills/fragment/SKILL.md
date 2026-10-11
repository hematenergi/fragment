---
name: fragment
description: Keep project decisions, current state, and next steps in the repo so a fresh coding agent can resume. Use when installing or updating Fragment in an existing repository.
---

# Fragment

![An open project folder carries a decision across the gap into a new coding session.](https://raw.githubusercontent.com/hematenergi/fragment/main/site/assets/fragment-context-handoff.jpg)

**Keep the next coding session from starting blind.** Fragment stores project
decisions, lessons, current state, and the next action in repository files. A
Bash guard checks the handoff locally and in CI.

It works with the coding agent already in use. It adds project docs and a Bash
check, not application behavior. It needs only Bash and Git—no model API,
database, daemon, or account. The guard checks documented structure; it does not
verify application code or whether a recorded decision is correct.

## What goes in the repo

| Core file | What it gives the next session |
|---|---|
| `docs/AGENT-PROTOCOL.md` | Shared rules for agents and people |
| `CLAUDE.md` / `AGENTS.md` | Short entry points to those rules |
| `docs/STATE.md` | Current phase, active work, blockers, and next action |
| `docs/README.md` | A map of the project's managed docs |
| `scripts/docs-check.sh` | A check for missing structure, links, and handoff updates |
| `.github/workflows/docs.yml` | Runs the check in CI |

`.gitattributes` keeps the guard's line endings stable and configures union
merges for `STATE.md`. `scripts/docs-check.local.sh` is optional for rules
unique to that repo.

Add `docs/plans/` for active work, `docs/decisions/` for durable choices, and
`docs/lessons/` for bugs the team has already paid for. Architecture, research,
runbooks, a glossary, and `START-HERE.md` are optional; add them only when the
team needs them.

## Adopt it safely

### 1. Inspect before writing

- Read the root and `docs/`, existing `CLAUDE.md` / `AGENTS.md`, contribution
  rules, and any ADR or decision folder.
- Read `docs/continuity.md` before mapping existing note sources and permissions.
- Check recent commits and the language used in the repo.
- Summarize the current setup and the smallest install plan. An explicit request
  to install Fragment authorizes the install; ask only about facts or invariants
  that cannot be inferred, and keep doing independent work.

### 2. Preserve the repo's existing rules

- Never overwrite or delete existing files. Add the Fragment protocol pointer to
  an existing front door; keep existing decisions where they are.
- Copy the Core from `template/`, merging it into the repo rather than replacing
  existing files.
- Match the repo's language. `docs-check.sh` reads file structure, not English
  headings.
- Reuse the team's documented source roles and permissions. Do not crawl private
  notes or create a daily log by default.
- Add optional folders only for real work. Never fill STATE or the queue with
  template placeholders.

### 3. Fill project facts from evidence

- Write only invariants visible in code, config, or existing docs. Ask about
  rules only the owner can set; mark uncertain rules `PROPOSED — confirm`.
- Seed `STATE.md` from current commits, tasks, and blockers. Record one honest
  handoff line.
- Add plans only for authorized work. Record lessons only when a real bug or
  repeat failure supports them; do not invent examples.
- Add every managed doc to `docs/README.md`.

### 4. Prove the guard works, then wire CI

Run the guard after the core files are in place, before filling the template
values. Treat its failures as the setup checklist and fix them with the owner.
Then demonstrate both failure and recovery by creating a temporary unlisted
Markdown file under `docs/`, running the guard, removing only that file, and
confirming the guard returns green. Show both results.

Install `.github/workflows/docs.yml`. If the repo uses another CI system, run
the same one-line Bash check there. Explain its scope plainly: it catches
missing documentation structure and handoffs, not code defects or false facts.

### 5. Close the session

Follow the newly installed protocol on this work: update affected records and
`STATE.md`, preserve other sessions' changes, and confirm any external writes
separately. Report the files installed, guard results, and unresolved blockers.

## Common misses

| Symptom | Fix |
|---|---|
| `STATE.md` is stale | Update it when the work changes the current phase or next action; dates alone do not prove review |
| Front doors grow into full rulebooks | Keep rules in `docs/AGENT-PROTOCOL.md` and link to it |
| The guard is disabled in CI | Restore the check; otherwise the structure can drift unnoticed |
| A fragment is marked `done` without evidence | Record the commands and results that prove it is finished |
