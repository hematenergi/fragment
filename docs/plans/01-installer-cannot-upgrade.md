---
id: plan-01
title: "01 — install.sh cannot upgrade an existing install"
status: todo
owner: hematenergi
last-verified: 2026-09-09
depends-on: []
---

# 01 — install.sh cannot upgrade an existing install

**Goal.** Someone on an older Fragment can reach the current one without copying
files by hand.

## Why this is needed

`install.sh` only writes files that do not exist. That is correct for a first
install and useless for every one after it. Run against a repository already on
0.1.0 it reports `0 would be written, 22 already exist` and stops — so the guard,
the part that actually changes between releases, never arrives.

Observed in flimapp, which is on an old guard for exactly this reason.

## Read first

- `../../install.sh` — the copy loop and the existing-install detection
- `../decisions/` — nothing settled here yet; the shape is an open question

## Work

- [ ] Decide the shape: `--upgrade`, or a diff printed for the guard only
- [ ] Report per file what would change, not just that it exists
- [ ] Never silently overwrite a file a team has edited

## Done when

- [ ] A repository installed at an older version can reach the current guard
      with one documented command
- [ ] A file the team has customised is never overwritten without being named
- [ ] The dry run still writes nothing

## Traps

Most adopters edit `AGENT-PROTOCOL.md` — that is the point of it. An upgrade path
that treats every template file the same will either clobber their invariants or
refuse to move the guard. The guard and the prose need different rules.

## Validation

```bash
# to be filled in when the work is done
```

## Out of scope

Version pinning, rollback, anything resembling a package manager.

## Session log

- `2026-09-09` · claude · queued while installing Fragment into Fragment · next: decide the shape before writing code
