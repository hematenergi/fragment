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
  <a href="#production-evidence">Production evidence</a> ·
  <a href="CASE-STUDY.md">Full case study</a>
</p>

<p align="center">
  <a href="https://github.com/hematenergi/fragment/actions/workflows/tests.yml"><img src="https://github.com/hematenergi/fragment/actions/workflows/tests.yml/badge.svg" alt="tests"></a>
</p>

Fragment is a small continuity harness around your coding agent. It stores project state, decisions, lessons, and active work as ordinary files. A Bash guard checks their structure and handoff in local runs and CI.

It works with the agent you already use. It does not run the model or decide whether your code is correct.

## Install

Ask your coding agent:

```text
Install Fragment v0.6.0 from https://github.com/hematenergi/fragment into this repository.
Preserve existing files. Use only decisions supported by this repository and our conversation.
Run bash scripts/docs-check.sh and leave unknowns as blockers instead of guessing.
```

Or install from Bash:

```bash
git clone --depth 1 --branch v0.6.0 https://github.com/hematenergi/fragment
bash fragment/install.sh /path/to/your/repo
cd /path/to/your/repo
bash scripts/docs-check.sh
```

The first check may fail while template values are still present. Fill in the project facts it names, then run it again. The installer preserves existing files; merge them deliberately. To upgrade a recognized, unmodified guard:

```bash
bash fragment/install.sh --upgrade /path/to/your/repo
```

## How it works

At the start of a session, the agent follows the repo's front door to the protocol, `docs/STATE.md`, active work, and relevant decisions or lessons. At the end, it records meaningful progress and the next move. The guard checks the required files, links, and handoff evidence so a missing update can fail the build.

```text
CLAUDE.md / AGENTS.md → docs/AGENT-PROTOCOL.md → docs/STATE.md
                       → active fragment → relevant decisions and lessons
```

Fragment's checks use Bash and Git, with no runtime database, daemon, account, or model API.

## v0.6.0 tools

- `bash scripts/recall.sh "query"` ranks decisions and lessons using deterministic keyword matching. No model call or network access.
- `bash scripts/state-prune.sh --keep 20` previews older STATE history for archival; add `--apply` to write the archive.
- `bash scripts/load-context.sh --budget 12000 "query"` assembles STATE and relevant whole records under a conservative size bound for the requested token budget.
- Decision and lesson files can use optional `tags: [topic, system]` frontmatter to improve retrieval.

## Production evidence

The v0.5.0 snapshot was observed on 2026-10-08, before v0.6.0 shipped. Two production repositories used the same byte-identical 588-line shared guard; each kept its own checks in a local extension.

| Repository | Observed use |
|---|---|
| **medulla** | 96 decisions, 51 lessons, and 89 plans. Its 23-line local guard checks tracked state/secret-shaped files, architecture budgets, and contract drift. |
| **flimapp** | Its 80-line local guard checks release-ledger/app-manifest alignment, store copy/build-number alignment, and API inventory updates. |

Both repos are run by Fragment's author (n=2). This shows the shared guard fitting two different systems; it is not independent adopter validation. The case study also records earlier source-repo evidence: CI caught three documentation failures from one rename, and a second contributor followed the same handoff pattern in 7 of 7 commits.

**Limits:** no time or token savings have been measured, and the current benchmark is incomplete. Fragment checks documented continuity and workflow structure; it does not prove that application code is correct. See [`CASE-STUDY.md`](CASE-STUDY.md) for the evidence and its limitations.

## Learn more

- [Agent protocol](docs/AGENT-PROTOCOL.md) · [continuity and migration](docs/continuity.md)
- [Filled-in example](examples/online-shop/START-HERE.md)
- [Changelog](CHANGELOG.md) · [all documents](docs/README.md)

## License

[MIT](LICENSE).
