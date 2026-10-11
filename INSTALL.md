# Install Fragment

Fragment keeps decisions, current state, and the next step in your repository so
the next coding agent can pick up the work. Choose the install path that fits
your agent.

## Agent skill

For agents supported by the skills CLI, install the onboarding skill:

```bash
npx skills add hematenergi/fragment --skill fragment
```

[Open Fragment on skills.sh](https://www.skills.sh/hematenergi/fragment/fragment) · [View the skill source](https://raw.githubusercontent.com/hematenergi/fragment/main/skills/fragment/SKILL.md)

The skill inspects the repository and guides your agent through installing the
full harness without overwriting existing files.

## Native plugin packages

These packages install from this GitHub repository. They are not listings in a
vendor-curated marketplace.

### Codex

```bash
codex plugin marketplace add hematenergi/fragment \
  --sparse .agents/plugins \
  --sparse plugins/adopt-fragment
```

Then open the Plugins Directory and install **adopt-fragment** from
**Fragment**.

### Claude Code

```text
/plugin marketplace add hematenergi/fragment
/plugin install adopt-fragment@fragment
```

### Cursor

Open **Customize → Plugins → From GitHub Repository**, enter
`https://github.com/hematenergi/fragment`, then install **adopt-fragment**.
For a team marketplace, a Team or Enterprise admin can import the repository
from the Cursor dashboard.

### Kimi Code

```text
/plugins install https://github.com/hematenergi/fragment/tree/main/plugins/adopt-fragment
/reload
```

## Install the full harness directly

Use the [README's Bash install instructions](README.md#install) if you want to
install Fragment without the onboarding skill.
