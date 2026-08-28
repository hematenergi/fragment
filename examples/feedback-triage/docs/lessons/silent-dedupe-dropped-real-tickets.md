---
id: lesson-silent-dedupe
title: Silent de-duplication dropped real tickets
status: active
owner: priya
last-verified: 2026-08-28
---

# Silent de-duplication dropped real tickets

## What happened

The first matcher deleted a new report when its normalized text matched an
existing one. It emitted no event and preserved no relationship. Over nine
days, 431 legitimate reports disappeared from the working queue.

## Why it survived

The service stayed healthy and the visible queue looked cleaner. Review focused
on matching quality, not on whether every source item remained countable.

## Rule we keep

De-duplication is metadata, not deletion: retain raw input, mark the proposed
relationship, and make reversal possible. The policy is recorded in
[`../decisions/0001-mark-duplicates-never-delete.md`](../decisions/0001-mark-duplicates-never-delete.md)
and implemented in
[`../plans/01-ingest-and-dedupe.md`](../plans/01-ingest-and-dedupe.md).
