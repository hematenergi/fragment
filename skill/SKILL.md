---
name: fragment
description: Adopt Fragment in a repo — a stack-agnostic documentation harness that keeps AI-assisted work resumable and honest across sessions, people, and different agents. Use when a repo has no durable working state, when context keeps dying with the chat session, when several people or several AI tools take turns on the same codebase, when instructions have drifted between CLAUDE.md and AGENTS.md, or when someone asks to install/apply "Fragment", a docs harness, an agent protocol, or a STATE board. Works on existing repos of any language or framework.
---

# Fragment

Install a documentation harness so work survives the end of a session.

**Touches no source code.** No language, framework, or package manager is
assumed. Only `bash` and `git`.

## What you are installing

The Core is the part observed transferring to a second person on a different
machine driving a different agent. Install the Core first, always.

| Core | Job |
|---|---|
| `docs/AGENT-PROTOCOL.md` | The rules. The only place they live |
| `CLAUDE.md` / `AGENTS.md` | Thin front doors pointing at the protocol. Three lines each |
| `docs/STATE.md` | The board. Read first, written last |
| `docs/README.md` | The index. Every doc listed, or the guard fails |
| `scripts/docs-check.sh` | The guard |
| `.github/workflows/docs.yml` | Runs the guard for whoever pushes, with whatever tool |
| `.gitattributes` | `eol=lf` for the script; `merge=union` for the board |
| `scripts/docs-check.local.sh` | Optional. This repo's own rules, kept out of the shared guard |

| Then, if they want it | Job |
|---|---|
| `docs/plans/` | Fragments: numbered, self-contained units of work |
| `docs/decisions/`, `docs/lessons/` | Why something is the way it is; bugs already paid for |
| `architecture/`, `research/`, `runbooks/`, `GLOSSARY.md`, `START-HERE.md` | Optional |

The guard is the load-bearing part. **Structure without it rots, usually within
a week.** Never install the structure and skip the guard.

## Before you touch anything

**This is an existing repo. Assume it already has opinions.** Read before writing:

1. `ls` the root and `docs/` if present. Is there a `CLAUDE.md`, `AGENTS.md`,
   `CONTRIBUTING.md`, `.cursorrules`, an `adr/` or `decisions/` folder?
2. `git log --oneline -30` — how do they write commit messages, how often?
3. Read any existing agent instruction file **in full**.
4. Check the language the repo is written in. Docs, comments, commit messages.

Then tell the user what you found and what you plan to do. **Wait for their
answer before writing files.**

## Rules for adopting into an existing repo

1. **Never clobber.** An existing `CLAUDE.md` gets the protocol pointer *added*;
   its content moves into `docs/AGENT-PROTOCOL.md` or an architecture doc.
   Nothing is deleted without being told.
2. **Existing decision records stay where they are.** If they already have
   `adr/`, point `docs/README.md` at it — do not migrate files to prove a point.
3. **Match the repo's language.** If their docs and commits are in Indonesian,
   Spanish or Japanese, write the docs in that language. The templates are
   English because that is the open-source default. The guard is built to be
   language-independent — it reads frontmatter, checkboxes, code fences and
   links, never English headings — so nothing breaks when you translate.
4. **Seed from reality, not from the template.** `STATE.md` describes what is
   genuinely happening in this repo right now — derived from recent commits,
   open branches, TODOs, the issue tracker. A `STATE.md` full of placeholders
   teaches everyone to ignore it.
5. **Start with the Core.** Add `plans/` when the user is the one holding a
   plan. Add `research/`, `runbooks/`, `GLOSSARY.md` only if they need them.

## Steps

### 1. Copy the Core

Copy `template/` into the repo root, merging rather than overwriting. Then
delete what does not apply — no non-engineers on the team means no
`START-HERE.md` and no `GLOSSARY.md`; nothing to operate means no `runbooks/`.

**Never edit the shared guard to add a rule for this repo.** If the team needs
one — a client name that must not appear, an internal hostname, a convention only
they have — copy `scripts/docs-check.local.sh.example` to
`scripts/docs-check.local.sh` and put it there. The guard sources it if present.
That is how the shared script stays updatable.

Never drop: `scripts/docs-check.sh`, `docs/STATE.md`, `docs/README.md`, the two
front doors, `.gitattributes`.

### 2. Run the guard immediately, before filling anything in

```bash
bash scripts/docs-check.sh
```

**It will fail with about ten items. That is the adoption checklist**, and
showing it to the user first is the fastest way to explain what the harness is.
Work down it together.

### 3. Fill in the invariants

The `Invariants` section of `docs/AGENT-PROTOCOL.md` is the heart, and it cannot
be guessed from a template. Ask the user directly:

> What are the rules in this repo that, if broken, would make you revert the
> change rather than discuss it?

Aim for five to ten. Good ones are specific and testable. Common examples: what
may never enter the repo, what the system may never do without a human, which
numbers are trusted for decisions, what must never change without two people.

If they cannot name any yet, write the ones you can infer from the code and mark
them `PROPOSED — confirm`. Do not invent invariants and present them as agreed.

### 4. Seed STATE.md from reality

Not a blank board. Fill it from what the repo actually shows: **Phase** from
recent commit history; **Queue** from TODOs, issues or the user; **Blocked**
with who and since when; a first honest **Session log** line.

### 5. Write the first real fragment (if they took the plans tier)

Copy `docs/plans/00-template.md` to `01-<slug>.md` for work that actually needs
doing. Fill `Current state` with facts read from the code (`file.ext:123`),
never assumptions. **It is the example every later fragment gets copied from.**

Its `Validation` block is not decoration — the guard will refuse to accept
`status: done` on a fragment with unticked boxes or no recorded commands.

### 6. Seed the lessons folder

Do not leave `docs/lessons/` empty. Empty folders get deleted. Look for bugs the
repo already paid for — `git log --grep='fix'`, a post-mortem, recurring issue
labels — and write two or three as **Symptom → Root cause → Rule.** Ask the
user: *what bug in this repo has bitten you more than once?*

### 7. Prove the guard works, in both directions

A guard nobody has seen fail is not trusted. Get it green, then break it on
purpose in front of them:

```bash
bash scripts/docs-check.sh          # expect: GREEN

printf -- '---\nid: t\ntitle: t\nstatus: active\nowner: t\nlast-verified: 2026-01-01\n---\n' > docs/architecture/tmp.md
bash scripts/docs-check.sh          # expect: FAILED — not listed in docs/README.md
rm docs/architecture/tmp.md
bash scripts/docs-check.sh          # expect: GREEN
```

Show them both outputs.

### 8. Wire CI

Install `.github/workflows/docs.yml`. If they do not use GitHub Actions, port
the one-line invocation to whatever they do use — it is plain bash.

Explain the point plainly: local hooks only apply to the tool that installed
them. **CI is the only layer that cannot be bypassed by switching tools**, and
for a teammate on another OS who never runs the script locally, it is the only
enforcement they will ever see.

### 9. Close the session using the ritual you just installed

Run the Close ritual on your own work: tick the fragment, add a `Session log`
line that reads as a handoff (`date · agent · fragment · what changed · what is
next` — the guard rejects a line too thin to be one), update `STATE.md`, run the
guard until green, commit.

Do it visibly. **It is the clearest possible demonstration of how the thing is
meant to be used**, and it is the step most likely to be skipped later if nobody
has seen it done once.

## What to tell the user when you are done

- The guard is what keeps this alive — show them the failing output, not just
  the green one.
- The rules now live in exactly one file. Changing them anywhere else is how two
  agents end up following two rulebooks.
- `STATE.md` is read first and written last. A session that ends without
  updating it is unfinished.
- Adding a third AI tool later costs three lines, not a fork of the rules.

## Failure modes to warn about

| Symptom | What it means |
|---|---|
| `STATE.md` untouched for weeks | The board is fiction. Either the team stopped using it, or work stopped |
| Front doors growing past ~40 lines | Rules leaking back out of the protocol. They will drift |
| `lessons/` still empty after a month | Either nothing broke, or nobody is writing them down. It is the second one |
| Guard disabled in CI "temporarily" | The structure is now decorative and will rot within weeks |
| Session log lines that say nothing | People are satisfying the check, not leaving a handoff. The next session starts blind |
| Fragments going `done` in bulk | Check the Validation blocks. `done` without recorded commands is a claim, not a result |
