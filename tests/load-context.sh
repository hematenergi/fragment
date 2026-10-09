#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/link-fixtures.sh
. "$ROOT/tests/link-fixtures.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REPO="$TMP/repo"
mkdir -p "$REPO/scripts" "$REPO/docs/decisions" "$REPO/docs/lessons" "$REPO/docs/plans"
git -C "$REPO" init -q .
cp "$ROOT/template/scripts/recall.sh" "$REPO/scripts/recall.sh"
cp "$ROOT/template/scripts/load-context.sh" "$REPO/scripts/load-context.sh"

cat > "$REPO/docs/STATE.md" <<'STATE'
---
id: state
title: Position
status: active
owner: test
last-verified: 2026-10-08
---

Current project phase and next action.
STATE

cat > "$REPO/docs/decisions/0001-large.md" <<'DOC'
---
id: decision-large
title: Liquidity source details
status: active
owner: test
last-verified: 2026-10-08
tags: [liquidity]
---
DOC
for ((i=0; i<80; i++)); do printf 'liquidity detail %s with additional context\n' "$i" >> "$REPO/docs/decisions/0001-large.md"; done

cat > "$REPO/docs/decisions/0002-short.md" <<'DOC'
---
id: decision-short
title: Fee ladder
status: active
owner: test
last-verified: 2026-10-08
tags: [liquidity, pricing]
---

Choose a fee by band.
DOC

cat > "$REPO/docs/lessons/unrelated.md" <<'DOC'
---
id: lesson-unrelated
title: Retry network calls
status: active
owner: test
last-verified: 2026-10-08
tags: [network]
---

Retry transient RPC errors.
DOC

chunk_size() {
  { printf '# Source: %s\n' "$1"; cat "$2"; printf '\n'; } | wc -c | tr -d '[:space:]'
}
state_size=$(chunk_size docs/STATE.md "$REPO/docs/STATE.md")
short_size=$(chunk_size docs/decisions/0002-short.md "$REPO/docs/decisions/0002-short.md")
budget=$((state_size + short_size))

(cd "$REPO" && bash scripts/load-context.sh --budget "$budget" --limit 10 liquidity) \
  > "$TMP/context.md" 2> "$TMP/report"
actual=$(wc -c < "$TMP/context.md" | tr -d '[:space:]')
[ "$actual" -le "$budget" ] || { printf 'FAIL: emitted %s bytes for a %s-token cap\n' "$actual" "$budget"; exit 1; }
grep -q '^# Source: docs/STATE.md$' "$TMP/context.md" || { printf 'FAIL: STATE was not loaded first\n'; exit 1; }
grep -q '^# Source: docs/decisions/0002-short.md$' "$TMP/context.md" || { printf 'FAIL: loader stopped at an oversized top result instead of trying the next record\n'; exit 1; }
! grep -q '0001-large.md' "$TMP/context.md" || { printf 'FAIL: oversized record exceeded the cap\n'; exit 1; }
printf '  ok    STATE is included and whole ranked records stay within the cap\n'

if (cd "$REPO" && bash scripts/load-context.sh --budget "$((state_size - 1))" liquidity) \
  > "$TMP/too-small.md" 2> "$TMP/too-small.err"; then
  printf 'FAIL: a budget smaller than STATE was accepted\n'; exit 1
else
  code=$?
  [ "$code" = 3 ] || { printf 'FAIL: too-small STATE exited %s instead of 3\n' "$code"; exit 1; }
fi
[ ! -s "$TMP/too-small.md" ] || { printf 'FAIL: partial context was emitted when STATE did not fit\n'; exit 1; }
grep -q 'STATE alone needs' "$TMP/too-small.err" || { printf 'FAIL: missing STATE budget explanation\n'; exit 1; }
printf '  ok    loader refuses to exceed a budget that cannot fit STATE\n'

(cd "$REPO" && bash scripts/load-context.sh --budget 10000 'network errors') \
  > "$TMP/roomy.md" 2> "$TMP/roomy.err"
grep -q '^# Source: docs/lessons/unrelated.md$' "$TMP/roomy.md" || { printf 'FAIL: relevant lesson was not loaded\n'; exit 1; }
printf '  ok    recall-selected lessons are included when budget allows\n'

if (cd "$REPO" && bash scripts/load-context.sh --budget 10000 >/dev/null 2>&1); then
  printf 'FAIL: missing query was accepted\n'; exit 1
fi
printf '  ok    missing query is rejected\n'

if (cd "$REPO" && STATE_FILE="$REPO/docs/../outside.md" bash scripts/load-context.sh --budget 10000 liquidity >/dev/null 2>&1); then
  printf 'FAIL: a STATE path escaping the checkout was accepted\n'; exit 1
fi
printf '  ok    STATE paths cannot escape the checkout\n'

printf 'outside STATE must never be emitted\n' > "$TMP/outside-state.md"
if make_test_file_link "$TMP/outside-state.md" "$REPO/docs/state-link.md"; then
  if (cd "$REPO" && STATE_FILE="$REPO/docs/state-link.md" \
    bash scripts/load-context.sh --budget 10000 liquidity >/dev/null 2>&1); then
    printf 'FAIL: a symlinked STATE path was accepted\n'; exit 1
  fi
  printf '  ok    loader refuses symlinked STATE files\n'
else
  printf '  SKIP  symlinked STATE check unavailable on this platform\n'
fi

mv "$REPO/docs" "$REPO/project docs"
(cd "$REPO" && DOCS_ROOT='project docs' bash scripts/load-context.sh --budget 10000 liquidity) \
  > "$TMP/relocated.md" 2> "$TMP/relocated.err"
grep -q '^# Source: project docs/STATE.md$' "$TMP/relocated.md" || { printf 'FAIL: relocated STATE was not included\n'; exit 1; }
grep -q '^# Source: project docs/decisions/0002-short.md$' "$TMP/relocated.md" || { printf 'FAIL: recall failed under relocated docs root\n'; exit 1; }
printf '  ok    relocated docs roots with spaces work in the budget loader\n'
printf 'GREEN — load-context tests passed\n'
