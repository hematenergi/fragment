---
id: plan-02
title: Auto-triage rules
status: in-progress
owner: priya
last-verified: 2026-08-28
depends-on: [plan-01]
---

# 02 — Auto-triage rules

**Goal.** Suggest a destination team using rules the support lead can read and
edit, while keeping final routing under human control.

## Read first

- [`../AGENT-PROTOCOL.md`](../AGENT-PROTOCOL.md) — the model never routes invariant
- [`01-ingest-and-dedupe.md`](01-ingest-and-dedupe.md) — the input contract

## Current state

Flat YAML rules match 91.2% of the support lead's decisions in a replay of
6,240 items. Every remaining mismatch is in the billing/login overlap.

## Work

- [x] Define a flat, readable rule format without regex.
- [x] Replay the rules against last month's retained items.
- [ ] Record the human decision for billing/login overlap.
- [ ] Wire rule suggestions to the live queue after that decision.

## Done when

- [ ] The support lead can edit and dry-run a rule without engineering help.
- [ ] No rule directly routes an item without human confirmation.
- [ ] Misroutes remain below 5% for one full week.

## Validation

Planned commands in the original project; application source is not included
in this documentation snapshot.

```bash
npm test -- --runTriage
npm run triage:dry -- --since 24h
```

## Out of scope

Machine-learned classification and automatic routing.

## Session log

- `2026-08-24` · claude · replay reached 91.2%; isolated every mismatch to the
  billing/login overlap · next: Priya and the support lead choose one policy
