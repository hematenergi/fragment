---
id: decision-0008
title: Automatic STATE pruning at local close
status: active
owner: hematenergi
last-verified: 2026-10-11
tags: [state, pruning, archive, continuity]
---

# Automatic STATE pruning at local close

## Context

The v0.6.0 prune command required an agent to decide when to preview and apply it. Its keep-count implementation followed file order, so an older entry placed after a newer one could make the hot/cold split incorrect.

## Decision

Every successful local `docs-check.sh` run measures STATE against a 12,000-byte UTF-8 budget. If it is over budget, Fragment archives the oldest dated session entries until STATE fits or no removable entries remain. It preserves every record and adds a Markdown link from hot STATE to the archive. For equal dates, later file positions archive first; retained records stay in their original order. A failed guard, inventory run or CI comparison does not write adopter files.

The archive remains a normal Markdown note linked from STATE, so Obsidian and other Markdown graph views can discover it. Explicit links provide navigation; graph degree does not decide which history is important.

## Why

Manual maintenance is easy to skip and does not create the automatic continuity behavior Fragment promises. A byte threshold gives a repeatable need/no-need decision, and ISO dates give a repeatable archive order even when log lines are out of order. Archiving keeps history recoverable while shrinking the hot context.

## Consequences

- Local close checks handle ordinary pruning without a separate agent step.
- CI and diagnostic inventory remain read-only.
- If fixed STATE content alone exceeds the budget, the guard reports that pruning could not fit it and preserves the file.
- Customized prune scripts remain user-owned during upgrades.

## To change this

Create a new decision if the budget, trigger or automatic lifecycle changes.
