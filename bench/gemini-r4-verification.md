# Gemini R4 pre-run verification

## Freeze

- R4 core protocol/prompt/system/builder/runner freeze: `e7adaefda5c568fdc83392d7f4f06e9516bdad82` on `codex/v06-benchmark-resume`.
- Local and remote branch SHAs matched after the push.
- Only the post-freeze, ping-only model check has run; no repository-content transfer has occurred.
- R3 remains unchanged; R4 is a separate revision.
- R4 repository-content requests: none.

## Local freeze validation

- Date: 2026-10-10.
- `node --check` passed for the R4 runner and bundle builder.
- The R4 runner self-check passed.
- The bundle builder smoke check completed on the Fragment checkout without printing bundle contents.
- `bash tests/run.sh`: 147 passed.
- `bash scripts/docs-check.sh`: green.
- Redacted gitleaks scan: no leaks found.
- Original frozen GPT and Gemini R1/R2/R3 files are unchanged; `bench/.env` remains ignored.

## Project quota

- Checked in Google AI Studio Rate Limit on 2026-10-10.
- Project tier: Free Tier; “Set up billing” remained available.
- Gemini 3.8 Flash limits shown: 5 RPM, 250K input TPM, 20 RPD.
- These are project limits, not a capacity guarantee. Recheck before each phase.
- Dashboard anomaly: a generic “You have reached a rate limit” banner was visible. The Gemini 3.8 Flash row was below its displayed limits; the Gemini 3.1 Flash-Lite row showed a 28-day peak above its TPM limit. Whether the generic banner applies across model rows is unconfirmed. The R4 ping succeeded; future request capacity is still not guaranteed. Do not enable billing.
- Google documents Free Tier Standard input/output as no-charge and says Free Tier content may be used to improve its products. `countTokens` transmits the prompt before generation as well.

## Model pin check

- Time: 2026-10-10 19:10:09 WIB.
- Request: one `generateContent` call; the user message was exactly `ping`. No repository code, documents, questions, answer key, or task was sent.
- Model endpoint: `gemini-3.8-flash`; HTTP 200.
- Response `modelVersion`: `gemini-3.8-flash`; pinned in the ignored local configuration for R4.
- Temperature: omitted and accepted.
- Thinking: low accepted.
- Usage: 2 prompt tokens, 1 completion token, reasoning field absent, 3 total tokens. Absence is not recorded as zero.
- Rate-limit headers: none returned.
- The earlier generic AI Studio rate-limit banner was not explained, but this Gemini 3.8 Flash ping succeeded while the project remained Free Tier. Do not infer future capacity from this one call.
- Authorization header and API key: not logged or recorded.

## Medulla condition-B calibration

- Pending count-only bundle preflight; no calibration request has been sent.
- Use a separately built R4 bundle with a 120,000-token onboarding ceiling and a 220,000-token per-request ceiling.
- Store bundle, manifest, raw request/response logs, and private task material outside the public repository with owner-only permissions.
- No calibration result or `N` exists until one full task-completing run has valid usage metadata for every generation.

## Sources

- [Gemini 3.8 Flash model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Gemini Free Tier pricing and data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
