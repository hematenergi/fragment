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

> **Two people appending on the same day.** Every session adds a line at the top
> of the session log, so that is the hottest line in the repo. `.gitattributes`
> sets `merge=union` on `STATE.md`, which keeps both sides of a concurrent
> append instead of raising a conflict. If two people edit the *same queue row*
> you get a visibly duplicated row — fix it by hand. A duplicate you can see is
> a better outcome than a conflict on every push.

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

These labels say how a handoff stands. They are **not** the `status:` field, which
is a different axis and has two vocabularies — one per kind of document:

| Kind | `status:` may be | Meaning |
|---|---|---|
| A fragment in [`plans/`](plans/) | `todo` → `in-progress` → `done` \| `parked` \| `superseded` | where the work has got to |
| Every other document | `active`, `draft`, `superseded` | whether it still describes reality |

A fragment being worked on right now is `in-progress`, not `active` — `active`
belongs to documents. The guard enforces the split, and mirrors the fragment's
value on the board in [`STATE.md`](STATE.md).

### Closing a fragment you did not finish

Most fragments do not end by being finished. They get overtaken, or stop
mattering. Both have somewhere to go, and both cost one sentence:

| Situation | Status | What the guard requires |
|---|---|---|
| The work happened, but elsewhere — another fragment, a ticket, a commit | `superseded` | `superseded-by:` naming it |
| Stopped on purpose, might resume, might not | `parked` | `reason:` saying why |
| Finished here | `done` | every box ticked, and the commands you ran pasted in |

**`parked` used to require nothing**, which made it the cheapest way to turn a
red board green: park everything, explain nothing. It now costs a `reason:`.
That is the point — closing a fragment should be easy, and lying about why it
closed should not be.

## Daily note

Template: [`templates/daily-note.md`](templates/daily-note.md). One per day.

The section people skip and shouldn't: **Carry-over** — what was unfinished yesterday. If nothing, write "clean". Never leave it empty, so "nothing" and "not filled in" stay distinguishable.

## Who decides what

| Decision | Who |
|---|---|
| **Stopping the system** | **anyone, any time, no permission needed** |
| Starting it / raising limits | <FILL IN — should require more than one person> |
| Order of work | anyone proposes, owner decides |
| How to build something | whoever builds it |
| Whether a claim passed or failed | the number written down beforehand, not a person |

Note the asymmetry in the first two rows. It is deliberate: stopping something healthy costs hours, failing to stop something broken costs everything.

Decisions already made are written in [`decisions/`](decisions/) so they are not decided twice.

## The rules that keep this tidy

- **One `in-progress` fragment at a time.** Found other work? Write a fragment; do not do it now.
- **A session that ends without updating `STATE.md` is unfinished**, whatever it produced.
- **Bugs outside the current scope: note them, do not fix them.**
- **If something is ambiguous, stop and ask.** Do not guess.
- **KISS, DRY, YAGNI.** Adding an abstraction, refactoring outside scope, swapping a library? Ask first.
