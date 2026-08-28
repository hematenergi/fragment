---
id: decision-0001
title: "0001 — Sign-up is by phone number, not email"
status: active
owner: dina
last-verified: 2026-08-28
---

# 0001 — Sign-up is by phone number, not email

**Decided** 2026-08-24, by Dina.

## Context

Checkout needs some way to reach a customer about their order. The obvious
default is an email address, and every agent that has opened this project has
proposed one.

## Decision

Sign-up and checkout ask for a **phone number**. There is no email field
anywhere in the shop.

## Why

Most of our customers do not have an email address they check. They have a phone
number, and they already message Dina on it. An email field would be a box that
people fill in with something fake so the button turns green, which is worse
than not asking.

## Consequences

- Order updates go out by message, not by email.
- We cannot use the payment provider's built-in email receipts. That is fine;
  the dashboard is the record.
- A phone number is a customer detail, so it falls under invariant 1: it must
  never appear in this repository. `scripts/docs-check.local.sh` checks for it.

## To change this

It would take Dina finding that customers are asking for email receipts. Not a
technical decision, and not one an agent can make on its own.

> **Note for whoever reads this next.** This decision has been re-opened twice by
> agents starting a fresh session, on 2026-08-26 and 2026-08-27, because a new
> session has no memory of the week it was settled in. That is exactly why it is
> written here and listed on the board.
