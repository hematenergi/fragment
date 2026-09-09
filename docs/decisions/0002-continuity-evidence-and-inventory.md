---
id: decision-0002
title: "0002 — separate continuity evidence from documentation inventory"
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# 0002 — separate continuity evidence from documentation inventory

**Decided** 2026-09-09 from the owner's mature-adopter proposal (fragment 05).

## Contract

Daily checks cover the core entry points, open fragments, changed documents and
contracts explicitly selected with `--check-doc path`. The index is a directory,
not a recursive declaration that everything it links is active. Historical
structural findings and age/size hints appear only with `--inventory`. Secrets
remain a checkout-wide document tripwire. Inventory never spends warning budget.

Local session comparison defaults to HEAD versus the worktree (including staged
and untracked non-ignored files). `BASE_REF` selects committed base-to-HEAD work
for CI; `--worktree` includes pending work against that base for a longer local
session. Positional Git pathspecs after `--` narrow work and allow exclusions.
They express scope, not inferred ownership. Shared files with multiple owners
need a separate checkout or an agreed whole-file scope; no hunk attribution is
claimed. Invalid explicit bases are errors. No history means no session proof.

The default evidence destination is STATE. Repeated `--handoff path` selects
the affected checkout destinations instead. The guard checks for new prose in
their bodies, excluding metadata, headings and punctuation-only additions. It
does not read a specific English heading, demand a middle dot, or interpret the
meaning of Markdown. GREEN says body updated, not truth verified. Agents check
results, next steps, contradictions and whether all necessary destinations were
selected; an external write cannot be certified by a checkout diff.

Optional STATE_FILE, PROTOCOL_FILE and INDEX_FILE select existing core paths;
the roles may share one file. Defaults preserve ordinary installs. Keep those
values in existing command/CI configuration, described by the protocol, without
introducing a manifest or duplicating an existing board.

## Source authority and portability

Use a role table in the existing protocol. One fact has one primary home; other
documents point to it. Agent instructions cover daily selection, open carry-over,
read/write permissions, latest-state reads before retries, partial handoffs and
portable decisions. No mandatory integration, manifest, private path or daemon.
An unavailable source only blocks work that needs information absent elsewhere.

## Consequences

This replaces fragments 02 and 03's warning-triage proposals: their premise that
all date discrepancies are actionable warnings was contradicted by the adopter.
There is no bulk date bump or migration of historical documentation. Existing
protocols remain user-owned, so upgrade documentation calls for reviewing the
new source/evidence contract deliberately, without overwriting their rules.
