# Start here

**For anyone new — and you do not need to read code.** Ten minutes. After this
you know what we are building, what you are allowed to do, and what to do when
something looks wrong.

## What this is

A small online shop. People look at a short list of things we sell, put some in
a cart, and pay. That is the whole product. It is not finished: you can browse
and add to a cart today, but paying does not work yet.

## Three things that matter most for you

### 1. If the shop is charging people wrongly, take it offline. You do not need permission.

One command, written down here:
[`docs/runbooks/take-the-shop-offline.md`](docs/runbooks/take-the-shop-offline.md).
Taking it down is safe. Nobody loses an order; the page just says we are closed
for a moment. **We have already been burned once by waiting to ask** — see
[`docs/lessons/a-test-order-charged-a-real-card.md`](docs/lessons/a-test-order-charged-a-real-card.md).

### 2. Numbers are only real if they come from the dashboard

If you hear a figure in chat that is not on the orders dashboard, treat it as
unverified — not because anyone is lying, but because counting orders by hand
across a spreadsheet and a screen is wrong more often than it is right.

### 3. If something looks off, say so — even if you are not sure

"This looks weird to me" is a useful thing to say. The most expensive problem we
have had so far was silent: no error, no alarm, just two prices that disagreed
with each other for nine days.

## If you want something built

Do not ask in chat and hope it is remembered. Chat disappears; a **fragment**
does not — [`docs/HOW-WE-WORK.md`](docs/HOW-WE-WORK.md) explains how to write
one. You do not need to write code to write a fragment. Say what you want and
how you will know it is done.

The same goes for decisions. If you settle something — which payment provider,
what the delivery cutoff is, whether we sell to another city — it goes in
[`docs/decisions/`](docs/decisions/). Otherwise you will be asked again next
week, by a person or by an agent, and neither of you will remember why.

## Map

| You want to… | Open |
|---|---|
| stop the shop | [`docs/runbooks/take-the-shop-offline.md`](docs/runbooks/take-the-shop-offline.md) |
| know what a word means | [`docs/GLOSSARY.md`](docs/GLOSSARY.md) |
| know how we work | [`docs/HOW-WE-WORK.md`](docs/HOW-WE-WORK.md) |
| know where things stand | [`docs/STATE.md`](docs/STATE.md) |
| know why something is the way it is | [`docs/decisions/`](docs/decisions/) |
| see every document | [`docs/README.md`](docs/README.md) |
