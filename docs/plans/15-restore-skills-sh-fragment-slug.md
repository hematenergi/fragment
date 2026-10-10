---
id: plan-15
title: "15 — restore the skills.sh Fragment slug"
status: in-progress
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

The canonical skill is named `fragment` at `skills/fragment/SKILL.md:2`. The plugin package keeps its own `adopt-fragment` identifier and carries a byte-identical copy under `plugins/adopt-fragment/skills/fragment/SKILL.md`. README, install guide, installer output, and homepage are being aligned to `npx skills add hematenergi/fragment --skill fragment` and the direct skills.sh route.

## Work

- [x] Restore one root CLI skill named `fragment`, with the packaged copy byte-identical.
- [x] Align CLI instructions, installer output, source links, and the above-fold homepage CTA.
- [x] Record the owner-approved slug change and supersede the prior catalog decision.
- [x] Pass the repository suite, docs guard, and package-copy check.
- [ ] Verify the skills CLI listing with `--list` after publishing.
- [ ] Publish and verify the live detail page and homepage.

## Done when

- [ ] `npx skills add hematenergi/fragment --list` shows one `fragment` skill, and `--skill fragment` is the documented command.
- [ ] All public install pages use the direct `/hematenergi/fragment/fragment` URL and the matching source path.
- [ ] The live skills.sh detail page opens the Fragment skill after the source is published; any remaining platform cache issue is recorded accurately.
- [ ] Local validation and the merged repository checks pass.

## Traps

- Keep exactly one skills CLI entry; do not publish both `fragment` and `adopt-fragment` under the repository.
- The native plugin packages retain the separate `adopt-fragment` package name.
- A successful HTTP status can still contain an application-level 404. Inspect the page body after publishing.
- Skill install telemetry is organic; do not create synthetic installs or imply that fixing the route changes ranking by itself.

## Validation

```bash
npx skills add hematenergi/fragment --list
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

- 2026-10-10 · GPT-6 / Codex · 15 · renamed the canonical CLI skill to `fragment`, aligned install surfaces and hero CTA, and passed all 150 tests plus docs guard · next: publish, confirm the CLI sees one `fragment` skill, then inspect the live page.
- 2026-10-10 · GPT-6 / Codex · 15 · restoring the `fragment` skill slug and linking the direct detail route per owner direction; plugin package IDs stay unchanged · next: run local validation, publish, and inspect the live skills.sh page.
