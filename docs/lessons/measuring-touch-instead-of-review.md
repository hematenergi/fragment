---
id: lesson-touch-vs-review
title: The staleness check measured touch, not review
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# The staleness check measured touch, not review

## Symptom

A warning shipped in 0.3.0 for a `todo` fragment left alone too long. In the only
repository using Fragment outside its own tests, it **never fired once** —
including on fragments nobody had opened in two seasons.

## Root cause

It read `git log -1 --format=%ct` on the fragment: the date the *file* last
changed. A single mechanical commit — a rename, a formatting pass, a frontmatter
sweep — touches every fragment at once and resets the whole queue's clock. One
such commit had landed a week before the check was written.

The check was measuring a proxy that looked right and answered a different
question: *was this file written to*, rather than *has anyone reconsidered this*.

## Rule

**When a check uses a proxy, name the question it is actually answering** and ask
whether a routine, blameless action can satisfy it by accident. If it can, the
check will read green through exactly the situation it was built for.

Staleness now reads `last-verified`, the one field whose meaning is a human
confirming the document is still true — the only signal here that a mechanical
commit cannot produce.
