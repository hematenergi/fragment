# Feedback Triage — front door for Codex and other agents

Ingests customer feedback from three channels, de-duplicates it, and routes each
item to the team that owns it.

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
- If you are unsure whether a decision has already been made, search
  `docs/decisions/` before deciding it again.
