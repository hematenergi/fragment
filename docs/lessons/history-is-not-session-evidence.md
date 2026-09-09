---
id: lesson-history-is-not-session-evidence
title: A documentation clue is not an unfinished session
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# A documentation clue is not an unfinished session

## Symptom

The adopter closed a recorded session and received GREEN with 122 warnings and
another question about STATE. The count meant 121 commit/review date differences
and one protocol length clue, not 122 verified errors or unfinished tasks.

## Root cause

The guard promoted historical proxies into an actionable warning budget. Its
closing reminder was unconditional, while actual code-only work without a
handoff was invisible locally and to the old docs-only CI comparison.

## Rule

Separate historical inventory, checkout structure and session evidence. Name
what a check establishes: a body addition is not proof of truth, and an old
date is not proof of a missing handoff. Agents verify relevant claims when
using them; the guard checks explicit structural contracts. Keep a regression
for the mature-adopter count alongside missing code-handoff cases.
