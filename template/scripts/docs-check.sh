#!/usr/bin/env bash
# Fragment Architecture — the document guard.
#
# Pure bash + git. No Node, no Python, no package manager. It never reads your
# source code, so it works the same in any stack.
#
# Local:  bash scripts/docs-check.sh
# CI:     BASE_REF=<sha> bash scripts/docs-check.sh   (also checks the session ritual)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'
fail=0; warn=0
err()   { printf '%s✗%s %s\n' "$RED" "$OFF" "$1"; fail=$((fail+1)); }
warnf() { printf '%s!%s %s\n' "$YEL" "$OFF" "$1"; warn=$((warn+1)); }

INDEX="docs/README.md"
[ -f "$INDEX" ] || { err "docs/README.md (the index) is missing"; exit 1; }

# 1. every doc: complete frontmatter, known status, listed in the index
while IFS= read -r f; do
  rel="${f#./}"
  head -1 "$f" | grep -q '^---$' || err "$rel — no frontmatter"
  for key in id title status owner last-verified; do
    grep -q "^${key}:" "$f" || err "$rel — frontmatter missing '${key}:'"
  done
  base="${rel#docs/}"
  if [ "$rel" != "$INDEX" ]; then
    grep -q "$base" "$INDEX" || err "$rel — not listed in docs/README.md"
  fi
  st=$(grep -m1 '^status:' "$f" | sed 's/^status:[[:space:]]*//')
  case "$st" in
    active|draft|superseded|todo|in-progress|done|parked) ;;
    *) err "$rel — unknown status: '$st'" ;;
  esac
done < <(find docs -name '*.md' -not -path 'docs/_attic/*' | sort)

# 2. at most one fragment in progress
inprog=$(grep -l '^status: in-progress' docs/plans/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "${inprog:-0}" -gt 1 ] && err "$inprog fragments in-progress — only one allowed (docs/plans/)"

# 3. every fragment is in the STATE queue
for f in docs/plans/[0-9]*.md; do
  [ -e "$f" ] || continue
  b=$(basename "$f")
  [ "$b" = "00-template.md" ] && continue
  grep -q "$b" docs/STATE.md || err "docs/plans/$b — missing from the queue in docs/STATE.md"
done

# 4. front doors stay thin and keep pointing at the protocol
for door in CLAUDE.md AGENTS.md; do
  [ -f "$door" ] || { warnf "$door missing — that agent has no entry point"; continue; }
  grep -q 'AGENT-PROTOCOL.md' "$door" || err "$door — does not point at docs/AGENT-PROTOCOL.md"
  lines=$(wc -l < "$door" | tr -d ' ')
  [ "$lines" -gt 40 ] && warnf "$door — $lines lines. Front doors stay thin; rules live in AGENT-PROTOCOL.md"
done
proto=$(wc -l < docs/AGENT-PROTOCOL.md 2>/dev/null | tr -d ' ')
[ "${proto:-0}" -gt 150 ] && warnf "docs/AGENT-PROTOCOL.md — $proto lines (>150). Move content into its own document"

# 5. the board should not go stale
if [ -n "$(find docs/STATE.md -mtime +7 2>/dev/null)" ]; then
  warnf "docs/STATE.md unchanged for >7 days — does it still reflect reality?"
fi

# 6. no dangling relative links between documents
dangling=0
while IFS= read -r f; do
  d=$(dirname "$f")
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    if [ ! -e "$d/$link" ]; then
      printf '%s✗%s %s → dangling link: %s\n' "$RED" "$OFF" "${f#./}" "$link"
      dangling=$((dangling+1))
    fi
  done < <(grep -o '](\.\{0,2\}[^):]*\.md)' "$f" 2>/dev/null | sed 's/^](//; s/)$//')
done < <(find docs -name '*.md' -not -path 'docs/_attic/*')
fail=$((fail + dangling))

# 7a. real secrets -> FAIL.
# A private key and a hash are both 64 hex. The difference is context: transaction
# hashes, order hashes and block hashes are always named on the same line -- a
# private key never is.
hex64=$(grep -rnE '0x[0-9a-fA-F]{64}' docs/ ./*.md 2>/dev/null \
  | grep -v '_attic' \
  | grep -viE 'hash|transaction|[^a-z]tx[^a-z]|commit|block|token|digest|checksum|example' || true)
if [ -n "$hex64" ]; then
  err "64-hex with no hash/tx context in a document. If it is a PRIVATE KEY, rotate it now:"
  printf '%s\n' "$hex64" | head -3 | sed 's/^/    /'
fi
if grep -rnE '(BEGIN [A-Z ]*PRIVATE KEY|(api[_-]?key|secret|password|token)[[:space:]]*[:=][[:space:]]*['"'"'"]?[A-Za-z0-9+/_-]{24,})' \
    docs/ ./*.md 2>/dev/null | grep -v '_attic' | grep -viE 'example|placeholder|<|xxx' | grep -q .; then
  err "something looks like a credential inside a document — check it, and rotate if real"
fi

# 8. session ritual -> CI only, needs a comparison commit.
# The rule from AGENT-PROTOCOL.md: docs changed means STATE.md changed too.
if [ -n "${BASE_REF:-}" ] && git rev-parse --verify -q "$BASE_REF" >/dev/null 2>&1; then
  changed=$(git diff --name-only "$BASE_REF" HEAD -- docs/ | grep -v '^docs/_attic/' || true)
  if [ -n "$changed" ]; then
    echo "$changed" | grep -q '^docs/STATE.md$' \
      || err "docs/ changed but docs/STATE.md did not. The Close ritual in docs/AGENT-PROTOCOL.md was skipped."
    git diff "$BASE_REF" HEAD -- docs/STATE.md | grep -q '^+.*·' \
      || warnf "docs/STATE.md changed but gained no Session log line — this session left no trace."
    for f in $(echo "$changed" | grep '^docs/plans/[0-9]' || true); do
      git diff "$BASE_REF" HEAD -- "$f" | grep -q '^+.*·' \
        || warnf "$f changed without a new Session log line."
    done
  fi
fi

echo
if [ "$fail" -gt 0 ]; then
  printf '%sFAILED%s — %s problem(s), %s warning(s)\n' "$RED" "$OFF" "$fail" "$warn"; exit 1
fi
printf '%sGREEN%s — documents are consistent%s\n' "$GRN" "$OFF" "$([ "$warn" -gt 0 ] && echo " ($warn warning(s))")"
printf '%sOne last thing: does docs/STATE.md reflect this session?%s\n' "$DIM" "$OFF"
