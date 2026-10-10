# Fragment Benchmark Spec — Gemini track (v0.6 item #0)

**Status: frozen before any dry run.** This is a new provider-specific protocol. It does not amend `FragmentBenchmarkSpec.md`; GPT results and Gemini results must never be pooled or compared as if they used the same model.

## 1. Question and completion rule

Measure whether Fragment's documented context-loading procedure helps a fresh coding agent become competent with fewer cumulative input tokens. Each run has the same three stages:

1. Onboarding: provide the repository according to A, B, or C. The agent receives no quiz questions yet. End onboarding when it emits the exact ready signal in the frozen agent system prompt, or when cumulative input reaches half of budget `N`, whichever comes first.
2. Quiz: provide all 10 questions at once. The agent may use the locked local tools.
3. Task: provide the repository task and automatic pass criteria. The agent may use the same tools.

A run is competent only when it scores at least 7/10 and passes the task. Report success rate first. Report median and range of cumulative input tokens only for successful runs, and compare medians only when both conditions have at least 3/5 successes. Report the two trap items separately.

`N` is fixed from one unscored condition-B medulla dry run after this protocol is frozen: use exactly 2× its cumulative input-token count, rounded up to the next 10,000. The dry run is calibration and is excluded from results. Its harness has a 10,000,000 cumulative-input safety ceiling; if the task is not complete at that ceiling, calibration is incomplete and no `N` may be set. Before every request, use Gemini `countTokens` to prevent knowingly crossing the active input budget; use generation `usageMetadata.promptTokenCount` for reported totals. The first condition-B onboarding preflight must also stay at or below 80% of the model context window; if it exceeds that limit, do not generate, truncate oldest records as specified in §2, record the omitted fraction, then repeat preflight. If a request fails without usage metadata after dispatch, mark that run as infrastructure-incomplete and replace it; preserve the failed attempt and report infrastructure failures separately. Do not present an incomplete run as an exact token measurement.

## 2. Conditions and phases

| Condition | Setup |
|---|---|
| A — no Fragment tooling | Keep repository knowledge files present. Remove only Fragment's documented loading/tooling. The Draupnir KB remains present; A tests how it is loaded, not whether it exists. |
| B — load all | Load all decisions, lessons, and plans at session start. If this exceeds 80% of the pinned model's context window, truncate oldest records first and record the fraction removed. Gemini 3.8 Flash's documented input window is 1,048,576 tokens, so the limit is 838,860 tokens. |
| C — Fragment | Baseline phase uses the documented Fragment v0.5.0 process. Validation phase uses the documented v0.6 process, including deterministic `/recall` and token-budgeted loading. |

Run both phases: baseline v0.5.0 and validation v0.6. Each phase contains 3 conditions × 5 runs × 2 repositories = 30 completed runs. Use the same frozen questions, answer keys, rubrics, tasks, repository snapshots, and harness across both phases; only C's documented Fragment version changes. The medulla set already drafted for snapshot `01667b95454663848f193cd84e3fb055507035b0` is the candidate set; verify its snapshot and version mapping before dry run. Draupnir is the evaluation headline; medulla is for calibration and a separate within-repository readout. Do not compare medulla and Draupnir token counts directly.

## 3. Pinned Gemini configuration

- Provider/API: Google Gemini Developer API, `generateContent` and `countTokens`, standard Free Tier only.
- Model ID: stable GA alias `gemini-3.8-flash`. Record response `modelVersion` on every successful generation; expected value is `gemini-3.8-flash`. Stop and review before continuing if it changes. The API exposes no dated immutable snapshot in the verified metadata; this limits exact backend reproducibility and must appear in the final honesty note.
- API metadata observed: `models/gemini-3.8-flash`, metadata `version=3.0`; model-card knowledge cutoff is March 2026, with some domains possibly limited to January 2025. Draupnir question sources must be dated after March 2026.
- Thinking: `thinkingLevel=low`. Runtime generation accepted `low`; a generic high-thinking request also succeeded, but high is not used in scored runs.
- Temperature: omit the field. Gemini 3 guidance recommends leaving sampling parameters at their defaults. A request without temperature succeeded; explicit temperature is not part of this protocol.
- No seed, search grounding, URL context, caching, batch, or other provider feature. Keep calls stateless except for the conversation history the harness resends.
- Exact shared agent instructions are in `bench/gemini-agent-system.md`. The frozen harness is `bench/gemini-runner.mjs`: its tool schemas and fixed command allowlist are part of the protocol. Write/edit calls are further restricted to the per-run `--edit-path` allowlist. The conversation history persists from onboarding through quiz and task. The harness uses one network-disabled container per run and strips API-key variables from all child processes.
- Model availability: the official deprecation page showed no shutdown date announced on 2026-10-10. Recheck before a later validation phase; this is not a promise of future availability.

The user's approval covers this separate Gemini benchmark and the disclosed Free Tier data terms. Google lists Free Tier input/output as no-charge and states that Free Tier content may be used to improve its products. `countTokens` sends the full prompt to Google's API before generation, so those inputs are transmitted twice; include this in the disclosure. Before each phase, confirm the AI Studio project is still Free Tier and billing is not enabled. Stop if either is not true. Send no credentials, local runtime state, unrelated private files, or secrets. Store raw prompts/responses and answer keys outside the public repository; publish aggregate results and reproducibility metadata only.

## 4. Token accounting and API reliability

For each generation response, preserve the raw usage fields and log:

- cumulative input = sum of `usageMetadata.promptTokenCount` across every successful turn, including repeated context and tool declarations;
- output = `candidatesTokenCount`;
- reasoning = `thoughtsTokenCount`, separately, with absent fields preserved as absent (do not silently convert missing data to zero);
- `totalTokenCount`, `cachedContentTokenCount` if present, response `modelVersion`, HTTP status, duration, and whole-run attempt number.

Caching is disabled. The reasoning field was observed in a generic response, but it was absent in trivial responses; report its coverage as well as the observed total. Headline metric remains cumulative input. Space every API request at least 15 seconds apart because the benchmark project's exact active rate limit is not exposed. On HTTP 429/500/502/503/504 or a client timeout, stop that run attempt immediately and mark it infrastructure-incomplete; do not replay a prompt or resume partial history. A replacement is a fresh run attempt from a clean workspace after a 60-second wait, with a new attempt ID. At most two replacements per cell; if failures continue, stop the phase. Stop immediately on 401/403, quota exhaustion, model mismatch, invalid request, or content refusal. Keep API errors separate from model failures. Log each request attempt without authorization headers or key material. Only complete runs with usage metadata on every generation response are eligible for scored metrics.

## 5. Questions, task, and grading

Per repository, freeze 10 questions before the first dry run: 3 architecture facts, 3 decision rationales, 2 navigation/status questions, and 2 stale/reversal traps. Freeze answer key, rubric, task, and automatic pass check alongside the questions. Draupnir questions must come from its own issue/PR history after March 2026, including two decisions explicitly reversed by later merged PRs. Do not write Draupnir questions until its extracted KB is frozen.

Use a human grader who is blind to condition and phase. Grade against the frozen answer key and rubric. Do not use Gemini to judge Gemini. Keep questions, answers, raw transcripts, and private medulla material outside the public repository. The task must be small and use an automatic check derived from the historical merged PR/test.

## 6. Anti-bias, claims, and release gate

- Freeze this file, the extraction prompt, question sets, rubrics, task checks, system prompt, tools, and retry/accounting rules before any dry run. Any change after observing a dry-run or scored result starts a new Gemini benchmark; discard affected numbers.
- Extract Draupnir knowledge mechanically from one pinned repository SHA, then freeze the KB before writing its questions. Do not hand-edit claims except to repair a documented parse-format failure.
- Baseline C is v0.5.0; validation C is v0.6. Do not tune Fragment between baseline and validation from baseline results.
- Report each phase and provider separately. Label results indicative (`n=5` per condition), show success rates, successful-run median/range only where eligible, traps, and infrastructure failures. Claim a win only when the predeclared comparison supports it and ranges do not overlap.
- A v0.6.0 release requires the benchmark phases to have numbers and all four North Star v0.6 items shipped. Include a plain-language honesty block: author-run `n=2` repositories, one repository is non-author, Free Tier data terms, stable-alias limitation, and any incomplete/missing token fields. Do not claim third-party validation.

## 7. Execution order

1. Keep the original GPT spec and prompt untouched. Commit and push this separate Gemini protocol, `bench/extract-prompt-gemini.md`, and `bench/gemini-agent-system.md`; do not send repository content to Gemini until all three are frozen and pushed.
2. Confirm the project's Free Tier status, verify the pinned model/settings, and validate the existing final container plus clean medulla tests. Do not create a replacement environment unless separately directed.
3. Verify the private medulla question/key/task set is tied to the recorded snapshot and v0.5.0 procedure. Freeze the system prompt, tools, and grading sheet.
4. Run one condition-B medulla dry run; calculate `N` by §1. Record calibration only, not a result.
5. In the final container, clone Draupnir, record its exact SHA, and confirm its test suite is green.
6. Fill and commit only the new Gemini extraction prompt's snapshot/model/date placeholders, and verify the diff changes placeholders only. Run mechanical extraction and freeze the KB.
7. From post-March-2026 Draupnir issues/PRs, freeze questions, answers, rubric, task, and pass check.
8. Confirm the already-frozen harness/system prompt, fill the calibration-derived `N`, and record all artifact locations before scored runs. No harness or prompt edits are allowed after the dry run.
9. Run the 30-run v0.5.0 baseline. Then, without tuning from those results, run the separate 30-run v0.6 validation.
10. Recompute the tables from raw logs, write the benchmark report, complete the remaining release items, and only then prepare v0.6.0.

## 8. Freeze anchors and run record

- Initial protocol, extraction prompt, and system-prompt commit (pushed 2026-10-10): `c44b2e5b4482749056f343a9c2f7b00b93f92d47` on `codex/v06-benchmark-resume`. The remote branch SHA was verified equal to the local SHA. No repository content was sent in that commit or before it.
- Final harness/system prompt/tool allowlist freeze commit (pushed 2026-10-10): `e05a5b9139b27f5102dad5ebc80649e05fd7d383` on `codex/v06-benchmark-resume`. The local and remote branch SHAs matched. No repository content had been sent to Gemini before this freeze.
- Prompt metadata-only commit after final Draupnir clone: `[FILL AFTER STEP 5]`.
- Draupnir snapshot SHA: `[FILL AFTER STEP 5]`.
- Final image: `sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9` (`linux/arm64`); confirmed available and used for clean Medulla verification on 2026-10-10.
- Medulla snapshot: `01667b95454663848f193cd84e3fb055507035b0`.
- Final-image Medulla verification: 2026-10-10; clean clone, `npm ci` exit 0, `npm test` exit 0 with networking disabled (1,304 unit + 369 integration tests).
- `N`: `[FILL AFTER CONDITION-B MEDULLA DRY RUN]`.

## Sources checked 2026-10-10

- [Gemini 3.8 Flash model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Gemini 3.8 Flash migration/model guide](https://ai.google.dev/gemini-api/docs/latest-model)
- [Gemini model versions](https://ai.google.dev/gemini-api/docs/models)
- [Gemini thinking](https://ai.google.dev/gemini-api/docs/thinking)
- [Gemini model card](https://deepmind.google/models/model-cards/gemini-3-8-flash/)
- [Model deprecations](https://ai.google.dev/gemini-api/docs/deprecations)
- [Free Tier pricing and data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
- [Token counting API](https://ai.google.dev/api/tokens)
- [Generate Content API](https://ai.google.dev/api/generate-content)
- [Function calling](https://ai.google.dev/gemini-api/docs/function-calling)
