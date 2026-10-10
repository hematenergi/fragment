# Fragment Benchmark Spec — Gemini R3 Free Tier

**Status: protocol frozen at core commit c2671ac5a873af1ca046054ffee2e8e3f6dbf018 before the R3 pin check or any repository-content request.** The owner approved a new Gemini benchmark after the Free Tier data-use disclosure. R3 starts a new dataset. It does not alter or pool with the frozen GPT spec, Gemini R1, or Gemini R2. R2 remains frozen at 6ad0871326da41631df20a2acf8b5bc3e76b8fd5.

## 1. Inherited protocol

Unless this file explicitly overrides a point below, R3 inherits the question format, competence rule, stages, grading, conditions A/B/C, anti-bias rules, run counts, reporting, and release honesty block in FragmentBenchmarkSpec-Gemini-R2.md. R3 also uses the unchanged agent instructions in bench/gemini-agent-system.md and the separate extraction prompt bench/extract-prompt-gemini-r3.md.

R3 is a new benchmark because the R2 calibration attempt observed a 488,670-token B onboarding prompt and a 250,000-input-token Free Tier quota. No R2 response score, calibration, or N exists. Preserve the failed R2 attempt as infrastructure/quota evidence only.

## 2. Pinned provider and model

- Provider: Google Gemini Developer API, Free Tier only. Billing must remain unset.
- Model alias: gemini-3.1-flash-lite. The model page lists a stable alias, a 1,048,576-token input window, and thinking support.
- Thinking: low. Google lists low as a supported setting for Gemini 3.1 Flash-Lite. Verify it with the R3 pre-run ping after this protocol and runner are pushed.
- Temperature: omit the field, following Google's Gemini 3 guidance to keep the default.
- No search grounding, URL context, caching, batch, seed, or other provider feature. Preserve the same tool declarations and local-only environment from R2.
- Record the successful ping's modelVersion in the ignored bench/.env setting GEMINI_MODEL_VERSION_R3 and require every scored response to match it. If the model is unavailable, the setting is rejected, or modelVersion changes, stop and report evidence; do not silently change the pin.

The AI Studio project dashboard was checked on 2026-10-10 with All models enabled and the target project selected. It showed Free tier, Set up billing, and Gemini 3.1 Flash Lite limits of 15 RPM, 250K TPM, and 500 RPD. These are dashboard project limits, not a guarantee of capacity. Do not use paid inference or enable billing.

## 3. Free-tier input limits

- Keep every generation request at or below 230,000 preflight input tokens. If countTokens exceeds this ceiling, do not dispatch generateContent; mark the attempt incomplete and return the evidence for review.
- Start generateContent requests at least 61 seconds apart. Keep all API calls at least 4.1 seconds apart. This keeps a single 230,000-token generation below the observed 250,000 TPM ceiling and all calls below the observed RPM limit, assuming no unrelated project traffic.
- Condition B's initial onboarding bundle has a separate cap of 170,000 preflight input tokens. Build it from tracked Markdown under decisions/, lessons/, and plans/ using bench/gemini-r3-bundle.mjs. The builder orders records by first Git-add date, then path; it adds source-path headers and removes only whole oldest records. Use the runner's count-onboarding mode with the frozen system text and tool schemas to choose the smallest drop count that yields at most 170,000 tokens. This countTokens preparation is unscored and never calls generateContent. Save each private preflight log; freeze the final bundle SHA, included/omitted manifest, and omitted fraction. Do not summarize or rewrite retained records.
- Do not trim the transcript dynamically after onboarding. If any later request exceeds 230,000 tokens, stop before generation and record a request-cap failure. Do not count an incomplete attempt as a competent run.
- Reconfirm the project remains Free Tier before each benchmark phase. A quota rejection stops the affected attempt; preserve its log, do not retry it in the same run, and pause the phase for review.

This quota-bounded B condition is specific to R3. It is not the full untruncated load-all condition in R2 and must be labeled as such in every report. R3 is not numerically comparable with R1/R2 or the original GPT track.

## 4. Calibration and scored runs

- Use the existing verified Medulla snapshot and private question/key/task set only after confirming their SHA/version mapping.
- Run one unscored R3 condition-B Medulla calibration after the R3 protocol, runner, and pin are frozen. Set N to 2 times its cumulative promptTokenCount, rounded up to the next 10,000. Preserve it as calibration, not a score. If it cannot reach the task within the 10,000,000-token safety ceiling, no N is set.
- Then follow the inherited order: clone and verify the pinned Draupnir snapshot in the final container; mechanically extract and freeze its KB; only then write and freeze Draupnir questions, keys, rubrics, task, and check.
- Run the 30-run v0.5.0 baseline and, without tuning from its results, the separate 30-run v0.6 validation. Keep Medulla as tuning evidence and Draupnir as the headline repository.
- Report successful and incomplete attempts separately. Report success rate, eligible successful-run median/range of cumulative input tokens, task outcomes, and trap score x/2.

## 5. Freeze and change control

- R3 protocol, R3 extraction prompt, R3 runner, system prompt reference, per-request cap, generation spacing, and prepared onboarding bundles must be pushed before any repository content is sent for R3.
- The R3 pin check sends only the text ping, with no code, repository documents, question, answer key, or task.
- Any change after the pin check but before repository data is sent requires a new freeze commit. Any change after calibration output or a scored result starts a new Gemini revision; discard affected numbers.
- Never edit FragmentNorthstar.md, FragmentBenchmarkSpec.md, bench/extract-prompt.md, or CASE-STUDY.md.

## 6. Sources and evidence

- AI Studio project dashboard, Free Tier, All models view, 2026-10-10: Gemini 3.1 Flash Lite 15 RPM / 250K TPM / 500 RPD.
- Google model page: https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite
- Google Gemini thinking guide: https://ai.google.dev/gemini-api/docs/thinking
- Google rate limits: https://ai.google.dev/gemini-api/docs/rate-limits
- Google pricing and Free Tier data use: https://ai.google.dev/gemini-api/docs/pricing
- Google Gemini 3 guidance on default temperature: https://ai.google.dev/gemini-api/docs/gemini-3

## 7. Freeze anchors

- R2 ancestor protocol freeze: 6ad0871326da41631df20a2acf8b5bc3e76b8fd5.
- R3 protocol/prompt/runner freeze commit: c2671ac5a873af1ca046054ffee2e8e3f6dbf018.
- R3 modelVersion from ping: gemini-3.1-flash-lite.
- R3 bundle-preparation amendment freeze: recorded in bench/gemini-r3-verification.md before any repository-content request.
- Medulla snapshot: 01667b95454663848f193cd84e3fb055507035b0.
- Draupnir snapshot: fill only after the R3 Medulla calibration completes.
- R3 N: fill only after the R3 Medulla calibration completes.
