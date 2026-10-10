# Gemini model verification — separate benchmark track

Verification recorded 2026-10-10, 16:26 WIB. Exploratory requests in the same session were generic and contained no repository, question, answer-key, or task content. Exact per-request timestamps were not captured.

## Pin decision

- Requested model: `gemini-3.8-flash` (stable GA alias).
- Catalog lookup returned `models/gemini-3.8-flash`, metadata version `3.0`; successful generation responses returned `modelVersion=gemini-3.8-flash`. No dated immutable backend snapshot was exposed. Record the response field per call and stop if it changes.
- `thinkingLevel=low` was accepted in successful generation requests. A generic high-thinking request also succeeded; scored runs pin low.
- Temperature was omitted and the request succeeded. Explicit temperature acceptance was not verified; protocol pins omission, following Google's recommendation to leave sampling parameters at defaults.
- Reasoning-token usage is `usageMetadata.thoughtsTokenCount`; one generic high-thinking response returned 331 thoughts tokens separately from 4 candidate tokens. Other simple responses omitted the thoughts field, so benchmark logs must preserve missing fields and report coverage.

## Probe observations

| Probe | HTTP | Usage returned |
|---|---:|---|
| `ping`, temperature omitted, thinking low | 200 | prompt 1, candidates 2, total 3; no thoughts field |
| Generic arithmetic, first attempt | 503 | no usage |
| Same generic arithmetic, retry | 200 | prompt 27, candidates 104, total 131; no thoughts field |
| Generic logic question, thinking high | 200 | prompt 22, candidates 4, thoughts 331, total 357 |

The earlier session also recorded three 503 responses and a 15-second client timeout. This confirms intermittent availability; it does not establish stable quota capacity. No quota/rate-limit headers appeared on the successful probes. Exact active RPM/RPD limits were not confirmed.

## Cost, privacy, and lifecycle

- On 2026-10-10, the AI Studio API Keys page showed the project attached to the configured key as **Free tier**, with **Set up billing** still offered. A later view selected that exact project, **Gemini API**, on the Rate Limit page; it still showed **Free tier** and **Set up billing**.
- For `Gemini 3.8 Flash`, AI Studio displayed peak usage/limit over 28 days as **3/5 RPM, 46/250K TPM, and 9/20 RPD**. These are dashboard peak/limit figures, not a live remaining-quota counter. The API's R2 `QuotaFailure` independently named `generate_content_free_tier_input_token_count` with value `250000`; no rate-limit headers were returned. The official rate-limit page says limits vary by project/tier and must be read in AI Studio; it lists the Free tier spend-based limit as N/A.
- Google's pricing page lists Gemini 3.8 Flash Free Tier input/output as free of charge and says Free Tier content may be used to improve Google products. Owner explicitly approved a separate Gemini benchmark after that disclosure.
- Reconfirm Free Tier and no billing before each phase. Do not send credentials or unrelated private material. Do not record API keys or authorization headers.
- Google's model card gives a March 2026 knowledge cutoff, with some domains possibly limited to January 2025. Use Draupnir source events after March 2026 for contamination-resistant questions.
- Official deprecations listed no shutdown date announced for Gemini 3.8 Flash on 2026-10-10; availability still needs a pre-validation check.

## Final benchmark environment check

Verified 2026-10-10, 16:37 WIB using the existing `linux/arm64` image `sha256:1dc5bcac894ca20e094cb9c71c626fc3cc350d005dbdc853aae46c040d4f45b9`. A clean clone of Medulla snapshot `01667b95454663848f193cd84e3fb055507035b0` was checked out detached; Git reported no changes. `npm ci` exited 0 in the pinned image. `npm test` then exited 0 with container networking disabled: 1,304 unit tests and 369 integration tests passed, none failed or skipped. The image remains available; the test container was ephemeral and removed. This was environment validation, not a benchmark run, and no model call received repository content.

The preceding “no model call” statement is scoped to the environment-check timestamp; the later `countTokens` transmission is recorded below.

## First data-bearing preflight

At 2026-10-10 17:08 WIB, the frozen runner started condition-B calibration attempt `medulla-b-calibration-01` from a clean workspace at the recorded Medulla snapshot. The first `countTokens` request carried the onboarding material and returned HTTP 400 with API status `INVALID_ARGUMENT`. No `generateContent` request was made; there is no dry-run result or `N`. The private log retains the request/response, without authorization headers or key material. The attempt stopped and was not retried, per the frozen invalid-request rule. The run wrapper labeled the end state `infrastructure-incomplete`; the public record keeps the API status distinct from any model outcome.

**Likely cause (inference; not re-tested):** a redacted local classifier extracted “model not specified” from the private error response. The frozen `countTokens` body wraps `generateContentRequest` but does not set its `model` field; Google's REST schema marks `GenerateContentRequest.model` required. No request was sent after this diagnosis. See the official [countTokens API](https://ai.google.dev/api/tokens) and [GenerateContentRequest schema](https://ai.google.dev/api/generate-content).

## R2 freeze and calibration attempt

R2 adds `model: models/gemini-3.8-flash` to the shared request body and distinguishes invalid-request, authorization, rate-limit/quota, and server-error categories. `node --check`, the no-network runner self-check, all 147 repository tests, and the docs guard passed. Freeze commit `6ad0871326da41631df20a2acf8b5bc3e76b8fd5` is pushed to `codex/v06-benchmark-resume`; local and remote SHAs matched before the attempt. The R2 spec and harness remain unchanged after it.

At **2026-10-10 17:25 WIB**, R2 attempt `medulla-b-calibration-r2-01` used Medulla snapshot `01667b95454663848f193cd84e3fb055507035b0` and the pinned `gemini-3.8-flash` alias. The B onboarding `countTokens` request returned HTTP 200 and estimated **488,670 input tokens**. The following `generateContent` request returned HTTP 429 `RESOURCE_EXHAUSTED`; its structured `QuotaFailure` named metric `generate_content_free_tier_input_token_count`, value `250000`, and `RetryInfo` of 23 seconds. No rate-limit headers were returned. No generation response, `usageMetadata`, score, or calibration `N` exists. The failed attempt is not replayed; its complete private log is retained outside the repository at `~/.codex/private-benchmarks/fragment-v06-medulla/gemini-runs/medulla-b-calibration-r2-01.jsonl`.

The Free-tier limit is lower than the 488,670-token B onboarding prompt. The frozen spec's 80%-of-context truncation threshold is 838,860, so it would not truncate this prompt. A repeated identical request would still exceed the API's reported 250,000 input-token quota. No replacement attempt was sent. This is a protocol gap, recorded for owner review; the frozen R2 spec was not changed.

## Sources

- [Model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Model card](https://deepmind.google/models/model-cards/gemini-3-8-flash/)
- [Pricing and Free Tier data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Deprecations](https://ai.google.dev/gemini-api/docs/deprecations)
- [Rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
