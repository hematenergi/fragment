---
id: lesson-section-is-not-history-boundary
title: A section heading does not end a document's history
status: active
owner: hematenergi
last-verified: 2026-10-11
tags: [state, pruning, structure, testing]
---

# A section heading does not end a document's history

## Symptom

The automatic STATE pruner reported fixed content over budget on Medulla even
though the file contained many old dated records.

## Root cause

The parser treated the last level-two heading as the start of all history. A
later handoff heading made older dated records invisible, and the remaining
closed plan rows had no archive rule.

## Rule

Find structural records throughout the document, not only in the final section.
For non-session rows, require explicit status and corroborate it against the
linked source file. Keep a realistic multi-section adopter fixture in the test
suite so local behavior matches the documents teams actually use.
