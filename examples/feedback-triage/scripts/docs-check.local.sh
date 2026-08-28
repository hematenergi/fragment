#!/usr/bin/env bash
# Local rules — true for this repo and nobody else's.
#
# The shared guard (scripts/docs-check.sh) knows about documents, not about us.
# Anything specific to this project goes here, so that pulling a newer shared
# guard never clobbers it. err / warnf / note / scan are available.

# Invariant 1: no customer identity ever enters this repository.
scan '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  | grep -viE 'example\.com|@team|noreply' \
  | grep -q . && err "an email address is in a document. Invariant 1: reference an item by id, never by person"

# A runbook nobody but its author has followed is a runbook that fails at 3am.
for f in docs/runbooks/*.md; do
  [ -e "$f" ] || continue
  case "$f" in */README.md) continue ;; esac
  grep -qi '^tested by:' "$f" || err "$f — no 'Tested by:' line. Someone other than the author has to have followed it"
done

# Internal hostnames belong in the deploy repo, not in documents people read.
scan '([a-z0-9-]+\.internal|10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' \
  | grep -q . && warnf "an internal hostname or private IP appears in a document"
