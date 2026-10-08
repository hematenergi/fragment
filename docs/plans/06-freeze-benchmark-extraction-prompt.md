---
id: plan-06
title: "06 — freeze the benchmark extraction prompt"
status: done
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

`bench/extract-prompt.md` was committed in `4582cec728a46aa9122005314fd923e17b937052`. At verification, remote `origin/main` pointed to that commit and its prompt blob matched the local blob (`8d78088a2ec78056edd1de7199fd7b29e21a1ec8`). No benchmark question files have been written.

## Work

- [x] Commit the reviewed prompt contents before writing any benchmark questions.
- [x] Push the prompt commit to `origin/main`.
- [x] Verify the remote contains that commit and record its SHA in the handoff.

## Done when

- [x] The exact prompt is present on `origin/main` in a verified commit.
- [x] The prompt commit SHA is recorded for the next benchmark step.

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

- 2026-10-08 · GPT-6 / Codex · 06 · committed and pushed the frozen prompt as `4582cec728a46aa9122005314fd923e17b937052`; remote prompt blob verified · next: follow frozen §7 while preserving the prompt's commit-before-questions rule; the user's summarized ordering differs from the current §7, so report before any sequence change.
