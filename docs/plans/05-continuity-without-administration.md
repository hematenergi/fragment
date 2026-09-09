---
id: plan-05
title: "05 — continuity without an administrative backlog"
status: done
owner: hematenergi
last-verified: 2026-09-09
depends-on: []
---

# 05 — continuity without an administrative backlog

**Fragment repo · GPT-6 / Codex · fragment 05.** Adapted from the owner's
flimapp fragment 19 proposal, delivered here for implementation. Private daily
contents and machine-specific paths do not belong in the shared implementation.

## Goal and evidence

The mature adopter's 122 warnings comprise 121 commit/review date differences
and one protocol length hint. Neither establishes that its session is unfinished.
Dates are inventory clues; decisions require relevant evidence when used.

## Work and acceptance

- [x] Move historical dates and length hints to opt-in `--inventory`, outside
  the warning budget; stop the unconditional closing question.
- [x] Check core, open work, changed documents and explicitly selected contracts;
  retain structural failures there without requiring migration of old history.
- [x] Check code and docs changes locally (staged, unstaged, new files) and in
  an explicit CI range. Invalid bases fail; no history states the evidence limit.
- [x] Allow explicit Git path scope and exclusions for parallel/generated work;
  do not infer ownership or recursively activate an entire index.
- [x] Reject metadata-only / separator-only handoff edits; accept meaningful
  body edits in the project's language and selected local destinations.
- [x] Document source authority, rotating daily selection, permissions, partial
  writes, retries and portable decisions as agent responsibilities.
- [x] Keep adopted customisations safe and document the migration.
- [x] Prove structural contradictions, done evidence and secrets still fail;
  test the mature-adopter pattern, nonstandard paths and a repo with no work.

## Validation

```bash
bash tests/run.sh                 # GREEN — 138 tests passed
bash scripts/docs-check.sh        # GREEN — checked workflow structure; handoff body updated
shellcheck -S warning install.sh template/scripts/docs-check.sh tests/run.sh tests/continuity.sh
git diff --check                  # exit 0
```

The regression suite was first run against the original guard: 25 failures
demonstrated the missing behaviour (90 existing/passing assertions). The
implementation passed 138 checks including the optional-template upgrade
regression. A full isolated clone of the real adopter showed
the original `GREEN (122 warning(s))` and unconditional question; after swapping
only the clone's guard and establishing its test baseline, the daily command
returned `GREEN — checked workflow structure; no changes in the checked range`.
The actual adopter worktree was not changed. The synthetic mature-adopter case
also asserts that inventory retains exactly 121 date discrepancies plus one
protocol-size clue, outside a zero-warning budget.

Scenario review for agent responsibilities is recorded in `../continuity.md`:
explicit/configured daily selection, authoritative open carry-over, partial
destination writes, latest-state reads before retry, permissions and portable
decisions. These are agent workflow instructions, not a claim of live connector
testing or an implemented sync engine. The guard's multi-destination, external
path rejection and body-evidence behaviours are executable regressions.

The role map may reuse one existing file via STATE_FILE / PROTOCOL_FILE /
INDEX_FILE; a regression covers this without introducing dummy tasks or moving
old documents. A disposable target using the actual tagged guard was upgraded
successfully while its custom protocol stayed byte-for-byte intact.

Runtime remains bash, git and standard shell utilities. No synchronisation
engine, private-note crawler, semantic Markdown parser or per-document manifest.
An explicit source map in the existing protocol supplies authority; checkout
checks cannot certify external writes or truth of prose.

## Session log

- 2026-09-09 · GPT-6 / Codex · 05 · prepared release 0.5.0 at the owner's request, including migration guidance, matching stamps and the next-release upgrade regression; all 138 release tests and the local guard passed · next: publish the verified tag as Latest and inspect CI; the real adopter remains unchanged.
- 2026-09-09 · GPT-6 / Codex · 05 · implemented inventory, scoped checkout evidence, reusable source roles and upgrade without optional-file backlogs; 138 tests and adopter-clone comparison passed · next: review the unreleased change and migrate user-owned protocols deliberately before rollout.
