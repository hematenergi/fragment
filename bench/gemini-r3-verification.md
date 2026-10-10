# Gemini R3 pre-run verification

## Freeze

- R3 protocol, extraction prompt, and runner were pushed in commit c2671ac5a873af1ca046054ffee2e8e3f6dbf018 on codex/v06-benchmark-resume.
- Local and remote branch SHAs matched before the pin check.
- Deterministic bundle builder and count-only onboarding preflight were added in a pre-data R3 amendment, pushed at 7ba4fdc140cd917a16721d5ff5d8ea5357849400; local and remote SHAs matched.
- A config-parser fix for the recorded response-model pin was pushed at 998fe25b7345951aa4155c35cd1cee6a6bfd0e00; local and remote SHAs matched before any countTokens request.
- R2 and the original GPT artifacts remain unchanged.
- No repository content, question, answer key, or task was included in the pin check.

## Project quota

AI Studio showed the selected project on Free tier with Set up billing still offered. With All models enabled, Gemini 3.1 Flash Lite showed 15 RPM, 250K TPM, and 500 RPD in the 28-day peak-usage table on 2026-10-10. These are dashboard limits, not guaranteed capacity.

## Model pin check

- Time: 2026-10-10 17:53:10 WIB.
- Request: one generateContent call whose user message was exactly ping.
- Model endpoint: gemini-3.1-flash-lite.
- HTTP: 200.
- Response modelVersion: gemini-3.1-flash-lite; pinned for R3.
- Temperature: omitted and accepted.
- Thinking: low accepted.
- Usage: 2 prompt tokens, 2 candidate/completion tokens, 123 thoughts/reasoning tokens, 127 total.
- Rate-limit headers: none returned.
- Authorization header and API key: not logged or recorded.

## Medulla condition-B calibration attempts

The private R3 bundle was built from Medulla snapshot
`01667b95454663848f193cd84e3fb055507035b0`. It retains 86 of 236 records and
omits the 150 oldest whole records (63.6% by record count). The final private
bundle SHA-256 is
`7d0567f74942613f6da04563e0883f7b2ab58a21f3b5187c3522657bf321715d`; its
included/omitted manifest and count-only preflight logs are retained outside
the repository. The B onboarding preflight was 169,271 tokens, within the
170,000-token onboarding cap.

No calibration completed and no `N` was set. Three private attempts used the
same pinned Medulla snapshot and frozen R3 inputs:

| Run | Time (WIB) | Outcome |
|---|---|---|
| `medulla-b-calibration-r3-01` | 2026-10-10 18:07:13–18:15:27 | Eight successful generations; then HTTP 503. Partial successful-response input usage: 1,393,404 tokens. |
| `medulla-b-calibration-r3-02` | 2026-10-10 18:17:04–18:17:13 | Initial onboarding count was 169,271; first generation returned HTTP 503. No generation usage. |
| `medulla-b-calibration-r3-03` | 2026-10-10 18:20:03–18:46:04 | Twenty-six successful generations; partial successful-response input usage: 5,317,452 tokens. One response omitted `thoughtsTokenCount`. The next countTokens estimate was 232,231, above the 230,000 per-request cap, so the runner stopped before sending that generation (`FREE_TIER_REQUEST_TOKEN_CAP`). |

These are incomplete calibration attempts, not task results or exact
tokens-to-competent measurements. The partial input sums are diagnostic only.
The raw request/response logs remain private with owner-only permissions. No
question grading, score, or calibrated `N` exists. R3's request-cap stop was
followed; any protocol or bundle change requires a separately frozen Gemini
revision. The local failed-attempt workspace is retained privately.

## Sources

- [Gemini 3.1 Flash-Lite model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite)
- [Gemini thinking controls](https://ai.google.dev/gemini-api/docs/thinking)
- [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
- [Gemini API pricing and Free Tier data use](https://ai.google.dev/gemini-api/docs/pricing)
