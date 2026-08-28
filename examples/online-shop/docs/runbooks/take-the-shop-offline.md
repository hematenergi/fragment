---
id: runbook-offline
title: Take the shop offline
status: active
owner: dina
last-verified: 2026-08-28
---

# Take the shop offline

**Use this whenever something looks wrong with money.** A wrong price, a charge
that should not have happened, an order that arrived twice. You do not need to
be sure, and you do not need to ask anyone.

Taking the shop down is safe. Nobody loses an order. The page says we are closed
for a moment, and that is all a customer sees.

## Do this

```bash
npm run shop:close
```

If you cannot run that — you are on your phone, or it is three in the morning —
open the hosting dashboard, find this project, and turn off the deployment. The
button is called **Pause**. Same result.

## Then check

1. The shop's front page shows the closed message.
2. No new orders are appearing on the payment dashboard.
3. Write in [`../STATE.md`](../STATE.md) what you saw and what time it was.
   One line is enough.

## Bringing it back

Needs both of us, deliberately. Nothing goes back online until whatever you saw
is understood — not guessed at.

Tested by: Dina, 2026-08-26, from her phone, without asking anyone first. She
had not opened the code before. That is the test that matters — a runbook only
its author can follow is not a runbook.
