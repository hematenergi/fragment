#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/link-fixtures.sh
. "$ROOT/tests/link-fixtures.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REPO="$TMP/repo"
mkdir -p "$REPO/scripts" "$REPO/docs"
git -C "$REPO" init -q .
cp "$ROOT/template/scripts/state-prune.sh" "$REPO/scripts/state-prune.sh"

cat > "$REPO/docs/STATE.md" <<'STATE'
---
id: state
title: Position
status: active
owner: test
last-verified: 2026-10-08
---

## Phase

v0.6 work

## Registro de sesión

One dated bullet per session.

- 2026-10-08 · agent · newest session · next: continue
- 2026-10-07 · agent · next newest · next: continue
- 2026-09-30 · agent · older session · next: nothing
  wrapped detail belonging to the older record
- 2026-09-29 · agent · oldest session · next: nothing
STATE

STATE_FILE='docs/STATE.md'
STATE_ARCHIVE_FILE='docs/_attic/history.md'
export STATE_FILE STATE_ARCHIVE_FILE
before=$(cat "$REPO/docs/STATE.md")
out=$(cd "$REPO" && bash scripts/state-prune.sh --keep 2)
case "$out" in *"Would move 2"*"no files changed"*) ;; *) printf 'FAIL: dry run did not explain its preview\n%s\n' "$out"; exit 1 ;; esac
[ "$(cat "$REPO/docs/STATE.md")" = "$before" ] || { printf 'FAIL: dry run changed STATE\n'; exit 1; }
[ ! -e "$REPO/docs/_attic/history.md" ] || { printf 'FAIL: dry run created the archive\n'; exit 1; }
printf '  ok    dry run previews without writing\n'

mkdir -p "$TMP/outside"
if make_test_dir_link "$TMP/outside" "$REPO/docs/escape"; then
  if (cd "$REPO" && STATE_ARCHIVE_FILE='docs/escape/history.md' \
    bash scripts/state-prune.sh --keep 2 --apply >/dev/null 2>&1); then
    printf 'FAIL: archive path through a linked directory was accepted\n'; exit 1
  fi
  [ ! -e "$TMP/outside/history.md" ] || { printf 'FAIL: archive escaped through a symlinked directory\n'; exit 1; }
  printf '  ok    archive refuses linked parent directories\n'
else
  printf '  SKIP  linked-parent check unavailable on this platform\n'
fi

out=$(cd "$REPO" && bash scripts/state-prune.sh --keep 2 --apply)
case "$out" in *"Archived 2 older session record(s)"*) ;; *) printf 'FAIL: apply did not report moved records\n%s\n' "$out"; exit 1 ;; esac
grep -q '2026-10-08.*newest session' "$REPO/docs/STATE.md" || { printf 'FAIL: newest session was not kept hot\n'; exit 1; }
grep -q '2026-10-07.*next newest' "$REPO/docs/STATE.md" || { printf 'FAIL: second newest session was not kept hot\n'; exit 1; }
! grep -q 'older session' "$REPO/docs/STATE.md" || { printf 'FAIL: old sessions remain in hot STATE\n'; exit 1; }
grep -q '2026-09-30.*older session' "$REPO/docs/_attic/history.md" || { printf 'FAIL: old session was not archived\n'; exit 1; }
grep -q 'wrapped detail belonging to the older record' "$REPO/docs/_attic/history.md" || { printf 'FAIL: wrapped session details were lost\n'; exit 1; }
grep -Fq 'Archived session history: [open archive](_attic/history.md)' "$REPO/docs/STATE.md" || { printf 'FAIL: STATE does not link to its archive\n'; exit 1; }
case "$(uname -s)" in
  Darwin) mode=$(stat -f '%Lp' "$REPO/docs/_attic/history.md") ;;
  *) mode=$(stat -c '%a' "$REPO/docs/_attic/history.md") ;;
esac
[ "$mode" = 644 ] || { printf 'FAIL: archive mode is not readable by the team\n'; exit 1; }
printf '  ok    apply keeps newest records and archives older history\n'

# Simulate interruption after the archive move but before the STATE replacement.
cp "$REPO/docs/STATE.md" "$TMP/pruned-state"
printf '%s\n' "$before" > "$REPO/docs/STATE.md"
cd "$REPO"
bash scripts/state-prune.sh --keep 2 --apply >/dev/null
markers=$(grep -c 'session-record:' docs/_attic/history.md)
[ "$markers" = 2 ] || { printf 'FAIL: retry duplicated archive entries\n'; exit 1; }
cmp -s "$TMP/pruned-state" docs/STATE.md || { printf 'FAIL: retry did not restore the pruned STATE\n'; exit 1; }
printf '  ok    retry is idempotent after an interrupted handoff\n'

if bash "$REPO/scripts/state-prune.sh" --keep 0 >/dev/null 2>&1; then
  printf '  FAIL  non-positive keep counts are rejected\n'; exit 1
fi
printf '  ok    non-positive keep counts are rejected\n'
if STATE_ARCHIVE_FILE="$TMP/outside.md" bash "$REPO/scripts/state-prune.sh" --keep 2 >/dev/null 2>&1; then
  printf '  FAIL  an archive path outside the checkout was accepted\n'; exit 1
fi
printf '  ok    archive paths cannot escape the checkout\n'

cat > "$REPO/docs/STATE-empty.md" <<'STATE'
---
id: state-empty
title: Empty history
status: active
owner: test
last-verified: 2026-10-08
---

## Overview

No session records here.
STATE
before_empty=$(cat "$REPO/docs/STATE-empty.md")
out=$(STATE_FILE='docs/STATE-empty.md' STATE_ARCHIVE_FILE='docs/_attic/empty.md' \
  bash "$REPO/scripts/state-prune.sh" --keep 2)
case "$out" in *"nothing to prune"*) ;; *) printf 'FAIL: empty session log was not a no-op\n%s\n' "$out"; exit 1 ;; esac
[ "$(cat "$REPO/docs/STATE-empty.md")" = "$before_empty" ] || { printf 'FAIL: empty session log changed\n'; exit 1; }
[ ! -e "$REPO/docs/_attic/empty.md" ] || { printf 'FAIL: empty session log created an archive\n'; exit 1; }
printf '  ok    empty session log is a no-op\n'

printf 'body without a structural section\n' > "$REPO/docs/STATE-bare.md"
if STATE_FILE='docs/STATE-bare.md' bash "$REPO/scripts/state-prune.sh" --keep 2 >/dev/null 2>&1; then
  printf '  FAIL  malformed STATE without a level-two section was accepted\n'; exit 1
fi
printf '  ok    malformed STATE is rejected without editing it\n'
printf 'GREEN — state-prune tests passed\n'
