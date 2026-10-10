---
id: plan-11
title: "11 — put production evidence on the public site and README"
status: in-progress
owner: hematenergi
last-verified: 2026-10-10
depends-on: [10]
---

# 11 — put production evidence on the public site and README

**One-sentence goal.** Make the homepage and GitHub README explain what Fragment does and show what v0.5.0 was observed doing in its two production repositories, with limits stated alongside the evidence.

## Why this is needed

The live homepage has a general product pitch, a source-repository incident, and a v0.6.0 install prompt. It does not surface the later v0.5.0 adoption evidence from `CASE-STUDY.md:129`, despite that evidence describing two production repositories and their different local checks. The README is also long and does not lead with a concise explanation and the same evidence. Visitors should be able to see both the useful evidence and what it does not establish.

## Read first

- `../../CASE-STUDY.md:129` — observed v0.5.0 use in medulla and flimapp
- `../../site/index.html:164` — current proof section on the homepage
- `../../site/styles.css:370` — existing proof-section presentation
- `../../README.md` — GitHub repository front page
- `../STATE.md` — current release and active fragment

## Current state

The live page at `https://hematenergi.github.io/fragment/` matches `site/index.html`: its proof section shows the source-repository rename incident but not the v0.5.0 production-adoption evidence. The case study records the v0.5.0 snapshot on 2026-10-08: two author-run production repos, identical 588-line shared guard, 23- and 80-line local guards, and medulla's 96 decisions, 51 lessons, and 89 plans. It also states that this is not independent validation and does not measure time or token savings. The README was 492 lines; it is now a concise product, usage, and evidence summary.

## Work

- [x] Compare the live homepage with its tracked source and identify the missing evidence.
- [x] Check every proposed claim against the frozen case study; keep its source text unchanged.
- [x] Add a concise, accessible production-evidence section to the homepage and preserve the benchmark limitation.
- [x] Shorten the README and make its product explanation, install path, v0.6.0 tools, production evidence, and limits easy to scan.
- [x] Narrow release-version consistency checks to current install instructions so historical evidence can name v0.5.0.
- [x] Run the local site preview and required repository checks; resolve any defects they reveal.
- [ ] Merge the homepage and README changes and verify the GitHub Pages deployment and live copy.

## Done when

- [ ] The homepage describes the two v0.5.0 production installs and their separate local checks using source-backed facts.
- [ ] The README is substantially shorter, direct, and uses the same source-backed evidence and limits.
- [ ] The page states the n=2/author-run limits and says that time/token savings are not measured.
- [ ] The full case study remains linked, repository checks pass, and the deployed page displays the new section.

## Traps

- `CASE-STUDY.md` and the frozen benchmark/design files are source evidence; do not rewrite them as part of a website edit.
- Both repositories are author-run. Do not imply independent adopters, prove that code is correct, or claim measured time/token savings.
- The v0.5.0 snapshot predates the v0.6.0 release; keep that date and version clear.

## Validation

```bash
rtk bash scripts/docs-check.sh
rtk bash tests/run.sh
rtk git diff --check
```

Verify the merged `Deploy website` workflow and fetch the live homepage to confirm its production-evidence copy.

## Out of scope

Changing benchmark results or protocol, revising the frozen case study, or changing the v0.6.0 release.

## Session log

- 2026-10-10 · GPT-6 / Codex · 11 · added the v0.5.0 production evidence to the homepage and shorter README; local preview returned HTTP 200, all 148 tests and the docs guard passed, and version checks still pin install instructions to v0.6.0 · next: publish both updates and verify the live homepage.
- 2026-10-10 · GPT-6 / Codex · 11 · found that the live site exposed only version metadata from v0.6.0 and omitted the later v0.5.0 production snapshot · next: add the source-backed evidence to the homepage and README.
