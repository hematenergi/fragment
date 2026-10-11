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
  link_status=$?
  [ "$link_status" -ne 2 ] || { printf 'FAIL: Windows parent-link fixture was not a reparse point\n'; exit 1; }
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
before_empty=$(cat "$REPO/docs/STATE-empty.md")
if out=$(cd "$REPO" && STATE_FILE='docs/STATE-empty.md' STATE_ARCHIVE_FILE='docs/_attic/empty-over-budget.md' \
  bash scripts/state-prune.sh --budget 20 --apply 2>&1); then
  printf 'FAIL: over-budget fixed STATE without dated records was accepted\n%s\n' "$out"; exit 1
else
  code=$?
  [ "$code" -eq 3 ] || { printf 'FAIL: fixed-content limit returned %s, expected 3\n' "$code"; exit 1; }
fi
[ "$(cat "$REPO/docs/STATE-empty.md")" = "$before_empty" ] \
  && [ ! -e "$REPO/docs/_attic/empty-over-budget.md" ] \
  || { printf 'FAIL: impossible budget changed STATE or created an archive\n'; exit 1; }
printf '  ok    impossible STATE budget reports the limit without writing\n'

printf 'body without a structural section\n' > "$REPO/docs/STATE-bare.md"
if STATE_FILE='docs/STATE-bare.md' bash "$REPO/scripts/state-prune.sh" --keep 2 >/dev/null 2>&1; then
  printf '  FAIL  malformed STATE without a level-two section was accepted\n'; exit 1
fi
printf '  ok    malformed STATE is rejected without editing it\n'

# Automatic pruning is budget-triggered and uses record dates, not file order.
cat > "$REPO/docs/STATE-auto.md" <<'STATE'
---
id: state-auto
title: Automatic history
status: active
owner: test
last-verified: 2026-10-08
---

## Overview

Fixed context stays hot.

## Catatan
STATE
padding=$(printf '%0250d' 0 | tr '0' x)
printf -- '- 2026-10-08 · agent · newest · %s\n' "$padding" >> "$REPO/docs/STATE-auto.md"
printf -- '- 2026-10-01 · agent · older-in-the-middle · %s\n' "$padding" >> "$REPO/docs/STATE-auto.md"
printf -- '- 2026-10-07 · agent · second-newest · %s\n' "$padding" >> "$REPO/docs/STATE-auto.md"
printf -- '- 2026-09-30 · agent · oldest · %s\n' "$padding" >> "$REPO/docs/STATE-auto.md"
before_auto=$(cat "$REPO/docs/STATE-auto.md")
out=$(cd "$REPO" && STATE_FILE='docs/STATE-auto.md' STATE_ARCHIVE_FILE='docs/_attic/auto.md' \
  bash scripts/state-prune.sh --budget 900)
case "$out" in *"Would archive"*"no files changed"*) ;; *) printf 'FAIL: automatic dry run did not explain its decision\n%s\n' "$out"; exit 1 ;; esac
[ "$(cat "$REPO/docs/STATE-auto.md")" = "$before_auto" ] || { printf 'FAIL: automatic dry run changed STATE\n'; exit 1; }
out=$(cd "$REPO" && STATE_FILE='docs/STATE-auto.md' STATE_ARCHIVE_FILE='docs/_attic/auto.md' \
  bash scripts/state-prune.sh --budget 900 --apply)
case "$out" in *"Archived"*"within the"*) ;; *) printf 'FAIL: automatic apply did not report a budget result\n%s\n' "$out"; exit 1 ;; esac
auto_size=$(wc -c < "$REPO/docs/STATE-auto.md" | tr -d '[:space:]')
[ "$auto_size" -le 900 ] || { printf 'FAIL: automatic prune left STATE over its byte budget (%s)\n' "$auto_size"; exit 1; }
grep -q '2026-10-08.*newest' "$REPO/docs/STATE-auto.md" || { printf 'FAIL: newest dated record was not kept hot\n'; exit 1; }
grep -q '2026-10-07.*second-newest' "$REPO/docs/STATE-auto.md" || { printf 'FAIL: second-newest dated record was not kept hot\n'; exit 1; }
! grep -q 'older-in-the-middle\|oldest' "$REPO/docs/STATE-auto.md" || { printf 'FAIL: an older date remained hot ahead of newer records\n'; exit 1; }
grep -q 'older-in-the-middle' "$REPO/docs/_attic/auto.md" || { printf 'FAIL: out-of-order old record was not archived\n'; exit 1; }
grep -q 'oldest' "$REPO/docs/_attic/auto.md" || { printf 'FAIL: oldest record was not archived\n'; exit 1; }
grep -Fq 'Archived session history: [open archive](_attic/auto.md)' "$REPO/docs/STATE-auto.md" || { printf 'FAIL: automatic archive is not linked from hot STATE\n'; exit 1; }
printf '  ok    automatic budget pruning archives oldest dates and keeps the archive linked\n'

# Adopter regression: session entries can live before later STATE sections,
# and explicit terminal plan rows can be archived after dated history is spent.
mkdir -p "$REPO/docs/plans"
cat > "$REPO/docs/plans/01-done.md" <<'PLAN'
---
id: plan-done
title: Done plan
status: "done"
owner: test
last-verified: 2026-10-01
---
PLAN
cat > "$REPO/docs/plans/02-parked.md" <<'PLAN'
---
id: plan-parked
title: Parked plan
status: parked
reason: waiting on owner
owner: test
last-verified: 2026-10-02
---
PLAN
cat > "$REPO/docs/plans/03-todo.md" <<'PLAN'
---
id: plan-todo
title: Open plan
status: todo
owner: test
last-verified: 2026-10-03
---
PLAN
cat > "$REPO/docs/plans/04-mismatch.md" <<'PLAN'
---
id: plan-mismatch
title: Status mismatch
status: todo
owner: test
last-verified: 2026-10-04
---
PLAN
cat > "$REPO/docs/STATE-adopter.md" <<'STATE'
---
id: state-adopter
title: Adopter-shaped STATE
status: active
owner: test
last-verified: 2026-10-08
---

# STATE

## Snapshot

Keep this active summary hot.

## Session log

- 2026-10-08 · agent · newest session stays hot
- 2026-10-01 · agent · oldest session moves · xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  wrapped session evidence stays with its record
  related plan: [open](plans/03-todo.md)
  repository guide: [README](../README.md#install)

## Handoff

This section follows the session log and must remain in place.

| # | Fragment | Status | Details |
|---|---|---|---|
| 01 | [Done](plans/01-done.md) | `done` | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
| 02 | [Parked](plans/02-parked.md) | `parked` | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
| 03 | [Open](plans/03-todo.md) | `todo` | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
| 04 | [Mismatch](plans/04-mismatch.md) | `done` | this row contradicts its linked plan |
STATE
out=$(cd "$REPO" && STATE_FILE='docs/STATE-adopter.md' STATE_ARCHIVE_FILE='docs/_attic/adopter.md' \
  bash scripts/state-prune.sh --budget 1400 --apply 2>&1) || {
  printf 'FAIL: adopter-shaped STATE could not be pruned\n%s\n' "$out"; exit 1;
}
adopter_size=$(wc -c < "$REPO/docs/STATE-adopter.md" | tr -d '[:space:]')
[ "$adopter_size" -le 1400 ] || { printf 'FAIL: adopter STATE remains over budget (%s)\n' "$adopter_size"; exit 1; }
grep -q 'newest session stays hot' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: newest session was removed\n'; exit 1; }
grep -q 'wrapped session evidence stays with its record' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: wrapped session evidence was lost\n'; exit 1; }
grep -Fq '](../plans/03-todo.md)' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: archived session link no longer resolves\n'; exit 1; }
grep -Fq '](../../README.md#install)' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: archived parent link or anchor no longer resolves\n'; exit 1; }
grep -q 'This section follows the session log' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: fixed section after session log was lost\n'; exit 1; }
grep -q 'plans/03-todo.md' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: active plan row was archived\n'; exit 1; }
grep -q 'plans/04-mismatch.md' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: mismatched plan status was archived\n'; exit 1; }
! grep -q 'plans/01-done.md' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: done plan row remains hot\n'; exit 1; }
grep -q 'plans/02-parked.md' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: parked plan was pruned before needed\n'; exit 1; }
grep -q 'plans/01-done.md' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: done plan row is missing from archive\n'; exit 1; }
grep -Fq '](../plans/01-done.md)' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: archived plan row link no longer resolves\n'; exit 1; }
! grep -q 'plans/02-parked.md' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: parked plan was archived while the budget could be met without it\n'; exit 1; }
out=$(cd "$REPO" && STATE_FILE='docs/STATE-adopter.md' STATE_ARCHIVE_FILE='docs/_attic/adopter.md' \
  bash scripts/state-prune.sh --budget 900 --apply 2>&1) || {
  printf 'FAIL: parked-row fallback could not meet the tighter budget\n%s\n' "$out"; exit 1;
}
adopter_size=$(wc -c < "$REPO/docs/STATE-adopter.md" | tr -d '[:space:]')
[ "$adopter_size" -le 900 ] || { printf 'FAIL: tighter adopter budget remains over limit (%s)\n' "$adopter_size"; exit 1; }
! grep -q 'plans/02-parked.md' "$REPO/docs/STATE-adopter.md" || { printf 'FAIL: parked plan row was not archived when needed\n'; exit 1; }
grep -q 'plans/02-parked.md' "$REPO/docs/_attic/adopter.md" || { printf 'FAIL: parked plan row is missing from fallback archive\n'; exit 1; }
before_adopter_state=$(cksum "$REPO/docs/STATE-adopter.md")
before_adopter_archive=$(cksum "$REPO/docs/_attic/adopter.md")
out=$(cd "$REPO" && STATE_FILE='docs/STATE-adopter.md' STATE_ARCHIVE_FILE='docs/_attic/adopter.md' \
  bash scripts/state-prune.sh --budget 900 --apply 2>&1)
[ "$(cksum "$REPO/docs/STATE-adopter.md")" = "$before_adopter_state" ] \
  && [ "$(cksum "$REPO/docs/_attic/adopter.md")" = "$before_adopter_archive" ] \
  || { printf 'FAIL: adopter pruning changed files on a no-op rerun\n'; exit 1; }
printf '  ok    adopter STATE prunes across sections, keeps parked rows until needed, and preserves active rows\n'

printf 'GREEN — state-prune tests passed\n'
