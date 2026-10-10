# Gemini R4 pre-run verification

## Freeze

- R4 core protocol/prompt/system/builder/runner freeze: `e7adaefda5c568fdc83392d7f4f06e9516bdad82` on `codex/v06-benchmark-resume`.
- Local and remote branch SHAs matched after the push.
- After the post-freeze ping, three count-only Medulla onboarding preflights ran; no generation request has used repository content.
- R3 remains unchanged; R4 is a separate revision.
- R4 repository-content requests: `countTokens` only; questions, answer key, and task have not been sent.

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

### Recheck before Medulla calibration — 2026-10-10 19:20 WIB

- AI Studio still showed Free Tier and “Set up billing”; no billing setup was enabled.
- The generic “You have reached a rate limit” banner remained visible. The model table labels its values as peak usage over 28 days; Gemini 3.8 Flash showed 3/5 RPM, 46K/250K input TPM, and 9/20 RPD. These are not current remaining-quota counters. Treat the banner and available capacity as unresolved; stop on any API quota error.

## Medulla condition-B calibration

- Verified the existing private 10-question set and answer key against Medulla snapshot `01667b95454663848f193cd84e3fb055507035b0` and v0.5.0; the standalone task file is linked to the answer-key artifact. Private files remain outside the repo with owner-only file permissions.
- The existing Linux/arm64 image is present. The recorded clean run on this exact snapshot passed `npm ci` and network-disabled `npm test` (1,304 unit + 369 integration tests).
- Final R4 bundle: 67/236 tracked records; 169 oldest whole records omitted; bundle SHA-256 `e9cfcb2b202dfde00868357608cf1bfb008922a80dd401dcf0bc7a3275598c5f`; private manifest SHA-256 `780cf46b8f90f8c7d901a6124da055ce4fef1d1dd9634ac169f4ccfb4b8c2ea4`; count-only `countTokens` result 99,733 (HTTP 200), below the 120,000 onboarding cap. The bundle and manifest are stored outside the public repo with mode 0600.
- Count-only preparation history: 46 records / 73,020 tokens (HTTP 200); 59 / 91,818 (HTTP 200); final 67 / 99,733 (HTTP 200). Each request used the frozen R4 system prompt and Gemini 3.8 Flash; no questions, answer key, or task were sent. Redacted secret scan of the final bundle and system prompt found no leaks.
- No calibration `generateContent` request has been sent. No calibration result, score, or `N` exists.

## Sources

- [Gemini 3.8 Flash model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Gemini Free Tier pricing and data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
