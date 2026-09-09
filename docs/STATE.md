---
id: state
title: STATE — where the work stands
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# STATE

**Read this first, write it last.** The only place that answers "where are we?".

---

## Phase

**0.3.0 released.** Everything local is pushed and tagged, and it went out on a
green build — which 0.2.0 did not. The next phase is the queue below, taken in
order, starting with the one adopter who is stuck.

The gate that ends it: an existing install can reach a newer guard with one
documented command.

## Active fragment

_(none — 01 is next, not yet started)_

> At most **one** active fragment. If something is here and it is not yours, ask
> before touching it.

## Queue — take from the top

| # | Fragment | Status | Blocked by |
|---|---|---|---|
| 01 | [install.sh cannot upgrade](plans/01-installer-cannot-upgrade.md) | `todo` | — |
| 02 | [no way down from a warning pile](plans/02-no-way-down-from-a-warning-pile.md) | `todo` | — |
| 03 | [last-verified is the loudest rule](plans/03-last-verified-is-the-loudest-rule.md) | `todo` | 02 |
| 04 | [version written by hand](plans/04-version-written-by-hand.md) | `todo` | — |

## Blocked / waiting on a human

| What | Waiting on | Since |
|---|---|---|
| Whether 02 and 04 are wanted at all, or whether 01 ends this round | owner | 2026-09-09 |

## Decisions already made — do not ask again

- **The guard has exactly one canonical copy**, `template/scripts/docs-check.sh`.
  `scripts/` and `examples/online-shop/scripts/` vendor it byte-identically, and
  a test asserts each. Do not propose a symlink; Windows checkouts do not
  reliably get one, and the whole point is that a Windows teammate can run it.
- **Fragment installs Fragment at the Core plus fragment-workflow tiers only.**
  No non-engineer layer, no runbooks, no research — everyone working here reads
  code and the repository operates nothing. That is the README's own advice,
  followed rather than quoted.

---

## Session log

One line per session, newest first. Format:
`date · agent · fragment · what changed · what is next`.

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
