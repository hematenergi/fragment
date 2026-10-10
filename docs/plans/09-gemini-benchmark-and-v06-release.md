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
- `../../FragmentBenchmarkSpec-Gemini-R2.md` — current pre-run Gemini revision; do not send data until its freeze commit is pushed
- `../../FragmentBenchmarkSpec.md` — original frozen GPT protocol; do not edit
- `../../bench/extract-prompt-gemini.md` — separate Draupnir extraction prompt
- `../../bench/gemini-agent-system.md` — fixed agent instructions
- `../../bench/gemini-verification.md` — model and usage probe evidence
- `08-v06-context-features.md` — shipped feature record
- `../decisions/0004-separate-gemini-benchmark.md` — provider/model decision

## Current state

- `FragmentBenchmarkSpec.md` and `bench/extract-prompt.md` remain frozen and unchanged.
- Gemini R1's first data-bearing condition-B preflight sent Medulla onboarding material to `countTokens` and returned HTTP 400 `INVALID_ARGUMENT`; it produced no generation, dry run, score, or `N` and remains unchanged. Separate Gemini R2 is frozen and pushed at `6ad0871326da41631df20a2acf8b5bc3e76b8fd5`, with the required nested model resource and distinct API error categories. Its first B calibration attempt returned a 488,670-token onboarding estimate from `countTokens`, then HTTP 429 `RESOURCE_EXHAUSTED` from `generateContent`; the structured quota metric was `generate_content_free_tier_input_token_count` at 250,000, with `RetryInfo=23s`. No generation usage, score, or `N` exists; the raw log remains private and no replacement was sent.
- Gemini 3.8 Flash stable alias and `thinkingLevel=low` are pinned in the new spec. AI Studio showed the target project is Free tier with billing not enabled; target-model limits shown were 5 RPM, 250K TPM, and 20 RPD (peak usage over 28 days was 3, 46K, and 9 respectively). The exact dated backend snapshot remains unavailable.
- The separate harness now carries one conversation across onboarding, quiz, and task, preflights the half-budget onboarding boundary, and restricts edits to per-run paths. It aborts if the first condition-B prompt exceeds 80% of context; the calibration safety ceiling is 10,000,000 cumulative input tokens.
- The existing Linux/arm64 image was rechecked at snapshot `01667b95454663848f193cd84e3fb055507035b0`; `npm ci` and network-disabled `npm test` passed in a clean clone (1,304 unit + 369 integration).
- Fragment v0.6 features are implemented and merged; GitHub v0.6.0 release is not published.

## Work

- [x] Record owner authorization and create a distinct Gemini model-verification report without exposing the key.
- [x] Freeze a provider-specific protocol and extraction prompt without changing the original GPT artifacts.
- [x] Freeze and push the exact agent system prompt, tool schemas, run-command allowlist, and per-run edit allowlist before dry run; the verified freeze commit is `e05a5b9139b27f5102dad5ebc80649e05fd7d383`.
- [x] Commit and push the new protocol, extraction prompt, and system prompt before sending repository content to Gemini.
- [x] Reconfirm Free Tier/no billing, final container availability, and clean Medulla test results.
- [x] Verify the private Medulla questions/key/task map to the recorded baseline snapshot and v0.5.0 procedure.
- [x] Stop Gemini R1 on the invalid countTokens request without retrying, and retain its raw record privately.
- [x] Freeze and push the separate R2 protocol and harness correction at `6ad0871326da41631df20a2acf8b5bc3e76b8fd5`; local and remote SHAs match and no R2 request has been sent.
- [ ] Run one R2 B-condition Medulla dry run and set `N` using the frozen rule; retain as calibration only. **Stopped:** the frozen 488,670-token B prompt exceeds the reported 250,000 Free-tier input-token quota; no `N` exists.
- [x] Stop after the R2 `generateContent` 429, preserve the private failed-attempt log, and do not retry the over-limit prompt or modify frozen R2; await owner review.
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
rtk node --check bench/gemini-runner.mjs
rtk node bench/gemini-runner.mjs --self-test
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
```

Run clean Medulla and Draupnir checks in the pinned final container before their respective benchmark stages.

## Out of scope

Changing the frozen GPT benchmark, adopter outreach, v0.7 work, or changing shipped v0.6 features in response to the same benchmark results.

## Session log

- 2026-10-10 · GPT-6 / Codex · 09 · first B calibration preflight returned HTTP 400 `INVALID_ARGUMENT` from `countTokens`; no generation or `N`, and stopped without retry per protocol · next: owner reviews the invalid-request evidence before any new benchmark revision.
- 2026-10-10 · GPT-6 / Codex · 09 · after owner directed continuation through release, kept R1 unchanged and drafted Gemini R2 with the required nested model resource and distinct API-error categories; local runner self-check passes · next: push R2 freeze, then calibrate.
- 2026-10-10 · GPT-6 / Codex · 09 · froze and pushed Gemini R2 at `6ad0871`; local and remote SHAs match, 147 tests and docs guard pass, no R2 request sent · next: reconfirm Free Tier/no billing, then run the B-condition Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · R2 B calibration estimated 488,670 onboarding tokens; the Free-tier input-token quota of 250,000 rejected `generateContent` with HTTP 429; no score or `N`, no replacement or spec edit · next: owner reviews the protocol gap before a distinct revision or further API calls.
- 2026-10-10 · GPT-6 / Codex · 09 · froze and pushed the Gemini runner, schemas, command/edit allowlists, and corrected system prompt at `e05a5b9`; remote SHA matches and no repo content sent · next: run the condition-B Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · fixed Gemini run-history carryover, onboarding budget enforcement, and per-run write fencing; runner self-check and all 147 Fragment tests pass · next: freeze and push the harness, then run the B-condition Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · rechecked AI Studio Free tier and validated the pinned image with a clean Medulla clone; `npm ci` passed and 1,304 unit + 369 integration tests passed offline · next: freeze tool schemas and command allowlist before calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · pushed the frozen Gemini protocol/prompt commit `c44b2e5` and verified the remote SHA matches; no repo content sent · next: confirm container/test state and freeze harness before calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · owner authorized a separate Gemini track; recorded successful generic probes, Free Tier terms, and separate protocol/prompt without touching frozen artifacts · next: validate and push protocol before sending repository content or running calibration.
