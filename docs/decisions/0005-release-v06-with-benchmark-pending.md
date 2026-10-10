---
id: decision-0005
title: Publish v0.6.0 before benchmark completion
status: active
owner: hematenergi
last-verified: 2026-10-10
---

# Publish v0.6.0 before benchmark completion

## Context

The v0.6 context features are merged and validated. Gemini R4's Medulla
calibration stopped after 11 successful responses at the Free Tier daily
request cap; the quiz and task did not complete, so no score or `N` exists.
The benchmark protocol originally made results a release gate.

## Decision

Publish v0.6.0 using the existing feature and test evidence. Benchmark numbers
may follow separately when the frozen protocol produces complete results.

## Why

The owner directed that the shipped features be released with the evidence
available rather than wait for the provider's daily quota. A truthful release
can disclose that the benchmark is incomplete without claiming a performance
improvement.

## Consequences

The release notes state that there is no completed benchmark score or
tokens-to-competent result, and disclose that Gemini Free Tier content may be
used by Google to improve its products. The incomplete calibration does not set
`N` and is not reported as a benchmark result. The frozen R4 protocol remains
unchanged; its results will be published separately.

## To change this

The owner can authorize a different release or benchmark policy. Any benchmark
protocol change still follows its own freeze and reporting rules.
