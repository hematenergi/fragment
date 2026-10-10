---
id: plan-10
title: "10 — publish v0.6.0 with benchmark pending"
status: in-progress
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

Feature PR #2 is merged to `main` at `5f13f7b`; v0.5.0 is still the latest
GitHub release. The R4 Medulla calibration stopped on the Free Tier daily
request cap after 11 successful responses; the quiz and task did not complete,
so no score or `N` exists. The Gemini protocol and prompt remain frozen.

## Work

- [x] Record the owner direction to publish v0.6.0 before benchmark completion.
- [x] Prepare release notes that describe shipped features and disclose the
  incomplete benchmark without a performance claim.
- [x] Update all release version references and add the v0.6.0 guard fingerprint
  while preserving fingerprints for earlier releases.
- [ ] Pass the local suite, docs guard, and release pull-request CI.
- [ ] Merge the release change, tag `v0.6.0`, and publish its GitHub release.
- [ ] Record the published tag and leave benchmark results as a follow-up.

## Done when

- [ ] GitHub lists v0.6.0 as the latest release with matching version stamps.
- [ ] The release notes contain the benchmark status and make no unsupported
  performance claim.
- [ ] CI and local release checks pass on the exact tagged commit.

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

- 2026-10-10 · GPT-6 / Codex · 10 · prepared v0.6.0 version stamps, installer fingerprint, and honest benchmark-pending release notes · next: pass checks and publish the tag/release.
