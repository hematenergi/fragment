#!/usr/bin/env bash
# Hash host work into the context repo, then reuse the ordinary handoff guard.
set -euo pipefail
if [ -n "${GIT_DIR:-}${GIT_WORK_TREE:-}${GIT_INDEX_FILE:-}${GIT_COMMON_DIR:-}${GIT_OBJECT_DIRECTORY:-}${GIT_ALTERNATE_OBJECT_DIRECTORIES:-}" ]; then
  printf 'local mode requires Git location/index environment overrides to be unset\n' >&2; exit 2
fi
action=${1:-check}
[ "$#" -le 1 ] && [[ "$action" = check || "$action" = close ]] || {
  printf 'usage: bash .fragment/scripts/local-mode.sh [check|close]\n' >&2; exit 2;
}
root=$(cd "$(dirname "$0")/.." && pwd -P)
[ "${root##*/}" = .fragment ] && [ -d "$root/.git" ] && [ ! -L "$root/.git" ] || {
  printf 'run this command from an installed .fragment workspace\n' >&2; exit 2;
}
host=${root%/*}
host_top=$(git -C "$host" rev-parse --show-toplevel)
host_top=$(cd "$host_top" && pwd -P)
[ "$host_top" = "$host" ] || { printf 'host Git worktree root changed; reinstall deliberately\n' >&2; exit 2; }
context_top=$(git -C "$root" rev-parse --show-toplevel)
context_top=$(cd "$context_top" && pwd -P)
[ "$context_top" = "$root" ] || { printf 'private context history is missing\n' >&2; exit 2; }
git -C "$host" check-ignore -q .fragment/docs/STATE.md || {
  printf '.fragment is no longer ignored by the host repository; restore its local exclusion\n' >&2; exit 2;
}
[ -z "$(git -C "$host" ls-files -- .fragment)" ] || {
  printf '.fragment is tracked by the host repository; resolve that before using local mode\n' >&2; exit 2;
}
[ -z "${BASE_REF:-}${CI:-}${GITHUB_ACTIONS:-}" ] || {
  printf 'local mode requires an interactive local checkout without BASE_REF or CI mode\n' >&2; exit 2;
}
cd "$root"
mkdir .close-lock 2>/dev/null || { printf 'another local check/close is running; inspect .fragment/.close-lock before retrying\n' >&2; exit 2; }
snapshot=''
trap 'rm -f "${snapshot:-}"; rmdir .close-lock' EXIT
snapshot=$(mktemp "$root/.project-snapshot.XXXXXX")
# Both diffs matter: staged changes can be reversed in the worktree. Hash new
# file contents as well, since porcelain status alone cannot see further edits.
(
  cd "$host"
  git rev-parse --verify HEAD 2>/dev/null || printf 'unborn\n'
  git status --porcelain=v1 -z --untracked-files=all
  git diff --binary --no-ext-diff --no-textconv
  git diff --cached --binary --no-ext-diff --no-textconv
  while IFS= read -r -d '' path; do
    printf '%s\0' "$path"
    if [ -L "$path" ]; then
      readlink "$path" | git hash-object --stdin
    elif [ -f "$path" ]; then
      git hash-object --no-filters -- "$path"
    fi
  done < <(git ls-files --others --exclude-standard -z)
) | git hash-object --stdin > "$snapshot"
mv "$snapshot" .project-snapshot
snapshot=''
# Local context always uses its own core files; caller environment must not
# accidentally select the host project's docs or another evidence destination.
unset DOCS_ROOT STATE_FILE PROTOCOL_FILE INDEX_FILE STATE_ARCHIVE_FILE
bash scripts/docs-check.sh
if [ "$action" = close ]; then
  git add -A
  if ! git diff --cached --quiet; then
    git commit -qm 'Record verified local handoff'
    printf 'Local handoff saved; next host changes require fresh evidence.\n'
  else
    printf 'Local handoff unchanged; baseline retained.\n'
  fi
else
  printf 'Local check passed; baseline unchanged until close.\n'
fi
