---
id: research-index
title: Research — notes, and how they get verified
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Research

Research notes per person, plus independent verification. Deliberately separate from a claims/theses folder: **here is where you observe and hypothesize**; a claim with a number attached graduates elsewhere.

## Rules

- **Notes go in the author's own folder** — `dhika/`, `dany/`, `<name>/`. That is their note. Do not edit someone else's.
- **Verification is a separate document.** Never overwrite the original. Write your own, and link both ways.
- **A verification recomputes. It does not cite.** If you are repeating the original's numbers, you have not verified anything.
- State plainly what **could not** be established, not only what could.
- Research does not become code directly. It graduates through a written claim with a pre-registered gate first.

## The verification convention, and why

This is the part teams get wrong, so it is worth being explicit.

When someone brings a finding, the instinct is to accept the numbers and argue about the interpretation. That gets it backwards: the interpretation is usually fine and **the numbers usually contain a selection effect nobody noticed.**

The convention that catches it: pull the raw data yourself, recompute, and write your result as its own document. It costs an hour. In the repo this template came from, it caught a survivorship bias that made a losing strategy look like an 8× winner — and, a week later, caught the reviewer's *own* earlier number being wrong in the other direction.

Both were found by the same rule, applied without exception, including to oneself.

## Structure

```text
research/
  <name>/           notes by that person
  verdict-*.md      verification of a specific note, standing on its own
```
