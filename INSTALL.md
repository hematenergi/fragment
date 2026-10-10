# Install Fragment

## Agent skill

Install the onboarding skill with the skills CLI:

```bash
npx skills add hematenergi/fragment --skill adopt-fragment
```

[View the adopt-fragment skill source](https://raw.githubusercontent.com/hematenergi/fragment/main/skills/adopt-fragment/SKILL.md).
The skill guides your agent through adding the full Fragment harness while
preserving files already in your repository.

## Native plugin packages

The repository includes package manifests for Codex, Claude Code, Cursor, and
Kimi Code. These install from Fragment's GitHub repository; they are not claims
of inclusion in a vendor-curated global marketplace.

### Codex

Add Fragment's repo marketplace in Codex:

```bash
codex plugin marketplace add hematenergi/fragment \
  --sparse .agents/plugins \
  --sparse plugins/adopt-fragment
```

Then open the Plugins Directory and install **adopt-fragment** from **Fragment**.

### Claude Code

```text
/plugin marketplace add hematenergi/fragment
/plugin install adopt-fragment@fragment
```

### Cursor

Open **Customize → Plugins → From GitHub Repository**, enter
`https://github.com/hematenergi/fragment`, then install **adopt-fragment**.
For a team marketplace, a Team or Enterprise admin can import the same
repository from the Cursor dashboard.

### Kimi Code

In Kimi Code, install the repository path from its plugin manager:

```text
/plugins install https://github.com/hematenergi/fragment/tree/main/plugins/adopt-fragment
/reload
```

## Other skill-compatible agents

For GitHub Copilot, Cline, OpenCode, and other agents supported by the skills
CLI, use the `npx skills add` command above. Fragment packages this onboarding
workflow as an Agent Skill for these tools.

## Full harness

The agent skill is an onboarding workflow. To install the full Bash and Git
harness directly, follow the [README install instructions](README.md#install).
