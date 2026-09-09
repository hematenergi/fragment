---
id: continuity
title: Continuity — sources, evidence and inventory
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# Continuity and source roles

The protocol's role table names the source of session direction, project
position, task evidence, durable decisions, operational contracts and history.
Use existing files and formats. Repo-only projects need no daily integration.
Each fact has one primary home; other destinations link or summarise it.
Record who may read or write each selected source and which source has authority
when two claims disagree. Timestamps do not settle authority.

## Opening and reviewing

Use the daily, ticket or brief selected by the user for this session. Automatic
daily discovery must be explicitly configured with directory, timezone, date
format and language. Do not choose by mtime or search unrelated personal folders.
If several relevant candidates remain, ask for that choice and continue work
that does not depend on it.

Read the task and the contracts needed for the current decision. Verify the
relevant claims against code, contracts or available records before relying on
them. Neither a recent review date nor GREEN proves that a claim is true.
Resolve conflicts that affect this work with the authoritative source; report
the evidence, affected decision, location and next action. Do not recursively
read the entire index merely because it contains links.

## Rollover, permissions and partial results

A new day does not close unfinished work. Carry over only open work and pending
decisions, with source references. Check authoritative task status before
carrying anything over; do not revive completed work from yesterday's note.
Preserve previous dailies as history. Create a new daily only when the user's
workflow and permission call for it.

For each result, identify the affected destinations and update their relevant
sections in their own format. A UI change may affect task evidence, STATE's next
step and one daily task block. An API decision may also affect its contract.
Do not rewrite unrelated sections or require every destination to change.
A source can be read-only. Connector access does not grant permission to move a
task tracker status.

Read the latest destination before writing, preserve other people's edits, and
locate the existing task/session block before retrying. Update that block rather
than appending duplicates. Confirm writes through the available tool. If one
write fails, report which destinations are saved and pending; supply the exact
ready-to-copy entry. Do not claim the whole handoff is complete until required
writes are confirmed. Once confirmed, finish without an extra ritual question.

Record the portable decision, reason, source reference, blocker and next step
needed by the next person in the repo's chosen durable home. Do not copy a whole
private daily, personal path or credential into a shared repo. An unavailable
external source blocks only decisions requiring information not already
available. A teammate without Obsidian must still find the needed durable context.

## What the guard proves

The daily command checks core documents, open fragments, documents changed in
scope and explicitly selected contracts. An index link does not recursively
activate its target. Historical document structure and review-date/size clues
are optional inventory. Secret-shaped content remains a document-wide tripwire.

Local comparison is HEAD to the worktree, including staged and untracked
non-ignored files. A clean checkout has no new handoff obligation. No Git
history means structural checks can run but session comparison is unavailable.
No dummy fragment is required.

Existing core filenames can be selected with `STATE_FILE`, `PROTOCOL_FILE`
and `INDEX_FILE`, using repo-relative paths. They may all name one existing
document holding several roles. `DOCS_ROOT` selects the documentation directory.
Front doors point at the selected protocol; no duplicate state files are needed.
Put these choices in the project's existing command/CI environment and document
them in its protocol, rather than adding a per-document manifest.

`BASE_REF` selects committed base-to-HEAD work, normally in CI. An invalid
explicit base fails and must be fetched or corrected, never silently replaced.
Use `--worktree` with that base for a local session spanning commits.
The guard inspects checkout files for structure; committed evidence comes from
Git objects, so an unstaged handoff cannot satisfy CI.

```bash
bash scripts/docs-check.sh
bash scripts/docs-check.sh --inventory
DOCS_ROOT=knowledge STATE_FILE=knowledge/HUB.md PROTOCOL_FILE=knowledge/HUB.md INDEX_FILE=knowledge/HUB.md bash scripts/docs-check.sh
bash scripts/docs-check.sh --check-doc docs/contracts/payments.md
bash scripts/docs-check.sh --handoff docs/plans/07-checkout.md --handoff notes/session.md
bash scripts/docs-check.sh -- src/checkout docs/plans/07-checkout.md ':!src/checkout/generated/**'
BASE_REF=HEAD~2 bash scripts/docs-check.sh --worktree
```

Paths for `--handoff` and `--check-doc` are explicit repo-relative checkout
paths, repeatable. STATE is the default handoff destination; explicit destinations
replace that default. Select only affected destinations from the role table.
No external write is proved by listing a path. Record external results in the
selected checkout handoff and separately confirm the actual write.

Git pathspecs after `--` select session work and can exclude generated/cache
paths or another session's files. Ignored untracked files are already excluded.
Scope is an explicit team decision; a diff cannot infer ownership. For parallel
edits to the same file, use an isolated checkout or agree a whole-file range.
The guard does not attribute hunks to people.

Handoff evidence is new body text at the selected destinations. Metadata,
headings, comment-only edits, date-only edits and punctuation are insufficient.
The minimum is 24 non-whitespace, non-digit, non-punctuation bytes of new body
text after comparing normalised lines. This deliberately modest structural
floor accepts multilingual prose and existing task formats without claiming to
understand Markdown. It does not prove validation was run, a next step is
correct, or an external write happened. The agent checks those facts. Keep code
fences and checkbox evidence for fragments claiming `done`.

`--max-warnings` still applies to actionable warnings, including local rules.
Inventory never spends that budget. GREEN names checked structure and the
available session evidence; it does not certify all documentation.

## Migrating an existing install

Upgrade the guard with `install.sh --upgrade`. Existing protocol, daily and
workflow files are user-owned and must be reviewed for these changes; they are
not overwritten. Review the role map and replace unconditional STATE/log rituals
with updates to the affected destinations. Keep your own invariants and status
permissions. Never mass-stamp dates, park all tasks or archive history to pass.

The workflow must pass its actual comparison base. A branch's first push has no
prior branch snapshot: report that limitation explicitly (or deliberately choose
a documented base). Other missing bases fail. CI checks only checkout evidence
and integrations actually available to it; private notes are not required.
