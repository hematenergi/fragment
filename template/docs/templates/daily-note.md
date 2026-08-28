---
id: template-daily-note
title: "Template — daily note"
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Daily note template

Copy to `notes/YYYY-MM-DD.md` (outside the repo is fine — a personal notes app works). Everything below the line is the note.

---

## Carry-over from yesterday

> The one section filled in by hand when starting a new note. Copy every item that was **not finished** yesterday, with its label (`READY TEST` / `CROSSCHECK` / `BLOCKED` / `PARKED`), plus any decision still waiting on an answer.
> If there is nothing, write **"clean"** — never leave it empty, so "nothing" and "not filled in" stay distinguishable.

-

## Today's focus

One sentence. If there are three, there is no focus.

-

## Fragments worked on

One block per fragment. Number and title copied from `docs/STATE.md`.

- [ ] `NN` — fragment title — **label**
    - `Steps done:`
        1. _prep: read STATE, read the fragment, read the area docs_
        2. _implementation: which file/module/logic changed_
        3. _validation: the command output, as it actually came out_
        4. _handoff: what needs to happen next_
    - `Next:` _ready test / crosscheck / follow up / verdict_

**`READY TEST` is only allowed when the validation output is actually written in this block.** Lint and build passing proves the code runs — not that the result is right.

## System state

Fill in if something is running. Copy numbers **from the system's own report; do not compute them by hand.**

| | |
|---|---|
| | |

## Findings

Anything that made you frown, even if it is not a problem yet. This is the section that most often turns out to have been the early warning.

-

## Blocked / waiting on a decision

Say **who** is being waited on and **what** the question is. If there is a sensible default, propose it — do not just ask.

-

## Needs to go into the docs

Non-obvious bug fixed → `docs/lessons/`. Decision made → `docs/decisions/`. If neither, write "none".

-
