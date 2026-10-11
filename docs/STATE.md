---
id: state
title: STATE — where the work stands
status: active
owner: hematenergi
last-verified: 2026-10-11
---

# STATE

**Read this first, write it last.** The only place that answers "where are we?".

---

## Phase

**v0.6.2 is the latest published release** (`62b7402729a17d2f00cab58762afa67bd7dbe86a`).
It fixes adopter STATE pruning across sections and corroborated terminal plan
rows while retaining the 12,000-byte budget and linked history. Fragment 19 is
complete. The benchmark is still unscored; internal strategy and benchmark
working documents remain local and excluded from the public repo.

## Active fragment

**No fragment is active. Fragment 19 is complete:** PR #21 merged as
`62b7402729a17d2f00cab58762afa67bd7dbe86a`; v0.6.2 is published. The
adopter-shaped regression and disposable Medulla copy pass without modifying
Medulla; Ubuntu, macOS, Windows, docs-check, and secrets CI checks all passed.
See [plan 19](plans/19-adopter-safe-state-pruning.md). Fragment 18 is complete:
PR #20 merged as `e97dad758a523b3cffe5864472629e311027a282`; v0.6.1 is published
and its Pages deploy succeeded. See [plan 18](plans/18-automatic-state-pruning.md).
Fragment 17 is complete: PR #18 merged as
`ae5f20f2d23d1bf9095f29de87a36e426bc6f1cb`; the public copy updates are live,
and the internal research files are absent from the current tree. Docs-check,
secrets, and Ubuntu passed; macOS and Windows were still running after merge.
See [plan 17](plans/17-fragment-copy-audit.md). Fragment 16 is complete: PR #16 merged as
`d3ed8f0263793e17465d3dcd2c7b3d5e8175cffc`; the original illustration is live
on the homepage and linked from both identical skill copies. Ubuntu and macOS
each passed 150 tests, docs-check and secrets passed, and Pages deployed. The
skills.sh detail page still showed its previous cached body after refresh; the
raw skill source and image are current. See [plan 16](plans/16-fragment-site-illustration.md).
Fragment 15 is complete: PR #14 merged as
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
limits. Fragment 10 established v0.6.0 before benchmark completion. The
benchmark follow-up remains unscored; plan 04 awaits the owner's decision.

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
| 08 | [ship the v0.6 context features](plans/08-v06-context-features.md) | `done` | — |
| 10 | [publish v0.6.0 with benchmark pending](plans/10-v06-release-before-benchmark.md) | `done` | — |
| 11 | [put production evidence on the public site and README](plans/11-site-production-evidence.md) | `done` | 10 |
| 12 | [complete Fragment's public install presence](plans/12-public-presence.md) | `done` | — |
| 13 | [replace the unavailable skills.sh link](plans/13-fix-skills-catalog-links.md) | `done` | — |
| 14 | [keep Fragment discoverable on skills.sh](plans/14-restore-skills-presence.md) | `done` | — |
| 15 | [restore the skills.sh Fragment slug](plans/15-restore-skills-sh-fragment-slug.md) | `done` | — |
| 16 | [add an original illustration to Fragment's public install surfaces](plans/16-fragment-site-illustration.md) | `done` | — |
| 17 | [clarify Fragment's value across the docs](plans/17-fragment-copy-audit.md) | `done` | — |
| 18 | [make STATE pruning automatic and budget-driven](plans/18-automatic-state-pruning.md) | `done` | — |
| 19 | [make automatic STATE pruning work for adopters](plans/19-adopter-safe-state-pruning.md) | `done` | 18 |

## Blocked / waiting on a human

| What | Waiting on | Since |
|---|---|---|
| Whether version-bump automation (04) is wanted | owner | 2026-09-09 |

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
- **STATE history pruning runs automatically after a successful local guard check.**
  See [decision 0008](decisions/0008-automatic-state-pruning.md).
- **STATE pruning now spans sections and uses corroborated terminal plan rows.**
  See [decision 0009](decisions/0009-prune-state-across-sections.md).

---

## Session log
Archived session history: [open archive](_attic/STATE-session-archive.md)

- 2026-10-11 · GPT-6 / Codex · 19 · merged PR #21 as `62b7402`, published v0.6.2, and passed all five required checks (Windows 18m35s); disposable Medulla STATE reached 11,930 bytes from 52,780 without editing Medulla · next: benchmark remains unscored.

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

- 2026-10-11 · GPT-6 / Codex · 18 · merged PR #20 as `e97dad7`, published v0.6.1 with no benchmark claim, and verified Pages deploy; five pre-merge CI checks passed · next: resume benchmark measurement separately.
- 2026-10-11 · GPT-6 / Codex · 18 · implemented automatic 12,000-byte STATE pruning with a linked, recoverable archive; 167 tests, ShellCheck, docs guard and Gitleaks pass on macOS · next: open PR, wait for every OS check, then publish v0.6.1.
- 2026-10-11 · GPT-6 / Codex · 17 · merged PR #18 (`ae5f20f`), publishing clearer copy and removing internal research Markdown from the current public tree; docs-check, secrets, and Ubuntu passed while macOS/Windows continued after merge.
- 2026-10-11 · GPT-6 / Codex · 17 · reviewed the live skills.sh top ten, found the main copy leads with product jargon and the skill is 1,597 words; next: publish clearer copy and keep internal research files out of the tracked tree.
- 2026-10-10 · GPT-6 / Codex · 16 · generated 1536×1024 art, published it on the homepage, synced both skill copies, and verified live image/alt text; Ubuntu/macOS tests (150 each), docs guard, secrets, and Pages deploy passed; skills.sh still showed its old cached skill text · next: resume parked benchmark plan 07 when Free Tier quota is available.
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
