---
id: decision-0001
title: "0001 — one canonical guard, copied byte-for-byte, never linked"
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# 0001 — one canonical guard, copied byte-for-byte, never linked

**Decided** 2026-09-09.

## Context

`template/scripts/docs-check.sh` is the guard. Two other places need to run it:
`examples/online-shop/`, which has to be a working repository, and now
`scripts/`, so that Fragment can check itself. Three copies of a file whose
entire purpose is preventing undiffed duplicates is an obvious thing to object
to, and it will be objected to again.

## Decision

There is one canonical guard. The other two are **byte-identical copies**, and a
test asserts each. They are never symlinks.

## Why

A symlink is smaller and it is what most repositories would reach for. It fails
on the thing this project deliberately supports: a teammate on Windows. Git
checkouts there do not reliably materialise symlinks, and the guard-on-Windows
job in `tests.yml` exists because half the argument for pure bash is that a
Windows teammate can run it.

The copies are safe because the drift is machine-checked. That is the same trade
made everywhere else here — duplication is acceptable exactly when something
fails loudly the moment the copies disagree, and unacceptable otherwise.

## Consequences

- Every change to the guard has to copy it to both places in the same commit.
- The tests will refuse the commit if you forget, which is the point.
- `install.sh` writes a third copy into whoever installs it. Their copy is
  theirs; upgrading it is fragment 01.

## To change this

Evidence that symlinks now survive a Windows checkout reliably, or dropping
Windows support. Neither is on the table.
