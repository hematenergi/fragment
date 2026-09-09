---
id: plan-02
title: "02 — no way down from a pile of warnings"
status: todo
owner: hematenergi
last-verified: 2026-09-09
depends-on: []
---

# 02 — no way down from a pile of warnings

**Goal.** A repository sitting on a large warning count can see which rule to
attack first, and watch the number fall.

## Why this is needed

`--max-warnings` sets a ceiling but offers no way to walk it down. flimapp sits
at 122 warnings with no per-rule grouping and no per-rule count, so the pile
reads as one undifferentiated wall — and a wall gets ignored rather than
climbed.

A warning nobody can triage is a warning nobody reads, which is the same as not
emitting it.

## Read first

- `../../template/scripts/docs-check.sh` — `warnf` and the tally at the end
- `04-version-written-by-hand.md` — unrelated, but touches the same summary block

## Work

- [ ] Group the summary by rule: "N warnings from X"
- [ ] Keep the individual lines; the summary is in addition, not instead
- [ ] Decide whether the grouping needs a flag or is always on

## Done when

- [ ] A repository with many warnings can name its worst rule from one run
- [ ] The per-rule counts add up to the total
- [ ] Output stays readable at three warnings, not only at a hundred

## Traps

Grouping means giving every `warnf` call a stable rule identity. Doing that by
matching on message text will break the moment a message is reworded — which
this project does often, on purpose.

## Validation

```bash
# to be filled in when the work is done
```

## Out of scope

Suppressing warnings, baselines, per-rule thresholds.

## Session log

- `2026-09-09` · claude · queued while installing Fragment into Fragment · next: decide how a rule gets a stable identity
