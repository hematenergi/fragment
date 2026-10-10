---
id: plan-12
title: "12 — complete Fragment's public install presence"
status: done
owner: hematenergi
last-verified: 2026-10-10
depends-on: [11]
---

# 12 — complete Fragment's public install presence

**One-sentence goal.** Make Fragment's current value clear and its agent skill easy to find and install through the real supported agent surfaces.

## Why this is needed

The README and homepage needed links to the skill, and the skill and repository shared the name `fragment`, producing the awkward `/hematenergi/fragment/fragment` page. The GitHub description led with “vibe-coded,” and the homepage's sample conversation was not marked as illustrative. The attached ecosystem list also showed missing native package metadata; only add formats each agent actually documents.

## Read first

- `../../README.md` — repository landing page
- `../../site/index.html` — public homepage and metadata
- `../../skills/adopt-fragment/SKILL.md` — current install skill
- `../STATE.md` — release, benchmark, and active work status
- `11-site-production-evidence.md` — published claims and their limits

## Current state

PR #7 merged the v0.5.0 evidence and shortened the README. PR #8 (`95033e6`) published one canonical skill, `adopt-fragment`, with documented agent package metadata and concise install paths. The direct page `https://www.skills.sh/hematenergi/fragment/adopt-fragment` returns 200, and `npx skills add hematenergi/fragment --list` finds only that skill. The old page `https://www.skills.sh/hematenergi/fragment/fragment` still returns 200 with its former slug after the default branch stopped publishing it; this stale catalogue entry is outside the repository's control. The owner route `/hematenergi` returns 404 while `/miqdadbadjuber` has a populated skills.sh catalogue profile. Skills.sh documents anonymous install telemetry and read-only catalog APIs, but no repository-side profile creation or stale-entry deletion control. We do not create synthetic installs. The README and homepage now link the direct skill page. Draft PR #4 is closed; its branch and unrun benchmark work are preserved for later.

## Work

- [x] Rename the public skill to `adopt-fragment`; package it using the current Agent Skills directory layout and remove the duplicate old skill entry from the default branch. The old skills.sh detail URL remains as a stale platform catalogue entry.
- [x] Add self-contained plugin metadata for the documented Agent Plugins, Codex, Claude Code, Cursor, and Kimi Code formats, plus marketplace catalogs where those formats support them.
- [x] Document installation paths accurately: skills.sh for agent skills, native marketplaces for packaged plugins, and the existing Bash installer for the full harness. Do not claim a Cline/OpenCode plugin where those tools document skill support instead.
- [x] Add a direct skills.sh install path and a link to the filled example on the README and homepage; label the homepage conversation as illustrative and align current product/SEO metadata.
- [x] Update the GitHub description and discovery topics to match the product.
- [x] Close the superseded PR #4 with an accurate handoff; preserve its branch for future benchmark work.
- [x] Validate JSON and package manifests, exercise the skills CLI and plugin validators that are available, run the required repository checks, publish the changes, and verify the live surfaces.

## Done when

- [x] The default branch contains one Fragment skill with a distinct skills.sh URL and verified public install command. The legacy skills.sh URL still serves a stale catalogue item; skills.sh exposes no documented repo-side removal control.
- [x] Native package metadata passes each available official validator and carries the same skill text as the canonical source.
- [x] Visitors can reach one concise install guide from both GitHub and the homepage and can inspect the filled example.
- [x] Public descriptions match the current product and do not imply measured savings or finished benchmark results.
- [x] The stale PR is closed with its benchmark handoff intact; required checks pass; the merged README and deployed homepage are verified.

## Traps

- A skills.sh listing is keyed by skill name as well as repository name. Do not keep both `fragment` and `adopt-fragment` as active skills.
- Skills.sh indexes public repository contents; do not claim a new listing is live until its default-branch source is published and the resulting page is checked. A prior detail URL may continue to serve stale catalogue data after a slug rename.
- Skills.sh owner pages are catalogue views, not automatic GitHub profiles. Do not create a synthetic install to make `/hematenergi` appear; link directly to the real skill page. The FAQ says catalogue rankings use anonymous CLI installation telemetry, and the documented API is read-only; report the owner profile only if it appears from genuine catalogue activity.
- Cline plugins are executable packages, and OpenCode plugins are code modules. Fragment's onboarding workflow is an Agent Skill; use their documented skill support rather than adding empty plugin markers.
- The only measured adoption evidence remains two author-run v0.5.0 repositories. Benchmark values and independent-adopter claims are still unavailable.
- PR #4 contains unrun Gemini protocols and no valid score or `N`; closing it must preserve the branch and must not present its draft as a result.

## Validation

```bash
python3 -m json.tool .agents/plugins/marketplace.json
python3 -m json.tool .claude-plugin/marketplace.json
python3 -m json.tool .cursor-plugin/marketplace.json
python3 -m json.tool plugins/adopt-fragment/plugin.json
python3 -m json.tool plugins/adopt-fragment/.codex-plugin/plugin.json
python3 -m json.tool plugins/adopt-fragment/.claude-plugin/plugin.json
python3 -m json.tool plugins/adopt-fragment/.cursor-plugin/plugin.json
python3 -m json.tool plugins/adopt-fragment/.kimi-plugin/plugin.json
cmp skills/adopt-fragment/SKILL.md plugins/adopt-fragment/skills/adopt-fragment/SKILL.md
bash tests/run.sh
bash scripts/docs-check.sh
git diff --check
```

Verify the skills.sh page, GitHub metadata, and the deployed homepage after publication.

## Out of scope

Running the frozen benchmark, changing its specifications, submitting plugins to vendor-owned global stores, or claiming adoption from listing views.

## Session log

- 2026-10-10 · GPT-6 / Codex · 12 · merged PR #8 as `95033e6` with one canonical `adopt-fragment` skill and install packages; all five CI checks passed, direct skills.sh page and homepage verified, README and GitHub metadata aligned, and superseded PR #4 closed with its branch preserved; documented the stale legacy skills.sh detail URL and that `/hematenergi` is not an automatically created GitHub profile · next: resume parked benchmark plan 07 when free-tier quota is available.
