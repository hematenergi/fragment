---
id: plan-14
title: "14 — keep Fragment discoverable on skills.sh"
status: in-progress
owner: hematenergi
last-verified: 2026-10-10
depends-on: [13]
---

# 14 — keep Fragment discoverable on skills.sh

**One-sentence goal.** Keep Fragment linked from skills.sh while making the current install path clear and grounded in real leaderboard behavior.

## Why this is needed

The prior correction removed the skills.sh link from Fragment's public pages after its renamed detail page returned an application-level 404. The owner clarified that keeping Fragment's platform presence matters. The repository listing route works but still shows an older skill entry, so public pages need to retain that route and explain which skill the install command selects.

## Read first

- `../../README.md` — public install entry point
- `../../INSTALL.md` — agent install guide
- `../../site/index.html` — public homepage
- `../decisions/0006-keep-skills-platform-presence.md` — link and listing policy

## Current state

As of 2026-10-10, `https://www.skills.sh/hematenergi/fragment` returns a repository listing, but it shows the older `fragment` entry. The `adopt-fragment` detail route renders an application-level 404. The supported install remains `npx skills add hematenergi/fragment --skill adopt-fragment`, and the skill source is available from the repository. Skills.sh documents leaderboard ranking through anonymous CLI install telemetry; its current All Time leaderboard shows about 920K installs at rank 10.

## Work

- [x] Restore the repository-level skills.sh link in README, INSTALL.md, and the homepage.
- [x] Keep the working install command and canonical source link beside it; explain that the catalog entry is stale.
- [x] Check the live top ten and the official leaderboard telemetry documentation; report organic discovery steps without manufacturing installs.
- [x] Run the repository suite and docs guard; inspect the final diff.
- [ ] Publish the public-page changes and verify the live homepage and README.

## Done when

- [x] All three public install surfaces link to the Fragment repository listing on skills.sh and preserve the current install path.
- [x] The stale catalog state is described accurately, with no link to the unavailable `adopt-fragment` detail route.
- [x] Local validation passes.
- [ ] The merged homepage and README show the restored skills.sh link and stale-catalog note.

## Traps

- An HTTP 200 can still render a framework-level 404; verify page content, not only status.
- Leaderboard counts reflect platform install telemetry. Do not use synthetic installs or describe marketing reach as install evidence.
- Do not imply a catalog refresh, search result, or rank change until the platform actually shows it.

## Validation

```bash
rg -n "skills\.sh/hematenergi/fragment" README.md INSTALL.md site/index.html
rg -n "npx skills add hematenergi/fragment --skill adopt-fragment" README.md INSTALL.md site/index.html
rg -n "raw.githubusercontent.com/hematenergi/fragment/main/skills/adopt-fragment/SKILL.md" README.md INSTALL.md site/index.html
bash tests/run.sh
bash scripts/docs-check.sh
git diff --check
```

## Out of scope

Changing skills.sh catalog data, generating install telemetry, splitting the skill into artificial entries, or claiming a top-ten target is near-term.

## Session log

- 2026-10-10 · GPT-6 / Codex · 14 · restored the skills.sh repository link and current install/source guidance across README, INSTALL.md, and homepage; reviewed the live all-time top ten and official telemetry rules; 150 tests and docs guard passed · next: publish the link restoration and verify the live homepage.
