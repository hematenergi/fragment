---
id: how-we-work
title: How this team works
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# How this team works

Readable by everyone, technical or not. This is the rhythm — not the technical rules (those are in `AGENT-PROTOCOL.md`).

## Work runs as fragments

A **fragment** is one unit of work that stands on its own: it can be abandoned mid-way and picked up by someone else **without the conversation that produced it**.

Why: work here is done in turns, by different people and different AI agents, on different days. If the context only lives in someone's head or in one chat window, work stops the moment that person gets busy.

All fragments are in [`plans/`](plans/). The board is [`STATE.md`](STATE.md).

## Three files hold everything up

| File | What it holds | Who writes it |
|---|---|---|
| [`STATE.md`](STATE.md) | Position: what is active, queued, stuck | whoever just finished a session |
| [`plans/NN-*.md`](plans/) | One unit of work in detail | whoever asked for it, or does it |
| [`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md) | Rules for agents and developers | changed together, rarely |

**If you only ever open one file: open `STATE.md`.**

## Asking for something to be built

Do not ask in chat and hope someone remembers. Chat disappears; fragments do not.

1. Copy [`plans/00-template.md`](plans/00-template.md) to the next number.
2. Fill in at least these three — the technical parts can come later:
   - **Goal** — what is different in the world once this is done
   - **Why** — the problem you actually feel
   - **Done when** — how *you* will check it, yourself
3. Add it to the queue in [`STATE.md`](STATE.md).

You do not need to write code to write a fragment. "Done when" is often **better** written by someone who is not building it.

## Status labels

| Label | Meaning |
|---|---|
| `READY TEST` | Built, checks pass, ready for someone else to try |
| `CROSSCHECK` | Built but depends on another party or dataset — say what needs verifying |
| `BLOCKED` | Cannot proceed. Must state the reason **and** a recommended default |
| `PARKED` | Deliberately stopped, with the reason written down. An honourable outcome, not a failure |

`READY TEST` is only allowed when the check results are written out. **Nobody says "done" without evidence someone else can read.**

## Daily note

Template: [`templates/daily-note.md`](templates/daily-note.md). One per day.

The section people skip and shouldn't: **Carry-over** — what was unfinished yesterday. If nothing, write "clean". Never leave it empty, so "nothing" and "not filled in" stay distinguishable.

## Who decides what

| Decision | Who |
|---|---|
| **Stopping the system** | **anyone, any time, no permission needed** |
| Starting it / raising limits | <fill in — should require more than one person> |
| Order of work | anyone proposes, owner decides |
| How to build something | whoever builds it |
| Whether a claim passed or failed | the number written down beforehand, not a person |

Note the asymmetry in the first two rows. It is deliberate: stopping something healthy costs hours, failing to stop something broken costs everything.

Decisions already made are written in [`decisions/`](decisions/) so they are not decided twice.

## The rules that keep this tidy

- **One active fragment at a time.** Found other work? Write a fragment; do not do it now.
- **A session that ends without updating `STATE.md` is unfinished**, whatever it produced.
- **Bugs outside the current scope: note them, do not fix them.**
- **If something is ambiguous, stop and ask.** Do not guess.
- **KISS, DRY, YAGNI.** Adding an abstraction, refactoring outside scope, swapping a library? Ask first.
