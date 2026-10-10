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

**v0.5.0 is released; v0.6 context features are implemented, validated, and merged.**
Feature PR #2 merged as `5f13f7b`. The extraction prompt is committed and
pushed. The original GPT benchmark remains frozen. The owner authorized a
separate Gemini Free-tier benchmark after its data-use terms were disclosed;
its provider-specific protocol, extraction prompt, and harness are pushed. The
first condition-B preflight transmitted Medulla onboarding content to Gemini
`countTokens` and returned HTTP 400 `INVALID_ARGUMENT`; no `generateContent`,
dry run, score, or `N` resulted. The frozen protocol stops on invalid requests,
so R1 is retained unchanged. The owner then directed work through the v0.6
release. A separate Gemini R2 protocol and harness correction is frozen and
pushed at `6ad0871326da41631df20a2acf8b5bc3e76b8fd5`; it adds the required
nested `model` field and corrects API error categories. Its first B calibration
counted 488,670 onboarding tokens, then `generateContent` returned HTTP 429
for the Free-tier 250,000 input-token quota. No generation, dry run, score, or
`N` resulted. R2 remains frozen; no replacement request was sent pending owner
review of the protocol gap. The owner then explicitly approved a new, separate
Gemini benchmark. AI Studio now confirms the selected Free-tier project has
Gemini 3.1 Flash-Lite limits of 15 RPM, 250K TPM, and 500 RPD. R3 protocol,
prompt, and runner were pushed at c2671ac5a873af1ca046054ffee2e8e3f6dbf018
and the remote SHA matched. A single ping-only pin check returned HTTP 200 and
pinned modelVersion gemini-3.1-flash-lite with thinking low. The 236-record
Medulla B bundle is assembled locally. The deterministic builder and
count-only preflight amendment are pushed at
7ba4fdc140cd917a16721d5ff5d8ea5357849400. A parser allowlist fix for the
non-secret model-version pin was pushed at
998fe25b7345951aa4155c35cd1cee6a6bfd0e00; both remote SHAs matched. One
count-only invocation stopped locally before network because of that parser
bug; no R3 repository content has been sent.

## Active fragment

**Fragment 09 is active.** Fragment 08 is complete: deterministic `/recall`,
tags, STATE history pruning, and token-budgeted loading are implemented in the
template and this checkout; all 147 tests and the docs guard pass. Fragment 07
remains parked for the original frozen GPT protocol. The new Gemini track is
defined separately in `FragmentBenchmarkSpec-Gemini.md` (failed R1), the
frozen `FragmentBenchmarkSpec-Gemini-R2.md`, and the newly approved R3
revision, frozen at c2671ac5a873af1ca046054ffee2e8e3f6dbf018. Its Medulla
questions/key/task are drafted privately against snapshot
`01667b95454663848f193cd84e3fb055507035b0`; the shared Linux/arm64 container
and clean Medulla test result are recorded. The R1 private condition-B
onboarding preflight reached `countTokens` and failed with HTTP 400
`INVALID_ARGUMENT`. The R2 B calibration preflight counted 488,670 tokens,
then `generateContent` failed with HTTP 429 because the Free-tier input-token
quota is 250,000. There is no R2 generation, dry run, score, or calibrated
`N`; R2 remains frozen and its failed attempt was not replayed. R3 has a
frozen core protocol, extraction prompt, and separate runner; the ping-only pin
check succeeded. The quota-aware builder/counting amendment is pushed. The capped B preflight
and calibration remain pending.

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
| 07 | [establish the v0.6 benchmark baseline](plans/07-v06-benchmark-baseline.md) | `parked` | original frozen GPT-5.4 Mini access is unavailable; the separate Gemini track is plan 09 |
| 08 | [ship the v0.6 context features](plans/08-v06-context-features.md) | `done` | — |
| 09 | [run the Gemini benchmark and release v0.6](plans/09-gemini-benchmark-and-v06-release.md) | `in-progress` | owner review: choose a free-tier-compatible model/protocol after R2's 488,670 vs. 250,000 TPM result |

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

---

## Session log

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

- 2026-10-10 · GPT-6 / Codex · 09 · condition-B preflight sent onboarding docs to Gemini `countTokens` and received HTTP 400 `INVALID_ARGUMENT`; no generation or calibration value exists, so stopped per frozen protocol · next: owner reviews the invalid-request evidence before any new benchmark revision.
- 2026-10-10 · GPT-6 / Codex · 09 · owner directed work through v0.6 release; retained failed Gemini R1 and started separate R2 with required nested model field and accurate API categories; local self-check passes, no R2 request sent · next: freeze/push R2 before its condition-B calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · froze and pushed separate Gemini R2 protocol/harness correction at `6ad0871`; local and remote SHAs match, 147 tests and docs guard pass, no R2 request sent · next: reconfirm Free Tier/no billing, then run B-condition Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · R2 B calibration counted 488,670 onboarding tokens, then Free-tier `generateContent` returned 429 for the 250,000 input-token quota; no usage, score, or `N`, and no replacement sent because frozen truncation threshold would not reduce this prompt · next: owner reviews the protocol gap before any R3 or further API call.
- 2026-10-10 · GPT-6 / Codex · 09 · checked no-cost alternatives without sending content: Muse exposes only its ambient panel; local Ollama is 0.5B/32K and cloud options do not fit the full prompt; Gemini 3.1 Flash-Lite has a documented 1M window but project quota is unconfirmed · next: owner review before creating another frozen benchmark revision.
- 2026-10-10 · GPT-6 / Codex · 09 · pushed frozen Gemini harness/system prompt/tool allowlist as `e05a5b9`; local and remote SHAs match, the key stayed ignored, and no repository content has been sent · next: record the freeze anchor and run the condition-B Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · repaired the Gemini harness so onboarding, quiz, and task share one transcript; enforced the onboarding cap and per-run edit paths; harness self-check and all 147 repository tests pass · next: push the frozen harness/system prompt, then run the condition-B Medulla calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · confirmed the AI Studio key project remains Free tier; clean Medulla snapshot passed npm ci and 1,304 unit + 369 integration tests in the pinned image with test networking disabled · next: freeze benchmark harness before calibration.
- 2026-10-10 · GPT-6 / Codex · 09 · pushed protocol/prompt commit `c44b2e5` to `codex/v06-benchmark-resume`; remote SHA matches and no repo content has been sent · next: verify container/tests and freeze harness before dry run.
- 2026-10-10 · GPT-6 / Codex · 09 · owner authorized a separate Gemini benchmark; recorded successful generic probes, Free Tier terms, and a separate protocol/prompt without changing the frozen GPT artifacts · next: validate and push the new protocol before sending repo content or running calibration.
- 2026-10-10 · GPT-6 / Codex · 07 · checked the owner-configured Gemini key without exposing it: model metadata returned HTTP 200/version 3.0, all listed projects showed Free tier, and three `gemini-3.8-flash` generation pings returned HTTP 503; no repo content or benchmark run data was sent/created · next: retry only after service capacity recovers and preserve the frozen GPT-5.4 Mini pin unless the owner authorizes a new protocol.
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
