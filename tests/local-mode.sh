#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
pass=0
ok() { printf '  ok    %s\n' "$1"; pass=$((pass+1)); }
fail() { printf 'FAIL: %s\n%s\n' "$1" "${OUT:-}" >&2; exit 1; }
run() { set +e; OUT=$("$@" 2>&1); CODE=$?; set -e; }
repo() {
  D="$TMP/$1"; mkdir -p "$D"
  git -C "$D" init -q
  git -C "$D" config user.name tester
  git -C "$D" config user.email tester@example.com
  printf 'office instructions\n' > "$D/AGENTS.md"
  printf 'office Claude instructions\n' > "$D/CLAUDE.md"
  printf 'initial application\n' > "$D/app.txt"
  git -C "$D" add .
  git -C "$D" commit -qm initial
}
# Exercise local behavior even when the suite itself runs on a CI worker.
local_cmd() { CI='' GITHUB_ACTIONS='' BASE_REF='' bash "$D/.fragment/scripts/local-mode.sh" "$@"; }
fill() {
  # Use the minimal, filled-in fixture shared by the main suite.
  cp -R "$ROOT/examples/online-shop/docs/." "$D/.fragment/docs/"
  cp "$ROOT/examples/online-shop/AGENTS.md" "$D/.fragment/AGENTS.md"
  cp "$ROOT/examples/online-shop/CLAUDE.md" "$D/.fragment/CLAUDE.md"
  cp "$ROOT/examples/online-shop/START-HERE.md" "$D/.fragment/START-HERE.md"
  printf '\n- Local adoption completed with verified project context and the next task recorded.\n' >> "$D/.fragment/docs/STATE.md"
}
handoff() { printf '\n- %s: verified the selected application work and recorded its next action.\n' "$1" >> "$D/.fragment/docs/STATE.md"; }

repo 'office repo'
before=$(git -C "$D" status --porcelain)
exclude_before=$(cksum "$D/.git/info/exclude")
run bash "$ROOT/install.sh" --local --dry-run "$D"
[ "$CODE" = 0 ] && [ ! -e "$D/.fragment" ] || fail 'local dry run must write nothing'
[ "$(cksum "$D/.git/info/exclude")" = "$exclude_before" ] || fail 'dry run changed local exclude rules'
ok 'local dry run writes no context directory'
run bash "$ROOT/install.sh" --local "$D"
[ "$CODE" = 0 ] && [ -d "$D/.fragment/.git" ] || fail 'local install must create isolated history'
[ "$(git -C "$D" status --porcelain)" = "$before" ] || fail 'host status changed'
grep -qx 'office instructions' "$D/AGENTS.md" || fail 'office instructions overwritten'
git -C "$D" check-ignore -q .fragment/docs/STATE.md || fail 'context is not ignored'
[ -z "$(git -C "$D/.fragment" remote)" ] || fail 'local context must have no remote'
ok 'installation preserves host tracked files, status and instructions'
run local_cmd check
[ "$CODE" != 0 ] || fail 'unfilled local template incorrectly passed'
ok 'local install still enforces template adoption'
fill
run local_cmd close
[ "$CODE" = 0 ] || fail 'filled local adoption could not close'
baseline=$(git -C "$D/.fragment" rev-parse HEAD)
run local_cmd close
[ "$CODE" = 0 ] && [ "$(git -C "$D/.fragment" rev-parse HEAD)" = "$baseline" ] || fail 'idle close should not make a commit'
ok 'successful close stores a baseline and idle close stays quiet'

for kind in unstaged staged untracked committed; do
  case "$kind" in
    unstaged) printf 'edit\n' >> "$D/app.txt" ;;
    staged) printf 'staged\n' >> "$D/app.txt"; git -C "$D" add app.txt ;;
    untracked) printf 'new\n' > "$D/new file.txt" ;;
    committed) git -C "$D" add -A; git -C "$D" commit -qm application ;;
  esac
  run local_cmd close
  [ "$CODE" != 0 ] && [[ "$OUT" == *'handoff'* ]] || fail "$kind work accepted an old handoff"
  [ "$(git -C "$D/.fragment" rev-parse HEAD)" = "$baseline" ] || fail 'failed close advanced baseline'
  handoff "$kind"
  run local_cmd check
  [ "$CODE" = 0 ] && [ "$(git -C "$D/.fragment" rev-parse HEAD)" = "$baseline" ] || fail 'check must validate without acknowledging'
  run local_cmd close
  [ "$CODE" = 0 ] || fail "$kind work with fresh handoff failed"
  baseline=$(git -C "$D/.fragment" rev-parse HEAD)
  ok "$kind work requires a fresh handoff and failed close preserves baseline"
done

printf 'changed again\n' >> "$D/new file.txt"
run local_cmd close
[ "$CODE" != 0 ] || fail 'changed contents of an existing untracked file escaped'
handoff 'untracked content'
run local_cmd close
[ "$CODE" = 0 ] || fail 'could not close changed untracked file'
ok 'untracked content changes are detected even when Git status is identical'

printf 'staged reversal\n' >> "$D/app.txt"; git -C "$D" add app.txt
git -C "$D" show HEAD:app.txt > "$D/app.txt"
run local_cmd close
[ "$CODE" != 0 ] || fail 'staged reversal escaped detection'
handoff 'staged reversal'
run local_cmd close
[ "$CODE" = 0 ] || fail 'could not close staged reversal'
ok 'staged changes remain visible when worktree content matches HEAD'

printf 'metadata work\n' >> "$D/app.txt"
perl -pi -e 's/^last-verified: .*/last-verified: 2026-11-03/' "$D/.fragment/docs/STATE.md"
run local_cmd close
[ "$CODE" != 0 ] || fail 'metadata alone counted as handoff'
ok 'date-only edits do not satisfy local handoff evidence'
handoff 'metadata recovery'
run local_cmd close
[ "$CODE" = 0 ] || fail 'metadata recovery failed'
run bash "$D/.fragment/scripts/recall.sh" checkout
[ "$CODE" = 0 ] || fail 'local recall failed'
run bash "$D/.fragment/scripts/load-context.sh" --budget 12000 checkout
[ "$CODE" = 0 ] && [[ "$OUT" == *'# Source: docs/STATE.md'* ]] || fail 'local context loader failed'
ok 'recall and context loading work inside the ignored installation'

baseline=$(git -C "$D/.fragment" rev-parse HEAD)
printf '\n[missing](missing-local-note.md)\n' >> "$D/.fragment/docs/STATE.md"
run local_cmd close
[ "$CODE" != 0 ] && [ "$(git -C "$D/.fragment" rev-parse HEAD)" = "$baseline" ] || fail 'broken structure advanced local history'
perl -ni -e 'print unless /missing-local-note/' "$D/.fragment/docs/STATE.md"
ok 'structural failures preserve the previous baseline'
mkdir "$D/.fragment/.close-lock"
run local_cmd close
[ "$CODE" = 2 ] && [[ "$OUT" == *'another local'* ]] || fail 'concurrent close was not rejected'
rmdir "$D/.fragment/.close-lock"
ok 'concurrent local checks cannot race their baseline writes'
run env BASE_REF=HEAD bash "$D/.fragment/scripts/local-mode.sh" close
[ "$CODE" = 2 ] || fail 'host comparison environment bypassed local evidence'
ok 'CI and BASE_REF environments cannot bypass local evidence'
host_index=$(cksum "$D/.git/index")
run env GIT_INDEX_FILE="$D/.git/index" bash "$D/.fragment/scripts/local-mode.sh" close
[ "$CODE" = 2 ] && [ "$(cksum "$D/.git/index")" = "$host_index" ] || fail 'inherited host index was not rejected safely'
ok 'an inherited Git index cannot redirect private commits into the host index'

saved=$(git -C "$D/.fragment" rev-parse HEAD)
run bash "$ROOT/install.sh" --local "$D"
[ "$CODE" != 0 ] && [ "$(git -C "$D/.fragment" rev-parse HEAD)" = "$saved" ] || fail 'reinstall overwrote local history'
ok 'reinstall refuses to overwrite an existing local workspace'
run bash "$ROOT/install.sh" --local --upgrade "$D"
[ "$CODE" = 2 ] && [ "$(git -C "$D/.fragment" rev-parse HEAD)" = "$saved" ] || fail 'unsupported local upgrade changed context'
ok 'unsupported local upgrade preserves context'

repo reinclude
printf '!.fragment/\n!.fragment/**\n' > "$D/.gitignore"
git -C "$D" add .gitignore; git -C "$D" commit -qm reinclude
run bash "$ROOT/install.sh" --local "$D"
[ "$CODE" != 0 ] && [ ! -e "$D/.fragment" ] || fail 'explicit host ignore override was not respected'
ok 'host ignore overrides cannot silently expose local notes'

repo unborn
git -C "$D" checkout -q --orphan empty
git -C "$D" rm -q -r --cached .
run bash "$ROOT/install.sh" --local "$D"
[ "$CODE" = 0 ] || fail 'unborn host install failed'
fill
run local_cmd close
[ "$CODE" = 0 ] || fail 'unborn host close failed'
ok 'a host without commits still gets a reliable private baseline'

repo tracked
mkdir "$D/.fragment"; printf 'shared\n' > "$D/.fragment/shared.txt"
git -C "$D" add .fragment; git -C "$D" commit -qm tracked
run bash "$ROOT/install.sh" --local "$D"
[ "$CODE" != 0 ] && [ ! -e "$D/.fragment/.git" ] || fail 'tracked context directory must be refused'
ok 'installer refuses an existing tracked context directory'

repo linked
mkdir "$TMP/outside"
if ln -s "$TMP/outside" "$D/.fragment" 2>/dev/null; then
  run bash "$ROOT/install.sh" --local "$D"
  [ "$CODE" != 0 ] && [ ! -e "$TMP/outside/.git" ] || fail 'linked context was followed'
  ok 'installer refuses linked local storage'
fi

repo worktree
git -C "$D" worktree add -qb other "$TMP/linked worktree"
D="$TMP/linked worktree"
run bash "$ROOT/install.sh" --local "$D"
[ "$CODE" = 0 ] && git -C "$D" check-ignore -q .fragment/docs/STATE.md || fail 'linked Git worktree install failed'
ok 'linked host worktrees receive their own ignored local context'

printf 'GREEN — %s local-mode tests passed\n' "$pass"
