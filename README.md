<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/fragment-logo-dark.png">
    <img src="assets/fragment-logo.png" alt="Fragment logo" width="132">
  </picture>
</p>

<h1 align="center">Fragment</h1>

<p align="center">
  <strong>Project memory for AI coding agents.</strong><br>
  Keep decisions, current state, and the next step in the repository.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="INSTALL.md">Agent install guide</a> ·
  <a href="#evidence-and-limits">Evidence and limits</a> ·
  <a href="CASE-STUDY.md">Full case study</a>
</p>

<p align="center">
  <a href="https://github.com/hematenergi/fragment/actions/workflows/tests.yml"><img src="https://github.com/hematenergi/fragment/actions/workflows/tests.yml/badge.svg" alt="tests"></a>
</p>

Your next coding session should not have to reconstruct decisions or ask where
the work stopped. Fragment keeps project decisions, lessons, current state, and
the next action in files committed with the repo. The next agent can read them;
a Bash guard checks the handoff locally and in CI.

Fragment works with the coding agent you already use and runs on Bash and Git.
It needs no model API, database, daemon, or account. The guard checks documented
handoffs, not whether your code or decisions are correct.

## Install

### Guided install

Install the skill to have your coding agent adopt Fragment in the current repo:

```bash
npx skills add hematenergi/fragment --skill fragment
```

[Install Fragment on skills.sh](https://www.skills.sh/hematenergi/fragment/fragment) · [View the skill source](https://raw.githubusercontent.com/hematenergi/fragment/main/skills/fragment/SKILL.md) · [Other agent install paths](INSTALL.md)

The skill inspects the repository, preserves existing files, and guides the
adoption.

### Install the full harness directly

Use the prompt below to have your agent install the harness, or use the Bash
commands after it.

Ask your coding agent:

```text
Install Fragment v0.6.2 from https://github.com/hematenergi/fragment into this repository.
Preserve existing files. Use only decisions supported by this repository and our conversation.
Run bash scripts/docs-check.sh and leave unknowns as blockers instead of guessing.
```

Or install from Bash:

```bash
git clone --depth 1 --branch v0.6.2 https://github.com/hematenergi/fragment
bash fragment/install.sh /path/to/your/repo
cd /path/to/your/repo
bash scripts/docs-check.sh
```

The first check may fail while template values are still present. Fill in the project facts it names, then run it again. The installer preserves existing files; merge them deliberately.

### Upgrade an existing repo

Before upgrading, commit and push the project changes you want to keep. The
target repo should have a clean working tree and index, and its current branch
should be synced with its upstream. Check from the target repo:

```bash
git fetch
git status --short
git status -sb
```

`git status --short` should print nothing; `git status -sb` should show an
upstream (for example, `## main...origin/main`) with no ahead/behind count. If
there is local work, commit and push it through your normal review. If the
branch is ahead, push it; if it is behind, pull or rebase it through your normal
workflow and check again. If no upstream is configured, configure and push one
before upgrading. Fragment will not commit or push project changes for you.
This gives the upgrade a known Git baseline to compare or restore.

Then, from the Fragment checkout at the release you want to install, preview and
apply the upgrade:

```bash
bash fragment/install.sh --dry-run --upgrade /path/to/your/repo
bash fragment/install.sh --upgrade /path/to/your/repo
```

Run the target repo's local guard and its usual tests afterward:

```bash
cd /path/to/your/repo
bash scripts/docs-check.sh
```

A successful local guard may archive dated STATE history automatically. Review
`git status` and the archive afterward; your repo's ignore rules may leave the
archive untracked. If the guard reports that fixed STATE content still exceeds
the 12,000-byte budget, it leaves the files unchanged; review that report
instead of forcing or manually pruning content.

The installer itself does not commit or push the upgrade. Review and commit the
result through the target repo's normal workflow.

## How it works

At the start of a session, the agent reads the repo's protocol and `docs/STATE.md`,
then opens only the relevant work and decisions. At the end, it records what
changed and what comes next. The guard catches missing files, broken links, and
missing handoff updates.

```text
CLAUDE.md / AGENTS.md → docs/AGENT-PROTOCOL.md → docs/STATE.md
                       → active fragment → relevant decisions and lessons
```

Fragment's checks use Bash and Git, with no runtime database, daemon, account, or model API.

## Pick up the right context (v0.6.2)

- Find relevant prior decisions and lessons with `bash scripts/recall.sh "query"`.
  It uses deterministic keyword matching—no model call or network access.
- A successful local `docs-check.sh` automatically keeps STATE within 12,000
  bytes by archiving the oldest dated session entries when needed. It preserves
  the archive and links it from STATE; CI and inventory checks stay read-only.
- Load STATE and relevant whole records within an explicit budget with
  `bash scripts/load-context.sh --budget 12000 "query"`.
- Optional `tags: [topic, system]` frontmatter improves retrieval.

## Evidence and limits

The v0.5.0 snapshot was observed on 2026-10-08, before v0.6.0 shipped. Two production repositories used the same byte-identical 588-line shared guard; each kept its own checks in a local extension.

| Repository | Observed use |
|---|---|
| **medulla** | 96 decisions, 51 lessons, and 89 plans. Its 23-line local guard checks tracked state/secret-shaped files, architecture budgets, and contract drift. |
| **flimapp** | Its 80-line local guard checks release-ledger/app-manifest alignment, store copy/build-number alignment, and API inventory updates. |

Both repos are run by Fragment's author (n=2). This shows the shared guard fitting two different systems; it is not independent adopter validation. The case study also records earlier source-repo evidence: CI caught three documentation failures from one rename, and a second contributor followed the same handoff pattern in 7 of 7 commits.

**Limits:** no time or token savings have been measured, and the current benchmark is incomplete. Fragment checks documented continuity and workflow structure; it does not prove that application code is correct. See [`CASE-STUDY.md`](CASE-STUDY.md) for the evidence and its limitations.

## Learn more

- [Agent protocol](docs/AGENT-PROTOCOL.md) · [continuity and migration](docs/continuity.md)
- [Filled-in example](examples/online-shop/START-HERE.md) · [agent install guide](INSTALL.md)
- [Changelog](CHANGELOG.md) · [all documents](docs/README.md)

## License

[MIT](LICENSE).
