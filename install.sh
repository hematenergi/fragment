#!/usr/bin/env bash
# Fragment — installer.
# Copies the template into a repo WITHOUT overwriting anything that already exists.
#
#   bash install.sh [target-repo]     (default: current directory)
#   bash install.sh --dry-run [dir]   show what would be written, touch nothing
#   bash install.sh --upgrade [dir]   update an unmodified known guard
#   bash install.sh --version
set -uo pipefail

# Read from the guard so there is exactly one place the version is written.
FRAGMENT_VERSION=$(sed -n 's/^FRAGMENT_VERSION="\(.*\)"$/\1/p' \
  "$(dirname "$0")/template/scripts/docs-check.sh" 2>/dev/null | head -1)
FRAGMENT_VERSION="${FRAGMENT_VERSION:-unknown}"

DRY=0; UPGRADE=0
args=()
for a in "$@"; do
  case "$a" in
    --version) printf 'fragment %s\n' "$FRAGMENT_VERSION"; exit 0 ;;
    --dry-run|-n) DRY=1 ;;
    --upgrade) UPGRADE=1 ;;
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

# An upgrade cannot tell whether a file was customised from its version alone:
# it has to recognise the complete, shipped file. These are cksum's checksum
# and byte count for every released guard. An unknown or changed guard stays
# untouched; a collision is far less plausible than a team losing its changes.
guard_fingerprint() (
  read -r checksum bytes _ < <(cksum "$1")
  printf '%s:%s\n' "$checksum" "$bytes"
)
known_guard() {
  case "$1:$2" in
    unknown:1163781831:14620|\
    0.2.0:3601293120:18195|\
    0.3.0:3524956158:21571|\
    0.4.0:3777372876:21571) return 0 ;;
    *) return 1 ;;
  esac
}
guard_version() {
  sed -n 's/^FRAGMENT_VERSION="\(.*\)"$/\1/p' "$1" | head -1
}

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
  if [ "$UPGRADE" = 1 ]; then
    echo "  --upgrade only replaces an unmodified, recognised guard. Every other file"
    echo "  stays yours and is named below for a manual merge."
  else
    echo "  Existing files are never overwritten — anything listed as 'skip' below"
    echo "  keeps your version, and you merge the change by hand if you want it."
  fi
  echo
fi

copied=0; skipped=0; upgraded=0; retained=0
while IFS= read -r f; do
  rel="${f#"$SRC"/}"
  out="$DST/$rel"
  if [ -e "$out" ]; then
    if [ "$UPGRADE" = 1 ] && [ "$rel" = "scripts/docs-check.sh" ]; then
      installed=$(guard_version "$out")
      installed="${installed:-unknown}"
      fingerprint=$(guard_fingerprint "$out")
      if [ "$installed" = "$FRAGMENT_VERSION" ] && [ "$fingerprint" = "$(guard_fingerprint "$f")" ]; then
        printf '  current %s  (already Fragment %s)\n' "$rel" "$FRAGMENT_VERSION"; retained=$((retained+1)); continue
      fi
      if known_guard "$installed" "$fingerprint"; then
        if [ "$DRY" = 1 ]; then
          printf '  would upgrade %s  (Fragment %s → %s)\n' "$rel" "$installed" "$FRAGMENT_VERSION"
        else
          cp "$f" "$out"; chmod +x "$out" 2>/dev/null || true
          printf '  upgraded %s  (Fragment %s → %s)\n' "$rel" "$installed" "$FRAGMENT_VERSION"
        fi
        upgraded=$((upgraded+1)); continue
      fi
      printf '  keep    %s  (customised or unknown Fragment %s — merge by hand)\n' "$rel" "$installed"; retained=$((retained+1)); continue
    fi
    if [ "$UPGRADE" = 1 ]; then
      printf '  keep    %s  (existing file — merge by hand)\n' "$rel"; retained=$((retained+1)); continue
    fi
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
  if [ "$UPGRADE" = 1 ]; then
    echo "$copied would be written, $upgraded guard would be upgraded, $retained kept. Nothing was changed."
    echo "Run without --dry-run to install or upgrade."
  else
    echo "$copied would be written, $skipped already exist. Nothing was changed."
    echo "Run without --dry-run to install."
  fi
  exit 0
fi
if [ "$UPGRADE" = 1 ]; then
  echo "$copied copied, $upgraded guard upgraded, $retained kept."
else
  echo "$copied copied, $skipped skipped."
fi
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
