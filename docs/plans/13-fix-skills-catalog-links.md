---
id: plan-13
title: "13 — replace the unavailable skills.sh link"
status: in-progress
owner: hematenergi
last-verified: 2026-10-10
depends-on: [12]
---

# 13 — replace the unavailable skills.sh link

**One-sentence goal.** Make every public install page link to a skill source that visitors can open while skills.sh catalog data is stale.

## Why this is needed

The canonical skill exists at `skills/adopt-fragment/SKILL.md` on the default branch, and `npx skills add hematenergi/fragment --list` detects it. The skills.sh detail URL returns HTTP 200 but its page content reports a 404; the repository page still lists the old `fragment` slug. The last verification checked only the HTTP status and incorrectly called the detail page live.

## Read first

- `../../README.md` — public install entry point
- `../../INSTALL.md` — agent install guide
- `../../site/index.html` — public homepage
- `12-public-presence.md` — package and catalogue history

## Current state

The install command `npx skills add hematenergi/fragment --skill adopt-fragment` remains valid. The skills CLI lists one skill from the public repository. The canonical source is `https://raw.githubusercontent.com/hematenergi/fragment/main/skills/adopt-fragment/SKILL.md`, which serves the current skill text. The skills.sh owner/repository/detail pages are stale: the repo detail route's HTML body states the skill is unavailable, while the repo listing advertises the old slug. The skills.sh docs describe anonymous install telemetry and read APIs; they expose no repo-side cache refresh or deletion operation. No synthetic install will be used to change catalog telemetry.

## Work

- [x] Replace the broken skills.sh detail link in README, INSTALL.md, and the homepage with the canonical GitHub skill source.
- [x] Correct plan 12's live-page status and record why the prior HTTP-only verification was wrong.
- [x] Run the repository tests and docs guard; inspect the final diff for stale public links.
- [ ] Publish the correction and verify the deployed homepage and source links.

## Done when

- [ ] README, install guide, and homepage retain the CLI install command and link to the canonical skill source.
- [ ] No public repo-controlled page links to the skills.sh URL that currently renders an application-level 404.
- [ ] Required local checks pass and published content is verified.

## Traps

- HTTP 200 can still contain a framework-rendered 404. Check page content, title, and the visible body before calling a route live.
- Do not create an install solely to seed skills.sh ranking or telemetry. The existing CLI install command is independently verified against the repository.
- Search uses `/search?q=...`; the `/?q=...` form redirects. This does not make the skill undiscoverable by source, but catalog results depend on the platform's indexed data.

## Validation

```bash
! rg -n "skills\.sh/hematenergi/fragment/adopt-fragment" README.md INSTALL.md site
rg -n "raw.githubusercontent.com/hematenergi/fragment/main/skills/adopt-fragment/SKILL.md" README.md INSTALL.md site
bash tests/run.sh
bash scripts/docs-check.sh
git diff --check
```

## Out of scope

Changing skills.sh's catalog data, creating synthetic installation telemetry, or changing the skill's frozen name or contents.

## Session log

- 2026-10-10 · GPT-6 / Codex · 13 · replaced README, INSTALL.md, and homepage links with the GitHub skill source; corrected the prior HTTP-only verification; local suite passed 150 tests and docs-check passed · next: publish and verify the deployed links.
- 2026-10-10 · GPT-6 / Codex · 13 · found a skills.sh application-level 404 behind HTTP 200; replacing the broken public detail links with the canonical GitHub source · next: validate, publish, and verify the deployed links.
