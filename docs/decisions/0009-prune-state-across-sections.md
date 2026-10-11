---
id: decision-0009
title: Prune STATE history across sections and explicit terminal rows
status: active
owner: hematenergi
last-verified: 2026-10-11
tags: [state, pruning, archive, continuity]
---

# Prune STATE history across sections and explicit terminal rows

## Context

The v0.6.1 pruner only searched below the final level-two heading. In an
adopter STATE with handoff sections after its session log, most dated history
was invisible to the budget check. Removing all recognized entries could also
leave explicitly closed plan rows bloating the hot board.

## Decision

Keep the 12,000-byte local-close trigger and read-only behavior for CI,
inventory and failed checks. Recognize dated bullet records anywhere in STATE,
regardless of heading. Archive the oldest records first while keeping the
newest dated record hot if the budget can be met another way.

If older dated records are not enough, a Markdown table row is eligible only
when it links to a plan under the STATE document's `plans/` directory, its
status cell is exactly `done`, `parked` or `superseded`, and the linked plan's
frontmatter confirms the same status. Archive the oldest `last-verified` rows
first, breaking ties by later file position. Archive `done` and `superseded`
rows before `parked` rows; parked work stays hot whenever earlier tiers meet
the budget. Keep active, missing, malformed or status-mismatched rows hot. The
newest dated record is the final history fallback if all plan rows still cannot
bring STATE under budget.

Every removed line remains in the linked archive. Relative Markdown links in
archived entries are rebased from STATE's directory to the archive's directory
so Obsidian and other graph readers still reach the same files. If the remaining
content cannot fit, report the limit and change no files.

## Why

Headings describe a team's organization, not where its history ends. Explicit
plan status and a matching linked file give a deterministic signal that a
board row is no longer active, without guessing from its prose. The linked
plan remains in place, and the archive keeps the removed board entry reachable.

## Consequences

- Local close checks can bound STATE files with later handoff sections and
  large boards without asking an agent to choose what to delete.
- `todo` and `in-progress` rows remain in hot STATE; parked rows stay hot when
  possible, and all archived rows remain available through their plan file and
  the archive graph link.
- The archive order is based on ISO dates and explicit frontmatter, never graph
  degree or inferred importance.

## To change

Create a new decision if the budget, trigger, eligible structures, ordering or
automatic lifecycle changes.
