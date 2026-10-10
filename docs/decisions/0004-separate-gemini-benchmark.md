---
id: decision-0004
title: "0004 — use a separate Gemini benchmark protocol"
status: active
owner: hematenergi
last-verified: 2026-10-10
tags: [benchmark, gemini, v0.6, model]
---

# 0004 — use a separate Gemini benchmark protocol

**Decided** 2026-10-10.

## Context

The frozen benchmark protocol pins a GPT model, but the owner does not have access to that API. The configured Gemini Free Tier key can call Gemini 3.8 Flash, although requests have intermittently returned 503 or timed out. Google states Free Tier prompts may be used to improve its products.

## Decision

Run a **new, separate Gemini benchmark** using Gemini 3.8 Flash and a new protocol and extraction prompt. Keep the frozen GPT specification, prompt, and any future results separate. Use only the Free Tier; stop if billing is enabled or the project is no longer Free Tier. The owner authorized this choice after the data-use terms were disclosed.

## Why

It allows v0.6 measurement to proceed without API spend while preserving the original protocol as an unaltered record. Separate labels prevent model/provider differences from being mistaken for Fragment feature effects.

## Consequences

- `FragmentBenchmarkSpec-Gemini.md` and `bench/extract-prompt-gemini.md` define the new track.
- Gemini 3.8 Flash's stable alias has no dated immutable API snapshot in the verified metadata; capture response `modelVersion` for each call and disclose the limit.
- Free Tier content may be used by Google to improve products. Send only the benchmark inputs needed; never send secrets or local runtime credentials.
- This decision supersedes decision 0003 only on the question of whether benchmark work may resume with an explicitly authorized alternate provider. It does not change or unfreeze the original GPT protocol.

## To change this

The owner must authorize another provider/model or accept paid-tier billing. Any provider change requires a separate benchmark protocol and separate result set.
