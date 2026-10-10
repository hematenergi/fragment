---
id: docs-index
title: Document index
status: active
owner: hematenergi
last-verified: 2026-10-10
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
| [`continuity.md`](continuity.md) | Source roles, daily rollover, scoped checks and migration |
| [`why.md`](why.md) | Every rule in Fragment, and the failure that produced it |

## Fragments

| File | What it is |
|---|---|
| [`plans/README.md`](plans/README.md) | How fragments work |
| [`plans/00-template.md`](plans/00-template.md) | Template for a new one |
| [`plans/01-installer-cannot-upgrade.md`](plans/01-installer-cannot-upgrade.md) | `done` — an old install can upgrade its unmodified guard safely |
| [`plans/02-no-way-down-from-a-warning-pile.md`](plans/02-no-way-down-from-a-warning-pile.md) | `superseded` — 05 separates inventory from actionable warnings |
| [`plans/03-last-verified-is-the-loudest-rule.md`](plans/03-last-verified-is-the-loudest-rule.md) | `superseded` — 05 moves review to relevant claims when used |
| [`plans/04-version-written-by-hand.md`](plans/04-version-written-by-hand.md) | `todo` — seven places, one command |
| [`plans/05-continuity-without-administration.md`](plans/05-continuity-without-administration.md) | `done` — inventory, scoped handoff and source authority |
| [`plans/06-freeze-benchmark-extraction-prompt.md`](plans/06-freeze-benchmark-extraction-prompt.md) | `done` — frozen extraction prompt committed and pushed before benchmark questions |
| [`plans/07-v06-benchmark-baseline.md`](plans/07-v06-benchmark-baseline.md) | `parked` — benchmark work resumes after v0.6 features and API access |
| [`plans/08-v06-context-features.md`](plans/08-v06-context-features.md) | `done` — deterministic retrieval, STATE pruning, and token-budgeted loading |
| [`plans/10-v06-release-before-benchmark.md`](plans/10-v06-release-before-benchmark.md) | `done` — v0.6.0 published with honest benchmark-pending notes |
| [`plans/11-site-production-evidence.md`](plans/11-site-production-evidence.md) | `in-progress` — publish observed v0.5.0 production evidence on the homepage and README |

## Decisions

| File | What it settles |
|---|---|
| [`decisions/README.md`](decisions/README.md) | Decision format and the next number |
| [`decisions/0001-one-canonical-guard-vendored-copies.md`](decisions/0001-one-canonical-guard-vendored-copies.md) | Three copies of the guard, checked by a test, never symlinked |
| [`decisions/0002-continuity-evidence-and-inventory.md`](decisions/0002-continuity-evidence-and-inventory.md) | Scope, structural evidence, inventory and source authority |
| [`decisions/0003-defer-benchmark-spend-until-v06-features.md`](decisions/0003-defer-benchmark-spend-until-v06-features.md) | Develop v0.6 features before API spending; keep the benchmark protocol frozen |
| [`decisions/0005-release-v06-with-benchmark-pending.md`](decisions/0005-release-v06-with-benchmark-pending.md) | Publish v0.6.0 from shipped feature evidence; follow with benchmark results |

## Lessons

| File | The rule it produced |
|---|---|
| [`lessons/README.md`](lessons/README.md) | Symptom → Root cause → Rule, and when to write one |
| [`lessons/silent-replacement-deleted-a-feature.md`](lessons/silent-replacement-deleted-a-feature.md) | Every automated replacement asserts that it landed |
| [`lessons/a-rule-enforced-only-in-ci.md`](lessons/a-rule-enforced-only-in-ci.md) | Anything CI can fail on, the local suite runs too |
| [`lessons/measuring-touch-instead-of-review.md`](lessons/measuring-touch-instead-of-review.md) | Name the question a proxy actually answers |
| [`lessons/the-secret-scanner-flagged-the-tests.md`](lessons/the-secret-scanner-flagged-the-tests.md) | A repo that tests a detector needs an allowlist for its fixtures |
| [`lessons/history-is-not-session-evidence.md`](lessons/history-is-not-session-evidence.md) | A documentation clue is not a verified error or unfinished handoff |
