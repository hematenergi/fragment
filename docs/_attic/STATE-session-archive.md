# Archived STATE session history

<!-- session-record:2250681504 348 -->
- 2026-10-09 · GPT-6 / Codex · 08 · macOS CI exposed a flaky `grep -q`/`pipefail` test helper that could report a broken pipe despite a match; changed it to drain the output, and the full local suite (147 tests) plus docs guard now pass · next: confirm CI on the fix before merging; benchmark plan 07 still awaits an authorized model API path.

<!-- session-record:1014457721 301 -->
- 2026-10-09 · GPT-6 / Codex · 08 · Windows CI now passes the verified junction/file-link safety tests and the full 147-test suite; Ubuntu, macOS, docs guard, and secrets checks also pass on `07c9831` · next: merge the v0.6 feature PR; benchmark plan 07 still awaits an authorized model API path.

<!-- session-record:3570272620 418 -->
- 2026-10-09 · GPT-6 / Codex · 08 · Windows CI showed the old `ln -s` fixture created a plain directory, not a junction; fixtures now assert the Windows reparse-point attribute, and the early safety step covers recall, pruning, and loading while product checks remain Bash/Git-only · next: confirm the Bash/Git checks reject the verified junction and file link on Windows; benchmark still awaits model API access.

<!-- session-record:2090009403 236 -->
- 2026-10-09 · GPT-6 / Codex · 08 · committed v0.6 context features and supporting docs as `ee9feff`; 147 repository tests and the docs guard pass · next: resume benchmark plan 07 §7.3 when a supported model API path is available.

<!-- session-record:862196761 274 -->
- 2026-10-08 · GPT-6 / Codex · 07 · rechecked official GPT-5.4 Mini snapshot, retirement, parameter and price docs; $20 is not a safe cap for 60 runs at preliminary N · next: authorized API path for §7.3 runtime verification and dry run; spec and prompt remain frozen.

<!-- session-record:1682967818 190 -->
- 2026-10-08 · GPT-6 / Codex · 06 · completed pre-run preparation; no scored result was produced · next: keep detailed evaluation work in local notes until a result is ready to publish.

<!-- session-record:1145669839 374 -->
- 2026-10-08 · GPT-6 / Codex · 07 · opened v0.6 baseline work, cloned Draupnir at `4e949ddd57ad0f9d590c1080bed174f5a0451c34`, and started its pinned-container validation; verified the current goal's order conflicts with frozen §7 and condition C references not-yet-built features · next: finish container tests, then resolve the baseline definition before scored runs.

<!-- session-record:653290360 289 -->
- 2026-10-08 · GPT-6 / Codex · 07 · reread the owner's amended spec: baseline C is v0.5.0 and validation C is v0.6; removed premature Draupnir scratch clone/image and excluded its exploratory test · next: write medulla questions per §7.2, then pin model and container before dry run.

<!-- session-record:1852891264 266 -->
- 2026-10-08 · GPT-6 / Codex · 07 · drafted the private medulla question/key/rubric/task set against committed snapshot `01667b95454663848f193cd84e3fb055507035b0`; no model calls or runs · next: model/API verification and final container setup per frozen §7.3.

<!-- session-record:974041657 284 -->
- 2026-10-08 · GPT-6 / Codex · 07 · defined and built the private shared Node 22/24 Linux image; clean Medulla Git clone at snapshot `01667b95454663848f193cd84e3fb055507035b0` passed npm ci and npm test, 1,304 unit + 369 integration · next: model/API verification before dry run.

<!-- session-record:3309119011 142 -->
- 2026-10-08 · GPT-6 / Codex · 07 · Fragment docs-check GREEN after the progress update · next: model/API verification and dry run setup.

<!-- session-record:2348004286 241 -->
- 2026-10-08 · GPT-6 / Codex · 07 · owner accepted the candidate's no-announced-shutdown status; API key unavailable, so endpoint verification and dry run remain pending · next: resume §7.3 when a supported local API path is available.

<!-- session-record:1423159436 263 -->
- 2026-10-08 · GPT-6 / Codex · 08 · owner chose develop-first; parked benchmark plan 07 without changing its protocol or using results, and started the three v0.6 context features · next: implement deterministic `/recall` with tagged decision/lesson records.

<!-- session-record:2699192092 218 -->
- 2026-10-08 · GPT-6 / Codex · 08 · implemented deterministic retrieval, safe STATE history archival and bounded context loading; focused tests pass · next: record the full repository suite and docs guard results.

<!-- session-record:1694337928 242 -->
- 2026-10-08 · GPT-6 / Codex · 08 · closed symlink path escapes in retrieval, archival, and loading; 147 tests, shellcheck, and docs guard pass · next: resume benchmark plan 07 when authorized API access is available; no run data exists.

<!-- session-record:3577360024 187 -->
- 2026-09-22 · claude-opus-5 · — · secrets CI job + template: `pull-requests: read` so gitleaks passes on PRs (403 before); CHANGELOG Unreleased · next: include in the next release

<!-- session-record:241133736 308 -->
- 2026-09-09 · GPT-6 / Codex · 05 · packaged 0.5.0 with consistent version stamps, an immutable upgrade fingerprint and migration notes; 138 release tests and the local guard passed before the owner-authorised push/release · next: verify publication and GitHub checks; adopter migration is not included.

<!-- session-record:524271858 340 -->
- 2026-09-09 · GPT-6 / Codex · 05 · completed the continuity proposal with 138 passing tests; an isolated adopter checkout moved from 122 warnings to a quiet daily result, while inventory retained the clues · next: review the unreleased implementation and protocol migration; no adopter files or public release changed in this session.

<!-- session-record:3208527438 279 -->
- `2026-09-09` · codex · 01 · released 0.4.0 with `install.sh --upgrade`; an
  unmodified guard from a known earlier Fragment release upgrades in one
  command, while customisations are retained and named · **Next:** owner
  decides the warning-triage design in fragment 02.

<!-- session-record:2176461750 203 -->
- `2026-09-09` · codex · 01 · started the installer-upgrade fragment; chose an
  explicit, non-destructive `--upgrade` path · **Next:** implement its guarded
  file replacement and regression tests.

<!-- session-record:3432548365 343 -->
- `2026-09-09` · claude-opus-5 · — · 0.3.0 tagged and released on a green build.
  `Unreleased` was folded into it rather than cut as 0.3.1: 0.3.0 had never been
  tagged, so nothing in it had ever reached anyone, and describing the staleness
  correction as a fix to a shipped release would have invented one · **Next:**
  fragment 01.

<!-- session-record:4110845806 472 -->
- `2026-09-09` · claude-opus-5 · — · Fragment now uses Fragment: Core plus the fragment
  workflow installed into its own root, with the four open items written up as
  a real queue. The first run of the shipped workflow immediately found
  something — gitleaks flags the suite's deliberate fake credentials, so
  `.gitleaks.toml` exempts `tests/run.sh` and the template now warns adopters
  who test a secret detector · **Next:** owner decides release vs. queue.

<!-- session-record:913610759 363 -->
- `2026-09-09` · claude-opus-5 · — · Staleness was measuring whether a file had been
  touched, not whether anyone had looked. One mechanical commit reset every
  fragment's clock, so the 0.3.0 warning never fired once in the only repo using
  it. Now reads `last-verified` and needs no git · **Next:** none; 03 will
  revisit how loudly that field speaks.

<!-- session-record:4105069211 324 -->
- `2026-09-09` · claude-opus-5 · — · `main` had been red since `266f08c` and 0.2.0 was
  tagged on top of it: one unquoted `done` in a `for` list, SC1010. shellcheck
  ran only in CI, so nothing local could catch it; the suite runs it now, and
  skips visibly when it is absent · **Next:** the staleness defect above.

