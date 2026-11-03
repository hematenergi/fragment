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

## Local mode

Use local mode when you can use your coding agent but cannot add Fragment files
to the shared repository. Run the installer from a Fragment release checkout:

```bash
bash fragment/install.sh --local --dry-run /path/to/your/repo
bash fragment/install.sh --local /path/to/your/repo
```

The target must be the host Git worktree root. `.fragment/` must not already
exist or be tracked. The installer adds `/.fragment/` to Git's local
`info/exclude`; existing host ignore rules that explicitly re-include it must
be resolved before installation. Host tracked files, front doors, hooks and CI
are preserved. Linked Git worktrees are supported, each with its own context.

Give the agent this entry instruction:

```text
Read the host repository instructions first. Then read .fragment/AGENTS.md
and .fragment/LOCAL.md. Adopt the local template using verified project facts.
Keep application edits and tests in the host repo; keep continuity in .fragment.
Use local-mode.sh close for the session handoff.
```

This entry is explicit: no universal automatic discovery of ignored files is
assumed. For Claude Code, `.fragment/CLAUDE.md` is the equivalent local door.
The host instructions retain authority. Do not merge local pointers into the
host's existing instructions or CI as part of this installation.

From the host root, local commands are:

```bash
bash .fragment/scripts/recall.sh "query"
bash .fragment/scripts/load-context.sh --budget 12000 "query"
bash .fragment/scripts/local-mode.sh check
bash .fragment/scripts/local-mode.sh close
```

Before close, record the outcome, validation and next action in
`.fragment/docs/STATE.md`. The wrapper hashes host HEAD, status, staged/unstaged
diffs and untracked file contents into a snapshot. Application diffs are not
stored in the local notes. The canonical guard compares this snapshot and local
documents with the last successful close; metadata-only edits do not count as
handoff evidence. A failed check does not advance the baseline. A successful
check may archive STATE history using the same 12,000-byte rule as normal mode.
Use `close` to commit the context baseline after validation, even if host
application changes have already been committed.

The private history has no remote and never pushes. Inspect it with
`git -C .fragment log`; keep application Git commands at the host root. Direct
`docs-check.sh` checks only the context repo, so use the wrapper for host work.
Host submodules or nested repositories need their own local context to detect
changes within an already-dirty nested repo. Local mode has no shared CI gate
and does not prove that code works or that recorded claims are true.
Existing Git commit hooks and signing settings still apply to private history;
resolve any policy rejection through the project's normal rules before closing.

### Backup, upgrades and removal

Back up the entire `.fragment/` directory, including its hidden `.git` history,
to a location approved for the host project's data. Ignoring files is not
encryption, backup, or a restriction on what your coding agent may read.
`git clean -ffdx` can remove the ignored nested repository. Another clone or worktree does not
inherit it automatically; switching host branches also does not switch the
local notes, so review STATE against the current branch.

This release refuses local reinstall and `--local --upgrade` rather than
overwriting personal context. Preserve the directory and its history before a
future migration. The ordinary installer upgrade remains for shared installs.

To remove local mode, first back up the complete directory. Then remove
`.fragment/` and the Fragment comment/pattern block from the host Git
`info/exclude` (locate it using `git rev-parse --git-path info/exclude`). For
linked worktrees, that exclusion file can be shared: leave the pattern in place
while any other worktree still uses local Fragment. No shared repository commit
is needed for installation or removal.
