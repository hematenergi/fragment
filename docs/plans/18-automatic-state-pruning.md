---
id: plan-18
title: "18 — make STATE pruning automatic and budget-driven"
status: done
owner: hematenergi
last-verified: 2026-10-11
depends-on: [08]
---

# 18 — make STATE pruning automatic and budget-driven

**One-sentence goal.** A successful local Fragment check keeps hot STATE within a fixed context budget and archives older session history without a manual prune step.

## Why this is needed

v0.6.0 shipped a manual preview/apply tool, but adopters can forget to run it and their hot STATE can keep growing. The existing implementation also trusts file order, which can archive newer entries when dates are out of order. Fragment should make the decision during its normal local close check, preserve every archived record, and keep the cold archive reachable through an explicit Markdown link.

## Read first

- `../decisions/0008-automatic-state-pruning.md` — trigger and safety rules
- `../../template/scripts/docs-check.sh` — local close check
- `../../template/scripts/state-prune.sh` — archive implementation
- `../../install.sh` — safe upgrade path for the helper

## Current state

v0.6.1 shipped the automatic budget trigger, date-ordered archive selection,
linked cold history, and safe helper-upgrade path described in decision 0008.

## Work

- [x] Add regression coverage for automatic trigger, no-op, date ordering, guard failure, inventory and CI behavior.
- [x] Make pruning budget-driven and select records by actual ISO date, preserving original order among records kept.
- [x] Invoke pruning automatically after a successful local guard run; skip CI, inventory and failed checks.
- [x] Upgrade only a recognized unmodified pruning helper; add it when absent and preserve customized copies.
- [x] Document the lifecycle and prepare the v0.6.1 changelog entry and correct installer fingerprints.

## Done when

- [x] A successful local `docs-check.sh` run archives the oldest dated records only when STATE exceeds 12,000 UTF-8 bytes.
- [x] The hot STATE remains at or below the bound when removable dated history can bring it under; otherwise no source file changes and the guard reports why.
- [x] Each record remains in the archive, and STATE contains a working Markdown link to it.
- [x] `--inventory`, CI comparisons, and a failed guard do not mutate adopter files.
- [x] A v0.6.0 install can safely receive the new guard and helper while local customizations stay untouched.
- [x] The full repository suite, cross-platform CI, docs guard and release workflow pass on the published v0.6.1 commit.

## Traps

- The decision trigger is the explicit byte budget, not document age or graph degree. Obsidian Graph View renders explicit Markdown links; it is not an importance score. The generated STATE-to-archive link keeps cold history connected and discoverable.
- Do not treat automatic archival as session evidence. Run it only after the normal guard has passed its handoff checks.
- Do not overwrite a customized pruning helper during upgrade.

## Validation

```bash
rtk bash tests/state-prune.sh
rtk bash tests/run.sh
rtk bash scripts/docs-check.sh
rtk git diff --check
```

Local validation on macOS (2026-10-11): `bash tests/run.sh` passed all 167
tests; ShellCheck passed; `bash scripts/docs-check.sh` was green; and Gitleaks
found no leaks. PR #20 passed Ubuntu, macOS and Windows tests, docs-check and
secrets. GitHub release v0.6.1 and Pages deploy succeeded.

## Out of scope

Changing the frozen benchmark or its results, scoring document-link importance, or deleting archived history.

## Session log

- 2026-10-11 · GPT-6 / Codex · 18 · PR #20 merged; v0.6.1 released, Pages deployed, and all five PR checks passed · next: resume benchmark measurement separately.
- 2026-10-11 · GPT-6 / Codex · 18 · implemented automatic 12,000-byte STATE pruning with a linked, recoverable archive; 167 tests, ShellCheck, docs guard and Gitleaks pass on macOS · next: open PR, wait for all OS checks, then publish v0.6.1.
