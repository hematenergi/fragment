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
Install Fragment v0.6.1 from https://github.com/hematenergi/fragment into this repository.
Preserve existing files. Use only decisions supported by this repository and our conversation.
Run bash scripts/docs-check.sh and leave unknowns as blockers instead of guessing.
```

Or install from Bash:

```bash
git clone --depth 1 --branch v0.6.1 https://github.com/hematenergi/fragment
bash fragment/install.sh /path/to/your/repo
cd /path/to/your/repo
bash scripts/docs-check.sh
```

The first check may fail while template values are still present. Fill in the project facts it names, then run it again. The installer preserves existing files; merge them deliberately. To upgrade a recognized, unmodified guard and pruning helper:

```bash
bash fragment/install.sh --upgrade /path/to/your/repo
```

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

## Pick up the right context (v0.6.1)

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
