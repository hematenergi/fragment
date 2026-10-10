---
id: plan-15
title: "15 — restore the skills.sh Fragment slug"
status: done
owner: hematenergi
last-verified: 2026-10-10
depends-on: [14]
---

# 15 — restore the skills.sh Fragment slug

**One-sentence goal.** Make Fragment's canonical agent skill available at its direct skills.sh detail route and put that install path in front of visitors.

## Why this is needed

Renaming the skill to `adopt-fragment` produced an unavailable detail route while the platform retained the old `fragment` listing. The owner approved restoring the original slug, including `/hematenergi/fragment/fragment`, so the public link, skill name, and CLI command agree again.

## Read first

- `../../skills/fragment/SKILL.md` — canonical CLI skill
- `../../README.md` and `../../INSTALL.md` — public install instructions
- `../../site/index.html` — homepage CTA and install section
- `../decisions/0006-keep-skills-platform-presence.md` — prior decision
- `../decisions/0007-restore-skills-sh-fragment-slug.md` — current decision

## Current state

PR #14 merged as `b3439c981261875f648e6628fa7d21d472da49f6`. The live skills.sh detail page at `/hematenergi/fragment/fragment` returns HTTP 200, has the title `fragment — hematenergi/fragment`, and displays the matching install command. With telemetry disabled, `npx skills add hematenergi/fragment --list` found exactly one skill named `fragment`. The GitHub Pages deployment succeeded (run `38066187505`); the live homepage shows the install CTA and direct route, and the raw source has `name: fragment`. The 150-test suite and docs guard pass locally; the PR's required docs, macOS, Ubuntu, and secrets checks passed. Its Windows run was still in progress after the merge.

## Work

- [x] Restore one root CLI skill named `fragment`, with the packaged copy byte-identical.
- [x] Align CLI instructions, installer output, source links, and the above-fold homepage CTA.
- [x] Record the owner-approved slug change and supersede the prior catalog decision.
- [x] Pass the repository suite, docs guard, and package-copy check.
- [x] Verify the skills CLI listing with `--list` after publishing.
- [x] Publish and verify the live detail page and homepage.

## Done when

- [x] `npx skills add hematenergi/fragment --list` shows one `fragment` skill, and `--skill fragment` is the documented command.
- [x] All public install pages use the direct `/hematenergi/fragment/fragment` URL and the matching source path.
- [x] The live skills.sh detail page opens the Fragment skill after the source is published; any remaining platform cache issue is recorded accurately.
- [x] Local validation and the required merged repository checks pass; the Windows CI job was still running after merge and is recorded in the session evidence.

## Traps

- Keep exactly one skills CLI entry; do not publish both `fragment` and `adopt-fragment` under the repository.
- The native plugin packages retain the separate `adopt-fragment` package name.
- A successful HTTP status can still contain an application-level 404. Inspect the page body after publishing.
- Skill install telemetry is organic; do not create synthetic installs or imply that fixing the route changes ranking by itself.

## Validation

```bash
DISABLE_TELEMETRY=1 npx skills add hematenergi/fragment --list
cmp skills/fragment/SKILL.md plugins/adopt-fragment/skills/fragment/SKILL.md
rg -n "npx skills add hematenergi/fragment --skill fragment" README.md INSTALL.md site/index.html
rg -n "skills.sh/hematenergi/fragment/fragment" README.md INSTALL.md site/index.html
! rg -n "skills/adopt-fragment|--skill adopt-fragment" README.md INSTALL.md site/index.html install.sh
bash tests/run.sh
bash scripts/docs-check.sh
git diff --check
```

## Out of scope

Changing skills.sh catalogue data directly, creating install telemetry, changing plugin package IDs, or promising leaderboard movement.

## Session log

- 2026-10-10 · GPT-6 / Codex · 15 · merged PR #14 as `b3439c9`; Pages run `38066187505` succeeded; live detail page and homepage verified; CLI listed one `fragment` with telemetry disabled; 150 tests, docs guard, and required CI checks passed (Windows run still in progress) · next: resume parked benchmark plan 07 when Free Tier quota is available.
- 2026-10-10 · GPT-6 / Codex · 15 · renamed the canonical CLI skill to `fragment`, aligned install surfaces and hero CTA, and passed all 150 tests plus docs guard · next: publish, confirm the CLI sees one `fragment` skill, then inspect the live page.
- 2026-10-10 · GPT-6 / Codex · 15 · restoring the `fragment` skill slug and linking the direct detail route per owner direction; plugin package IDs stay unchanged · next: run local validation, publish, and inspect the live skills.sh page.
