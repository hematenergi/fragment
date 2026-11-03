---
id: plan-21
title: "21 — use Fragment locally without changing the shared repository"
status: done
owner: hematenergi
last-verified: 2026-11-03
depends-on: []
---

# 21 — Local Fragment

**Goal.** Publish v0.7.0 with a local install that preserves the host repository's
tracked files and checks each handoff against a private, durable baseline.

## Scope

The owner authorized implementation through release on 2026-11-03. Work starts
from origin/main at 0341b55 in an isolated worktree; the original checkout has
two local commits, a divergent main and an unrelated output directory.
Decision 0005 already permits releases while the benchmark remains unscored.

## Work

- [x] Add an opt-in installer using .fragment/ and Git's local info/exclude.
- [x] Preserve existing project instructions and supply an explicit agent entry.
- [x] Reuse the canonical guard and context tools with private Git history.
- [x] Detect host changes, including staged, unstaged and untracked work, and
  save the next baseline only after a successful close.
- [x] Add regression tests and observe failure before implementing the feature.
- [x] Document adoption, backup, worktree limits, removal and release changes.
- [x] Pass local tests, ShellCheck, the docs guard, secret checks and all CI OSes.
  Local validation passed: 168 suite checks and 24 focused local-mode cases,
  including a run with CI environment variables set. All five PR checks passed
  on final head 16fd5de, including Ubuntu, macOS and Windows.
- [x] Merge and publish v0.7.0, then verify release and website publication.
  PR #24 merged as e74f107644ae7327bf60b338e50725a3b8bd8ca0. The annotated
  v0.7.0 tag and published release point at that identical tested tree. Pages
  run 41603377364 succeeded; the live site serves v0.7.0 and local guidance.

## Design boundaries

Use Bash, Git and existing POSIX utilities. The context directory is an independent
local Git repository; it has no remote and never pushes. Host source differences
are hashed into a snapshot, not copied into context. A successful close commits
the local context so an old handoff cannot satisfy the next changed snapshot.
Project instructions retain authority; local adoption never changes front doors
or CI in the host repo. Manual entry is explicit, not an auto-discovery promise.
No global hooks, cloud sync, dashboard, benchmark changes or performance claims.

## Validation

```bash
bash tests/local-mode.sh
bash tests/run.sh
bash scripts/docs-check.sh
git diff --check
```

```text
Before implementation: local dry-run regression FAIL (unknown --local target).
Inherited-index regression: FAIL before the Git environment rejection.
tests/run.sh: GREEN — 168 tests passed.
tests/local-mode.sh: GREEN — 24 cases, including CI environment simulation.
ShellCheck -S warning: PASS.
docs-check.sh: GREEN.
gitleaks dir --no-banner --redact .: no leaks found.
git diff --check: PASS.
Final PR head 16fd5de: docs-check, secrets, Ubuntu, macOS and Windows PASS.
Merged tree e74f107 equals the tested tree byte-for-byte.
Published tag files: installer, local helpers and canonical guard match checkout.
GitHub release v0.7.0: published, not draft or prerelease.
Pages run 41603377364: SUCCESS; live website HTTP 200, v0.7.0 and local link present.
```

## Session log

- 2026-11-03 · GPT-6 / Codex · merged PR #24 after all five checks passed, published v0.7.0 and verified the tag files and live website · next: benchmark remains unscored; no adopter repositories were upgraded.
- 2026-11-03 · GPT-6 / Codex · observed a configured-hook bypass regression, removed hook/signing overrides and retained the host author identity for local history · next: repeat validation and rerun the release PR checks.
- 2026-11-03 · GPT-6 / Codex · local suite, 23 focused cases, CI-environment simulation, ShellCheck, docs guard and secret scan pass · next: open the release PR, wait for OS checks and publish.
- 2026-11-03 · GPT-6 / Codex · implemented local install, canonical guard reuse and private close history; initial suite passed 168 checks and 22 local cases; observed and fixed inherited-index isolation failure · next: final checks, cross-platform CI and publication.
- 2026-11-03 · GPT-6 / Codex · opened the owner-authorized local-mode release from current remote state · next: regressions, implementation and publication.
