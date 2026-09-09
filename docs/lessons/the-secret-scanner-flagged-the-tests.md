---
id: lesson-scanner-vs-fixtures
title: The secret scanner flagged the tests that prove it works
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# The secret scanner flagged the tests that prove it works

## Symptom

The first time the shipped workflow ran here, gitleaks reported two leaks: a fake
AWS access key id and a fake GitHub token, both in `tests/run.sh`.

## Root cause

They are supposed to be there. The guard carries a secret tripwire, and a
tripwire can only be tested against strings that look like secrets. The scanner
was right about the shape and wrong about the intent, which is the only kind of
mistake a scanner can make.

Found on the first run of the workflow against this repository, because until
today Fragment did not use Fragment.

## Rule

**Any repository that tests a secret detector needs an allowlist for its
fixtures, and the allowlist names the file rather than the finding.** Pinning a
fingerprint pins a commit; naming the file survives every edit to it.

`.gitleaks.toml` here exempts `tests/run.sh` and nothing else. It is the one file
where a credential-shaped hit means the tests are working.

**This will happen to adopters**, so it is called out in the workflow Fragment
ships rather than left to be rediscovered.
