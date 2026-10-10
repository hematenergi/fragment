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

The Medulla candidate bundle was assembled locally from the verified snapshot and remains private. One count-only CLI invocation stopped locally because the parser did not yet allow the non-secret model-version setting; the log is empty and no API request was sent. No R3 countTokens preflight, condition-B calibration, or other repository-content request has been sent yet.

## Sources

- [Gemini 3.1 Flash-Lite model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite)
- [Gemini thinking controls](https://ai.google.dev/gemini-api/docs/thinking)
- [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
- [Gemini API pricing and Free Tier data use](https://ai.google.dev/gemini-api/docs/pricing)
