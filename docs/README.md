---
id: docs-index
title: Document index
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# Document index

**Every file under `docs/` is listed on this page.** Anything unlisted is treated
as junk — `scripts/docs-check.sh` will find it. Registration means a markdown
link whose target is the file's path relative to `docs/`, exactly like the rows
below.

The one exception is `docs/_attic/`, which the guard ignores entirely.

> This repository runs its own guard against itself. `scripts/docs-check.sh` is a
> byte-identical copy of `../template/scripts/docs-check.sh`, and a test in
> `../tests/run.sh` fails if the two ever drift. See
> [`decisions/0001-one-canonical-guard-vendored-copies.md`](decisions/0001-one-canonical-guard-vendored-copies.md).

## Start and state

| File | What it is |
|---|---|
| [`STATE.md`](STATE.md) | **Where the work stands.** Read first, written last |
| [`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md) | The rules, for every agent and every human |
| [`why.md`](why.md) | Every rule in Fragment, and the failure that produced it |

## Fragments

| File | What it is |
|---|---|
| [`plans/README.md`](plans/README.md) | How fragments work |
| [`plans/00-template.md`](plans/00-template.md) | Template for a new one |
| [`plans/01-installer-cannot-upgrade.md`](plans/01-installer-cannot-upgrade.md) | `todo` — an old install has no route to the current guard |
| [`plans/02-no-way-down-from-a-warning-pile.md`](plans/02-no-way-down-from-a-warning-pile.md) | `todo` — 122 warnings with no per-rule grouping |
| [`plans/03-last-verified-is-the-loudest-rule.md`](plans/03-last-verified-is-the-loudest-rule.md) | `todo` — correct, drowned, and now load-bearing |
| [`plans/04-version-written-by-hand.md`](plans/04-version-written-by-hand.md) | `todo` — seven places, one command |

## Decisions

| File | What it settles |
|---|---|
| [`decisions/README.md`](decisions/README.md) | Decision format and the next number |
| [`decisions/0001-one-canonical-guard-vendored-copies.md`](decisions/0001-one-canonical-guard-vendored-copies.md) | Three copies of the guard, checked by a test, never symlinked |

## Lessons

| File | The rule it produced |
|---|---|
| [`lessons/README.md`](lessons/README.md) | Symptom → Root cause → Rule, and when to write one |
| [`lessons/silent-replacement-deleted-a-feature.md`](lessons/silent-replacement-deleted-a-feature.md) | Every automated replacement asserts that it landed |
| [`lessons/a-rule-enforced-only-in-ci.md`](lessons/a-rule-enforced-only-in-ci.md) | Anything CI can fail on, the local suite runs too |
| [`lessons/measuring-touch-instead-of-review.md`](lessons/measuring-touch-instead-of-review.md) | Name the question a proxy actually answers |
| [`lessons/the-secret-scanner-flagged-the-tests.md`](lessons/the-secret-scanner-flagged-the-tests.md) | A repo that tests a detector needs an allowlist for its fixtures |
