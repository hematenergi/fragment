---
id: how-we-work
title: How this team works
status: active
owner: priya
last-verified: 2026-08-28
---

# How this team works

Readable by everyone, technical or not. This is the rhythm — not the technical
rules (those are in [`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md)).

## Work runs as fragments

A **fragment** is one unit of work that stands on its own: it can be abandoned
mid-way and picked up by someone else **without the conversation that produced
it.** All fragments are in [`plans/`](plans/). The board is [`STATE.md`](STATE.md).

**If you only ever open one file: open [`STATE.md`](STATE.md).**

## Asking for something to be built

Do not ask in chat and hope someone remembers. Chat disappears; fragments do not.

1. Copy [`plans/00-template.md`](plans/00-template.md) to the next number.
2. Fill in at least these three — the technical parts can come later:
   - **Goal** — what is different once this is done
   - **Why** — the problem you actually feel
   - **Done when** — how *you* will check it, yourself
3. Add it to the queue in [`STATE.md`](STATE.md).

"Done when" is often **better** written by someone who is not building it. The
best one we have was written by the support lead: *"I stop re-routing billing
items by hand on Monday mornings."*

## Status labels

| Label | Meaning |
|---|---|
| `READY TEST` | Built, checks pass, ready for someone else to try |
| `BLOCKED` | Cannot proceed. Must state the reason **and** a recommended default |
| `PARKED` | Deliberately stopped, with the reason written down. An honourable outcome |

`READY TEST` is only allowed when the check results are written out. **Nobody
says "done" without evidence someone else can read.**

## Who decides what

| Decision | Who |
|---|---|
| **Stopping ingestion** | **anyone, any time, no permission needed** |
| Starting it again / changing a routing rule in production | two people, one of them the support lead |
| Order of work | anyone proposes, Priya decides |
| How to build something | whoever builds it |
| Whether a claim passed or failed | the number written down beforehand, not a person |

Note the asymmetry in the first two rows. It is deliberate: stopping something
healthy costs an hour of queued items, failing to stop something broken cost us
nine days and 431 tickets.

Decisions already made are written in [`decisions/`](decisions/) so they are not
decided twice.
