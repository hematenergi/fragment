---
id: architecture-index
title: Architecture — cross-cutting design
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Architecture

Design that spans features or repos, and the reasoning behind boundaries. Not per-feature detail — that belongs with the feature.

Good candidates:

- **Boundaries.** What this repo builds and what it deliberately does not. Which direction data flows across each boundary, and which directions are forbidden.
- **Invariants with teeth.** Rules the code must uphold, and where they are enforced. Enforcement location matters: a rule checked by the caller is a rule that one forgetful code path can bypass.
- **How correctness is measured.** Which numbers are trusted for decisions and why, and which look authoritative but are not.
