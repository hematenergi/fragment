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
- `../../FragmentBenchmarkSpec-Gemini-R4.md` — current Gemini revision draft; do not send repository content until the R4 freeze is pushed and ping passes
- `../../FragmentBenchmarkSpec-Gemini-R3.md` — frozen historical revision; do not run more R3 attempts
- `../../FragmentBenchmarkSpec.md` — original frozen GPT protocol; do not edit
- `../../bench/extract-prompt-gemini-r4.md` — R4 Draupnir extraction prompt
- `../../bench/gemini-agent-system.md` — fixed agent instructions
- `../../bench/gemini-r4-agent-system.md` — R4 fixed instructions with explicit command allowlist
- `../../bench/gemini-verification.md` — original Gemini probe and quota evidence
- `../../bench/gemini-r3-verification.md` — R3 freeze and ping-only model pin evidence
- `../../bench/gemini-r4-verification.md` — R4 quota, freeze, and ping evidence
- `08-v06-context-features.md` — shipped feature record
- `../decisions/0004-separate-gemini-benchmark.md` — provider/model decision

## Current state

- `FragmentBenchmarkSpec.md` and `bench/extract-prompt.md` remain frozen and unchanged.
- Gemini R1's first data-bearing condition-B preflight sent Medulla onboarding material to `countTokens` and returned HTTP 400 `INVALID_ARGUMENT`; it produced no generation, dry run, score, or `N` and remains unchanged. Separate Gemini R2 is frozen and pushed at `6ad0871326da41631df20a2acf8b5bc3e76b8fd5`, with the required nested model resource and distinct API error categories. Its first B calibration attempt returned a 488,670-token onboarding estimate from `countTokens`, then HTTP 429 `RESOURCE_EXHAUSTED` from `generateContent`; the structured quota metric was `generate_content_free_tier_input_token_count` at 250,000, with `RetryInfo=23s`. No generation usage, score, or `N` exists; the raw log remains private and no replacement was sent.
- Gemini R2 remains frozen after its quota failure. R3 used Gemini 3.1 Flash-Lite Free Tier; its protocol, prompt, and runner remain pushed and unchanged. Its three B-calibration attempts were incomplete: two HTTP 503s; the last stopped before generation at a 232,231-token request estimate. One successful response lacked `thoughtsTokenCount`; no task result, score, or `N` exists. Raw logs and the modified attempt workspace remain private. Keep R3 evidence out of R4 metrics.
- A separate R4 protocol/prompt/system/builder/runner freeze was pushed at `e7adaefda5c568fdc83392d7f4f06e9516bdad82`, matching local and remote. It uses the model selected in decision 0004, Gemini 3.8 Flash; AI Studio still shows Free Tier/no billing setup, with displayed limits of 5 RPM, 250K input TPM, and 20 RPD. The frozen caps are 220K per request and 120K for B onboarding, with 15-second API spacing and 61-second generation spacing. The ping-only check returned HTTP 200 and pinned `modelVersion=gemini-3.8-flash`, thinking low, temperature omitted; reasoning usage was absent. Three count-only Medulla preflights succeeded at 73,020, 91,818, and 99,733 tokens. The final bundle is 67/236 records and remains under the cap. A generic rate-limit banner remains unresolved, and displayed usage numbers are 28-day peaks, not current counters.
- R4 calibration attempt `r4-medulla-b-calibration-01` received 11 successful `generateContent` responses (aggregate `promptTokenCount` 1,119,505; all omitted `thoughtsTokenCount`), then HTTP 429 `RESOURCE_EXHAUSTED` on generation 12. The structured violation is `generate_content_free_tier_requests`, quota ID `GenerateRequestsPerDayPerProjectPerModel-FreeTier`, model `gemini-3.8-flash`, value 20. Twelve `countTokens` responses were HTTP 200. Onboarding ended `READY`; quiz remained incomplete and task was not reached. No calibration result or `N` exists. The response had no rate-limit headers and included `RetryInfo=41127s`; this does not align with the documented midnight-Pacific reset relative to the request time, so retry timing is unresolved. The private log is retained; the attempted Medulla checkout is clean. Stop and preserve this attempt; after quota reset and verified headroom, resume with a fresh attempt ID. Do not clone Draupnir before a complete calibration.
- Other no-cost alternatives were checked without sending benchmark content: the only configured provider key is Gemini; Muse exposes only its ambient panel; local Ollama has Qwen 0.5B/32K, while its cloud GPT-OSS tag is 131K context and usage-credit eligibility was not checked. Gemini 3.8 Flash is documented with a 1,048,576-token input window and Free Tier pricing; its selected-project quota is now verified in AI Studio.
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
- [x] Owner approved a separate Gemini R3; confirm Gemini 3.1 Flash-Lite Free-tier limits in the selected AI Studio project.
- [x] Validate, freeze, and push the R3 protocol, extraction prompt, and runner; verify matching remote SHA and run the no-repository-content ping check.
- [x] Validate and push the deterministic R3 bundle builder and count-only preflight extension before sending any repo content.
- [x] Fix the R3 config parser to read its non-secret response model pin; confirm the failed local invocation sent no request and push the fix.
- [x] Use countTokens to trim the Medulla B bundle to the 170K onboarding cap; preserve its record manifest and hash.
- [x] Preserve the three incomplete R3 calibration attempts without changing frozen R3 files or treating partial usage as a result; no R3 `N` exists.
- [x] Freeze and push separate R4 protocol, extraction prompt, system prompt, bundle builder, and runner at `e7adaefda5c568fdc83392d7f4f06e9516bdad82`; local/remote SHAs match, 147 tests and docs guard pass, and redacted secret scan is clean.
- [x] Reconfirm Free Tier and perform the R4 ping-only model pin without repository content; HTTP 200, response version pinned to `gemini-3.8-flash`, low thinking accepted, temperature omitted, reasoning usage absent.
- [x] Build/count deterministic R4 Medulla B bundles; final 67/236-record bundle is 99,733 tokens under the 120K cap, with private manifest/hash and raw count-only records preserved.
- [ ] Run one complete R4 Medulla B calibration and set `N`; stop without `N` if quota/infrastructure prevents task completion. **Stopped:** attempt `r4-medulla-b-calibration-01` exhausted the structured 20/day Free-tier generation-request quota at HTTP 429 after 11 successful generations; quiz/task did not complete, so no `N` exists. Follow the frozen stop rule; do not replay this attempt. Resume after quota reset only with verified headroom and a fresh attempt ID.
- [x] Preserve the incomplete R4 calibration evidence privately and record its quota failure without changing frozen protocol/prompt artifacts.
- [ ] Clone Draupnir in the final container, record its SHA, and verify tests.
- [ ] Fill and commit only R4 Gemini prompt placeholders; mechanically extract and freeze the Draupnir KB.
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
rtk node --check bench/gemini-runner-r4.mjs
rtk node bench/gemini-runner-r4.mjs --self-test
rtk node --check bench/gemini-r4-bundle.mjs
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
```

Run clean Medulla and Draupnir checks in the pinned final container before their respective benchmark stages.

## Out of scope

Changing the frozen GPT benchmark, adopter outreach, v0.7 work, or changing shipped v0.6 features in response to the same benchmark results.

## Session log

- 2026-10-10 · GPT-6 / Codex · 09 · R4 Medulla B calibration `r4-medulla-b-calibration-01` stopped at HTTP 429 after 11 successful generations; quota metric is the 20/day Free-tier generation-request limit, quiz/task incomplete, no result or `N`; preserved private log and clean checkout, and recorded unresolved `RetryInfo` timing without changing frozen artifacts · next: after quota reset, verify AI Studio headroom and resume with a fresh attempt ID; do not replay this attempt or clone Draupnir before calibration completes.

- 2026-10-10 · GPT-6 / Codex · 09 · rechecked Free Tier/no billing, verified the private Medulla Q/key/task map to snapshot `01667b9`, and count-preflighted deterministic B bundles at 73,020 / 91,818 / 99,733 tokens; final 67/236 bundle and manifest hashes are recorded, secret scan clean, no generation sent · next: run the one unscored R4 calibration; stop if quota blocks completion.
- 2026-10-10 · GPT-6 / Codex · 09 · post-freeze R4 ping-only check succeeded (HTTP 200, `gemini-3.8-flash`, low thinking accepted, temperature omitted, reasoning usage absent); no repository content sent · next: freeze ping evidence, then prepare/count the private Medulla B bundle.
- 2026-10-10 · GPT-6 / Codex · 09 · after the final R3 request-cap stop, preserved R3 and drafted/pushed separate Gemini 3.8 Flash R4 at `e7adaef`; matching remote SHA, runner/builder checks, 147 tests, docs guard, and redacted secret scan pass; no R4 API request or repository-content transfer · next: do the ping-only pin check.
- 2026-10-10 · GPT-6 / Codex · 09 · froze the private R3 B bundle (86/236 records) and made three calibration attempts; two ended HTTP 503 and the final attempt stopped before generation at 232,231 estimated tokens, so no calibration result or N exists; preserved all private logs, updated evidence only, and confirmed 147 tests plus docs guard green · next: owner review before a separately frozen Gemini revision; do not continue R3.
- 2026-10-10 · GPT-6 / Codex · 09 · first B calibration preflight returned HTTP 400 `INVALID_ARGUMENT` from `countTokens`; no generation or `N`, and stopped without retry per protocol · next: owner reviews the invalid-request evidence before any new benchmark revision.
- 2026-10-10 · GPT-6 / Codex · 09 · after owner directed continuation through release, kept R1 unchanged and drafted Gemini R2 with the required nested model resource and distinct API-error categories; local runner self-check passes · next: push R2 freeze, then calibrate.
- 2026-10-10 · GPT-6 / Codex · 09 · froze and pushed Gemini R2 at `6ad0871`; local and remote SHAs match, 147 tests and docs guard pass, no R2 request sent · next: reconfirm Free Tier/no billing, then run the B-condition Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · R2 B calibration estimated 488,670 onboarding tokens; the Free-tier input-token quota of 250,000 rejected `generateContent` with HTTP 429; no score or `N`, no replacement or spec edit · next: owner reviews the protocol gap before a distinct revision or further API calls.
- 2026-10-10 · GPT-6 / Codex · 09 · checked Muse, configured provider names, and local/cloud Ollama model context without sending benchmark data; Gemini 3.1 Flash-Lite remains a documented Free-tier candidate pending project-specific quota verification · next: owner review before any R3 draft is frozen or sent.
- 2026-10-10 · GPT-6 / Codex · 09 · owner approved separate R3; AI Studio All models view confirms Gemini 3.1 Flash Lite is 15 RPM / 250K TPM / 500 RPD on the Free-tier project; added a separate quota-bounded R3 protocol, extraction prompt, and runner without changing R1/R2 · next: validate and push the R3 freeze before its ping.
- 2026-10-10 · GPT-6 / Codex · 09 · pushed R3 protocol/prompt/runner at c2671ac and verified remote SHA; ping-only pin check returned HTTP 200 with modelVersion gemini-3.1-flash-lite, thinking low, temperature omitted, and reasoning usage present · next: prepare capped Medulla B bundle and calibrate N.
- 2026-10-10 · GPT-6 / Codex · 09 · assembled the 236-record Medulla B candidate locally from the verified snapshot; pushed the deterministic bundle builder/count-only preflight at 7ba4fdc; its first invocation stopped locally on a parser allowlist bug before network; fixed and pushed at 998fe25 with matching remote SHA, still no repository content sent · next: count full bundle, remove oldest whole records to the 170K limit, then calibrate.
- 2026-10-10 · GPT-6 / Codex · 09 · froze and pushed the Gemini runner, schemas, command/edit allowlists, and corrected system prompt at `e05a5b9`; remote SHA matches and no repo content sent · next: run the condition-B Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · fixed Gemini run-history carryover, onboarding budget enforcement, and per-run write fencing; runner self-check and all 147 Fragment tests pass · next: freeze and push the harness, then run the B-condition Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · rechecked AI Studio Free tier and validated the pinned image with a clean Medulla clone; `npm ci` passed and 1,304 unit + 369 integration tests passed offline · next: freeze tool schemas and command allowlist before calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · pushed the frozen Gemini protocol/prompt commit `c44b2e5` and verified the remote SHA matches; no repo content sent · next: confirm container/test state and freeze harness before calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · owner authorized a separate Gemini track; recorded successful generic probes, Free Tier terms, and separate protocol/prompt without touching frozen artifacts · next: validate and push protocol before sending repository content or running calibration.
