---
id: plan-12
title: "12 — complete Fragment's public install presence"
status: in-progress
owner: hematenergi
last-verified: 2026-10-10
depends-on: [11]
---

# 12 — complete Fragment's public install presence

**One-sentence goal.** Make Fragment's current value clear and its agent skill easy to find and install through the real supported agent surfaces.

## Why this is needed

The README and homepage explain the product and show honest adoption evidence, but neither links to the existing skills.sh listing. The skill and repository share the name `fragment`, producing the awkward `/hematenergi/fragment/fragment` page. The GitHub description still leads with “vibe-coded,” and the homepage's sample conversation is not marked as illustrative. The attached ecosystem list also shows missing native package metadata; only add formats each agent actually documents.

## Read first

- `../../README.md` — repository landing page
- `../../site/index.html` — public homepage and metadata
- `../../skills/adopt-fragment/SKILL.md` — current install skill
- `../STATE.md` — release, benchmark, and active work status
- `11-site-production-evidence.md` — published claims and their limits

## Current state

PR #7 merged the v0.5.0 evidence and shortened the README. The public skills.sh path is `/hematenergi/fragment/fragment` because both the repository and skill are named `fragment`. The owner profile `/hematenergi` currently returns 404; skills.sh only shows owner profiles backed by catalog data, while `/miqdadbadjuber` has six listed skills and installs. The repository homepage is set, but its description still says “vibe-coded projects.” Draft PR #4 is closed; its branch and unrun benchmark work are preserved for later.

## Work

- [ ] Rename the public skill to `adopt-fragment`; package it using the current Agent Skills directory layout and remove the duplicate old skill entry.
- [ ] Add self-contained plugin metadata for the documented Agent Plugins, Codex, Claude Code, Cursor, and Kimi Code formats, plus marketplace catalogs where those formats support them.
- [ ] Document installation paths accurately: skills.sh for agent skills, native marketplaces for packaged plugins, and the existing Bash installer for the full harness. Do not claim a Cline/OpenCode plugin where those tools document skill support instead.
- [ ] Add a direct skills.sh install path and a link to the filled example on the README and homepage; label the homepage conversation as illustrative and align current product/SEO metadata.
- [ ] Update the GitHub description and discovery topics to match the product.
- [x] Close the superseded PR #4 with an accurate handoff; preserve its branch for future benchmark work.
- [ ] Validate JSON and package manifests, exercise the skills CLI and plugin validators that are available, run the required repository checks, publish the changes, and verify the live surfaces.

## Done when

- [ ] The single Fragment skill has a distinct, current skills.sh URL and its public install command is verified.
- [ ] Native package metadata passes each available official validator and carries the same skill text as the canonical source.
- [ ] Visitors can reach one concise install guide from both GitHub and the homepage and can inspect the filled example.
- [ ] Public descriptions match the current product and do not imply measured savings or finished benchmark results.
- [ ] The stale PR is closed with its benchmark handoff intact; required checks pass; the merged README and deployed homepage are verified.

## Traps

- A skills.sh listing is keyed by skill name as well as repository name. Do not keep both `fragment` and `adopt-fragment` as active skills.
- Skills.sh indexes public repository contents; do not claim a new listing is live until its default-branch source is published and the resulting page is checked.
- Skills.sh owner pages are catalog views, not automatic GitHub profiles. Do not create a synthetic install to make `/hematenergi` appear; link directly to the real skill page and report the owner profile only if it becomes available from genuine catalog activity.
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

- 2026-10-10 · GPT-6 / Codex · 12 · verified `/hematenergi` is 404 while `/miqdadbadjuber` is a catalog-backed profile, closed superseded draft PR #4 and preserved its branch, and confirmed the duplicated skills.sh slug · next: publish a distinct skill slug and accurate agent install surfaces.
