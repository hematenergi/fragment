# Fragment — front door for Claude Code

A continuity harness for repositories where humans and AI agents take turns.
Pure bash and git; the guard is the load-bearing part.

**The rules for working here live in one file, not this one:**

@docs/AGENT-PROTOCOL.md

This file deliberately does not copy them. To change a rule, change
`docs/AGENT-PROTOCOL.md` — do not add rules here, or agents that read a
different front door will never see them.

## Claude Code specifics

- The `@docs/AGENT-PROTOCOL.md` import above loads automatically. **Still open
  `docs/STATE.md` yourself at the start of a session** — it changes every
  session and it decides what you work on.
- Before closing a session: `bash tests/run.sh` and `bash scripts/docs-check.sh`
  must both be green. The first covers the thing this repo ships; the second is
  that same thing, pointed at us.
