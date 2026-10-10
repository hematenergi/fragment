---
id: state
title: STATE — where the work stands
status: active
owner: hematenergi
last-verified: 2026-10-10
---

# STATE

**Read this first, write it last.** The only place that answers "where are we?".

---

## Phase

**v0.6.0 is the latest release.** Release PR #5 merged as
`25e7dfd37d8d9e2c113773245c71c32261db5787`; the `v0.6.0` tag points to that
commit and the GitHub release is published. Its notes disclose that the Gemini
R4 Medulla calibration stopped after 11 successful responses at the Free Tier
daily request cap; the quiz and task did not finish, so there is no valid score,
`N`, or performance claim. Benchmark numbers can follow separately.

## Active fragment

**Fragment 16 is in progress:** adding one original illustration to the
homepage and canonical skill source. See
[plan 16](plans/16-fragment-site-illustration.md). Fragment 15 is complete: PR #14 merged as
`b3439c981261875f648e6628fa7d21d472da49f6`, restoring the single `fragment`
skills CLI slug and adding a direct homepage install CTA. The skills CLI listed
one skill with telemetry disabled, the live skills.sh detail page opens, and
Pages deploy `38066187505` plus the live homepage check succeeded. Local tests
and docs guard passed; required CI checks passed, while the Windows run was still
in progress after merge. Fragment 14 is complete: public pages retain Fragment's
skills.sh presence. PR #12 is merged and the live homepage and README were
verified.
Fragment 13's source-link correction remains valid; its removal of the skills.sh
link was reversed at the owner's request. Skills.sh ranks skills from anonymous
install telemetry; no synthetic installs were created. Fragment 12 completed the
repo-side package and presence work. Fragment 11 is complete: the homepage and
GitHub README show the observed v0.5.0 adoption in medulla and flimapp, with its
limits. Fragment 10 is complete and v0.6.0 remains the latest release. Benchmark
plan 07 is parked until Free Tier quota is available; plan 04 awaits the owner's
decision.

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
| 10 | [publish v0.6.0 with benchmark pending](plans/10-v06-release-before-benchmark.md) | `done` | — |
| 11 | [put production evidence on the public site and README](plans/11-site-production-evidence.md) | `done` | 10 |
| 12 | [complete Fragment's public install presence](plans/12-public-presence.md) | `done` | — |
| 13 | [replace the unavailable skills.sh link](plans/13-fix-skills-catalog-links.md) | `done` | — |
| 14 | [keep Fragment discoverable on skills.sh](plans/14-restore-skills-presence.md) | `done` | — |
| 15 | [restore the skills.sh Fragment slug](plans/15-restore-skills-sh-fragment-slug.md) | `done` | — |
| 16 | [add an original illustration to Fragment's public install surfaces](plans/16-fragment-site-illustration.md) | `in-progress` | — |

## Blocked / waiting on a human

| What | Waiting on | Since |
|---|---|---|
| Whether version-bump automation (04) is wanted | owner | 2026-09-09 |
| Gemini benchmark follow-up (07) | R4 stopped after 11 successful responses at the Free Tier daily cap; owner chose a free-tier R3 rerun when quota is available | 2026-10-10 |

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
- **v0.6.0 may ship before benchmark completion.** See
  [decision 0005](decisions/0005-release-v06-with-benchmark-pending.md). Do not
  present the incomplete R4 calibration as a score or performance claim.

---

## Session log

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

- 2026-10-10 · GPT-6 / Codex · 16 · generated a 1536×1024 illustration, integrated it into the responsive homepage and canonical skill source, and confirmed the mobile preview · next: run repository validation and verify the live pages after publication.
- 2026-10-10 · GPT-6 / Codex · 15 · merged PR #14 as `b3439c9`; Pages run `38066187505` succeeded; live detail page and homepage verified; CLI listed one `fragment` with telemetry disabled; 150 tests, docs guard, and required CI checks passed (Windows run still in progress) · next: resume parked benchmark plan 07 when Free Tier quota is available.
- 2026-10-10 · GPT-6 / Codex · 15 · renamed the canonical CLI skill to `fragment`, aligned install surfaces and hero CTA, and passed all 150 tests plus docs guard · next: publish, confirm the CLI sees one `fragment` skill, then inspect the live page.
- 2026-10-10 · GPT-6 / Codex · 15 · restoring the canonical skills CLI skill slug to `fragment`, linking directly to its skills.sh detail page, and keeping plugin package IDs intact per owner direction · next: validate CLI discovery, tests, docs guard, then publish and inspect the live detail page.

- 2026-10-10 · GPT-6 / Codex · 14 · merged PR #12 (`2b1f068`), Pages deploy `38065113487` succeeded, and live homepage plus GitHub README show the restored skills.sh link and stale-catalog note · next: resume parked benchmark plan 07 when Free Tier quota is available.
- 2026-10-10 · GPT-6 / Codex · 14 · restored the skills.sh repository link and current install/source guidance across README, INSTALL.md, and homepage; reviewed the live all-time top ten and official telemetry rules; local validation passed · next: publish the link restoration and verify the live homepage.
- 2026-10-10 · GPT-6 / Codex · 13 · merged PR #10 (`b8e6f38`), Pages deploy `38063624357` succeeded, live homepage HTTP 200 contains the raw GitHub skill link and no stale skills.sh link, and the source file returns HTTP 200; local suite (150 tests) and docs guard passed · next: resume parked benchmark plan 07 when Free Tier quota is available.
- 2026-10-10 · GPT-6 / Codex · 13 · replaced README, INSTALL.md, and homepage links with the GitHub skill source; corrected the prior HTTP-only verification; local suite passed 150 tests and docs-check passed · next: publish and verify the deployed links.
- 2026-10-10 · GPT-6 / Codex · 13 · found the skills.sh detail URL returned HTTP 200 with an application-level 404 and that search/catalog pages still show stale data; correcting public links to point to the canonical GitHub skill source · next: verify local docs and site, then publish the link correction.
- 2026-10-10 · GPT-6 / Codex · 12 · merged PR #8 (`95033e6`); all five CI checks passed, the single canonical skill and direct install page verified, and public metadata updated; recorded that skills.sh still serves the removed legacy slug and does not document a repo-side cleanup control · next: resume parked benchmark plan 07 when Free Tier quota is available.

- 2026-10-10 · GPT-6 / Codex · 12 · closed superseded draft PR #4 after v0.6.0 shipped separately in PR #5; confirmed its Gemini benchmark work remains unscored and its branch is preserved; identified the duplicated `/fragment/fragment` skills.sh path · next: publish the distinct `adopt-fragment` skill and complete verified agent install surfaces.
- 2026-10-10 · GPT-6 / Codex · 11 · merged PR #6 as `7ec46f0`; all five checks passed, Pages deploy run `38058193388` succeeded, the live homepage returned HTTP 200, and the README on `main` is 93 lines · next: resume benchmark plan 07 when Free Tier quota is available; plan 04 awaits the owner.
- 2026-10-10 · GPT-6 / Codex · 11 · added source-backed v0.5.0 production evidence to the homepage and README, shortened README from 492 to 93 lines, and passed local preview (HTTP 200), 148 tests, and docs guard · next: publish both updates and verify the live homepage.
- 2026-10-10 · GPT-6 / Codex · 11 · verified v0.6.0 is live as the latest release and found the homepage still omitted the two-repo v0.5.0 adoption evidence · next: add it to the homepage and README.
- 2026-10-10 · GPT-6 / Codex · 10 · prepared the v0.6.0 release candidate from merged feature PR #2, updated version references and the new guard fingerprint, and documented the incomplete Gemini benchmark without a performance claim · next: pass local and PR checks, merge, tag, and publish v0.6.0; benchmark numbers follow separately.

- 2026-10-10 · GPT-6 / Codex · 08 · merged the v0.6 context features via PR #2 (`5f13f7b`); commit `4ea6587` passed Windows, macOS, Ubuntu, docs guard, and secrets checks, and local tests pass (147) · next: resume benchmark plan 07 §7.3 when an authorized model API path is available.
- 2026-10-09 · GPT-6 / Codex · 08 · macOS CI exposed a flaky `grep -q`/`pipefail` test helper that could report a broken pipe despite a match; changed it to drain the output, and the full local suite (147 tests) plus docs guard now pass · next: confirm CI on the fix before merging; benchmark plan 07 still awaits an authorized model API path.
- 2026-10-09 · GPT-6 / Codex · 08 · Windows CI now passes the verified junction/file-link safety tests and the full 147-test suite; Ubuntu, macOS, docs guard, and secrets checks also pass on `07c9831` · next: merge the v0.6 feature PR; benchmark plan 07 still awaits an authorized model API path.
- 2026-10-09 · GPT-6 / Codex · 08 · Windows CI showed the old `ln -s` fixture created a plain directory, not a junction; fixtures now assert the Windows reparse-point attribute, and the early safety step covers recall, pruning, and loading while product checks remain Bash/Git-only · next: confirm the Bash/Git checks reject the verified junction and file link on Windows; benchmark still awaits model API access.
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
