<p align="center">
  <img src="assets/fragment-logo-square.jpg" alt="Fragment logo" width="180">
</p>

<h1 align="center">Fragment</h1>

<p align="center">
  <em>The session ends. The context doesn't.</em>
</p>

<p align="center">
  <a href="https://github.com/hematenergi/fragment/actions/workflows/tests.yml"><img src="https://github.com/hematenergi/fragment/actions/workflows/tests.yml/badge.svg" alt="tests"></a>
</p>

<p align="center">
  <sub><strong>74 minutes</strong> from install to catching its first real incident &middot;
  <strong>7 of 7</strong> commits from a second contributor who was never in the room &middot;
  <strong>bash + git</strong>, nothing else<br>
  <a href="CASE-STUDY.md">The git history behind those numbers</a> &middot;
  <a href="docs/why.md">every rule, and the failure that produced it</a></sub>
</p>

---

It is Monday. You ask the agent to pick up where you left off. It reads the
code, infers a plan, and confidently proposes the approach you rejected on
Thursday — for exactly the reasons you rejected it, which it cannot see,
because they were in a chat window that no longer exists.

Nobody did anything wrong. The reasoning happened. It just never landed
anywhere a machine or a colleague could find it.

Now add a second person. They are building with an agent too, on another
machine, possibly a different agent, possibly not an engineer at all. Their
context is in *their* chat window. Neither of you can see the other's, and
neither of you will read the other's transcript — nobody reads transcripts.

**Fragment makes the last five minutes of a session produce a file instead of a
memory, and makes CI go red when it doesn't.** That file is the only thing both
of you can see.

Fragment preserves context and decisions; tests, code review, and security
tooling still decide whether the code is correct and safe.

## Before / after

You finish a session. Good work happened. Here is what the next person — or the
next agent, or you in three weeks — gets to start from.

Without:

```console
$ git log --oneline -3
a41f0c2  fix ledger rounding
9d7e1b8  wip
2c30ff5  try the other approach
```

With:

```console
$ head -20 docs/STATE.md
## Active fragment
04 — Duplicate import records · BLOCKED

## Blocked / waiting on a human
| What                                      | Waiting on | Since      |
| Which source id is canonical after retry | API owner  | 2026-08-26 |

## Session log
- 2026-08-26 · codex · 04 · replayed the import against raw events; retries
  created duplicate records under two ids · next: API owner picks the canonical
  id, then the fix can ship
```

The second one is not documentation. It is what the work leaves behind whether
anyone feels like writing it or not, because the build fails until it does.

## How it works

Three files hold it up, and one script keeps them honest:

```text
docs/AGENT-PROTOCOL.md   the rules. one file. every agent and human reads this one
CLAUDE.md / AGENTS.md    three lines each, pointing there. never a second copy
docs/STATE.md            the board. read first, written last
scripts/docs-check.sh    red when any of the above stops being true
```

The guard knows about documents and nothing else. It has never read a line of
your source, does not know your language, and has no opinion about your domain.
Rules that are true only for your repo — a client name that must not appear, an
internal hostname, an identifier that is public but still identifies you — go in
`scripts/docs-check.local.sh`, which the guard sources if it exists and ignores
if it does not. Updating the shared guard never touches them.

The guard fails on: a document nobody indexed, a link that stopped resolving, a
board that hasn't moved in a week, a fragment claiming `done` with an unticked
box and no command recorded, a front door that quietly stopped pointing at the
protocol, and a session that changed documents and left no trace.

**The guard is the whole product.** The folder layout is the cheap part; anyone
can copy a folder layout. Structure that depends on everyone remembering decays
inside a week — this repo has receipts for that, including the two occasions the
author of the guard was caught by his own guard.

## The receipts

Extracted from a private repo: two people, two operating systems, two different
AI agents, 25 commits in 18 hours.

| | |
|---|---|
| **74 minutes** | between wiring the guard into CI and it catching a real incident |
| **3 violations** | that one file rename through the GitHub web UI caused, all three caught |
| **7 of 7** | commits from the second contributor with the identical three-file shape — index, board, work |
| **0** | sessions those two people had shared before that happened |
| **both** | directions the verification rule fired in, inside 24 hours: it found the survivorship bias behind a colleague's 8.08x claim, then found the reviewer's own number was wrong the other way |

**And what those 25 commits do not prove**, stated up front because a case study
that only flatters itself is marketing: concurrency above two people is
untested — those two took turns and never collided. The cross-OS claim is not
visible in the git data. Nothing here shows the guard preventing a bug; it shows
it preventing lost context and re-litigated decisions. And extracting the guard
for publication silently weakened it in two places, which is the failure this
project is nominally about, applied recursively.

Full working: [`CASE-STUDY.md`](CASE-STUDY.md).

## Install

```bash
git clone https://github.com/hematenergi/fragment
bash fragment/install.sh /path/to/your/repo
cd /path/to/your/repo && bash scripts/docs-check.sh
```

The installer never overwrites; anything that exists is skipped for you to merge.

Then the guard fails. **That is the feature** — it is the adoption checklist:

```console
$ bash scripts/docs-check.sh
✗ 15 document(s) still carry last-verified: <YYYY-MM-DD>. Stamp them with a real date:
✗ CLAUDE.md — still contains template placeholders. Fill them in:
    1: # <PROJECT> — front door for Claude Code
✗ docs/STATE.md — owner: unassigned. A load-bearing document needs a named owner
✗ docs/plans/ has no fragment yet — the install is not finished

FAILED — 10 problem(s), 0 warning(s)
```

Work down the list until it is green. There is no other setup.

## See a filled-in example

[`examples/feedback-triage/`](examples/feedback-triage/) is a complete documentation
snapshot of a fictional customer-feedback routing project: a populated board,
finished fragment, active fragment, decision, lesson, runbook, and a non-engineer
starting point. The application source is deliberately omitted; the complete
artifact is the workflow and its documentation. Start with its
[`START-HERE.md`](examples/feedback-triage/START-HERE.md).

*Claude Code users: `skill/SKILL.md` does the adoption for you. Copy it to
`.claude/skills/fragment/SKILL.md` and ask for it by name.*

## What to install, in tiers

Tiered from evidence, not intent. **The Core is the part that was observed
transferring to a second person, on a different machine, driving a different
agent.** The rest was only ever used by the person who built it.

### Core — ten minutes, and the tier to hand a new collaborator

```text
docs/AGENT-PROTOCOL.md          the rules. ~150 lines, hard cap
CLAUDE.md / AGENTS.md           thin front doors. three lines each
docs/STATE.md                   the board
docs/README.md                  the index — every doc listed, or the guard fails
scripts/docs-check.sh           the guard
scripts/docs-check.local.sh     optional: your domain's rules, kept out of the shared one
.github/workflows/docs.yml      runs it for whoever pushes, with whatever tool
.gitattributes                  eol=lf for the script, merge=union for the board
```

### Fragment workflow — proven, but so far single-player

```text
docs/plans/       numbered fragments, each with its own session log
docs/decisions/   why something is the way it is, so it is not re-decided
docs/lessons/     Symptom → Root cause → Rule. one file per bug worth preventing
```

In the origin repo this was used heavily — by one of the two people. Take it
when you are the one holding a plan, not as the price of entry.

### The non-engineer layer — take it if anyone on the team does not read code

```text
START-HERE.md        ten minutes, written for someone who has never opened the source
docs/GLOSSARY.md     technical terms in plain language
docs/HOW-WE-WORK.md  the rhythm, the status labels, and who is allowed to decide what
```

This is the part with no equivalent in the spec-driven tools, and it is the
reason the harness survives contact with a mixed team. `HOW-WE-WORK.md` carries
a deliberate asymmetry — **stopping the system is anyone's call, at any time,
with no permission; starting it needs more than one person** — because stopping
something healthy costs hours and failing to stop something broken costs
everything. A person who cannot read the code can still read that table and
still pull the handle.

Skip this tier if everyone on the team is an engineer. Do not skip it because it
looks soft.

### Optional

`architecture/` · `research/` · `runbooks/` · `templates/`

Strip freely. `runbooks/` goes if you operate nothing.

## Next to the spec-driven tools

|  | Spec Kit / BMAD / OpenSpec / Kiro | Fragment |
|---|---|---|
| Optimises | *before* the work — what to build | *after* the work — what was decided, and where we are |
| Core artifact | the spec | the board |
| Enforcement | advisory phases; drift analysis is a separate step | one bash script, red in CI, no bypass |
| Failure it targets | the agent builds the wrong thing | session 40 re-derives what session 12 settled |
| Non-engineer layer | — | `START-HERE.md`, glossary, an explicit who-decides-what |
| Runtime | Python/Node CLI | `bash` + `git` |

They compose. Run Spec Kit for the specs and let Fragment hold the continuity.

## Why not just symlink CLAUDE.md to AGENTS.md

Claude Code reads `CLAUDE.md`. Codex and most others read `AGENTS.md`. Claude
Code still does not read `AGENTS.md` natively, and Anthropic's own documented
workaround is `ln -s AGENTS.md CLAUDE.md`.

The symlink is genuinely simpler, and it works right up until a front door needs
something tool-specific — Claude Code's `@docs/AGENT-PROTOCOL.md` import syntax
means nothing to Codex, and "your tool does not import files, so actually open
them" means nothing to Claude Code. One file cannot carry both.

Three lines per tool costs one extra file and keeps the rules in exactly one
place. The guard fails a front door that stops pointing at the protocol, and
warns when one grows past 40 lines — because rules leaking back into a front
door is how two agents end up following two rulebooks, silently, since nobody
diffs their instruction files.

## Known limits

- **Above two people, concurrency is untested.** Every session appends at the
  same anchor in `STATE.md`. `merge=union` in `.gitattributes` makes concurrent
  appends resolve instead of conflict, at the cost of a visibly duplicated row
  when two people edit the same queue line. Past that, the next move is a
  `docs/sessions/` directory of dated files.
- **The guard verifies documents, not code.** It can tell that a fragment claims
  `done` while a box is unticked and no command was ever recorded. It cannot
  tell you the code works. Your test suite is still your test suite.
- **The `status: done` checks are new** and have not survived a month of real
  use, unlike the rest.

## Language

The templates are English. **Write your real documents in whatever language your
team actually speaks.** The guard is built so that nothing depends on an English
heading — it reads frontmatter, checkbox syntax, code fences and links, never
prose. That constraint is not theoretical: the first version of the `done` check
read `## Validation` and immediately produced a false positive on a repo that
writes `## Validasi`.

A glossary in a second language is a glossary nobody opens.

## FAQ

**Isn't this just documentation?**
Documentation is what you write after the work, if there is time. This is what
the work leaves behind whether there is time or not, because the build is red
until it does.

**My team is one person.**
Then the second person is you in three weeks, and you will be surprised how
little you recognise.

**Can I use it with Spec Kit / BMAD / Kiro?**
Yes, and you probably should. They decide what gets built; this remembers what
you already decided. No overlap.

**Can I use it with [ponytail](https://github.com/DietrichGebert/ponytail)?**
Yes. Ponytail shrinks what the agent writes; Fragment holds what the team
decided. It works on the diff, this works on the trail between sessions — they
never touch the same file. Lean code, remembered reasons.

**What if I just write good commit messages?**
Commit messages answer *what changed*. They do not answer *what did we already
rule out, and why* — try finding a rejected approach in `git log`.

**Doesn't the ritual slow us down?**
About ninety seconds at the end of a session, and the build fails when you skip
them. That is the entire product.

**Why "Fragment"?**
Because a unit of work you can hand to a stranger halfway through is a fragment,
not a task. Also because the name was picked before anyone tried to search for
it.

## Development

```bash
bash tests/run.sh
```

41 cases across Linux, macOS and Windows/Git Bash. The guard is the load-bearing
part of this project and it does not change without a test —
see [`CONTRIBUTING.md`](CONTRIBUTING.md). It shipped without one once, and an
untouched install came out green while the README called it a checklist.

## License

[MIT](LICENSE). The guard does not check it.
