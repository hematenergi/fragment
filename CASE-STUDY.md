# Case study — the repo this was extracted from

Fragment was not designed and then tried. It was extracted from a private repo
after it had already survived a hard week. This page is what the git history of
that repo actually shows, so you can judge the claim rather than take it.

The repo is private and not mine alone to publish, so what follows is commit
SHAs, timestamps and shapes — not contents. Everything here is reproducible
from `git log` by anyone with access.

**The setting.** Two people. One on macOS driving Claude Code, one on Windows
driving Codex. They had never worked in the same session. 25 commits over 18
hours, from `830ea42` (2026-08-26 16:20 +07) to `c1ec15f` (2026-08-27 10:21 +07).
Result at the end of that window: 62 documents, 9 lessons, 7 decisions, 8
fragments, a 117-line protocol, and front doors of 16 and 23 lines.

---

## 1. The second contributor adopted the ritual without being taught it

This is the finding that made the harness worth extracting.

Seven commits came from the second contributor. **All seven have the identical
shape** — no exceptions, no reminders, no shared chat session:

```text
docs/README.md                  +1   (the index)
docs/STATE.md                   +1   (the session log)
docs/research/<name>/<new>.md        (the actual work)
```

```bash
git log --author=<partner> --stat --format='%h %s'
```

Two people, two different agents, two different machines, converging on the same
three-file move because they read the same protocol file. That is the whole
thesis, and it is the only part of it that could not have been designed in
advance.

**What did NOT transfer, and this matters more than the part that did:** all
seven of that contributor's session-log entries carry `—` in the fragment
column. They never took a fragment. They never touched `plans/`, the queue,
`depends-on`, or the phase gates. Their entire use of the harness was:
**the index, the board, and CI.**

That is why this repo now ships in tiers. What transferred to a second person
in the wild is a much smaller thing than what the first person built for
themselves — and it would be dishonest to keep selling the larger one.

## 2. The guard caught a real incident 74 minutes after being installed

| Time (+07) | Commit | What happened |
|---|---|---|
| 18:20:35 | `9211014` | `docs-check.sh` wired into GitHub Actions |
| 19:34:37 | `cc75448` | a file renamed through the GitHub web UI |
| 19:40:26 | `6107872` | fix, plus an incident note |

One ordinary rename broke three rules at once: the index link went dangling, the
renamed file was no longer listed, and the session ritual was skipped. CI failed
on all three within minutes.

Nobody was being careless. The rename was correct housekeeping done in the
obvious place. **That is the point:** the failure mode is not negligence, it is
that renames through a web UI cannot see an index they do not know exists.

The fix commit's body names all three violations. `git show 6107872`.

## 3. The second contributor improved the guard itself

Commit `0158c3d` — from the partner, not the author — added an exception to the
secret scanner: a block-explorer URL carries a public 64-hex hash, not a private
key, and was tripping the check.

A teammate who patches your linter has stopped treating it as your rule.

It is also the clearest argument for `scripts/docs-check.local.sh`. That
exception is true for one repo and meaningless everywhere else, and it does not
belong in a script other people install.

## 4. The verification convention fired in both directions, inside 24 hours

`docs/research/` says: **a verification recomputes from raw data; it does not
cite.** Applied without exception, including to yourself.

- Outward. A research document reported an **8.08×** result. Recomputing found
  the figure had been computed over 25 of 2,694 cases — the ones that produced a
  measurable outcome, which a case only did when it succeeded. 95% of the cost
  was invisible. Textbook survivorship bias, invisible in review because the
  selection happened a layer below the argument. Commit `bc9f00d`.
- Inward, same commit. Applying the rule to the reviewer's *own* earlier number
  found a 4-day window had been mistaken for a 26-day history. The headline
  metric moved **0.374 → 0.604**, the 95% interval now crossed the break-even
  line, and a previously confident claim was withdrawn.

The second half is the one that makes the convention worth keeping. Anyone will
recompute a rival's numbers.

## 5. What the history does not prove

Stated plainly, because a case study that only flatters itself is marketing.

- **Concurrency is untested above two people.** There are zero merge commits in
  those 25 — but the timeline shows strict turn-taking, with gaps of 30 minutes
  to 7 hours, and one `git pull --rebase` (`4606f2c`, author 19:39:34, commit
  19:40:13). Every one of the partner's commits appends at the same anchor in
  `STATE.md`. It has not conflicted because *n*=2 and they sleep at different
  hours. The `merge=union` line now shipped in `.gitattributes` is a mitigation,
  not a proof.
- **The cross-OS claim is not in the git data.** There are no CRLF artifacts and
  there was no `.gitattributes` — consistent with the partner never running the
  bash guard locally, and relying entirely on CI. Which, if true, means CI was
  the only enforcement the second contributor ever saw. That is an argument for
  CI, not against it, but it is not the same as "the script is proven on
  Windows."
- **The harness governs documents, not code.** Nothing here shows the guard
  preventing a bug. It shows it preventing *lost context* and *repeated
  decisions*. The `status: done` checks added since are an attempt to reach one
  step closer to the code; they are new and unproven.
- **Extraction lost things.** Diffing the published copy against the origin
  found the open-source version had quietly demoted a missing front door from
  failure to warning, and dropped a check that is still firing on five files in
  the origin repo today. Both are restored. The lesson generalises: a harness
  extracted by hand drifts from the harness that earned the evidence — which is
  the failure this project is nominally about.
