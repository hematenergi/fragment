# Gemini R4 pre-run verification

## Freeze

- R4 core protocol/prompt/system/builder/runner freeze: `e7adaefda5c568fdc83392d7f4f06e9516bdad82` on `codex/v06-benchmark-resume`.
- Local and remote branch SHAs matched after the push.
- No R4 API request or repository-content transfer has occurred yet.
- R3 remains unchanged; R4 is a separate revision.
- R4 repository-content requests: none before freeze and ping verification.

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
- Dashboard anomaly: a generic “You have reached a rate limit” banner was visible. The Gemini 3.8 Flash row was below its displayed limits; the Gemini 3.1 Flash-Lite row showed a 28-day peak above its TPM limit. Whether the generic banner applies across model rows is unconfirmed. Do not enable billing; the ping-only check must establish whether R4 requests are currently accepted.
- Google documents Free Tier Standard input/output as no-charge and says Free Tier content may be used to improve its products. `countTokens` transmits the prompt before generation as well.

## Model pin check

- Pending R4 freeze commit and ping-only request.
- Required user content: exactly `ping`; no repository code, documents, questions, answer key, or task.
- Model endpoint: `gemini-3.8-flash`.
- Temperature: omitted.
- Thinking: low.
- Record response `modelVersion`, HTTP status, separated usage fields, timestamp WIB, and rate-limit headers. Never record authorization headers or key material.

## Medulla condition-B calibration

- Pending successful R4 pin check and count-only bundle preflight.
- Use a separately built R4 bundle with a 120,000-token onboarding ceiling and a 220,000-token per-request ceiling.
- Store bundle, manifest, raw request/response logs, and private task material outside the public repository with owner-only permissions.
- No calibration result or `N` exists until one full task-completing run has valid usage metadata for every generation.

## Sources

- [Gemini 3.8 Flash model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Gemini Free Tier pricing and data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
