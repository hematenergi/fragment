# Kedai — front door for Claude Code

A small online shop. People browse a short catalogue, add things to a cart, and
pay. Two of us run it: Dina owns the shop and does not read code, Rafi does the
technical work with an agent.

**The rules for working here live in one file, not this one:**

@docs/AGENT-PROTOCOL.md

This file deliberately does not copy them. To change a rule, change
`docs/AGENT-PROTOCOL.md` — do not add rules here, or agents that read a different
front door will never see them.

## Claude Code specifics

- The `@docs/AGENT-PROTOCOL.md` import above loads automatically. **Still open
  `docs/STATE.md` yourself at the start of a session** — it changes every session
  and it decides what you work on.
- Before closing a session: `bash scripts/docs-check.sh` must be green.
