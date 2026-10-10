---
id: decision-0003
title: "0003 — develop v0.6 features before benchmark API spending"
status: superseded
superseded-by: decision 0004 — separate Gemini benchmark protocol
owner: hematenergi
last-verified: 2026-10-10
tags: [benchmark, sequencing, v0.6, api-access]
---

# 0003 — develop v0.6 features before benchmark API spending

**Decided** 2026-10-08.

## Context

The frozen benchmark needs a pinned model endpoint, but the owner has no API
key. The v0.6 product work can proceed without benchmark calls.

## Decision

Implement the three v0.6 context features before spending on model access or
running the benchmark. Park benchmark fragment 07 until feature work is done
and an authorized API path is available. Keep the benchmark spec and extraction
prompt unchanged; no benchmark results may inform implementation.

## Why

This keeps product work moving without inventing model access or borrowing
benchmark results that do not exist.

## Consequences

- Fragment 08 implements deterministic retrieval, STATE archival/pruning, and
  token-budgeted loading.
- Fragment 07 remains required. Its baseline uses documented v0.5.0 behavior;
  validation uses v0.6 behavior, as the frozen spec defines.
- No benchmark claim can be published until the required runs are completed.

## To change this

Provide an authorized model API path and choose a different sequencing.
