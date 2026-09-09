# Fragment — front door for Codex and other agents

A continuity harness for repositories where humans and AI agents take turns.
Pure bash and git; the guard is the load-bearing part.

## First step, before anything else

Open and read both of these in full. They are short and they are mandatory:

1. **`docs/AGENT-PROTOCOL.md`** — the rules. Same for every agent.
2. **`docs/STATE.md`** — where the work actually stands right now.

Your tool does not import files automatically, so **you must actually open
them** rather than assume their contents.

This file deliberately does not copy the protocol. To change a rule, change
`docs/AGENT-PROTOCOL.md`.

## Handoff convention

- Start a handoff with an identity header: which repo, which model, which
  fragment.
- **Before asking a question, search `docs/decisions/`.** Most of what an agent
  asks at the start of a session was settled weeks ago. Asking again is the
  failure this repository exists to prevent, and doing it here is embarrassing.
