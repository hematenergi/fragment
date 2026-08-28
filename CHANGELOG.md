# Changelog

## Unreleased

The guard was audited against the private repo it was extracted from, and
against its own claims. Both found problems.

### Fixed — the guard was passing things it promised to catch

- **An untouched install used to come out green.** Every `<PLACEHOLDER>` intact,
  every `owner: unassigned`, every `last-verified: <YYYY-MM-DD>`, no fragments —
  green, exit 0. The README called the guard "your to-do list"; it was not one.
  It now fails until the install is genuinely finished, and names each thing.
- **Frontmatter was checked for key presence only.** `last-verified: banana`,
  `owner:` empty and `id:` empty all passed. Values are now validated;
  `last-verified` must be a real ISO date.
- **The session-ritual rule could be satisfied with two characters.** A line
  reading `- x ·` passed. It now has to look like a handoff, and says so with
  the offending line when it does not.
- **The staleness check never ran in CI.** It read filesystem mtime, which every
  `git clone` resets to now. It reads git commit dates now, and there is a test
  that clones the repo and asserts the warning survives.
- **Dangling links with an `#anchor` were skipped entirely.** Only bare `.md`
  links were checked.
- **`docs/plans/*.md` was not recursive**, so a third `in-progress` fragment in a
  subdirectory evaded the one-at-a-time rule.
- **The index check used the path as a regex**, so `.` matched any character.
- **A contradictory pair of messages** could print together: "STATE.md did not
  change" immediately followed by "STATE.md changed but...".
- **An unusable `BASE_REF`** — the all-zero SHA GitHub sends on the first push to
  a branch — silently skipped the ritual check and reported green. It now says
  it skipped, and the workflow falls back to `HEAD~1`.
- **`install.sh` with a non-existent target** resolved the destination to the
  empty string and attempted to copy the template into `/`.
- **Windows checkouts converted Markdown fixtures to CRLF**, so the guard's
  cross-platform suite failed before exercising the intended cases. Root
  attributes now keep shell and Markdown files on LF without dropping Windows CI.
- **The public example linked to documents that were not shipped.** Its complete
  documentation snapshot now runs through the guard as a regression case.

### Fixed — regressions introduced when the guard was extracted

Diffing against the origin repo found the open-source copy was *weaker* than the
version that earned the credibility:

- **A missing `CLAUDE.md`/`AGENTS.md` had been demoted from failure to warning.**
  Restored to a failure.
- **The public-identifier check had been dropped entirely.** It is restored, and
  it is currently firing on five files in the origin repo.

### Added

- `tests/run.sh` — 41 cases. The guard had none.
- `status: done` now means done: unticked checkboxes and a fragment that records
  no commands both fail. Language-independent by construction.
- Fragment `status:` is cross-checked against its row on the board. Two places
  claiming different things is the exact drift this project exists to prevent.
- `last-verified` is compared against the file's git history, and warns when the
  content is newer than its last review.
- Secret patterns for AWS key ids, GitHub tokens, Slack tokens and PEM private
  keys. The previous set caught 2 of 6 planted credentials.
- `scripts/docs-check.local.sh` — an extension point the guard sources if it
  exists. Domain-specific rules belong to the repo that needs them, not to
  everyone who installs this. The first pass at restoring the dropped
  public-identifier check put a domain-specific pattern in the shared script,
  which contradicted the one claim on the front page: stack-agnostic. It is now
  an example in `docs-check.local.sh.example` and the shipped guard has no
  opinion about any domain.
- gitleaks in the shipped CI workflow. The in-guard patterns are a tripwire; a
  half-built scanner that people trust is worse than none.
- `.gitattributes` — `eol=lf` for the shell script, and `merge=union` on
  `STATE.md` so two people appending on the same day do not conflict.
- `CASE-STUDY.md`, `CONTRIBUTING.md`, and CI for this repo on Linux, macOS and
  Windows/Git Bash.
