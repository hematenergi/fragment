---
id: docs-index
title: Document index
status: active
owner: rafi
last-verified: 2026-08-28
---

# Document index

Every file under `docs/` is listed here. Anything unlisted is treated as junk,
and `scripts/docs-check.sh` will find it.

This is a complete workflow snapshot of a small fictional online shop. The
application source is deliberately not included — the artifact here is the
documentation and the ritual around it. Commands shown in fragments and runbooks
are records of what the fictional team ran.

New here, and you do not read code? Start at
[`../START-HERE.md`](../START-HERE.md).

## Start and state

| File | What it is |
|---|---|
| [`../START-HERE.md`](../START-HERE.md) | Ten minutes, for anyone, technical or not |
| [`STATE.md`](STATE.md) | **Where things stand.** Read first, written last |
| [`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md) | The rules, for every agent and both humans |
| [`HOW-WE-WORK.md`](HOW-WE-WORK.md) | The rhythm, the labels, and who decides what |
| [`GLOSSARY.md`](GLOSSARY.md) | Words in plain language |

## Fragments

| File | What it is |
|---|---|
| [`plans/README.md`](plans/README.md) | How fragments work |
| [`plans/00-template.md`](plans/00-template.md) | Template for a new one |
| [`plans/01-catalogue-and-cart.md`](plans/01-catalogue-and-cart.md) | `done` — browsing and the cart |
| [`plans/02-checkout.md`](plans/02-checkout.md) | `in-progress` — paying |

## Decisions

| File | What it settles |
|---|---|
| [`decisions/0001-phone-numbers-not-email.md`](decisions/0001-phone-numbers-not-email.md) | Sign-up is by phone number. Re-opened twice by agents; that is why it is written down |

**Next number: 0002.**

## Lessons

| File | The rule it produced |
|---|---|
| [`lessons/two-places-held-the-price.md`](lessons/two-places-held-the-price.md) | A price is read from one place only |
| [`lessons/a-test-order-charged-a-real-card.md`](lessons/a-test-order-charged-a-real-card.md) | Test keys and live keys never share a file |

## Runbooks

| File | What it is for |
|---|---|
| [`runbooks/take-the-shop-offline.md`](runbooks/take-the-shop-offline.md) | The most important page here. One command, no permission needed |

## The guard

`scripts/docs-check.sh` is a **verbatim copy** of the shared guard — vendored,
never edited. Everything specific to this shop lives beside it in
`scripts/docs-check.local.sh`, which the guard runs if it is present: no
customer phone numbers or email addresses in documents, and every runbook
carrying a `Tested by:` line. That split is what lets us take a newer shared
guard without losing our own rules.
