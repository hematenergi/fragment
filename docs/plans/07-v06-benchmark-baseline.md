---
id: plan-07
title: "07 — establish the v0.6 benchmark baseline"
status: parked
reason: "v0.6 features have shipped. The original GPT-5.4 Mini API path is unavailable. The owner authorized a separate Gemini track, which is recorded in plan 09; this fragment stays parked with its original frozen protocol unchanged."
owner: hematenergi
last-verified: 2026-10-10
depends-on: []
---

# 07 — establish the v0.6 benchmark baseline

**Goal.** Produce the frozen v0.5.0 baseline for medulla and Draupnir, then the v0.6 validation results, with source snapshots, model settings, answer keys, and run evidence. Feature work now precedes benchmark spending; no results exist to tune against.

## Why this is needed

The v0.6 roadmap makes tokens-to-competent its headline. The benchmark has to measure success rate, successful-run token counts, and trap scores under one pinned model and one harness, with Draupnir as the evaluation headline. The benchmark spec and extraction prompt are frozen; only their designated SHA/model/date placeholders may be filled as the run records require.

## Read first

- `../../FragmentBenchmarkSpec.md` — frozen benchmark protocol
- `../../FragmentNorthstar.md:84` — four v0.6 deliverables
- `../../bench/extract-prompt.md` — frozen Draupnir KB extraction prompt
- `06-freeze-benchmark-extraction-prompt.md` — verified prompt commit

## Current state

- The prompt was pushed in commit `4582cec728a46aa9122005314fd923e17b937052`; the current remote includes it. Its blob is `8d78088a2ec78056edd1de7199fd7b29e21a1ec8`.
- No benchmark questions or run records exist under `bench/` yet.
- The 10-question medulla set, answer key, rubric, task, and pass criteria are drafted in an owner-private directory against medulla snapshot `01667b95454663848f193cd84e3fb055507035b0`; no scored or dry-run data exists.
- Fragment's v0.6 source now includes deterministic `/recall`, STATE pruning, and token-budgeted loading. Baseline condition C remains the documented v0.5.0 procedure; validation condition C uses the shipped v0.6 procedure, exactly as frozen §2/§6 specify.
- The owner clarified and updated frozen §2/§6: baseline condition C uses the documented v0.5.0 procedure; validation condition C uses v0.6 with `/recall` and token budgets. The protocol distinguishes these phases.
- Frozen §7 remains the benchmark protocol. Medulla questions/key/task are prepared (§7.2), and the final container plus Medulla test validation are complete (§7.3). Benchmark execution is deferred until plan 08 ships the features and an authorized API path is available; no run results have informed implementation.
- An exploratory Draupnir clone at `4e949ddd57ad0f9d590c1080bed174f5a0451c34` and container build/test were started before the owner corrected the sequence. The test process exited 0, but that checkout and image were removed; the snapshot and test are excluded from benchmark evidence.
- Docker Desktop is available. `OPENAI_API_KEY` remains unconfigured. Gemini Free-tier exploratory probes later returned generic HTTP 200 responses as well as 503/timeouts; thinking `low` was accepted, and the response usage fields are recorded separately in `../../bench/gemini-verification.md`. The owner authorized a distinct Gemini protocol in plan 09. No repository content or benchmark run data has been sent to Gemini.
- Official API docs checked 2026-10-08 list the exact candidate snapshot `gpt-5.4-mini-2026-03-17`, with reasoning effort `none` (default), `low`, `medium`, `high`, or `xhigh`, a 400k context window, a 128k maximum output, and an Aug 31, 2025 knowledge cutoff. The current deprecation list includes `gpt-5-mini-2025-08-07` with a Dec 11, 2026 shutdown but has no entry for `gpt-5.4-mini-2026-03-17`. The owner accepts “no announced shutdown” as satisfying the 2027+ horizon; this is eligibility evidence, not a guarantee of availability through 2027. Sources: [model page](https://developers.openai.com/api/docs/models/gpt-5.4-mini), [deprecations](https://developers.openai.com/api/docs/deprecations).
- Static parameter evidence: the GPT-5.4 guide says `temperature`, `top_p`, and `logprobs` are supported only at reasoning effort `none`; the exact mini snapshot still needs an authenticated runtime check before pinning. The owner has not configured an OpenAI API key, so endpoint access and exact-request compatibility for the frozen candidate remain unverified. Source: [GPT-5.4 model guide](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.4).
- **Cost check, 2026-10-08:** the model page lists $0.75/M input tokens and $4.50/M output tokens (cached input is excluded by the frozen protocol). With 30 baseline + 30 validation runs, the input-only ceiling if every run reaches budget is `60 × N × $0.75 / 1,000,000`. At the spec's preliminary `N = 1–2M`, that is $45–$90 for input alone; output and separate LLM judging add cost. Actual spend may be lower because competent runs stop before N, and N is not set until the dry run. Therefore the earlier ~$20 estimate is not a safe cap at the preliminary N. A $20 input-only ceiling covers at most `N ≈ 444k` across all 60 runs, before output or grading. Source: [GPT-5.4 Mini pricing](https://developers.openai.com/api/docs/models/gpt-5.4-mini).
- Medulla requires Node 22.13.x (CI documents 22.13.1/npm 10.9.4); Draupnir requires Node >=24. A private Linux/arm64 shared image now contains both runtimes, selected consistently per repo for every condition. Docker Desktop is v29.8.1; no Draupnir checkout is present, and cloning/testing it waits until §7.5.
- Image ID is `sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9`. The clean Medulla Git clone at the recorded snapshot passed `npm ci` and `npm test` (1,304 unit + 369 integration); its full log is owner-private. An archive-only test copy failed a Git metadata test and is excluded; the clean Git clone passed.

## Work

- [x] Write 10 medulla questions, answer key, rubric, task, and automatic pass criteria in one focused session; keep the private set outside the Fragment repository.
- [ ] Pin `gpt-5.4-mini-2026-03-17`; verify endpoint access and supported temperature/reasoning settings. The owner accepts its lack of an announced shutdown for the 2027+ horizon. The Gemini key is a different provider/model and does not satisfy this check.
- [x] Define and build the final Linux container; confirm the medulla merged-PR tests pass there before dry run.
- [ ] Dry run condition B on medulla with the pinned model; set N to 1.5–2× observed cumulative input tokens. Record it as calibration, not benchmark data.
- [ ] Clone Draupnir at the then-current snapshot in the final container, record its SHA, and verify its merged-PR test suite passes.
- [ ] Fill the designated snapshot/model/date placeholders and commit the prompt metadata as a second prompt commit; verify the diff changes placeholders only.
- [ ] Extract and freeze the Draupnir KB mechanically from the pinned SHA; preserve every source citation and do not hand-edit extracted claims.
- [ ] Write 10 Draupnir questions, answer key, rubric, task, and automatic pass criteria after KB freeze.
- [ ] Lock tools, system prompt, loop, grading method, settings, and run logging before the first scored run.
- [ ] Run 30 baseline runs: 3 conditions × n=5 × 2 repos. Preserve all raw outputs and token accounting; report headline results only from Draupnir.
- [ ] After the baseline and feature implementation are complete, run a separate 30-run v0.6 validation phase with the same frozen protocol and v0.6 condition C. Preserve separate raw outputs and token accounting; do not tune from validation results.

## Done when

- [ ] All 30 baseline runs have raw artifacts and independently checkable input-token totals, success results, task results, and trap scores.
- [ ] All 30 v0.6 validation runs have separate raw artifacts and independently checkable input-token totals, success results, task results, and trap scores.
- [ ] Each repo's snapshot, model snapshot/settings, environment, questions, answer key, rubric, and N are recorded; the frozen method was not changed after seeing results.
- [ ] Baseline tables report success rate per condition and, only where both sides reach at least 3/5 successes, median and range tokens-to-competent; trap scores are reported separately.
- [ ] Validation tables report the same metrics per condition and phase; compare C(v0.6) with C(v0.5.0) to measure the feature delta, without comparing medulla and Draupnir numbers directly.
- [ ] Draupnir is the only cross-condition headline; results are labelled indicative and no unsupported win is claimed.

## Traps

- Baseline condition C is specifically the v0.5.0 documented procedure; do not bring `/recall` or token budgets into this phase.
- Do not read or modify medulla's local credentials, runtime state, or dirty worktree. Use a disposable snapshot/container and medulla's own instructions.
- Do not write Draupnir questions before the extracted KB is frozen. Preserve both sides of reversals; mark `superseded` only with an explicit source citation.
- Follow the current frozen §7 sequence; the early Draupnir checkout/test is discarded and must not supply the final snapshot SHA or benchmark evidence.
- The original `gpt-5-mini-2025-08-07` snapshot fails the goal's 2027+ horizon because it is scheduled to shut down on 2026-12-11. The newer mini snapshot remains a candidate pending API and parameter verification.

## Validation

Built once for `linux/arm64`; all conditions use image `sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9`. It contains Medulla Node 22.13.1/npm 10.9.4 and Draupnir Node 24.21.0/npm 11.19.0. Medulla `npm ci` and `npm test` passed at snapshot `01667b95454663848f193cd84e3fb055507035b0`; 1,304 unit and 369 integration tests passed. Container definition and full test log are stored outside the public repo.

## Out of scope

The three v0.6 feature implementations (tracked in plan 08), adopter outreach, and all v0.7 work. The benchmark protocol itself remains unchanged.

## Session log

- 2026-10-10 · GPT-6 / Codex · 07 · owner approved a separate Gemini benchmark; its protocol lives in plan 09 and does not alter the frozen GPT protocol or prompt · next: continue under plan 09; keep this GPT-specific fragment parked.
- 2026-10-10 · GPT-6 / Codex · 07 · retried the configured Gemini model with a minimal `ping`; client timed out after 15 seconds, with no response metadata or run data; 147 tests and docs-check pass; frozen spec/prompt remain unchanged · next: resolve the model/protocol gate before dry run.
- 2026-10-10 · GPT-6 / Codex · 07 · recorded a Gemini Free-tier metadata lookup (HTTP 200, version 3.0) and three generation HTTP 503 responses; no repo content was sent, and the frozen spec/prompt stayed unchanged · next: obtain working access to the pinned GPT-5.4 Mini candidate or explicitly authorize a new provider/model protocol; do not dry run.
- 2026-10-08 · GPT-6 / Codex · 07 · rechecked official model, deprecation, parameter and price docs; exact snapshot/settings are statically supported but authenticated access remains unverified, and ~$20 may not cover 60 full-budget runs · next: obtain an authorized API path, then complete the §7.3 runtime check/dry run; do not change the frozen protocol.
- 2026-10-08 · GPT-6 / Codex · 07 · parked by owner choice while v0.6 features are developed first; no benchmark results exist and the frozen protocol remains unchanged · next: resume after plan 08 and API access.
- 2026-10-08 · GPT-6 / Codex · 07 · reread the owner's updated spec; condition C is version-specific and baseline uses v0.5.0; removed the premature Draupnir checkout/image and excluded its passing exploratory test · next: write medulla questions per §7.2, then pin the model and container before dry run.
- 2026-10-08 · GPT-6 / Codex · 07 · drafted the medulla 10-question set, answer key, rubric, and regression-test task against snapshot `01667b95454663848f193cd84e3fb055507035b0`; files remain owner-private and no run data was created · next: verify model access/settings and prepare the shared final container per §7.3.
- 2026-10-08 · GPT-6 / Codex · 07 · built private Linux/arm64 image `sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9` with Node 22.13.1/npm 10.9.4 and Node 24.21.0/npm 11.19.0; clean Medulla clone at snapshot `01667b95454663848f193cd84e3fb055507035b0` passed npm ci and npm test (1,304 unit + 369 integration) · next: verify/pin the model before dry run.
- 2026-10-08 · GPT-6 / Codex · 07 · `rtk bash scripts/docs-check.sh` GREEN after tracking this progress · next: model API verification.
- 2026-10-08 · GPT-6 / Codex · 07 · owner accepted the no-announced-shutdown criterion for the eligible mini candidate; owner has no API key, so exact parameter/access check and dry run remain pending · next: resume §7.3 when an authorized model API path is available.
