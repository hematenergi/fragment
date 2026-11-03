---
id: decision-0010
title: Opt-in local context with independent Git handoff history
status: active
owner: hematenergi
last-verified: 2026-11-03
tags: [local, installation, evidence, continuity]
---

# Opt-in local context with independent Git handoff history

## Context

The owner wants Fragment usable when a developer cannot add workflow files to
the shared repository. Ignoring STATE alone loses its Git comparison baseline:
an old, untracked handoff can repeatedly appear new to the guard.

## Decision

An explicit local install places the ordinary template under .fragment/ and
excludes it using the host repository's Git info/exclude. It creates an
independent Git repository there, without a remote. The host's instructions,
tracked files, ignore rules and CI stay under the host team's control.

The local command hashes host HEAD, status, staged and unstaged diffs and
untracked file contents into a tracked snapshot in the context repository.
The ordinary guard then requires substantive STATE additions against the last
local commit. Only a successful explicit close commits a new context baseline;
an unsuccessful close and a check never advance it. The wrapper must preserve
the existing guard's structural and automatic STATE-budget behavior.

## Why

Git already supplies portable history and comparison using the existing runtime
contract. This reuses the canonical guard instead of inventing a second parser
or pretending that ignored files have host Git history. Hashed host changes
provide evidence triggers without storing application diffs in the context.

## Consequences

Local mode provides personal continuity and local checks, without shared CI
enforcement. The user explicitly directs an agent to the local entry point;
automatic discovery is not promised. Each worktree has separate context. Backup
and removal instructions must cover the complete directory, including .git.
There is no network sync or encryption guarantee. The guard still checks
document structure and body additions, not the truth of prose or application
correctness. Release v0.7.0 makes no benchmark or productivity claim.

## To change this

Record a new decision before adding synchronization, shared enforcement or a
different evidence baseline. Revisit local upgrade support separately; this
first release refuses to overwrite an existing local workspace.
