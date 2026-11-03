#!/usr/bin/env bash
# Private install: the ordinary template and guard live in a nested Git repo.
set -euo pipefail
if [ -n "${GIT_DIR:-}${GIT_WORK_TREE:-}${GIT_INDEX_FILE:-}${GIT_COMMON_DIR:-}${GIT_OBJECT_DIRECTORY:-}${GIT_ALTERNATE_OBJECT_DIRECTORIES:-}" ]; then
  printf 'local mode requires Git location/index environment overrides to be unset\n' >&2; exit 2
fi
source_root=$(cd "$(dirname "$0")/.." && pwd -P)
dry=0
if [ "${1:-}" = --dry-run ]; then dry=1; shift; fi
host=$(cd "${1:-.}" && pwd -P)
top=$(git -C "$host" rev-parse --show-toplevel) || { printf 'local mode needs a Git worktree\n' >&2; exit 2; }
top=$(cd "$top" && pwd -P)
[ "$top" = "$host" ] || { printf 'install local mode at the Git worktree root: %s\n' "$top" >&2; exit 2; }
local_root="$host/.fragment"
if [ -e "$local_root" ] || [ -L "$local_root" ]; then
  printf '.fragment already exists; preserve its contents and history instead of reinstalling\n' >&2
  exit 2
fi
[ -z "$(git -C "$host" ls-files -- .fragment)" ] || { printf '.fragment is already tracked; local mode requires an untracked directory\n' >&2; exit 2; }
exclude=$(git -C "$host" rev-parse --git-path info/exclude)
case "$exclude" in /*|[A-Za-z]:/*) ;; *) exclude="$host/$exclude" ;; esac
[ ! -L "$exclude" ] || { printf 'refusing a linked Git exclude file\n' >&2; exit 2; }
if [ "$dry" = 1 ]; then
  printf 'Would install .fragment/ with private Git history and add /.fragment/ to %s. Nothing was changed.\n' "$exclude"
  exit 0
fi
mkdir -p "$(dirname "$exclude")"
printf '\n# Fragment local context (not shared with the repository)\n/.fragment/\n' >> "$exclude"
if ! git -C "$host" check-ignore -q .fragment/docs/STATE.md; then
  printf 'host ignore rules re-include .fragment; resolve that conflict before installing local mode\n' >&2
  exit 2
fi
mkdir "$local_root"
bash "$source_root/install.sh" "$local_root" >/dev/null
cp "$source_root/scripts/local-mode.sh" "$local_root/scripts/local-mode.sh"
for door in AGENTS.md CLAUDE.md; do
  printf '\n## Local installation\n\nRead LOCAL.md before following the protocol. It describes command locations\nand the required local-mode.sh close command for host-project handoff evidence.\nThe host repository instructions retain authority.\n' >> "$local_root/$door"
done
cat > "$local_root/LOCAL.md" <<'DOC'
# Local Fragment

Read the host repository instructions first; they retain authority. This folder
contains private continuity notes for that project, not a replacement rulebook.
Read AGENTS.md (or CLAUDE.md), docs/AGENT-PROTOCOL.md, docs/STATE.md, and the active
plan here. Commands named in those files run from this directory; application
work and application tests run from the host repository root.

Use these commands from the host root:

```bash
bash .fragment/scripts/recall.sh "query"
bash .fragment/scripts/load-context.sh --budget 12000 "query"
bash .fragment/scripts/local-mode.sh check
bash .fragment/scripts/local-mode.sh close
```

The last two commands compare host work with the last successful local close.
Update docs/STATE.md with the outcome, validation and next step before closing.
`check` validates without advancing history. `close` validates, bounds STATE
using the ordinary guard, then commits a new local baseline. Failures preserve
the previous baseline. The canonical docs-check alone checks this context repo;
use local-mode.sh to include host changes. Do not commit application code from
this folder. No host CI, hooks, front doors or tracked ignore rules are installed.

Private Git history is stored in .fragment/.git without a remote. Back up the
whole .fragment directory (including hidden files) to an approved location.
Ignored files are not encryption or a backup; git clean -ffdx can delete them.
Each host clone/worktree has separate context. To remove Fragment, first back up
this folder, then remove it and the Fragment block in the host Git info/exclude.
Local context may be read by your coding agent under its normal data policy.
DOC
git -C "$local_root" -c init.templateDir= init -q
# Keep temporary lock/snapshot files out of the private history too.
mkdir -p "$local_root/.git/info"
printf '/.close-lock/\n/.project-snapshot.*\n' >> "$local_root/.git/info/exclude"
git -C "$local_root" config user.name Fragment
git -C "$local_root" config user.email fragment@localhost
git -C "$local_root" config commit.gpgSign false
git -C "$local_root" config core.autocrlf false
git -C "$local_root" add -A
git -C "$local_root" -c core.hooksPath=/dev/null commit -qm 'Initialize local Fragment context'
printf '\nLocal mode installed. Keep the host repository instructions in force.\n'
printf 'Tell your agent: Read the project instructions, then .fragment/AGENTS.md and .fragment/LOCAL.md.\n'
printf 'Fill the local template, update .fragment/docs/STATE.md, then run:\n  bash .fragment/scripts/local-mode.sh close\n'
