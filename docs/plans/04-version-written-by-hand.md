---
id: plan-04
title: "04 — the version is written by hand in seven places"
status: todo
owner: hematenergi
last-verified: 2026-09-09
depends-on: []
---

# 04 — the version is written by hand in seven places

**Goal.** Cutting a release is one command, not seven edits.

## Why this is needed

A test already forces all seven mentions to agree, so a half-finished bump fails
loudly rather than shipping. That is the important half and it is done. What is
left is that the bump itself is still manual, and a task that is manual and
seven-fold is one that eventually gets done six-fold on a Friday.

Low priority precisely because the test exists.

## Read first

- `../../tests/run.sh` — the release-consistency test that lists the seven places
- `../../CHANGELOG.md` — the entry the version must match

## Work

- [ ] A script that takes the new version and updates all seven
- [ ] It refuses if the CHANGELOG has no entry for that version
- [ ] It does not tag or push

## Done when

- [ ] Bumping a version is one command
- [ ] The consistency test passes immediately afterwards, with no manual fixes
- [ ] Running it with no CHANGELOG entry fails and changes nothing

## Traps

The script would become the eighth place the version lives. It has to read the
current value rather than carry one.

## Validation

```bash
# to be filled in when the work is done
```

## Out of scope

Tagging, pushing, release notes, anything that talks to GitHub.

## Session log

- `2026-09-09` · claude · queued while installing Fragment into Fragment · next: lowest priority of the four; the test already prevents the damage
