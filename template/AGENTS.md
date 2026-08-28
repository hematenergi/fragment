# <PROJECT> — front door for Codex and other agents

<ONE LINE: what this project is.>

## First step, before anything else

Open and read both of these in full. They are short and they are mandatory:

1. **`docs/AGENT-PROTOCOL.md`** — the rules. Same for every agent.
2. **`docs/STATE.md`** — where the work actually stands right now.

Your tool does not import files automatically, so **you must actually open them** rather than assume their contents.

This file deliberately does not copy the protocol. To change a rule, change `docs/AGENT-PROTOCOL.md` — do not add rules here, or agents reading a different front door will never see them.

## Handoff convention

- Start a handoff with an identity header: **which repo, which model, which fragment**.
- Do not edit other repositories from this session.
- If you are unsure whether a decision has already been made, search `docs/decisions/` before deciding it again.
