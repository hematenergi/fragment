---
id: plan-10
title: "10 — publish v0.6.0 with benchmark pending"
status: done
owner: hematenergi
last-verified: 2026-10-10
depends-on: [08]
---

# 10 — publish v0.6.0 with benchmark pending

**Goal.** Publish the already-merged v0.6 context features using the test
evidence available now, then publish benchmark results separately when the
frozen Gemini protocol completes.

## Why this is needed

The v0.6 features are merged and validated, while the Free Tier Gemini R4
calibration stopped before the quiz and task completed. The owner directed that
the release proceed with the evidence available and benchmark numbers follow
later. A release must state that limitation and make no performance claim.

## Read first

- `../STATE.md` — current release and benchmark status
- `../../CHANGELOG.md` — versioned release notes
- `../../install.sh` — immutable fingerprints for released guards
- `../../tests/run.sh` — release version consistency and installer checks

## Current state

Release PR #5 is merged to `main` as `25e7dfd37d8d9e2c113773245c71c32261db5787`.
The `v0.6.0` tag points to that commit, and the GitHub release is published and
listed as latest. Local checks passed (147 tests and the docs guard); all five
release PR checks passed on Ubuntu, macOS, Windows, docs, and secrets. The R4
Medulla calibration stopped at the Gemini Free Tier daily request cap after 11
successful responses; the quiz and task did not complete, so no score or `N`
exists. The Gemini protocol and prompt remain frozen.

## Work

- [x] Record the owner direction to publish v0.6.0 before benchmark completion.
- [x] Prepare release notes that describe shipped features and disclose the
  incomplete benchmark without a performance claim.
- [x] Update all release version references and add the v0.6.0 guard fingerprint
  while preserving fingerprints for earlier releases.
- [x] Pass the local suite, docs guard, and release pull-request CI.
- [x] Merge the release change, tag `v0.6.0`, and publish its GitHub release.
- [x] Record the published tag and leave benchmark results as a follow-up.

## Done when

- [x] GitHub lists v0.6.0 as the latest release with matching version stamps.
- [x] The release notes contain the benchmark status and make no unsupported
  performance claim.
- [x] CI and local release checks pass on the exact tagged commit.

## Traps

- Do not edit the frozen North Star, GPT benchmark spec, extraction prompt, or
  case study.
- Do not represent the incomplete R4 attempt as a score or set `N` from partial
  usage.
- Keep the v0.5.0 installer fingerprint immutable; add the exact v0.6.0 guard
  fingerprint instead.

## Validation

```bash
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
rtk git diff --check
```

## Out of scope

Completing or changing any benchmark protocol. The results will follow in the
separate benchmark work.

## Session log

- 2026-10-10 · GPT-6 / Codex · 10 · merged PR #5, published latest release v0.6.0 at `25e7dfd`, and verified its benchmark disclosure · next: publish the documented v0.5 production-adoption evidence on the public site.
- 2026-10-10 · GPT-6 / Codex · 10 · prepared v0.6.0 version stamps, installer fingerprint, and honest benchmark-pending release notes · next: pass checks and publish the tag/release.
