---
id: executor-prompt
title: Executor prompt — paste this to continue the work
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Executor prompt

Opening prompt for any session in this repo — Claude Code, Codex, anything. Paste as-is.

```text
Repo: <PROJECT>. Read docs/AGENT-PROTOCOL.md and docs/STATE.md in full before
doing anything.

Take the fragment that is active in STATE.md. If none is active, take the top of
the queue whose dependencies are done, and set it to in-progress.

Work on THAT FRAGMENT ONLY. If you find other work that needs doing, write a new
fragment in the queue — do not do it now.

Before touching code: tell me which fragment you took and your planned diff.
Wait for my answer.

Before closing the session, run the Close ritual in AGENT-PROTOCOL.md until
`bash scripts/docs-check.sh` is green.
```

## If you only want to ask, not work

```text
Repo: <PROJECT>. Read docs/AGENT-PROTOCOL.md and docs/STATE.md first. Do not take
a fragment, do not change any file. Just answer my question.
```

## If you want a new fragment written, not executed

```text
Repo: <PROJECT>. Read docs/AGENT-PROTOCOL.md and docs/plans/README.md. Create a
new fragment from docs/plans/00-template.md for: <description>.

Fill "Current state" with facts from reading the code (file:line), not
assumptions. Register it in the STATE.md queue and the docs/README.md index. Do
not implement it.
```
