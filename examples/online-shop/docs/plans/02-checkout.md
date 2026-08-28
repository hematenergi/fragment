---
id: plan-02
title: "02 — Checkout"
status: in-progress
owner: rafi
last-verified: 2026-08-28
depends-on: [plan-01]
---

# 02 — Checkout

**Goal.** A customer can pay, and the money arrives, without either of us
touching anything by hand.

## Why this is needed

This is the whole point of the shop. Until it works, Dina is still taking money
by transfer and matching it to orders herself.

## Read first

- `decisions/0001-phone-numbers-not-email.md` — checkout asks for a phone
  number. **Do not add an email field.** This has been re-opened twice.
- `lessons/a-test-order-charged-a-real-card.md` — before touching any key

## Work

- [x] Cart hands its total to the payment step
- [x] Phone number captured and validated
- [ ] Success screen after a payment goes through
- [ ] What happens when a payment fails — **blocked, see Done when**

## Done when

- [ ] Dina can buy something from her own shop, on her own phone, and the money
      shows up on the dashboard
- [ ] A deliberately failed payment does something sensible instead of a blank
      page
- [ ] No live key exists anywhere outside the deploy settings

## Traps

The payment provider's test mode and live mode look identical on screen. The
only way to tell them apart is which key is loaded. Check before assuming a
test did nothing.

## Validation

```bash
npm test
npm run dev
# pay with the provider's test card, confirm the order appears in test mode only
```

## Out of scope

Refunds. Delivery outside the city — Dina has not decided that yet.

## Session log

- `2026-08-27` · codex · phone number captured, payment step reached. The
  session opened by asking whether sign-up should use email or phone, which was
  settled on Monday; `decisions/0001` is now linked from "Read first" above and
  listed on the board · next: Dina decides what a failed payment shows.
