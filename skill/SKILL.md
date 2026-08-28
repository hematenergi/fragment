---
name: fragment-architecture
description: Adopt Fragment Architecture in a repo — a stack-agnostic documentation harness that keeps AI-assisted work resumable and honest across sessions, people, and different agents. Use when a repo has no durable working state, when context keeps dying with the chat session, when several people or several AI tools take turns on the same codebase, when instructions have drifted between CLAUDE.md and AGENTS.md, or when someone asks to install/apply "Fragment Architecture", a docs harness, an agent protocol, or a STATE board. Works on existing repos of any language or framework.
---

# Fragment Architecture

Install a documentation harness so work survives the end of a session.

**Touches no source code.** No language, framework, or package manager is assumed. Only `bash` and `git`.

## What you are installing

| Piece | Job |
|---|---|
| `docs/AGENT-PROTOCOL.md` | The rules. The only place they live |
| `CLAUDE.md` / `AGENTS.md` | Thin front doors pointing at the protocol. Three lines each |
| `docs/STATE.md` | The board. Read first, written last |
| `docs/plans/` | Fragments: self-contained units of work |
| `scripts/docs-check.sh` | The guard. Fails when documents drift |
| `.github/workflows/docs.yml` | Runs the guard for whoever pushes, with whatever tool |

The guard is the load-bearing part. **Structure without it rots, usually within a week.** Never install the structure and skip the guard.

## Before you touch anything

**This is an existing repo. Assume it already has opinions.** Read before writing:

1. `ls` the root and `docs/` if present. Is there a `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `.cursorrules`, an `adr/` or `decisions/` folder?
2. `git log --oneline -30` — how do they write commit messages, how often do they commit?
3. Read any existing agent instruction file **in full**.
4. Check the language the repo is written in. Docs, comments, commit messages.

Then tell the user what you found and what you plan to do. **Wait for their answer before writing files.**

## Rules for adopting into an existing repo

1. **Never clobber.** An existing `CLAUDE.md` gets the protocol pointer *added*; its content moves into `docs/AGENT-PROTOCOL.md` or an architecture doc. Nothing is deleted without being told.
2. **Existing decision records stay where they are.** If they already have `adr/`, point `docs/README.md` at it — do not migrate files to prove a point.
3. **Match the repo's language.** If their docs and commits are in Indonesian, Spanish, or Japanese, write the docs in that language. The templates are English because that is the open-source default, not because English is required. The non-technical layer only works if people actually read it.
4. **Seed from reality, not from the template.** `STATE.md` describes what is genuinely happening in this repo right now — derived from recent commits, open branches, TODOs, and the issue tracker. A `STATE.md` full of placeholders teaches everyone to ignore it.
5. **Start small.** The minimum viable install is the protocol, both front doors, `STATE.md`, one fragment, and the guard. Add `research/`, `runbooks/`, `GLOSSARY.md` only if the team needs them.

## Steps

### 1. Copy the template

Copy `template/` into the repo root, merging rather than overwriting. Then delete what does not apply:

- No non-engineers on the team → drop `START-HERE.md` and `GLOSSARY.md`
- Nothing to operate → drop `runbooks/`
- No research → drop `research/`

Never drop: `scripts/docs-check.sh`, `docs/STATE.md`, the two front doors.

### 2. Fill in the invariants

The `Invariants` section of `docs/AGENT-PROTOCOL.md` is the heart, and it cannot be guessed from a template. Ask the user directly:

> What are the rules in this repo that, if broken, would make you revert the change rather than discuss it?

Aim for five to ten. Good ones are specific and testable. Common examples: what may never enter the repo, what the system may never do without a human, which numbers are trusted for decisions, what must never be changed without two people.

If they cannot name any yet, write the ones you can infer from the code and mark them `<PROPOSED — confirm>`. Do not invent invariants and present them as agreed.

### 3. Seed STATE.md from reality

Not a blank board. Fill it from what the repo actually shows:

- **Phase** — what stage the project is in, from recent commit history
- **Queue** — real upcoming work, from TODOs, issues, or the user
- **Blocked** — anything genuinely waiting on a human, with who and since when
- **Session log** — one honest line: the architecture was installed, and what is next

### 4. Write the first real fragment

Copy `docs/plans/00-template.md` to `01-<slug>.md` for a piece of work that actually needs doing. Fill `Current state` with facts read from the code (`file.ext:123`), never assumptions.

This one is worth care: **it is the example every later fragment gets copied from.**

### 5. Seed the lessons folder

Do not leave `docs/lessons/` empty. Empty folders get deleted.

Look for bugs the repo already paid for — `git log --grep='fix'`, a post-mortem doc, recurring issue labels. Write two or three as **Symptom → Root cause → Rule**. Ask the user: *what bug in this repo has bitten you more than once?*

### 6. Install the guard, and prove it works

```bash
bash scripts/docs-check.sh
```

Fix until green. Then **test it in both directions** — a guard nobody has seen fail is not trusted:

```bash
# should FAIL: a document that is not in the index
printf -- '---\nid: t\ntitle: t\nstatus: active\nowner: t\nlast-verified: 2026-01-01\n---\n' > docs/architecture/tmp.md
bash scripts/docs-check.sh          # expect: FAILED
rm docs/architecture/tmp.md
bash scripts/docs-check.sh          # expect: GREEN
```

Show the user both outputs.

### 7. Wire CI

Install `.github/workflows/docs.yml`. If the repo does not use GitHub Actions, port the same one-line invocation to whatever they do use — the script is plain bash and needs nothing else.

Explain the point plainly: local hooks only apply to the tool that installed them. **CI is the only layer that cannot be bypassed by switching tools.**

### 8. Close the session using the ritual you just installed

Run the Close ritual on your own work: tick the fragment, add a `Session log` line, update `STATE.md`, run the guard until green, and commit.

Do it visibly. **It is the clearest possible demonstration of how the thing is meant to be used**, and it is the step most likely to be skipped later if nobody has seen it done once.

## What to tell the user when you are done

- The guard is what keeps this alive — show them the failing output, not just the green one.
- The rules now live in exactly one file. Changing them anywhere else is how two agents end up following two rulebooks.
- `STATE.md` is read first and written last. A session that ends without updating it is unfinished.
- Adding a third AI tool later costs three lines, not a fork of the rules.

## Failure modes to warn about

| Symptom | What it means |
|---|---|
| `STATE.md` untouched for weeks | The board is fiction. Either the team stopped using it, or work stopped |
| Front doors growing past ~40 lines | Rules leaking back out of the protocol. They will drift |
| `lessons/` still empty after a month | Either nothing broke, or nobody is writing them down. It is the second one |
| Guard disabled in CI "temporarily" | The structure is now decorative and will rot within weeks |
| Fragments with no `Session log` lines | People are working but not leaving a trail. The next session starts blind |
