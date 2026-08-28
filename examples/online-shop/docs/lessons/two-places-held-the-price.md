---
id: lesson-price
title: "Two places held the price"
status: active
owner: rafi
last-verified: 2026-08-28
---

# Two places held the price

## Symptom

For nine days the product page and the cart sometimes showed different prices
for the same item. It looked random. Two customers were charged an amount they
had not agreed to, and Dina refunded the difference out of her own pocket.

## Root cause

The price existed twice: once in the product list, and once copied into the cart
when an item was added. Editing a price updated the first one. Any cart created
before the edit kept the old number, quietly, forever.

Each time it was reported, the visible wrong number was corrected, which made
the bug look fixed for about a day.

## Rule

**A price is read from one place only.** If you find a second place holding a
price, that is the bug, whatever the symptom looked like. This is invariant 3 in
[`../AGENT-PROTOCOL.md`](../AGENT-PROTOCOL.md).

More generally: when the same fact is stored twice, the question is never *which
one is wrong*. It is *why there are two*.
