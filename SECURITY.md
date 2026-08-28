# Security

## Reporting a vulnerability

Open a [private security advisory](https://github.com/hematenergi/fragment/security/advisories/new)
rather than a public issue. Expect an acknowledgement within a week.

## What this project is, in security terms

`docs-check.sh` runs in your CI and in your shell. It reads markdown and calls
`git`, `grep`, `sed`, `awk` and `find`. It never executes anything it finds in a
document, never makes a network request, and never writes to your repository.

Two things are worth knowing:

**The secret patterns are a tripwire, not a scanner.** They catch a handful of
high-confidence shapes — PEM private keys, AWS key ids, GitHub and Slack tokens,
bare 32-byte hex, `api_key = …` assignments — so that an obvious leak fails on a
laptop in two seconds. They will miss most other formats. The shipped workflow
runs [gitleaks](https://github.com/gitleaks/gitleaks) for that reason. **A green
run is not a statement that your repository is clean.** If you treat it as one,
the tripwire has made you less safe, not more.

**`scripts/docs-check.local.sh` is sourced, not sandboxed.** The guard runs it as
shell in your shell. That is the point — it is your extension hook — but it means
the file deserves the same review as any other script in your repo. Do not accept
one in a pull request without reading it.

## Reporting a false negative

A credential shape the tripwire misses is worth an issue, with a synthetic
example — never a real credential, even an expired one. Add a case to
`tests/run.sh` if you can.
