---
id: lesson-live-key
title: "A test order charged a real card"
status: active
owner: rafi
last-verified: 2026-08-28
---

# A test order charged a real card

## Symptom

Testing the payment step, Rafi placed what he believed was a pretend order.
The money left his own account. He noticed twenty minutes later, by accident,
looking at something else.

## Root cause

The test key and the live key were both in the same settings file, one commented
out. Switching between them meant moving a `#`. It had been switched to live
for a real test earlier that week and never switched back, and nothing on screen
looked any different.

## Rule

**Test keys and live keys never sit in the same file.** The live key exists only
in the deploy settings, where nobody edits it by hand. Invariant 2 in
[`../AGENT-PROTOCOL.md`](../AGENT-PROTOCOL.md).

And the reason the loss was small rather than large: Rafi took the shop offline
before asking anyone. That is why
[`../runbooks/take-the-shop-offline.md`](../runbooks/take-the-shop-offline.md)
needs no permission.
