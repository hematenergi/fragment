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

- AI Studio showed the selected project as Free Tier during the prior check. Google's pricing page lists Gemini 3.8 Flash Free Tier input/output as free of charge and says Free Tier content may be used to improve Google products. Owner explicitly approved a separate Gemini benchmark after that disclosure.
- Reconfirm Free Tier and no billing before each phase. Do not send credentials or unrelated private material. Do not record API keys or authorization headers.
- Google's model card gives a March 2026 knowledge cutoff, with some domains possibly limited to January 2025. Use Draupnir source events after March 2026 for contamination-resistant questions.
- Official deprecations listed no shutdown date announced for Gemini 3.8 Flash on 2026-10-10; availability still needs a pre-validation check.

## Sources

- [Model page](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)
- [Model card](https://deepmind.google/models/model-cards/gemini-3-8-flash/)
- [Pricing and Free Tier data use](https://ai.google.dev/gemini-api/docs/pricing)
- [Deprecations](https://ai.google.dev/gemini-api/docs/deprecations)
- [Rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
