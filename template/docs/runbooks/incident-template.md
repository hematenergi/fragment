---
id: run-incident-template
title: "Template — incident note"
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Incident template

Copy to `runbooks/incident-YYYY-MM-DD-<slug>.md` whenever something goes wrong — **including when it turns out to be nothing.** A false alarm is still worth recording: the same thing will cause the same panic in six months.

Write it plainly. Nothing here is being graded. What is being looked for is a **rule that prevents recurrence**, not who was at fault.

---

## One-line summary

_What happened, in plain language._

## Timeline

Times, what was seen, who did what. Local time, and say which zone.

| Time | Event |
|---|---|
| | |

## Impact

- Money: _how much, or "none"_
- Time: _how long the system was not working_
- Data: _lost or not_

## What actually happened

Root cause, not symptom. If it is not known yet, write "not yet known" — that is a valid answer and more useful than a confident guess.

## Why it was not caught sooner

Usually the most expensive lesson is here. **What should have been screaming, and was silent?**

## Rules born from this

- [ ] _A concrete, actionable rule_
- [ ] Write it into `../lessons/<name>.md` if this is a recurring class of bug
- [ ] Register it in `../README.md`

## Deliberately not fixed now

So nothing rides along on an emergency fix.
