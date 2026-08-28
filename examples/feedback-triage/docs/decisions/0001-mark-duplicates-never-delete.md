---
id: decision-0001
title: Mark duplicates, never delete them
status: active
owner: priya
last-verified: 2026-08-28
---

# Mark duplicates, never delete them

## Context

Two reports can look identical while representing different customers or
separate incidents. Silent de-duplication dropped 431 real tickets before the
team noticed; see
[`../lessons/silent-dedupe-dropped-real-tickets.md`](../lessons/silent-dedupe-dropped-real-tickets.md).

## Decision

Keep every raw report. A suspected duplicate receives a marker and a reference
to the proposed canonical item, but neither record is deleted. A human can
remove or change that relationship.

## Consequences

Storage and dashboard counts are slightly higher. In exchange, every decision
is reversible, source totals remain auditable, and replay can recover from a
bad matching rule.

Implemented by [`../plans/01-ingest-and-dedupe.md`](../plans/01-ingest-and-dedupe.md).
