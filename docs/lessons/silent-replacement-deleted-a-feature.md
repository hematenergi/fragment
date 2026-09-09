---
id: lesson-silent-replacement
title: A silent replacement deleted a feature, and the board stayed green
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# A silent replacement deleted a feature, and the board stayed green

## Symptom

The `--max-warnings` option vanished from the guard. Nothing reported it. The
test suite was green, CI was green, and the option had simply stopped existing.

## Root cause

An automated edit — a `python .replace()` whose pattern no longer matched —
removed the whole block instead of changing it. Python's `str.replace` does not
raise on a miss; it returns the string unchanged, or in this shape, mangled.

It stayed hidden because the same session had trimmed that feature's tests for
an unrelated reason. Feature gone, tests gone, board green. That is precisely
the class of failure this repository exists to make impossible, reproduced
inside the repository itself.

## Rule

**Every automated text replacement asserts that it landed.** Count the
occurrences before replacing, assert the new text is present and the old text is
absent afterwards, and fail loudly on a miss.

The second half matters as much: **a feature disappearing must not be able to
take its tests with it in the same change.** When a diff removes both a feature
and its coverage, that is not a tidy-up — it is the one shape no review should
wave through.
