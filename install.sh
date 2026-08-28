#!/usr/bin/env bash
# Fragment Architecture — installer.
# Copies the template into a repo WITHOUT overwriting anything that already exists.
#
#   bash install.sh [target-repo]     (default: current directory)
set -uo pipefail
SRC="$(cd "$(dirname "$0")/template" && pwd)"
DST="$(cd "${1:-.}" && pwd)"
[ "$SRC" = "$DST" ] && { echo "target is the template itself"; exit 1; }

echo "Fragment Architecture → $DST"
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
echo "Next:"
echo "  1. Fill the <PLACEHOLDER> fields — start with Invariants in docs/AGENT-PROTOCOL.md"
echo "  2. Seed docs/STATE.md from what is ACTUALLY happening in this repo, not the template"
echo "  3. Write your first real fragment in docs/plans/"
echo "  4. bash scripts/docs-check.sh   # fix until green"
echo
echo "Skipped files were left untouched. Merge them by hand — especially CLAUDE.md"
echo "and AGENTS.md, which must end up pointing at docs/AGENT-PROTOCOL.md."
