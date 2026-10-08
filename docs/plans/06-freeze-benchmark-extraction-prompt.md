---
id: plan-06
title: "06 — freeze the benchmark extraction prompt"
status: in-progress
owner: hematenergi
last-verified: 2026-10-08
depends-on: []
---

# 06 — freeze the benchmark extraction prompt

**Goal.** Commit and push the frozen Draupnir extraction prompt before any benchmark questions are written.

## Why this is needed

The benchmark protocol uses the prompt to extract the Draupnir knowledge base. The prompt's commit order is evidence that it predates the questions, so the exact reviewed contents must be committed and pushed first.

## Read first

- `../../bench/extract-prompt.md` — the frozen extraction prompt
- `../../FragmentBenchmarkSpec.md:104` — benchmark execution order and prompt commit requirement

## Current state

`bench/extract-prompt.md` is untracked. It is the only file under `bench/`; no benchmark question files have been written.

## Work

- [ ] Commit the reviewed prompt contents before writing any benchmark questions.
- [ ] Push the prompt commit to `origin/main`.
- [ ] Verify the remote contains that commit and record its SHA in the handoff.

## Done when

- [ ] The exact prompt is present on `origin/main` in a verified commit.
- [ ] The prompt commit SHA is recorded for the next benchmark step.

## Traps

Do not change the frozen prompt or benchmark spec in this fragment. Do not write quiz questions before the prompt commit is verified on the remote.

## Validation

```bash
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
rtk git ls-remote origin refs/heads/main
```

## Out of scope

Cloning Draupnir, pinning a model, writing medulla or Draupnir questions, and running the benchmark.

## Session log
