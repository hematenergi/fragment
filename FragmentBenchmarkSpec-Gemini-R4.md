# Fragment Benchmark Spec — Gemini R4 Free Tier

**Status: protocol frozen at core commit `e7adaefda5c568fdc83392d7f4f06e9516bdad82` before the R4 ping or any R4 repository-content request.** R4 is a separate benchmark revision after three incomplete R3 Medulla calibration attempts. Keep R1, R2, R3, and the frozen GPT track unchanged; do not pool their partial usage with R4.

## 1. Inherited protocol and R3 evidence

R4 inherits the task/quiz structure, competence rule, conditions A/B/C, question mix, grading, anti-bias rules, phase counts, reporting, and release honesty block from `FragmentBenchmarkSpec-Gemini-R2.md`. It inherits the R3 quota-bounded B setup and Medulla calibration procedure except where this document overrides them. It uses `bench/gemini-r4-agent-system.md`, `bench/gemini-runner-r4.mjs`, `bench/gemini-r4-bundle.mjs`, and `bench/extract-prompt-gemini-r4.md`.

R3 stays frozen. Its three B-calibration attempts were incomplete (two HTTP 503 responses; the last stopped before generation at a 232,231-token request estimate). No R3 task result, score, or `N` exists. These are infrastructure evidence only and do not count toward R4.

## 2. Pinned provider and model

- Provider: Google Gemini Developer API, Standard Free Tier only. Do not enable billing or use a paid tier.
- Model: stable GA alias `gemini-3.8-flash`. Record and pin the exact successful `modelVersion` returned by the R4 ping in ignored `bench/.env`; every successful generation must match it. Stop if it changes or is missing.
- Thinking: `thinkingLevel=low`; verify acceptance with the R4 ping.
- Temperature: omit the field. No seed, grounding, URL context, caching, batch, or other provider feature.
- The selected AI Studio project showed Free Tier and these Gemini 3.8 Flash limits on 2026-10-10: **5 RPM, 250,000 input TPM, 20 RPD**. These are project limits and capacity may vary. Confirm Free Tier and current limits before each benchmark phase. Do not infer available headroom from another model's row.
- At the pre-run quota check, AI Studio also showed a generic rate-limit banner while the Gemini 3.8 Flash row remained below its displayed limits; the Gemini 3.1 Flash-Lite row's 28-day peak was above its TPM limit. This is unresolved dashboard evidence, not proof that R4 is available. Record the R4 ping result and stop if rejected; do not enable billing.
- Gemini 3.8 Flash has a documented 1,048,576-token input context. The stable alias has no dated immutable backend snapshot; record `modelVersion` per response and disclose this limit.
- Free Tier content may be used by Google to improve its products. `countTokens` sends each complete prompt before generation, so inputs are transmitted to Google twice. Continue only with the already-authorized Free Tier disclosure; send no credentials, secrets, local runtime state, or unrelated files.

## 3. Quota-safe request rules

- Before every generation, call `countTokens` on the exact request. Never dispatch `generateContent` above **220,000 input tokens**; this leaves 30,000 tokens below the observed 250,000 input-TPM ceiling. Stop the attempt before generation if the preflight exceeds the cap.
- Every condition-B onboarding bundle must be at or below **120,000 tokens**. Build Medulla bundles from tracked decisions, lessons, and plans; build Draupnir bundles from its frozen tracked `kb/decisions/`, `kb/lessons/`, `kb/plans/`, and `kb/STATE.md`. Use `bench/gemini-r4-bundle.mjs`; order by first Git-add date then path, and remove only whole oldest files. Count with the frozen R4 system prompt and tool schemas. Repeat only count-only preparation until within the cap. Preserve private included/omitted manifests, bundle hashes, and omitted fractions. No paraphrasing or manual curation.
- Keep every API request at least **15 seconds** apart and every `generateContent` request at least **61 seconds** apart. This is conservative for the observed 5 RPM and 250,000 input TPM; it does not guarantee capacity if other project traffic is present.
- The observed daily cap is 20 RPD, reset at midnight Pacific Time per Google's rate-limit documentation. Treat a 429 as quota/rate-limit evidence: stop the attempt and phase, preserve the private log, and do not replay. Resume only after the AI Studio panel shows the required headroom after reset. Do not turn on billing. For other 5xx/timeouts, follow the inherited fresh-attempt rule after 60 seconds, with at most two replacements per cell. Any replacement starts clean with a new attempt ID.
- No incomplete attempt contributes to `N`, a score, or tokens-to-competent. Preserve missing usage fields as missing.

## 4. Calibration and scored phases

- Use the existing private Medulla questions, answer key, rubric, task, and automatic check only after confirming their recorded snapshot/version mapping. Do not revise them for R4.
- Run one unscored R4 condition-B Medulla calibration after all R4 artifacts are frozen and the pin check passes. Set `N` to exactly 2× the successful calibration's cumulative `usageMetadata.promptTokenCount`, rounded up to the next 10,000. If the task does not complete within the 10,000,000-token safety ceiling, or infrastructure/quota stops it first, calibration is incomplete and no `N` may be set.
- Only after calibration, clone and verify Draupnir in the existing final container; record the exact SHA and green test evidence. Fill and commit only R4 extraction prompt metadata placeholders, verify that diff, mechanically extract and freeze its KB, then write Draupnir questions, answers, rubrics, task, and automatic check from post-March-2026 issue/PR history. Do not write Draupnir questions before the KB is frozen.
- Freeze the Draupnir set and all run artifacts before scored runs. Run 30 baseline v0.5.0 and 30 separate validation v0.6 runs. Keep raw prompts, responses, private Medulla data, grading sheets, and answer keys outside the public repository.

## 5. Accounting, grading, and reporting

Use the inherited R2 rules: success requires at least 7/10 and the automatic task check passing; report success rate first, then eligible successful-run median/range, and trap score x/2 separately. Human grading stays blind to condition and phase. Report successful-run input as the sum of each successful response's `promptTokenCount`; report completion and reasoning usage separately, preserving absent `thoughtsTokenCount` fields and their coverage. Keep API/infrastructure failures separate from model failures. Headline results come from Draupnir; Medulla is calibration and a separate within-repository readout.

Gemini results remain indicative and separate from GPT results. Do not compare Medulla directly with Draupnir. Release claims require the frozen comparison rule: at least 3/5 successes per compared condition, with non-overlapping successful-run ranges before claiming a win. Include the required honesty block and the Free Tier data-use disclosure.

## 6. Freeze and stop rules

- Freeze this R4 spec, extraction prompt, agent system prompt, bundle builder, runner, tool schemas, command/edit allowlists, and retry/accounting rules in one pushed commit before any R4 API request. The only R4 request before repository content may be the one-word `ping` pin check.
- Any change after the ping but before repository content requires a new freeze commit. Any change after calibration or scored output starts R5; discard the affected R4 numbers.
- Stop on 400, 401, 403, model mismatch, missing model version, refusal, quota exhaustion, or invalid usage. Report evidence without changing the frozen artifacts.
- Never edit `FragmentNorthstar.md`, `FragmentBenchmarkSpec.md`, `bench/extract-prompt.md`, `CASE-STUDY.md`, or any Gemini R1/R2/R3 artifact.

## 7. Execution order

1. Validate R4 source files, harness self-test, secret exclusion, and repository checks; then commit and push this R4 freeze.
2. Reconfirm the AI Studio project is Free Tier with no billing, then run the ping-only R4 model/settings check and pin its returned `modelVersion` in ignored local configuration. Do not send repository content in this check.
3. Confirm the existing final container and clean Medulla tests. Verify the private Medulla question/key/task mapping to the recorded snapshot and v0.5.0 procedure.
4. Build and count the deterministic Medulla R4 B bundle; preserve its private manifest and hash.
5. Run one R4 B Medulla calibration. Set `N` only if the task completes with valid usage on every generation.
6. Clone and test Draupnir in the final container; record its SHA, then fill only the R4 extraction prompt placeholders and freeze the extracted KB.
7. Freeze Draupnir question set, key, rubric, task, and check after KB freeze.
8. Run 30 baseline and 30 v0.6 validation attempts under this R4 configuration; respect current Free Tier quotas. If the daily cap limits progress, preserve the exact stopped attempt and resume only with a fresh attempt after the quota reset.
9. Recompute public aggregate metrics from private raw logs, complete the honesty block, and prepare GitHub v0.6.0 only when the release gate is satisfied.

## 8. Freeze anchors

- R1/R2/R3 records remain in their existing files and commits.
- R4 core protocol/prompt/system/builder/runner freeze commit: `e7adaefda5c568fdc83392d7f4f06e9516bdad82` on `codex/v06-benchmark-resume`; local and remote SHAs matched before any R4 API request.
- R4 ping response `modelVersion`: `[FILL AFTER PING]`.
- R4 Medulla snapshot: `01667b95454663848f193cd84e3fb055507035b0`.
- R4 Medulla B bundle SHA and manifest: `[FILL BEFORE CALIBRATION]`.
- Final container image: `sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9` (`linux/arm64`).
- Draupnir SHA: `[FILL AFTER CALIBRATION]`.
- `N`: `[FILL ONLY AFTER COMPLETED R4 CALIBRATION]`.

## Sources checked 2026-10-10

- [Gemini 3.8 Flash model card](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Gemini 3.8 Flash migration guide](https://ai.google.dev/gemini-api/docs/latest-model)
- [Gemini Free Tier pricing and data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
- [CountTokens API](https://ai.google.dev/api/tokens)
- Selected project's AI Studio Rate Limit panel, observed 2026-10-10: Free Tier, 5 RPM / 250K input TPM / 20 RPD.
