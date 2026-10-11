---
id: plan-18
title: "18 — make STATE pruning automatic and budget-driven"
status: in-progress
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

`state-prune.sh` is opt-in, keeps the first N records in the final section, and has no size threshold. `docs-check.sh` does not invoke it. v0.6.0 `--upgrade` replaces only a recognized guard and leaves other helper scripts untouched.

## Work

- [x] Add regression coverage for automatic trigger, no-op, date ordering, guard failure, inventory and CI behavior.
- [x] Make pruning budget-driven and select records by actual ISO date, preserving original order among records kept.
- [x] Invoke pruning automatically after a successful local guard run; skip CI, inventory and failed checks.
- [x] Upgrade only a recognized unmodified pruning helper; add it when absent and preserve customized copies.
- [x] Document the lifecycle and prepare the v0.6.1 changelog entry and correct installer fingerprints.

## Done when

- [ ] A successful local `docs-check.sh` run archives the oldest dated records only when STATE exceeds 12,000 UTF-8 bytes.
- [ ] The hot STATE remains at or below the bound when removable dated history can bring it under; otherwise no source file changes and the guard reports why.
- [ ] Each record remains in the archive, and STATE contains a working Markdown link to it.
- [ ] `--inventory`, CI comparisons, and a failed guard do not mutate adopter files.
- [ ] A v0.6.0 install can safely receive the new guard and helper while local customizations stay untouched.
- [ ] The full repository suite, cross-platform CI, docs guard and release workflow pass on the published v0.6.1 commit.

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
found no leaks. Cross-platform CI and publication remain pending.

## Out of scope

Changing the frozen benchmark or its results, scoring document-link importance, or deleting archived history.

## Session log

- 2026-10-11 · GPT-6 / Codex · 18 · implemented automatic 12,000-byte STATE pruning with a linked, recoverable archive; 167 tests, ShellCheck, docs guard and Gitleaks pass on macOS · next: open PR, wait for all OS checks, then publish v0.6.1.
