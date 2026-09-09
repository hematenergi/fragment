#!/usr/bin/env bash
# Fragment — installer.
# Copies the template into a repo WITHOUT overwriting anything that already exists.
#
#   bash install.sh [target-repo]     (default: current directory)
#   bash install.sh --dry-run [dir]   show what would be written, touch nothing
#   bash install.sh --version
set -uo pipefail

# Read from the guard so there is exactly one place the version is written.
FRAGMENT_VERSION=$(sed -n 's/^FRAGMENT_VERSION="\(.*\)"$/\1/p' \
  "$(dirname "$0")/template/scripts/docs-check.sh" 2>/dev/null | head -1)
FRAGMENT_VERSION="${FRAGMENT_VERSION:-unknown}"

DRY=0
args=()
for a in "$@"; do
  case "$a" in
    --version) printf 'fragment %s\n' "$FRAGMENT_VERSION"; exit 0 ;;
    --dry-run|-n) DRY=1 ;;
    *) args+=("$a") ;;
  esac
done
set -- "${args[@]+"${args[@]}"}"

SRC="$(cd "$(dirname "$0")/template" 2>/dev/null && pwd)" || true
[ -n "${SRC:-}" ] && [ -d "$SRC" ] || { echo "cannot find template/ next to install.sh"; exit 1; }

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo "target directory does not exist: $TARGET"; exit 1; }
DST="$(cd "$TARGET" && pwd)" || exit 1
[ -n "$DST" ] || { echo "cannot resolve target directory"; exit 1; }
[ "$SRC" = "$DST" ] && { echo "target is the template itself"; exit 1; }

echo "Fragment $FRAGMENT_VERSION → $DST"
[ "$DRY" = 1 ] && echo "(dry run — nothing will be written)"
echo

# An existing install should be recognised, not silently half-overwritten. The
# copier skips whatever already exists, so without this line an upgrade looks
# identical to a fresh install that mostly failed.
existing=""
if [ -f "$DST/scripts/docs-check.sh" ]; then
  existing=$(sed -n 's/^FRAGMENT_VERSION="\(.*\)"$/\1/p' "$DST/scripts/docs-check.sh" | head -1)
  if [ -z "$existing" ]; then
    echo "  Fragment is already installed here, from a build too old to carry a version."
  elif [ "$existing" = "$FRAGMENT_VERSION" ]; then
    echo "  Fragment $existing is already installed here. Nothing to upgrade."
  else
    echo "  Fragment $existing is already installed here; this is $FRAGMENT_VERSION."
  fi
  echo "  Existing files are never overwritten — anything listed as 'skip' below"
  echo "  keeps your version, and you merge the change by hand if you want it."
  echo
fi

copied=0; skipped=0
while IFS= read -r f; do
  rel="${f#"$SRC"/}"
  out="$DST/$rel"
  if [ -e "$out" ]; then
    printf '  skip    %s  (already exists — merge by hand)\n' "$rel"; skipped=$((skipped+1)); continue
  fi
  if [ "$DRY" = 1 ]; then
    printf '  would  %s\n' "$rel"; copied=$((copied+1)); continue
  fi
  mkdir -p "$(dirname "$out")"
  cp "$f" "$out"; printf '  copied  %s\n' "$rel"; copied=$((copied+1))
done < <(find "$SRC" -type f)

[ "$DRY" = 1 ] || chmod +x "$DST/scripts/docs-check.sh" 2>/dev/null || true

echo
if [ "$DRY" = 1 ]; then
  echo "$copied would be written, $skipped already exist. Nothing was changed."
  echo "Run without --dry-run to install."
  exit 0
fi
echo "$copied copied, $skipped skipped."
echo
echo "Next — the guard is the to-do list. Run it and it will name what is missing:"
echo
echo "  bash scripts/docs-check.sh"
echo
echo "It will fail until you have: filled the <PLACEHOLDER> fields, named an owner"
echo "on the three load-bearing documents, stamped last-verified with real dates,"
echo "and written one real fragment in docs/plans/. That is the whole install."
echo
echo "Skipped files were left untouched. Merge them by hand — especially CLAUDE.md"
echo "and AGENTS.md, which must end up pointing at docs/AGENT-PROTOCOL.md."
echo
echo "Optional, for Claude Code users: copy the adoption skill so an agent can do"
echo "the above for you —"
echo "  mkdir -p .claude/skills/fragment && cp ${SRC%/template}/skill/SKILL.md .claude/skills/fragment/"
