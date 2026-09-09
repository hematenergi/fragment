---
id: lesson-ci-only-rule
title: A rule enforced only in CI is a rule nobody runs
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# A rule enforced only in CI is a rule nobody runs

## Symptom

`origin/main` was red for two commits, and 0.2.0 was tagged and released on top
of the red build. The cause was one unquoted word in a `for` list that
shellcheck reports as SC1010.

## Root cause

shellcheck ran in exactly one place: GitHub Actions. It was not installed on the
machine the work happened on, and `tests/run.sh` did not call it. The only thing
that could catch the problem was the thing that runs *after* you push, and
nobody read the result.

This repository argues, at length, that a rule enforced in one place gets
bypassed everywhere else. That argument was aimed at agents switching tools. It
applies unchanged to maintainers.

## Rule

**Anything CI can fail on, the local suite runs too.** `tests/run.sh` now invokes
shellcheck with the same arguments the workflow uses.

Where the tool may be absent, **skip visibly, never silently** — the suite's own
constraint is that it needs nothing beyond bash and git, so a missing linter
prints `SKIP` rather than failing. A silent skip would have reproduced the
original bug with extra steps.
