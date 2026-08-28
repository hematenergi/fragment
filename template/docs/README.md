---
id: docs-index
title: Document index
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Document index

**Every file under `docs/` must be listed on this page.** Anything unlisted is treated as junk — `scripts/docs-check.sh` will find it.

> Rules for this repo are guarded by machine, not goodwill. `scripts/docs-check.sh` runs in CI on every push and pull request, whoever pushes and whatever tool they used. Local hooks only apply to the tool that installed them; CI cannot be bypassed by switching tools.

New here? Start at [`../START-HERE.md`](../START-HERE.md).

## Source-of-truth hierarchy

When two documents disagree, the higher one wins. If the higher one is wrong, **fix the higher one**.

1. Running code and its records
2. `<agreement / charter, if any>`
3. [`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md)
4. [`decisions/`](decisions/) → [`architecture/`](architecture/) → [`plans/`](plans/) → everything else

## Entry points

| File | What it is |
|---|---|
| [`../START-HERE.md`](../START-HERE.md) | For anyone new, engineer or not |
| [`STATE.md`](STATE.md) | **Where the work stands.** Read first, write last |
| [`HOW-WE-WORK.md`](HOW-WE-WORK.md) | Team rhythm: fragments, status labels, who decides what |
| [`GLOSSARY.md`](GLOSSARY.md) | Jargon in plain language |
| [`AGENT-PROTOCOL.md`](AGENT-PROTOCOL.md) | The working contract for every agent and human |

## Fragments

| File | What it is |
|---|---|
| [`plans/README.md`](plans/README.md) | How fragments work, and the phase gates |
| [`plans/executor-prompt.md`](plans/executor-prompt.md) | Paste-ready prompt to continue work |
| [`plans/00-template.md`](plans/00-template.md) | Template for a new fragment |

## Decisions

| File | What it is |
|---|---|
| [`decisions/README.md`](decisions/README.md) | Decision format and the next number |

## Lessons

| File | The rule |
|---|---|
| [`lessons/README.md`](lessons/README.md) | Symptom → Root cause → Rule, and when to write one |

## Architecture

| File | What it is |
|---|---|
| [`architecture/README.md`](architecture/README.md) | What belongs here |

## Research

| File | What it is |
|---|---|
| [`research/README.md`](research/README.md) | Research notes and the verification convention |

## Runbooks

| File | What it is |
|---|---|
| [`runbooks/README.md`](runbooks/README.md) | What belongs here |
| [`runbooks/incident-template.md`](runbooks/incident-template.md) | Incident note template |

## Templates

| File | What it is |
|---|---|
| [`templates/daily-note.md`](templates/daily-note.md) | Daily note |
