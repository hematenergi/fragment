---
id: how-we-work
title: How the two of us work
status: active
owner: dina
last-verified: 2026-08-28
---

# How the two of us work

Readable by everyone. This is the rhythm — not the technical rules, which are in
[`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md).

## Work runs as fragments

A **fragment** is one piece of work that stands on its own: it can be left
half-done and picked up by someone else — or by a different agent, on a
different day — **without the conversation that produced it.**

All fragments are in [`plans/`](plans/). The board is [`STATE.md`](STATE.md).

**If you only ever open one file: open [`STATE.md`](STATE.md).**

## Asking for something to be built

Do not ask in chat and hope it is remembered. Chat disappears; fragments do not.

1. Copy [`plans/00-template.md`](plans/00-template.md) to the next number.
2. Fill in three things — the technical parts can come later:
   - **Goal** — what is different once this is done
   - **Why** — the problem you actually feel
   - **Done when** — how *you* will check it, yourself
3. Add it to the queue in [`STATE.md`](STATE.md).

You do not need to write code to write a fragment. The best "Done when" we have
was Dina's: *"I can buy something from my own shop on my own phone, and the
money shows up."*

## When you settle something, write it down the same day

This is the rule we keep learning. A decision that lives only in a conversation
gets re-opened — by the other one of us, or by an agent starting a fresh
session, which has no memory of Monday at all. Writing it in
[`decisions/`](decisions/) takes two minutes. Explaining it for the fourth
time takes longer than that, every time.

## Status labels

| Label | Meaning |
|---|---|
| `READY TEST` | Built, checks pass, ready for the other one of us to try |
| `BLOCKED` | Cannot go on. Must say why **and** suggest a default |
| `PARKED` | Deliberately stopped, with the reason written down. A fine outcome |

`READY TEST` is only allowed when the check results are written out. **Nobody
says "done" without something the other person can read.**

## Who decides what

| Decision | Who |
|---|---|
| **Taking the shop offline** | **anyone, any time, no permission needed** |
| Putting it back online | both of us |
| Anything about price, refunds, or what we sell | Dina |
| How something is built | Rafi |
| Order of work | Dina says what matters, Rafi says what it costs |
| Whether something passed | the "Done when" written beforehand, not an opinion after |

Note the asymmetry in the first two rows. It is deliberate: closing a healthy
shop for an hour costs a few orders, and leaving a broken one open costs
customers we do not get back.
