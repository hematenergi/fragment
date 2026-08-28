---
id: plan-01
title: Ingest and de-duplicate feedback
status: done
owner: priya
last-verified: 2026-08-28
depends-on: []
---

# 01 — Ingest and de-duplicate feedback

**Goal.** Collect all three feedback channels without losing repeated reports.

## Why this was needed

The widget, support inbox, and app store produced separate queues and duplicate
complaints. An early silent de-duplication pass also removed real tickets; the
failure is recorded in
[`../lessons/silent-dedupe-dropped-real-tickets.md`](../lessons/silent-dedupe-dropped-real-tickets.md).

## Read first

- [`../AGENT-PROTOCOL.md`](../AGENT-PROTOCOL.md) — especially the raw-ingest invariant
- [`../decisions/0001-mark-duplicates-never-delete.md`](../decisions/0001-mark-duplicates-never-delete.md)

## Work

- [x] Ingest the widget, support inbox, and app-store feeds.
- [x] Keep every raw item before classification.
- [x] Mark likely duplicates instead of deleting either record.
- [x] Replay nine days of retained input and restore the 431 dropped tickets.

## Done when

- [x] Every source item has a stable source id and arrival timestamp.
- [x] A duplicate remains queryable and points to its proposed canonical item.
- [x] Replay counts match the retained raw input for all three channels.

## Validation

Recorded in the original project; the application source is not included in
this documentation snapshot.

```console
$ npm test -- --runIngest
PASS 18 tests

$ npm run ingest:replay -- --since 9d
6,240 processed · 431 restored · 0 deleted
```

## Out of scope

Automatic routing. That work is isolated in
[`02-auto-triage-rules.md`](02-auto-triage-rules.md).

## Session log

- `2026-08-21` · claude · replayed retained input, restored 431 tickets, and
  changed deletion to marking · next: close 01 and start routing rules
