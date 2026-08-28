---
id: state
title: STATE — where the work stands
status: active
owner: priya
last-verified: 2026-08-28
---

# STATE

**Read this first, write it last.** The only place that answers "where are we?".

> **Not an engineer?** Start at [`../START-HERE.md`](../START-HERE.md). The
> Phase and Blocked sections below are readable by anyone.

---

## Phase

**Phase 1 — routing that a human can predict.** Ingest and de-duplication are
live for all three channels. The gate that ends this phase: one full week where
the support lead does not manually re-route more than 5% of items.

## Active fragment

**`02` — [Auto-triage rules](plans/02-auto-triage-rules.md)** · `in-progress`

Rules engine is written and passing tests against last month's replay. Not yet
wired to the live queue.

> At most **one** active fragment. If something is here and it is not yours, ask
> before touching it.

## Queue — take from the top

| # | Fragment | Status | Blocked by |
|---|---|---|---|
| 01 | [Ingest and de-duplicate](plans/01-ingest-and-dedupe.md) | `done` | — |
| 02 | [Auto-triage rules](plans/02-auto-triage-rules.md) | `in-progress` | — |

## Blocked / waiting on a human

| What | Waiting on | Since |
|---|---|---|
| Which team owns "billing but actually login" items — the two overlap on ~40 a week | Priya + support lead | 2026-08-22 |
| App-store review API quota raise | vendor | 2026-08-20 |

## Open decisions

Closed by writing a file in `decisions/`, not by answering in chat.

- Do we route an item that matches two rules to both teams, or to the higher
  priority one? Routing to both doubles the notification volume; routing to one
  means the other team never learns the overlap exists.

The duplicate-handling policy is recorded in
[`decisions/0001-mark-duplicates-never-delete.md`](decisions/0001-mark-duplicates-never-delete.md).

---

## Session log

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

- `2026-08-24` · claude · 02 · Rules engine replayed against 6,240 items from last
  month: 91.2% matched the support lead's own routing, and every mismatch is in
  the billing/login overlap · **Next:** that overlap is a decision, not a bug —
  Priya and the support lead pick one, then wire to the live queue.
- `2026-08-23` · codex · 02 · Rule format settled as flat YAML a non-engineer
  can read and edit; deliberately no regex, because the support lead has to be
  able to change a rule without asking us · **Next:** replay it against last
  month before wiring anything live.
- `2026-08-21` · claude · 01 · Fragment 01 closed. De-duplication now marks
  instead of deleting, after it silently dropped 431 real tickets over nine days
  — written up in `lessons/` · **Next:** start 02.
