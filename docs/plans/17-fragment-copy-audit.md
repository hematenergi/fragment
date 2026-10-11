---
id: plan-17
title: Clarify Fragment's value across the docs
status: done
owner: hematenergi
last-verified: 2026-10-11
depends-on: []
---

# 17 — Clarify Fragment's value across the docs

**One-sentence goal.** Help a first-time reader understand what Fragment changes for their next coding session, then make installation and evidence easy to scan.

## Why this is needed

The public copy leads with terms such as “continuity harness” and “documentation harness” before naming the user payoff. The onboarding skill is 1,597 words, while the README, install guide, and case study explain the same idea at different lengths. The current skills.sh all-time leaders show a useful pattern: one direct outcome sentence, followed by specific capabilities and a visible install command.

## Read first

- `../../README.md` — main public explanation and install path
- `../../skills/fragment/SKILL.md` — skills.sh summary and adoption instructions
- `../../plugins/adopt-fragment/skills/fragment/SKILL.md` — packaged copy that must stay identical
- `../../INSTALL.md` — agent and plugin install choices
- `../../CASE-STUDY.md` — evidence and claim limits

## Current state

- `README.md`: 628 words; the first paragraph starts with “continuity harness.”
- `skills/fragment/SKILL.md`: 1,597 words; its page summary starts with “documentation harness.”
- `INSTALL.md`: 240 words.
- `CASE-STUDY.md`: 1,689 words; the product takeaway is spread across the opening and six evidence sections.

## Audit notes

skills.sh **All Time** top ten, opened 2026-10-11. Install counts are a snapshot;
they change over time.

| Rank | Skill | Repo | Installs |
|---:|---|---|---:|
| 1 | `find-skills` | `vercel-labs/skills` | 3.8M |
| 2 | `grill-me` | `mattpocock/skills` | 1.3M |
| 3 | `grill-with-docs` | `mattpocock/skills` | 1.1M |
| 4 | `improve-codebase-architecture` | `mattpocock/skills` | 1.1M |
| 5 | `agent-browser` | `vercel-labs/agent-browser` | 1.1M |
| 6 | `tdd` | `mattpocock/skills` | 1.1M |
| 7 | `setup-matt-pocock-skills` | `mattpocock/skills` | 978.6K |
| 8 | `frontend-design` | `anthropics/skills` | 972.9K |
| 9 | `handoff` | `mattpocock/skills` | 959.0K |
| 10 | `hyperframes-cli` | `heygen-com/hyperframes` | 931.0K |

**Copy pattern:** each page names one job or result first, follows with specific
capabilities, and puts the install command near the top. The leaderboard is
powered by anonymous CLI install telemetry; rank measures installs, not copy
quality or user satisfaction ([skills.sh docs](https://www.skills.sh/docs)).

## Work

- [x] Open the current skills.sh all-time top ten and review their page summaries and skill previews.
- [x] Audit the current public value copy and the core install skill.
- [x] Put the user outcome before product terminology in the README and skill summary.
- [x] Remove repeated onboarding prose while preserving the safe-adoption steps.
- [x] Make the case-study opening state the finding and its limits before the detail.
- [x] Keep the product promise scoped to available evidence.
- [x] Keep internal strategy and benchmark working documents out of the public tree while preserving local copies.
- [x] Keep the canonical and packaged skill files byte-identical.

## Done when

- [x] A new reader can tell what problem Fragment solves, what files/tools it adds, and how to install it from the first screen of the README and skill page.
- [x] The revised copy is shorter or more scannable without dropping adoption safeguards, evidence, or honesty limits.
- [x] No benchmark numbers or performance outcomes are implied before they exist.
- [x] Internal research documents remain untracked and ignored by Git.

## Traps

- Install telemetry is a ranking signal, not proof of copy quality or user satisfaction.
- Do not turn “intended to reduce repeated context” into a measured token or time-savings claim.
- Keep the two skill copies byte-identical; preserve the skill name, install command, and image URL.

## Validation

```bash
bash scripts/docs-check.sh
cmp skills/fragment/SKILL.md plugins/adopt-fragment/skills/fragment/SKILL.md
git diff --check
```

```text
scripts/docs-check.sh — GREEN
canonical and packaged skill copies — identical
git diff --check — PASS
internal research Markdown — local-only and ignored
```

## Out of scope

Benchmark changes, skill slug changes, install telemetry changes, feature implementation, and homepage HTML redesign.

## Session log

- 2026-10-11 · GPT-6 / Codex · 17 · reviewed the live skills.sh all-time top ten, rewrote public copy, and moved internal research Markdown out of the tracked tree; docs guard and copy parity pass.
