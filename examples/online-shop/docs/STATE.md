---
id: state
title: STATE — where things stand
status: active
owner: rafi
last-verified: 2026-08-28
---

# STATE

**Read this first, write it last.** The only place that answers "where are we?".

> **Do not read code?** Start at [`../START-HERE.md`](../START-HERE.md). The
> Phase and Blocked sections below are written for you.

---

## Phase

**Phase 1 — take one real order.** Browsing and the cart work. Paying does not.
The gate that ends this phase: one real customer completes one real order and
the money arrives, with nobody stepping in by hand.

## Active fragment

**`02` — [Checkout](plans/02-checkout.md)** · `in-progress`

The cart reaches the payment step and the phone number is captured. It stops
there because nobody has decided what a customer should see when a payment
fails.

> At most **one** active fragment. If something is here and it is not yours, ask
> before touching it.

## Queue — take from the top

| # | Fragment | Status | Blocked by |
|---|---|---|---|
| 01 | [Catalogue and cart](plans/01-catalogue-and-cart.md) | `done` | — |
| 02 | [Checkout](plans/02-checkout.md) | `in-progress` | — |

## Blocked / waiting on a human

| What | Waiting on | Since |
|---|---|---|
| What a customer sees when a payment fails — retry, or an order we chase by hand? | Dina | 2026-08-27 |
| Whether we deliver outside the city yet | Dina | 2026-08-26 |

## Decisions already made — do not ask again

Full reasoning in [`decisions/`](decisions/). Listed here because these are the
ones an agent keeps re-opening at the start of a session.

- **Sign-up is by phone number, not email.** Settled 2026-08-24. Most of
  our customers do not have an email address. See
  [`decisions/0001-phone-numbers-not-email.md`](decisions/0001-phone-numbers-not-email.md).

---

## Session log

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

- `2026-08-27` · codex · 02 · Checkout now collects a phone number and reaches
  the payment step; the agent opened the session by asking whether sign-up
  should use email, which `decisions/0001` had already settled — the
  decision is now listed on this board so it is seen before the question is
  asked · **Next:** Dina decides what a failed payment shows.
- `2026-08-26` · claude · 01 · Fragment 01 closed. The price is now read from
  one place only, after the cart and the product page disagreed for nine days
  and two customers were charged the wrong amount · **Next:** start 02.
- `2026-08-24` · claude · — · Harness installed. Invariants written from what
  had already hurt us: no customer details in the repo, test and live keys kept
  apart, one source for a price · **Next:** write fragment 01.
