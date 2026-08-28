---
id: plan-01
title: "01 — Catalogue and cart"
status: done
owner: rafi
last-verified: 2026-08-28
depends-on: []
---

# 01 — Catalogue and cart

**Goal.** A customer can see what we sell and put things in a cart.

## Why this was needed

Nothing existed. Dina was taking orders through chat messages and writing them
in a notebook, which worked until two people ordered the last of something
within a minute of each other.

## Read first

- `decisions/0001-phone-numbers-not-email.md` — the cart holds a phone number,
  not an email address
- `lessons/two-places-held-the-price.md` — why the price is read from one place

## Work

- [x] Product list, read from one file
- [x] Add to cart, remove from cart, change quantity
- [x] Cart survives a page reload
- [x] Price shown in the cart is read from the same place as the product page

## Done when

- [x] Dina can add three things to a cart on her own phone and the total is right
- [x] Reloading the page does not empty the cart
- [x] The product page and the cart never show different prices for the same item

## Traps

The price used to live in two places. Fixing the symptom in one of them makes
the bug look solved for about a day. If a price is wrong, look for the second
copy before looking at anything else.

## Validation

```bash
npm test
# 12 passing

npm run dev
# add 3 items, reload, total still 214.000 — checked on Dina's phone 2026-08-26
```

## Out of scope

Paying. That is fragment 02.

## Session log

- `2026-08-26` · claude · closed. The price now has one source; the cart and the
  product page can no longer disagree · next: fragment 02.
- `2026-08-25` · claude · cart and quantities work, but the cart showed a stale
  price after an edit · next: find where the second price is coming from.
