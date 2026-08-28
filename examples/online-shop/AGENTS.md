# Kedai — front door for Codex and other agents

A small online shop. People browse a short catalogue, add things to a cart, and
pay. Two of us run it: Dina owns the shop and does not read code, Rafi does the
technical work with an agent.

## First step, before anything else

Open and read both of these in full. They are short and they are mandatory:

1. **`docs/AGENT-PROTOCOL.md`** — the rules. Same for every agent.
2. **`docs/STATE.md`** — where the work actually stands right now.

Your tool does not import files automatically, so **you must actually open them**
rather than assume their contents.

This file deliberately does not copy the protocol. To change a rule, change
`docs/AGENT-PROTOCOL.md`.

## Handoff convention

- Start a handoff with an identity header: which repo, which model, which fragment.
- **If you are about to ask a question, search `docs/decisions/` first.** Most of
  what an agent asks at the start of a session was already settled weeks ago, and
  asking again is the failure this repo exists to prevent.
