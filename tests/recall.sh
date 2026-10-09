#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REPO="$TMP/repo"
mkdir -p "$REPO/scripts" "$REPO/docs/decisions" "$REPO/docs/lessons" "$REPO/docs/plans"
git -C "$REPO" init -q .
cp "$ROOT/template/scripts/recall.sh" "$REPO/scripts/recall.sh"
printf 'Index pages mention pricing and liquidity but are not records.\n' > "$REPO/docs/decisions/README.md"

cat > "$REPO/docs/decisions/0001-pricing.md" <<'DOC'
---
id: decision-0001
title: "0001 — Price ladder selection"
status: active
owner: test
last-verified: 2026-10-08
tags: [pricing, liquidity]
---

This chooses how the collateral band is selected.
DOC

cat > "$REPO/docs/lessons/retry.md" <<'DOC'
---
id: lesson-retry
title: Retry network calls
status: active
owner: test
last-verified: 2026-10-08
tags: [network, testing]
---

Retry transient RPC timeouts at the boundary.
DOC

cat > "$REPO/docs/lessons/legacy.md" <<'DOC'
---
id: lesson-legacy
title: Session evidence
status: active
owner: test
last-verified: 2026-10-08
---

A handoff is separate from historical inventory. Liquidity history remains
available, but a repeated liquidity note should not outrank a tagged decision.
DOC

cat > "$REPO/docs/lessons/block-tags.md" <<'DOC'
---
id: lesson-block-tags
title: Structured metadata
status: active
owner: test
last-verified: 2026-10-08
tags:
  - oracle
  - constraints
---

Block-style YAML tags remain searchable.
DOC

cat > "$REPO/docs/plans/ignored.md" <<'DOC'
---
id: plan-ignored
title: Pricing and liquidity
status: todo
owner: test
last-verified: 2026-10-08
---

Not part of decision or lesson recall.
DOC

assert_contains() {
  case "$1" in *"$2"*) printf '  ok    %s\n' "$3" ;; *) printf '  FAIL  %s\n' "$3"; printf '%s\n' "$1"; exit 1 ;; esac
}
assert_not_contains() {
  case "$1" in *"$2"*) printf '  FAIL  %s\n' "$3"; printf '%s\n' "$1"; exit 1 ;; *) printf '  ok    %s\n' "$3" ;; esac
}

out=$(cd "$TMP" && bash "$REPO/scripts/recall.sh" LIQUIDITY)
first=$(printf '%s\n' "$out" | head -1)
assert_contains "$first" '0001-pricing.md' 'tags retrieve the matching decision'
assert_not_contains "$out" 'docs/plans/ignored.md' 'plans are outside the recall scope'
assert_not_contains "$out" 'docs/decisions/README.md' 'index pages are not recall records'

out=$(bash "$REPO/scripts/recall.sh" 'rpc transient')
assert_contains "$out" 'docs/lessons/retry.md' 'title and body matches find records without exact tags'

out=$(bash "$REPO/scripts/recall.sh" 'historical inventory')
assert_contains "$out" 'docs/lessons/legacy.md' 'legacy records without tags remain searchable'

out=$(bash "$REPO/scripts/recall.sh" 'oracle')
assert_contains "$out" 'docs/lessons/block-tags.md' 'block-style YAML tags are supported'

out=$(bash "$REPO/scripts/recall.sh" --limit 1 'liquidity network')
[ "$(printf '%s\n' "$out" | wc -l | tr -d '[:space:]')" = 1 ] || { printf '  FAIL  limit restricts result count\n'; exit 1; }
printf '  ok    limit restricts result count\n'

if ln -s "$REPO/docs" "$REPO/docs-link" 2>/dev/null; then
  if DOCS_ROOT='docs-link' bash "$REPO/scripts/recall.sh" liquidity >/dev/null 2>&1; then
    printf '  FAIL  DOCS_ROOT symlink was accepted\n'
    printf '  DEBUG link: '; ls -ld "$REPO/docs-link"
    printf '  DEBUG -L: '; [ -L "$REPO/docs-link" ] && printf 'yes\n' || printf 'no\n'
    printf '  DEBUG readlink: '; readlink "$REPO/docs-link" 2>&1 || true
    printf '  DEBUG realpath: '; realpath "$REPO/docs-link" 2>&1 || true
    printf '  DEBUG logical/physical: '
    (cd -L "$REPO/docs-link" && pwd -L && pwd -P) 2>&1 || true
    printf '  DEBUG git prefix: '
    git -C "$REPO/docs-link" rev-parse --show-prefix 2>&1 || true
    if command -v powershell.exe >/dev/null 2>&1 && command -v cygpath >/dev/null 2>&1; then
      windows_root=$(cygpath -aw "$REPO")
      windows_link=$(cygpath -aw "$REPO/docs-link")
      printf '  DEBUG Windows metadata for %s:\n' "$windows_link"
      FRAGMENT_REPO_ROOT="$windows_root" FRAGMENT_CHECK_PATH="$windows_link" \
        powershell.exe -NoProfile -NonInteractive -Command \
        '$repo=$env:FRAGMENT_REPO_ROOT; $path=$env:FRAGMENT_CHECK_PATH; $item=Get-Item -LiteralPath $path -Force; Write-Output "repo=$repo"; Write-Output "path=$path"; Write-Output "attributes=$($item.Attributes)"; Write-Output "reparse=$([bool]($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint))"' 2>&1 || true
      printf '  DEBUG Windows reparse entries in repo root:\n'
      MSYS_NO_PATHCONV=1 cmd.exe /d /c "dir /a:l /b \"$windows_root\"" 2>&1 | tr -d '\r' || true
    fi
    exit 1
  fi
  printf '  ok    recall refuses DOCS_ROOT symlinks\n'
else
  printf '  SKIP  DOCS_ROOT symlink check unavailable on this platform\n'
fi

out=$(bash "$REPO/scripts/recall.sh" 'xyzzy-quokka-unicorn-827')
assert_contains "$out" 'No decisions or lessons matched.' 'no match is a clean empty result'

if bash "$REPO/scripts/recall.sh" --limit 0 test >/dev/null 2>&1; then
  printf '  FAIL  non-positive result limits are rejected\n'; exit 1
fi
printf '  ok    non-positive result limits are rejected\n'

mv "$REPO/docs" "$REPO/project docs"
out=$(DOCS_ROOT='project docs' bash "$REPO/scripts/recall.sh" liquidity)
assert_contains "$out" 'project docs/decisions/0001-pricing.md' 'relocated docs roots with spaces are supported'

printf 'GREEN — recall tests passed\n'
