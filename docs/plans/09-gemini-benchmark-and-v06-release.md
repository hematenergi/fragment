---
id: plan-09
title: "09 — run the Gemini benchmark and release v0.6"
status: in-progress
owner: hematenergi
last-verified: 2026-10-10
depends-on: [08]
---

# 09 — run the Gemini benchmark and release v0.6

**Goal.** Run a separately frozen Gemini benchmark for Fragment v0.5.0 and v0.6, report auditable results, then publish Fragment v0.6.0 on GitHub.

## Why this is needed

The original benchmark remains frozen to a GPT model whose API access is unavailable. The owner authorized a separate Gemini benchmark after the Free Tier data-use terms were disclosed. Keeping a new protocol, prompt, and results separate preserves the frozen GPT record and makes the provider change explicit.

## Read first

- `../../FragmentBenchmarkSpec-Gemini.md` — separate frozen Gemini protocol
- `../../FragmentBenchmarkSpec.md` — original frozen GPT protocol; do not edit
- `../../bench/extract-prompt-gemini.md` — separate Draupnir extraction prompt
- `../../bench/gemini-agent-system.md` — fixed agent instructions
- `../../bench/gemini-verification.md` — model and usage probe evidence
- `08-v06-context-features.md` — shipped feature record
- `../decisions/0004-separate-gemini-benchmark.md` — provider/model decision

## Current state

- `FragmentBenchmarkSpec.md` and `bench/extract-prompt.md` remain frozen and unchanged.
- The Gemini model endpoint has returned successful generic probes, but availability is intermittent (503s/timeouts). No repo content has been sent and no dry run or scored run exists.
- Gemini 3.8 Flash stable alias and `thinkingLevel=low` are pinned in the new spec. Exact dated backend snapshot and active quota remain unconfirmed.
- The shared Linux/arm64 image and clean Medulla tests passed previously at snapshot `01667b95454663848f193cd84e3fb055507035b0`; the current final environment still needs confirmation before dry run.
- Fragment v0.6 features are implemented and merged; GitHub v0.6.0 release is not published.

## Work

- [x] Record owner authorization and create a distinct Gemini model-verification report without exposing the key.
- [x] Freeze a provider-specific protocol and extraction prompt without changing the original GPT artifacts.
- [ ] Freeze the exact agent system prompt, tool schemas, and local command allowlist before dry run.
- [x] Commit and push the new protocol, extraction prompt, and system prompt before sending repository content to Gemini.
- [ ] Reconfirm Free Tier/no billing, final container availability, and clean Medulla test results.
- [ ] Verify the private Medulla questions/key/task map to the recorded baseline snapshot and v0.5.0 procedure.
- [ ] Run one B-condition Medulla dry run and set `N` using the frozen rule; retain as calibration only.
- [ ] Clone Draupnir in the final container, record its SHA, and verify tests.
- [ ] Fill and commit only Gemini prompt placeholders; mechanically extract and freeze the Draupnir KB.
- [ ] Write and freeze Draupnir questions, answer key, rubric, task, and automatic check from post-March-2026 sources.
- [ ] Freeze the harness/system prompt and run 30 baseline plus 30 v0.6 validation runs; preserve raw logs privately.
- [ ] Recompute results from raw logs, write the public aggregate report and honesty block, then prepare the GitHub v0.6.0 release.

## Done when

- [ ] Both 30-run phases have complete raw artifacts and reproducible input-token totals, success/task outcomes, and separate trap scores.
- [ ] Model, response `modelVersion`, repo snapshots, environment, question sets, answer keys, rubrics, retry handling, and `N` are recorded.
- [ ] Reports show success rates and eligible successful-run median/ranges; Gemini results are labelled indicative and kept separate from GPT data.
- [ ] All four North Star v0.6 items are shipped and GitHub release v0.6.0 is published with benchmark numbers and the required honesty block.

## Traps

- Never edit the four original frozen design artifacts: `FragmentNorthstar.md`, `FragmentBenchmarkSpec.md`, `bench/extract-prompt.md`, and `CASE-STUDY.md`.
- Do not send medulla secrets, local runtime state, or unrelated private documents to Gemini. Google Free Tier content may be used to improve Google products.
- Do not run on a paid tier or enable billing. Stop if the AI Studio project is no longer Free Tier.
- Do not write Draupnir questions before the mechanically extracted KB is frozen.
- Do not claim exact backend reproducibility from a stable model alias; record response `modelVersion` each time.
- A protocol change after observing dry-run/scored output starts a new Gemini benchmark; affected numbers are discarded.

## Validation

```bash
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
```

Run clean Medulla and Draupnir checks in the pinned final container before their respective benchmark stages.

## Out of scope

Changing the frozen GPT benchmark, adopter outreach, v0.7 work, or changing shipped v0.6 features in response to the same benchmark results.

## Session log

- 2026-10-10 · GPT-6 / Codex · 09 · pushed the frozen Gemini protocol/prompt commit `c44b2e5` and verified the remote SHA matches; no repo content sent · next: confirm container/test state and freeze harness before calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · owner authorized a separate Gemini track; recorded successful generic probes, Free Tier terms, and separate protocol/prompt without touching frozen artifacts · next: validate and push protocol before sending repository content or running calibration.
