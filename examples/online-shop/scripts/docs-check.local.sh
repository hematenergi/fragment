#!/usr/bin/env bash
# Local rules — true for this shop and nobody else's repository.
#
# The shared guard (scripts/docs-check.sh) knows about documents, not about us.
# Anything specific to this project goes here, so that pulling a newer shared
# guard never overwrites it. err / warnf / note / scan are available.

# Invariant 1: no customer detail ever enters this repository.
# A phone number here means one that starts + or 0 and runs on for nine digits
# or more; a date like 2026-08-26 does not match, which is the point.
scan '(\+[0-9]{7,}|[^0-9]0[0-9]{9,})' \
  | grep -q . && err "something shaped like a phone number is in a document. Invariant 1: refer to an order by its number"

scan '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  | grep -viE 'example\.com|noreply' \
  | grep -q . && err "an email address is in a document. Invariant 1: refer to an order by its number"

# A runbook nobody but its author has followed is a runbook that fails at 3am.
for f in docs/runbooks/*.md; do
  [ -e "$f" ] || continue
  case "$f" in */README.md) continue ;; esac
  grep -qi '^tested by:' "$f" || err "$f — no 'Tested by:' line. Someone other than the author has to have followed it"
done
