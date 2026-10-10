---
id: plan-16
title: Add an original illustration to Fragment's public install surfaces
status: in-progress
owner: hematenergi
last-verified: 2026-10-10
depends-on: []
---

# 16 — Add an original illustration to Fragment's public install surfaces

**One-sentence goal.** Give Fragment one original visual that explains project context surviving across coding sessions, on both the homepage and skill detail source.

## Why this is needed

The homepage explains Fragment through copy, transcript cards and code samples, but has no illustration. A single reusable asset makes the session handoff visible and gives the skills.sh detail page a visual entry point too.

## Read first

- `../decisions/0007-restore-skills-sh-fragment-slug.md` — keep one canonical `fragment` skill and its public detail route.
- `site/index.html:52` — current hero and its install CTA.
- `site/styles.css:184` — hero layout and responsive rules.
- `skills/fragment/SKILL.md:1` — canonical root skill shown by skills.sh.
- `plugins/adopt-fragment/skills/fragment/SKILL.md:1` — packaged copy kept byte-identical to the root skill.

## Current state

- `site/index.html` has a text-led hero with a transcript example and no illustration.
- `skills/fragment/SKILL.md` is the single root CLI skill; its packaged plugin copy must remain byte-identical.
- An original screen-print style illustration has been generated and saved as `site/assets/fragment-context-handoff.jpg` (1536×1024, 520 KB).

## Work

- [x] Generate an original illustration that fits the site's paper, ink and vermilion palette.
- [x] Add the illustration to the homepage with responsive sizing, a caption and useful alt text.
- [x] Reference the same image from the canonical Fragment skill and its byte-identical plugin copy, keeping install instructions and slug intact.
- [x] Inspect the rendered mobile homepage and confirm the canonical skill source points at the shared asset.

## Done when

- [x] The illustration is visible in the homepage source and has accessible alt text.
- [x] The canonical skill links to the same image hosted with the public site source.
- [x] The packaged plugin skill remains byte-identical to the canonical root skill.
- [ ] The full repository suite and documentation guard pass.

## Traps

- Keep the source asset in `site/assets/`; the Pages workflow publishes that directory with the site.
- The skill image URL uses the default branch, so its live image resolves after the source change reaches `main`.
- Keep the skills.sh repository listing and canonical `fragment` slug intact.

## Validation

```bash
bash tests/run.sh
bash scripts/docs-check.sh
```

## Out of scope

No benchmark changes, skill slug changes, new install telemetry, or release version changes.

## Session log

- 2026-10-10 · GPT-6 / Codex · generated the original paper-cut handoff illustration and saved the optimized project asset · next: integrate it into the homepage and canonical skill, then review the rendered result.
- 2026-10-10 · GPT-6 / Codex · added the responsive homepage figure and caption, linked the same artwork from the canonical skill, and confirmed the mobile preview and alt text · next: run repository validation and verify the live pages after publication.
- 2026-10-10 · GPT-6 / Codex · CI caught that the packaged plugin copy also needs the image reference; synced it byte-for-byte with the root skill · next: rerun CI, then verify the live homepage and skills.sh page after merge.
