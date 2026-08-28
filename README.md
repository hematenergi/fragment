# Fragment

A documentation harness for repos where humans and AI agents take turns.

**Stack-agnostic.** It touches no source code, assumes no language, no framework, no package manager. Frontend, backend, data, research — it does not care. The only dependency is `bash` and `git`.

---

## The problem it solves

You work on something with an AI agent. Good work happens. The session ends.

Three days later you come back — or a teammate does, or a different agent does — and the context that made the work make sense is gone. It lived in a chat log nobody will read. So the next session re-derives, re-decides, and quietly contradicts a decision you already made.

Fragment fixes that by making the working state a **file, not a conversation** — and by adding a check that fails when the state goes stale.

## The idea in three lines

1. **Work is fragments.** A fragment is one self-contained unit of work that can be picked up by anyone — human or agent — without the conversation that produced it.
2. **One board.** `docs/STATE.md` answers "where are we?" You read it first and write it last.
3. **A guard.** `scripts/docs-check.sh` fails CI when documents drift: unindexed files, dangling links, missing frontmatter, a session that changed docs without updating the board.

The third one is what makes the first two survive. Structure without a guard rots — usually within a week.

## Install

```bash
curl -fsSL <raw-url>/install.sh | bash     # or just copy template/ into your repo
bash scripts/docs-check.sh
```

Copy `template/` into the root of your repo, fill in the four `<PLACEHOLDER>` fields, run the check. That is the whole setup.

### What installing into an existing repo looks like

The installer never overwrites. Anything that already exists is skipped and left alone:

```text
  copied  docs/AGENT-PROTOCOL.md
  copied  AGENTS.md
  skip    CLAUDE.md  (already exists — merge by hand)

19 copied, 1 skipped.
```

Then the guard tells you exactly what still needs doing:

```text
✗ CLAUDE.md — does not point at docs/AGENT-PROTOCOL.md
FAILED — 1 problem(s)
```

**The guard is your to-do list.** Install is safe by construction; the check is what tells you when the adoption is actually finished.

## What you get

```text
CLAUDE.md            thin front door for Claude Code   ┐  both point at the same
AGENTS.md            thin front door for Codex etc.    ┘  protocol. zero duplication
START-HERE.md        for people who are not engineers

docs/
  AGENT-PROTOCOL.md  the rules. the single source. ~150 lines, hard cap
  STATE.md           the board: what is active, what is queued, what is blocked
  README.md          index — every doc must be listed here or the check fails
  HOW-WE-WORK.md     team rhythm, status labels, who decides what
  GLOSSARY.md        jargon in plain language, for the non-technical half of the team

  plans/             fragments — numbered, standalone, with their own session log
  decisions/         why something is the way it is, so it is not re-decided
  lessons/           Symptom → Root cause → Rule. one file per bug worth preventing
  architecture/      cross-cutting design that spans features
  research/          findings, and independent verification of them
  runbooks/          how to operate: stop it, rotate keys, handle an incident
  templates/         daily note

scripts/docs-check.sh          the guard
.github/workflows/docs.yml     runs the guard on every push and PR
```

## Why front doors are thin

`CLAUDE.md` and `AGENTS.md` are three lines each. They point at `docs/AGENT-PROTOCOL.md`.

If you copy rules into both, they drift, and then two agents follow two different rulebooks — silently, because nobody diffs their instruction files. The guard enforces this: front doors that stop pointing at the protocol fail the check.

Adding a third tool later (Cursor, Gemini, whatever) costs three lines. Rules still change in exactly one place.

## Research and verification

`docs/research/` has a convention worth calling out, because it is the part teams get wrong:

- Research notes live in the author's own folder: `research/<name>/`.
- **Verification is a separate document. It never edits the original.**
- A verification recomputes the numbers. It does not cite them.

That last rule sounds pedantic until it catches something. In the repo this was extracted from, recomputing a colleague's numbers found a survivorship bias that made a losing strategy look like an 8× winner — and recomputing *my own* numbers, a week later, found I had been wrong in the other direction. Both were caught by the same convention.

## What to strip

Fragment is a floor, not a framework. Delete freely:

- `GLOSSARY.md` and `START-HERE.md` if everyone on the team is an engineer
- `runbooks/` if you do not operate anything
- `research/` if you do not do research

Do **not** strip `scripts/docs-check.sh`, `STATE.md`, or the thin front doors. Those three are the load-bearing parts.

## Language

The templates are in English. **Write your actual docs in whatever language your team really speaks.**

The non-technical layer only works if people read it. A glossary in a second language is a glossary nobody opens. The guard does not care what language you write in.

## Where this came from

Extracted from a working repo built by a two-person team plus two different AI agents, over several days of heavy use. Every rule in it exists because something broke without it — the failures are documented in [`docs/why.md`](docs/why.md), with what each one cost.

## License

MIT. See [`LICENSE`](LICENSE).
