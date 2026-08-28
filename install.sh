#!/usr/bin/env bash
# Fragment — installer.
# Copies the template into a repo WITHOUT overwriting anything that already exists.
#
#   bash install.sh [target-repo]     (default: current directory)
set -uo pipefail

SRC="$(cd "$(dirname "$0")/template" 2>/dev/null && pwd)" || true
[ -n "${SRC:-}" ] && [ -d "$SRC" ] || { echo "cannot find template/ next to install.sh"; exit 1; }

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo "target directory does not exist: $TARGET"; exit 1; }
DST="$(cd "$TARGET" && pwd)" || exit 1
[ -n "$DST" ] || { echo "cannot resolve target directory"; exit 1; }
[ "$SRC" = "$DST" ] && { echo "target is the template itself"; exit 1; }

echo "Fragment → $DST"
echo

copied=0; skipped=0
while IFS= read -r f; do
  rel="${f#"$SRC"/}"
  out="$DST/$rel"
  if [ -e "$out" ]; then
    printf '  skip    %s  (already exists — merge by hand)\n' "$rel"; skipped=$((skipped+1)); continue
  fi
  mkdir -p "$(dirname "$out")"
  cp "$f" "$out"; printf '  copied  %s\n' "$rel"; copied=$((copied+1))
done < <(find "$SRC" -type f)

chmod +x "$DST/scripts/docs-check.sh" 2>/dev/null || true

echo
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
