---
id: plan-03
title: "03 — last-verified is the noisiest rule and the most valuable"
status: superseded
superseded-by: plan-05
owner: hematenergi
last-verified: 2026-09-09
depends-on: [plan-02]
---

# 03 — last-verified is the noisiest rule and the most valuable

**Goal.** The `last-verified` warning is acted on instead of scrolled past.

## Why this is needed

In flimapp this one rule produces most of the 122 warnings, so it is ignored.
And in a single day, two documents it was warning about produced two wrong
conclusions: fragment 02 was recorded `todo` when the work was finished, and
fragment 11 stated a blocker that had already gone away. Both were reported to
the repository owner before anyone checked.

A rule that is correct and drowned is worth the same as no rule at all — and
worse than none, because it lends false confidence to a green-ish run.

## Read first

- `../../template/scripts/docs-check.sh` — the `last-verified` comparison
- `../lessons/measuring-touch-instead-of-review.md` — staleness now leans on
  this same field, which raises the stakes
- `02-no-way-down-from-a-warning-pile.md` — grouping may be enough on its own

## Work

The unchecked work below is deliberately superseded by fragment 05. Review dates
remain useful clues, but neither age nor a commit/date discrepancy proves an
incorrect claim. Agents verify relevant claims when using documents; inventory
preserves the clues without demanding a retrospective audit.

- [ ] Decide: error for fragments only, or one summary line for all documents
- [ ] Check the interaction with staleness, which now reads the same field
- [ ] Confirm the noisy case in flimapp actually drops

## Done when

- [ ] A run's `last-verified` output fits in a few lines regardless of repo size
- [ ] A stale fragment is still impossible to miss
- [ ] flimapp's warning count falls without any rule being weakened

## Traps

Promoting it to an error for fragments would have failed flimapp's build on day
one for documents that were merely old, not wrong. Loud and blocking are not the
same lever, and this rule probably wants the first.

## Validation

```bash
# to be filled in when the work is done
```

## Out of scope

Changing what `last-verified` means, or auto-bumping it. An auto-bumped
`last-verified` is a lie, and staleness now depends on it being true.

## Session log

- 2026-09-09 · GPT-6 / Codex · 03 · superseded by claim-specific review and optional inventory in fragment 05, not by mass date updates · next: validate the mature-adopter scenario there.
- `2026-09-09` · claude · queued while installing Fragment into Fragment · next: depends on 02 — grouping may solve this without a new rule
