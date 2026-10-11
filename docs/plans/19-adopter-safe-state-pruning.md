---
id: plan-19
title: "19 — make automatic STATE pruning work for adopters"
status: done
owner: hematenergi
last-verified: 2026-10-11
depends-on: [18]
---

# 19 — make automatic STATE pruning work for adopters

**One-sentence goal.** A successful local close keeps an adopter's STATE within budget without relying on the session log being its final section.

## Why this is needed

Fragment v0.6.1 failed on Medulla's 52,780-byte STATE because later handoff
sections hid dated entries from the pruner and closed plan rows remained in the
hot board. The full original text must remain recoverable while active work
stays visible.

## Read first

- `../decisions/0008-automatic-state-pruning.md` — shipped behavior
- `../decisions/0009-prune-state-across-sections.md` — corrected lifecycle
- `../../template/scripts/state-prune.sh` — canonical pruning helper
- `../../tests/state-prune.sh` — automatic pruning regression

## Current state

v0.6.2 fixes the multi-section history scan and archives terminal plan rows
only when their exact status matches linked plan frontmatter. The implementation
is released; the Medulla checkout remains unchanged.

## Work

- [x] Add an adopter-shaped regression for dated entries before later sections, terminal plan rows, and active or mismatched rows.
- [x] Archive dated history globally, then `done`/`superseded` and only then needed `parked` rows, preserving the newest dated entry when possible.
- [x] Keep all three pruning helper copies and installer checks in sync.
- [x] Document the deterministic rules and prepare a patch release.

## Done when

- [x] The adopter-shaped fixture stays at or below 12,000 bytes with archived content and working relative links preserved and active rows retained.
- [x] A disposable copy of Medulla's STATE reaches the byte budget without editing Medulla: 52,780 → 11,930 bytes.
- [x] Full tests, ShellCheck, docs guard, CI and the v0.6.2 release pass. PR #21 merged as `62b7402729a17d2f00cab58762afa67bd7dbe86a`; all five required checks passed, including Windows in 18m35s.

## Traps

- Never decide that a row is old from its prose. Only exact plan status plus matching linked frontmatter is eligible.
- Do not edit adopters' STATE files as part of this release.
- Keep the frozen benchmark and prompt files private and unchanged.

## Validation

```bash
bash tests/state-prune.sh
bash tests/run.sh
bash scripts/docs-check.sh
git diff --check
```

## Out of scope

The benchmark, manual edits to adopter repositories, and changes to the 12,000-byte budget.

## Session log

- 2026-10-11 · GPT-6 / Codex · 19 · merged PR #21 as `62b7402` and published [v0.6.2](https://github.com/hematenergi/fragment/releases/tag/v0.6.2); all five required checks passed, and disposable Medulla STATE reached 11,930 bytes without modifying Medulla · next: benchmark remains unscored.
