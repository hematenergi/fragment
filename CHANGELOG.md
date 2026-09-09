# Changelog

## Unreleased

## 0.3.0 — 2026-09-09

### Upgrading from 0.2.0 — every parked fragment needs a reason

`status: parked` now requires a `reason:` in the frontmatter, and the new
`status: superseded` requires a `superseded-by:`. Existing parked fragments will
fail until you add one line each. That is the whole migration.

### Added — somewhere to put a fragment the world overtook

Most fragments do not end by being finished. They get overtaken by work that
happened elsewhere, or they stop mattering. Until now the vocabulary had nowhere
to say so: `done` demands ticked boxes and pasted commands, which work done
outside the fragment cannot supply, and `parked` demanded nothing at all.

- **`superseded` joins the fragment lifecycle**, and must name what replaced it
  in `superseded-by:` — another fragment, a ticket, a commit. A superseded file
  with no pointer is a dead end, which is the thing this repo exists to prevent.
  It applies to documents too, where the same promise was already being made in
  the glossary and never enforced.
- **`parked` now costs a `reason:`.** It used to demand nothing, which made it
  the cheapest way for anyone — an agent most of all — to turn a red board
  green: park everything, explain nothing. The guard's own error message
  suggested it ("or park the fragment and say why") while never checking that a
  why was written.
- **A `todo` untouched for 30 days now warns**, with `STALE_TODO_DAYS` to change
  the threshold. A queue nobody revisits is not a queue; this is what surfaces
  the fragments that were quietly overtaken, instead of leaving them to look
  like work that is still coming.

### Changed

- The two status vocabularies are now written once and everything derives from
  them, including the board's accepted tokens. Adding `superseded` to the
  lifecycle without teaching the board about it would have recreated the 0.1.0
  defect exactly; a test now asserts the board can mirror every fragment status.

## 0.2.0 — 2026-09-09

### Upgrading from 0.1.0 — this one can turn an existing repo red

`status: active` on a fragment now **fails**, where 0.1.0 let it warn forever.
If your `docs/plans/` has fragments marked `active`, `draft` or `superseded`,
they will each raise an error until you move them onto the fragment lifecycle:
`todo`, `in-progress`, `done` or `parked`. A fragment being worked on right now
is `in-progress`.

That is the point — those fragments were never satisfiable before, so the red is
older than this release. But it arrives the moment you copy the new guard in,
and the installer does not overwrite files, so it arrives when you choose.

### Fixed — a fragment could declare a status it was then punished for

- **`status: active` on a fragment was impossible to satisfy.** The frontmatter
  check accepted `active`, `draft` and `superseded` on any document; the board
  check only recognised `todo`, `in-progress`, `done`, `parked`. So a fragment
  marked `active` either warned forever ("no row carries a `status` token") or,
  if you did add a row, failed with *"one of them is lying"* — blaming two files
  that were both telling the truth. No board edit could clear it; the only way
  out was to guess a different status.

  `HOW-WE-WORK.md` was teaching the wrong word: *"One **active** fragment at a
  time"*, when the lifecycle value is `in-progress`. That sentence is where the
  broken state came from in the repo Fragment was extracted from — eleven
  fragments marked `active`, eleven permanent warnings, and a board column
  filled with prose because no token fit.

  The two vocabularies are now enforced separately, at the file: documents are
  `active`/`draft`/`superseded`, fragments are `todo`/`in-progress`/`done`/`parked`.
  The error names the vocabulary it wanted instead of pointing at the board.

- **The tests could not have caught it.** Every fragment fixture used
  `status: todo` — the one value that worked. The suite now walks the whole
  vocabulary in both directions and asserts every legal fragment status can
  actually reach green.

- **`is_fragment()` is now the single definition of what a fragment is.** The
  vocabulary check and the board check used to describe that set separately.

### Added

- **`--version`**, on both the guard and the installer. An installed copy
  carries `FRAGMENT_VERSION`, so a repo that adopted Fragment months ago can be
  asked what it is running — previously nothing on disk recorded it.
- **`install.sh --dry-run`** — list what would be written, touch nothing.
- **Re-running the installer recognises an existing install** and names both
  versions, instead of looking like a fresh install that mostly skipped.
- **`DOCS_ROOT`** — documents no longer have to live in `docs/`. The path was
  hardcoded in about thirty places, which kept the guard out of every repo that
  had settled on another name, and out of monorepos entirely.
- **`--max-warnings N`** — fail when more than N warnings survive. Warnings
  still never fail the build on their own; this makes the count a ratchet once
  the backlog is down, so it stays something people read.

## 0.1.0 — 2026-08-28

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

- `tests/run.sh` — 43 cases. The guard had none.
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
- `examples/online-shop/` — a complete filled-in repo, green, checked by CI,
  with a test that fails if its vendored copy of the guard ever drifts from the
  canonical one.
- `CASE-STUDY.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, issue
  and PR templates, and CI for this repo on Linux, macOS and Windows/Git Bash.
