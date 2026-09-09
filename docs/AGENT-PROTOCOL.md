---
id: agent-protocol
title: Agent Protocol — the working contract
status: active
owner: hematenergi
last-verified: 2026-09-09
---

# Agent Protocol

**The single source of truth for how work happens in this repo** — identical for
Claude Code, Codex, Cursor, or a human. `CLAUDE.md` and `AGENTS.md` at the root
are thin front doors that point here. Never copy this file's contents into them.

Fragment is a harness that other repositories install. That makes one thing true
here and nowhere else: **a mistake we ship is a mistake in somebody else's
repository.** The rules below exist because of that asymmetry.

## Invariants

1. **The guard does not change without a test in the same commit** that fails
   before the change and passes after. A check nobody has watched fail is
   decoration. This is also in `../CONTRIBUTING.md`, where contributors look.
2. **No check may depend on an English heading.** The templates ship in English;
   real repositories are written in whatever language their team speaks. Read
   frontmatter, checkbox syntax, code fences, link syntax — structure, never
   prose.
3. **No runtime dependency beyond `bash` and `git`.** Not Node, not Python, not
   `jq`. A harness you cannot run on a teammate's laptop at 1am is not a harness.
4. **Every vendored copy of the guard stays byte-identical** to
   `../template/scripts/docs-check.sh`. There are two — `../scripts/` and
   `../examples/online-shop/scripts/` — and a test asserts each. Two copies of
   the rules that nobody diffs is the failure this project is named after.
5. **Every automated text replacement is asserted.** A silent `.replace()` once
   deleted an entire feature from the guard while the board stayed green. See
   `lessons/silent-replacement-deleted-a-feature.md`.
6. **The version is one value in seven places**, and a test enforces it. Never
   hand-edit one of them alone.

Breaking one of these means: revert first, discuss after.

## Session ritual — mandatory

Work runs as **fragments**: one self-contained unit of work that can be left at
any moment and picked up by someone else, without the conversation that produced
it.

### Open
1. Read **`STATE.md`** — it says which fragment is active.
2. Read that fragment in `plans/NN-*.md` **in full**, including its `Session log`.
3. Before asking anything, search `decisions/`.

### Work
- **One fragment at a time.** Found other work? Write a fragment in the queue.
- **Do not reconstruct state between commits** by removing a feature and adding
  it back to make a tidy history. It has failed twice. If a change genuinely
  cannot be split without leaving a red commit — a new guard rule that rejects
  the old state, for instance — make one atomic commit and say why in the
  message.
- Small diffs a human can review.

### Close — do not skip, however small the work was
1. Tick the checkboxes. For anything unticked, write why, there.
2. Add **one line** to that fragment's `Session log`.
3. Update `STATE.md`. Its status for the fragment must match the fragment's own
   `status:`, and the session log line is a handoff, not a tick:
   `date · agent · fragment · what changed · what is next`.
4. Settled something? Write it in `decisions/` before you close.
5. Fixed a non-obvious bug that could recur? One file in `lessons/`
   (**Symptom → Root cause → Rule**), listed in `README.md`.
6. `bash tests/run.sh` and `bash scripts/docs-check.sh` must both be green.

## Source-of-truth hierarchy

1. The tests, and what the guard actually does when run
2. This document — invariants and ritual
3. `../CONTRIBUTING.md` → `decisions/` → `plans/` → everything else

## Document map

| If you want to… | Read |
|---|---|
| know where the work stands | `STATE.md` |
| pick up or continue work | `plans/README.md`, then the fragment |
| see every document | `README.md` (the index) |
| know why a rule exists | `why.md` |
| know why something is the way it is | `decisions/` |
| avoid a bug we already paid for | `lessons/` |

## Writing rules

- **Frontmatter required** on every `.md` under `docs/`: `id`, `title`,
  `status`, `owner`, `last-verified`. Values, not just keys.
- **One file, one topic.** New topic = new file + one line in the index.
- **Point at code with `file.ext:123`**, never a vague description.

## Commands

```bash
bash tests/run.sh                # the suite, including shellcheck
bash scripts/docs-check.sh       # the guard, pointed at this repo
gitleaks detect --no-banner      # what CI runs; .gitleaks.toml explains the one allowlist
```
