---
id: plan-08
title: "08 — ship the v0.6 context features"
status: done
owner: hematenergi
last-verified: 2026-10-09
depends-on: []
---

# 08 — ship the v0.6 context features

**Goal.** Ship the three v0.6 context features: deterministic `/recall` with minimal tags, STATE archival/pruning, and explicit token-budgeted loading.

## Why this is needed

The Northstar identifies context bloat as Fragment's main product problem. A new session needs a cheap way to find relevant decisions, keep the hot STATE small, and load cold context within a stated budget. These features can be developed while benchmark API access is unavailable.

## Read first

- `../../FragmentNorthstar.md:84` — the v0.6 feature definitions
- `../../FragmentBenchmarkSpec.md` — frozen baseline and validation procedures
- `../decisions/0003-defer-benchmark-spend-until-v06-features.md` — sequencing decision
- `../../template/docs/AGENT-PROTOCOL.md` — shipped user workflow contract
- `../../scripts/docs-check.sh` — structure and install integration

## Current state

- Fragment v0.5.0 is released. The template and this checkout now contain deterministic `recall.sh`, `state-prune.sh`, and `load-context.sh` commands.
- The installer copies the `template/` tree without overwriting existing adopter files. Commands run in Bash/Git; Git Bash path checks also query Windows' built-in PowerShell for reparse-point metadata so directory junctions cannot bypass the checkout boundary.
- New decision/lesson guidance uses optional inline YAML tags; all seven existing repo records now have tags, while retrieval still supports untagged legacy records.
- Benchmark fragment 07 is parked. No model calls or benchmark results exist.
- The command tests cover matching and empty retrieval, legacy and tagged records, malformed/empty STATE history, archive safety, and exact/insufficient loading budgets. Symlinked paths are rejected before retrieval or writes.
- `tests/run.sh` passes all 147 cases, including shellcheck and installed-template parity; `scripts/docs-check.sh` is green. The Unreleased changelog describes all three commands and tag guidance.

## Work

- [x] Add deterministic keyword-ranked `/recall` for decisions and lessons, with no model/network call at runtime.
- [x] Add optional minimal tags metadata and update templates/guidance so new records can be retrieved by topic.
- [x] Implement STATE archival/pruning that preserves history while bounding the active hot tier.
- [x] Implement deterministic context loading with an explicit token budget and documented counting/estimation behavior.
- [x] Wire commands into the installed template and agent protocol without breaking existing adopters or the Bash/Git command workflow; use the built-in Windows metadata query only for junction safety.
- [x] Add focused tests for ranking, tags, archive safety, and budget limits.
- [x] Run the full repository suite and guard; add the three features to the Unreleased release notes for v0.6.

## Done when

- [x] A query retrieves relevant decisions/lessons in deterministic rank order, using tags when present and remaining useful on legacy records without tags.
- [x] Archiving/pruning moves older dated session history out of hot STATE while retaining a traceable archive and working links.
- [x] Context loading stays within the requested documented budget, includes the required hot state, and reports any omitted material.
- [x] The shipped template and protocol explain how adopters invoke each feature.
- [x] Automated tests cover normal, empty, malformed, and boundary cases; `tests/run.sh` and `scripts/docs-check.sh` pass.

## Traps

- Runtime retrieval must remain deterministic; do not add an LLM or network dependency.
- Existing adopter files are user-owned. The installer must not overwrite protocols, STATE files, or records to add tags.
- Distinguish an exact token count from a safe estimate; never claim a byte/word heuristic is tokenizer-exact.
- Archive history rather than deleting it. Do not mass-move or rewrite adopter records.
- Do not inspect or tune against benchmark outcomes; none exist.

## Validation

```bash
rtk shellcheck -S warning scripts/recall.sh scripts/state-prune.sh scripts/load-context.sh template/scripts/recall.sh template/scripts/state-prune.sh template/scripts/load-context.sh tests/recall.sh tests/state-prune.sh tests/load-context.sh
rtk bash tests/recall.sh
rtk bash tests/state-prune.sh
rtk bash tests/load-context.sh
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
rtk git diff --check
```

```text
shellcheck -S warning — PASS
focused command tests — PASS
tests/run.sh — GREEN, 147 tests passed
scripts/docs-check.sh — GREEN
git diff --check — PASS
```

## Out of scope

Benchmark model calls/runs (plan 07), adopter outreach, v0.7 features, and the v0.6 GitHub release. The release follows only after feature validation and benchmark work.

## Session log

- 2026-10-08 · GPT-6 / Codex · 08 · created the feature fragment after the owner chose develop-first; no benchmark result data was used · next: define and implement `/recall` with tags.
- 2026-10-08 · GPT-6 / Codex · 08 · implemented tagged deterministic recall, dry-run STATE history archival with a traceable archive link, and a hard conservative context budget; focused tests pass · next: run and record the full repo suite, then finish product docs.
- 2026-10-08 · GPT-6 / Codex · 08 · rejected symlinked paths in retrieval, archival, and loading; all feature docs and tests are complete, with 147 tests and the docs guard green · next: resume benchmark plan 07 when authorized API access is available; no results exist.
- 2026-10-09 · GPT-6 / Codex · 08 · committed the v0.6 context features and supporting docs as `ee9feff`; reran the repository suite (147 tests) and docs guard, both green · next: resume plan 07 §7.3 when a supported model API path is available.
- 2026-10-09 · GPT-6 / Codex · 08 · Windows CI showed Git Bash treats directory junctions as ordinary directories, and direct PowerShell `Get-Item` followed the link and returned only target attributes; path checks now inspect the parent-directory entry, and the focused test prints that entry's Windows metadata on failure · next: read the new focused Windows result and adjust detection.
