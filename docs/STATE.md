---
id: state
title: STATE — where the work stands
status: active
owner: hematenergi
last-verified: 2026-10-09
---

# STATE

**Read this first, write it last.** The only place that answers "where are we?".

---

## Phase

**v0.5.0 is released; v0.6 context features are implemented and validated.**
The extraction prompt is committed and pushed. The frozen benchmark protocol
still requires its baseline and v0.6 validation before release; no run data
exists, and benchmark work is parked until authorized API access is available.

## Active fragment

**No active fragment.** Fragment 08 is complete: deterministic `/recall`, tags,
STATE history pruning, and token-budgeted loading are implemented in the
template and this checkout; all 147 tests and the docs guard pass. Fragment 07
is parked pending authorized API access. Its medulla questions/key/task are
drafted privately against snapshot
`01667b95454663848f193cd84e3fb055507035b0`; the shared Linux/arm64 container is
built and a clean Medulla snapshot passes npm ci and npm test (1,304 unit + 369
integration). No benchmark run data exists; the benchmark protocol is unchanged.

> At most **one** active fragment. If something is here and it is not yours, ask
> before touching it.

## Queue — take from the top

| # | Fragment | Status | Blocked by |
|---|---|---|---|
| 01 | [install.sh cannot upgrade](plans/01-installer-cannot-upgrade.md) | `done` | — |
| 02 | [no way down from a warning pile](plans/02-no-way-down-from-a-warning-pile.md) | `superseded` | replaced by 05 |
| 03 | [last-verified is the loudest rule](plans/03-last-verified-is-the-loudest-rule.md) | `superseded` | replaced by 05 |
| 04 | [version written by hand](plans/04-version-written-by-hand.md) | `todo` | — |
| 05 | [continuity without administration](plans/05-continuity-without-administration.md) | `done` | — |
| 06 | [freeze the benchmark extraction prompt](plans/06-freeze-benchmark-extraction-prompt.md) | `done` | — |
| 07 | [establish the v0.6 benchmark baseline](plans/07-v06-benchmark-baseline.md) | `parked` | resume after plan 08 and API access; no run data exists |
| 08 | [ship the v0.6 context features](plans/08-v06-context-features.md) | `done` | — |

## Blocked / waiting on a human

| What | Waiting on | Since |
|---|---|---|
| Whether version-bump automation (04) is wanted | owner | 2026-09-09 |
| Benchmark API access (07) | owner — no authorized API key/path is available; current model docs are verified but runtime access is still required | 2026-10-08 |

## Decisions already made — do not ask again

- **The guard has exactly one canonical copy**, `template/scripts/docs-check.sh`.
  `scripts/` and `examples/online-shop/scripts/` vendor it byte-identically, and
  a test asserts each. Do not propose a symlink; Windows checkouts do not
  reliably get one, and the whole point is that a Windows teammate can run it.
- **Fragment installs Fragment at the Core plus fragment-workflow tiers only.**
  No non-engineer layer, no runbooks, no research — everyone working here reads
  code and the repository operates nothing. That is the README's own advice,
  followed rather than quoted.
- **Dates and size are inventory; session evidence is scoped.** See
  [decision 0002](decisions/0002-continuity-evidence-and-inventory.md). Source
  authority and update destinations live in the existing protocol; an external
  daily is optional and CI cannot certify a write it did not observe.

---

## Session log

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

- 2026-10-09 · GPT-6 / Codex · 08 · Windows CI showed Git Bash junctions also bypass logical/physical `pwd` checks; added Git-prefix path validation and an early Windows path-safety step; local suite 147 and docs guard pass · next: verify focused and full Windows CI; benchmark still awaits model API access.
- 2026-10-09 · GPT-6 / Codex · 08 · committed v0.6 context features and supporting docs as `ee9feff`; 147 repository tests and the docs guard pass · next: resume benchmark plan 07 §7.3 when a supported model API path is available.
- 2026-10-08 · GPT-6 / Codex · 07 · rechecked official GPT-5.4 Mini snapshot, retirement, parameter and price docs; $20 is not a safe cap for 60 runs at preliminary N · next: authorized API path for §7.3 runtime verification and dry run; spec and prompt remain frozen.
- 2026-10-08 · GPT-6 / Codex · 06 · committed and pushed `bench/extract-prompt.md` as `4582cec728a46aa9122005314fd923e17b937052`; remote prompt blob matched · next: follow frozen §7; its current order differs from the user's summary, so report the discrepancy before changing sequence.
- 2026-10-08 · GPT-6 / Codex · 07 · opened v0.6 baseline work, cloned Draupnir at `4e949ddd57ad0f9d590c1080bed174f5a0451c34`, and started its pinned-container validation; verified the current goal's order conflicts with frozen §7 and condition C references not-yet-built features · next: finish container tests, then resolve the baseline definition before scored runs.
- 2026-10-08 · GPT-6 / Codex · 07 · reread the owner's amended spec: baseline C is v0.5.0 and validation C is v0.6; removed premature Draupnir scratch clone/image and excluded its exploratory test · next: write medulla questions per §7.2, then pin model and container before dry run.
- 2026-10-08 · GPT-6 / Codex · 07 · drafted the private medulla question/key/rubric/task set against committed snapshot `01667b95454663848f193cd84e3fb055507035b0`; no model calls or runs · next: model/API verification and final container setup per frozen §7.3.
- 2026-10-08 · GPT-6 / Codex · 07 · defined and built the private shared Node 22/24 Linux image; clean Medulla Git clone at snapshot `01667b95454663848f193cd84e3fb055507035b0` passed npm ci and npm test, 1,304 unit + 369 integration · next: model/API verification before dry run.
- 2026-10-08 · GPT-6 / Codex · 07 · Fragment docs-check GREEN after the progress update · next: model/API verification and dry run setup.
- 2026-10-08 · GPT-6 / Codex · 07 · owner accepted the candidate's no-announced-shutdown status; API key unavailable, so endpoint verification and dry run remain pending · next: resume §7.3 when a supported local API path is available.
- 2026-10-08 · GPT-6 / Codex · 08 · owner chose develop-first; parked benchmark plan 07 without changing its protocol or using results, and started the three v0.6 context features · next: implement deterministic `/recall` with tagged decision/lesson records.
- 2026-10-08 · GPT-6 / Codex · 08 · implemented deterministic retrieval, safe STATE history archival and bounded context loading; focused tests pass · next: record the full repository suite and docs guard results.
- 2026-10-08 · GPT-6 / Codex · 08 · closed symlink path escapes in retrieval, archival, and loading; 147 tests, shellcheck, and docs guard pass · next: resume benchmark plan 07 when authorized API access is available; no run data exists.

- 2026-09-22 · claude-opus-5 · — · secrets CI job + template: `pull-requests: read` so gitleaks passes on PRs (403 before); CHANGELOG Unreleased · next: include in the next release
- 2026-09-09 · GPT-6 / Codex · 05 · packaged 0.5.0 with consistent version stamps, an immutable upgrade fingerprint and migration notes; 138 release tests and the local guard passed before the owner-authorised push/release · next: verify publication and GitHub checks; adopter migration is not included.
- 2026-09-09 · GPT-6 / Codex · 05 · completed the continuity proposal with 138 passing tests; an isolated adopter checkout moved from 122 warnings to a quiet daily result, while inventory retained the clues · next: review the unreleased implementation and protocol migration; no adopter files or public release changed in this session.
- `2026-09-09` · codex · 01 · released 0.4.0 with `install.sh --upgrade`; an
  unmodified guard from a known earlier Fragment release upgrades in one
  command, while customisations are retained and named · **Next:** owner
  decides the warning-triage design in fragment 02.
- `2026-09-09` · codex · 01 · started the installer-upgrade fragment; chose an
  explicit, non-destructive `--upgrade` path · **Next:** implement its guarded
  file replacement and regression tests.
- `2026-09-09` · claude-opus-5 · — · 0.3.0 tagged and released on a green build.
  `Unreleased` was folded into it rather than cut as 0.3.1: 0.3.0 had never been
  tagged, so nothing in it had ever reached anyone, and describing the staleness
  correction as a fix to a shipped release would have invented one · **Next:**
  fragment 01.
- `2026-09-09` · claude-opus-5 · — · Fragment now uses Fragment: Core plus the fragment
  workflow installed into its own root, with the four open items written up as
  a real queue. The first run of the shipped workflow immediately found
  something — gitleaks flags the suite's deliberate fake credentials, so
  `.gitleaks.toml` exempts `tests/run.sh` and the template now warns adopters
  who test a secret detector · **Next:** owner decides release vs. queue.
- `2026-09-09` · claude-opus-5 · — · Staleness was measuring whether a file had been
  touched, not whether anyone had looked. One mechanical commit reset every
  fragment's clock, so the 0.3.0 warning never fired once in the only repo using
  it. Now reads `last-verified` and needs no git · **Next:** none; 03 will
  revisit how loudly that field speaks.
- `2026-09-09` · claude-opus-5 · — · `main` had been red since `266f08c` and 0.2.0 was
  tagged on top of it: one unquoted `done` in a `for` list, SC1010. shellcheck
  ran only in CI, so nothing local could catch it; the suite runs it now, and
  skips visibly when it is absent · **Next:** the staleness defect above.
