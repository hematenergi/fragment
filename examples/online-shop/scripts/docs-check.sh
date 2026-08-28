#!/usr/bin/env bash
# Fragment — the document guard.
#
# Pure bash + git. No Node, no Python, no package manager. It never reads your
# source code, so it works the same in any stack.
#
#   Local:  bash scripts/docs-check.sh
#   CI:     BASE_REF=<sha> bash scripts/docs-check.sh    (adds the session-ritual check)
#
# Exit 0 = green. Exit 1 = at least one failure. Warnings never fail the build.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else
  RED=''; YEL=''; GRN=''; DIM=''; OFF=''
fi
fail=0; warn=0
err()   { printf '%s✗%s %s\n' "$RED" "$OFF" "$1"; fail=$((fail+1)); }
warnf() { printf '%s!%s %s\n' "$YEL" "$OFF" "$1"; warn=$((warn+1)); }
note()  { printf '%s·%s %s\n' "$DIM" "$OFF" "$1"; }

INDEX="docs/README.md"
[ -f "$INDEX" ] || { err "docs/README.md (the index) is missing"; exit 1; }

HAVE_GIT=0
unstamped=""
git rev-parse --verify -q HEAD >/dev/null 2>&1 && HAVE_GIT=1

# Portable "date -> epoch seconds" for YYYY-MM-DD. GNU and BSD disagree; try both.
to_epoch() {
  date -j -f '%Y-%m-%d' "$1" '+%s' 2>/dev/null || date -d "$1" '+%s' 2>/dev/null || echo ''
}
NOW=$(date '+%s')

# ---------------------------------------------------------------------------
# 1. every doc: real frontmatter, real values, known status, listed in the index
# ---------------------------------------------------------------------------
while IFS= read -r f; do
  rel="${f#./}"
  head -1 "$f" | grep -q '^---$' || { err "$rel — no frontmatter"; continue; }

  for key in id title status owner last-verified; do
    line=$(grep -m1 "^${key}:" "$f" || true)
    if [ -z "$line" ]; then
      err "$rel — frontmatter missing '${key}:'"; continue
    fi
    val=$(printf '%s' "$line" | sed "s/^${key}:[[:space:]]*//; s/[[:space:]]*$//")
    [ -n "$val" ] || err "$rel — frontmatter '${key}:' is empty"
  done

  # last-verified must be a real ISO date, not <YYYY-MM-DD> and not prose.
  lv=$(grep -m1 '^last-verified:' "$f" | sed 's/^last-verified:[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')
  if [ -n "$lv" ]; then
    case "$lv" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
      '<YYYY-MM-DD>') unstamped="$unstamped $rel" ;;
      *) err "$rel — last-verified: '$lv' is not a date (expected YYYY-MM-DD)" ;;
    esac
  fi

  st=$(grep -m1 '^status:' "$f" | sed 's/^status:[[:space:]]*//; s/[[:space:]]*$//')
  case "$st" in
    active|draft|superseded|todo|in-progress|done|parked) ;;
    *) err "$rel — unknown status: '$st'" ;;
  esac

  # Registered in the index, as an actual link. Fixed-string, so dots are dots.
  base="${rel#docs/}"
  if [ "$rel" != "$INDEX" ]; then
    grep -qF -- "]($base)" "$INDEX" \
      || err "$rel — not listed in docs/README.md (add a link: [\`$base\`]($base))"
  fi

  # last-verified vs reality: content newer than its last review.
  if [ "$HAVE_GIT" = 1 ] && [ -n "$lv" ]; then
    gd=$(git log -1 --format=%cs -- "$f" 2>/dev/null || true)
    case "$gd" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
        e_lv=$(to_epoch "$lv"); e_gd=$(to_epoch "$gd")
        if [ -n "$e_lv" ] && [ -n "$e_gd" ] && [ "$e_gd" -gt "$e_lv" ]; then
          warnf "$rel — last changed $gd but last-verified says $lv. Re-read it or bump the date"
        fi ;;
    esac
  fi
done < <(find docs -name '*.md' -not -path 'docs/_attic/*' | sort)

if [ -n "$unstamped" ]; then
  n=$(printf '%s' "$unstamped" | wc -w | tr -d ' ')
  err "$n document(s) still carry last-verified: <YYYY-MM-DD>. Stamp them with a real date:"
  printf '%s\n' "$unstamped" | tr ' ' '\n' | grep -v '^$' | head -6 | sed 's/^/    /'
  [ "$n" -gt 6 ] && printf '    ... and %s more\n' "$((n-6))"
fi

# ---------------------------------------------------------------------------
# 2. setup completeness — an unfilled install is not a finished install
# ---------------------------------------------------------------------------
for f in CLAUDE.md AGENTS.md START-HERE.md docs/AGENT-PROTOCOL.md docs/STATE.md docs/README.md; do
  [ -f "$f" ] || continue
  hits=$(awk 'NR==1&&/^---$/{fm=1;next} fm&&/^---$/{fm=0;next} !fm{print NR": "$0}' "$f" \
    | grep -E '<[A-Z][^>]*>' | head -2 || true)
  if [ -n "$hits" ]; then
    err "$f — still contains template placeholders. Fill them in:"
    printf '%s\n' "$hits" | sed 's/^/    /'
  fi
done
for f in docs/AGENT-PROTOCOL.md docs/STATE.md docs/README.md; do
  [ -f "$f" ] || continue
  grep -q '^owner:[[:space:]]*unassigned[[:space:]]*$' "$f" \
    && err "$f — owner: unassigned. A load-bearing document needs a named owner"
done

# ---------------------------------------------------------------------------
# 3. fragments
# ---------------------------------------------------------------------------
if [ -d docs/plans ]; then
  frags=$(find docs/plans -name '[0-9]*.md' -not -name '00-template.md' | sort)

  [ -z "$frags" ] && err "docs/plans/ has no fragment yet — the install is not finished (see docs/plans/README.md)"

  inprog=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    grep -q '^status:[[:space:]]*in-progress' "$f" && inprog=$((inprog+1))
  done < <(printf '%s\n' "$frags")
  [ "$inprog" -gt 1 ] && err "$inprog fragments in-progress — only one allowed (docs/plans/)"

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    b=$(basename "$f")
    st=$(grep -m1 '^status:' "$f" | sed 's/^status:[[:space:]]*//; s/[[:space:]]*$//')

    # 3a. every fragment is on the board
    rows=$(grep -F -- "$b" docs/STATE.md || true)
    if [ -z "$rows" ]; then
      err "$f — missing from the queue in docs/STATE.md"
    else
      # 3b. and the board agrees with the fragment about its status.
      #     A fragment can be named in prose too; only rows carrying a status
      #     token count as the queue row.
      statusrows=$(printf '%s\n' "$rows" | grep -E '`(todo|in-progress|done|parked)`' || true)
      if [ -z "$statusrows" ]; then
        warnf "$f — no row in docs/STATE.md carries a \`status\` token for it"
      elif ! printf '%s\n' "$statusrows" | grep -qF -- "\`$st\`"; then
        err "$f — status: $st, but its row in docs/STATE.md says otherwise. One of them is lying"
      fi
    fi

    # 3c. done means done. Deliberately language-independent: these repos are
    #     written in whatever language the team speaks, so nothing here may
    #     depend on an English heading.
    if [ "$st" = "done" ]; then
      open=$(grep -c '^[[:space:]]*- \[ \]' "$f" | tr -d ' ')
      [ "${open:-0}" -gt 0 ] && err "$f — status: done but $open checkbox(es) still unticked. Tick them, or park the fragment and say why"
      fences=$(grep -c '^```' "$f" | tr -d ' ')
      [ "${fences:-0}" -lt 2 ] && err "$f — status: done but it records no commands that were run. Paste the validation output"
    fi
  done < <(printf '%s\n' "$frags")
fi

# ---------------------------------------------------------------------------
# 4. front doors stay thin and keep pointing at the protocol
# ---------------------------------------------------------------------------
for door in CLAUDE.md AGENTS.md; do
  if [ ! -f "$door" ]; then
    err "$door is missing — that agent has no entry point into this repo"; continue
  fi
  grep -q 'AGENT-PROTOCOL.md' "$door" || err "$door — does not point at docs/AGENT-PROTOCOL.md"
  lines=$(wc -l < "$door" | tr -d ' ')
  [ "$lines" -gt 40 ] && warnf "$door — $lines lines. Front doors stay thin; rules live in AGENT-PROTOCOL.md"
done
proto=$(wc -l < docs/AGENT-PROTOCOL.md 2>/dev/null | tr -d ' ')
[ "${proto:-0}" -gt 150 ] && warnf "docs/AGENT-PROTOCOL.md — $proto lines (>150). Move content into its own document"

# ---------------------------------------------------------------------------
# 5. the board should not go stale (git commit date; file mtime is meaningless
#    in CI, where every clone is brand new)
# ---------------------------------------------------------------------------
if [ "$HAVE_GIT" = 1 ]; then
  last=$(git log -1 --format=%ct -- docs/STATE.md 2>/dev/null || true)
  if [ -n "$last" ]; then
    age=$(( (NOW - last) / 86400 ))
    [ "$age" -gt 7 ] && warnf "docs/STATE.md unchanged for $age days — does it still reflect reality?"
  fi
fi

# ---------------------------------------------------------------------------
# 6. no dangling relative links between documents (anchors included)
# ---------------------------------------------------------------------------
while IFS= read -r f; do
  d=$(dirname "$f")
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    case "$target" in
      http*|mailto:*|'#'*|'<'*) continue ;;
    esac
    path="${target%%#*}"
    [ -z "$path" ] && continue
    [ -e "$d/$path" ] || err "${f#./} → dangling link: $target"
  done < <(awk '/^[[:space:]]*```/{fence=!fence;next} !fence' "$f" \
             | grep -oE '\]\([^) ]+\)' 2>/dev/null | sed 's/^](//; s/)$//')
done < <(find docs -name '*.md' -not -path 'docs/_attic/*')

# ---------------------------------------------------------------------------
# 7. secrets. High-confidence patterns only.
#    This is a tripwire, not a scanner — gitleaks runs in CI and is the real one.
#    A private key and a hash are both 64 hex; the difference is context. Hashes
#    are always named on the same line, private keys never are.
# ---------------------------------------------------------------------------
# Scan docs/ plus any markdown at the repo root. No eval: a security check is a
# bad place to build a command out of a string.
scan() {
  grep -rnE "$1" docs 2>/dev/null
  for m in ./*.md; do
    [ -e "$m" ] || continue
    grep -nE "$1" "$m" 2>/dev/null | sed "s|^|${m#./}:|"
  done
  # Always succeed. This script runs under `pipefail`, so a scan that found
  # nothing in its last file would otherwise poison `scan ... | grep -q .`
  # for anyone writing a local rule.
  return 0
}

secret_hit() {  # $1 = regex, $2 = message
  hits=$(scan "$1" \
    | grep -v '_attic' \
    | grep -viE 'example|placeholder|dummy|xxxx|YOUR_|<[A-Za-z]' || true)
  if [ -n "$hits" ]; then
    err "$2"
    printf '%s\n' "$hits" | head -3 | cut -c1-160 | sed 's/^/    /'
  fi
}

hex64=$(scan '0x[0-9a-fA-F]{64}([^0-9a-fA-F]|$)' \
  | grep -v '_attic' \
  | grep -viE 'hash|transaction|[^a-z]tx[^a-z]|commit|digest|checksum|signature|fingerprint|example' || true)
if [ -n "$hex64" ]; then
  err "a bare 32-byte hex value with no hash/checksum context. If it is a SECRET, rotate it now:"
  printf '%s\n' "$hex64" | head -3 | cut -c1-160 | sed 's/^/    /'
fi

secret_hit 'BEGIN [A-Z ]*PRIVATE KEY'                                  'a PEM private key is sitting in a document. Rotate it now'
secret_hit '(A3T[A-Z0-9]|AKIA|ASIA|ABIA|ACCA)[A-Z0-9]{16}'             'an AWS access key id is in a document. Rotate it now'
secret_hit 'gh[pousr]_[A-Za-z0-9]{36}'                                 'a GitHub token is in a document. Rotate it now'
secret_hit 'xox[baprs]-[A-Za-z0-9-]{10,}'                              'a Slack token is in a document. Rotate it now'
secret_hit '(api[_-]?key|secret|password|passwd|token)[[:space:]]*[:=][[:space:]]*.?[A-Za-z0-9+/_-]{24,}' \
                                                                       'something shaped like a credential is in a document — check it, and rotate if real'

# ---------------------------------------------------------------------------
# 7b. Rules that are true for YOUR repo and nobody else's.
#     This guard is stack-agnostic on purpose, so anything domain-specific --
#     an identifier that is public but still identifies you, a name under NDA,
#     an internal hostname -- belongs here, not in the shared script.
#     See scripts/docs-check.local.sh.example.
#     err / warnf / note / scan are all available to it.
# ---------------------------------------------------------------------------
if [ -f scripts/docs-check.local.sh ]; then
  # shellcheck disable=SC1091
  . scripts/docs-check.local.sh
fi

# ---------------------------------------------------------------------------
# 8. session ritual -> CI only, needs a comparison commit.
#    The rule from AGENT-PROTOCOL.md: docs changed means STATE.md changed too,
#    and the change has to say something.
# ---------------------------------------------------------------------------
if [ -n "${BASE_REF:-}" ]; then
  if ! git rev-parse --verify -q "${BASE_REF}^{commit}" >/dev/null 2>&1; then
    note "session-ritual check SKIPPED — BASE_REF '${BASE_REF}' is not a commit in this repo"
  else
    changed=$(git diff --name-only "$BASE_REF" HEAD -- docs/ | grep -v '^docs/_attic/' || true)
    if [ -n "$changed" ]; then
      if ! printf '%s\n' "$changed" | grep -q '^docs/STATE.md$'; then
        err "docs/ changed but docs/STATE.md did not. The Close ritual in docs/AGENT-PROTOCOL.md was skipped."
      else
        added=$(git diff "$BASE_REF" HEAD -- docs/STATE.md | grep '^+[^+]' | grep '·' || true)
        if [ -z "$added" ]; then
          err "docs/STATE.md changed but gained no Session log line — this session left no trace."
        else
          best=0
          while IFS= read -r l; do
            [ -z "$l" ] && continue
            body=$(printf '%s' "$l" | sed 's/^+//')
            seps=$(printf '%s' "$body" | tr -cd '·' | wc -c | tr -d ' ')
            len=$(printf '%s' "$body" | tr -d '[:space:]' | wc -c | tr -d ' ')
            [ "$seps" -ge 3 ] && [ "$len" -ge 40 ] && best=1
          done < <(printf '%s\n' "$added")
          if [ "$best" -eq 0 ]; then
            err "docs/STATE.md's new Session log line is too thin to be a handoff."
            printf '    expected: %s\n' 'date · agent · fragment · what changed · what is next'
            printf '%s\n' "$added" | head -2 | cut -c1-120 | sed 's/^/    got: /'
          fi
        fi
      fi
      for f in $(printf '%s\n' "$changed" | grep '^docs/plans/.*[0-9].*\.md$' || true); do
        [ "$(basename "$f")" = "00-template.md" ] && continue
        git diff "$BASE_REF" HEAD -- "$f" | grep '^+[^+]' | grep -q '·' \
          || warnf "$f changed without a new Session log line."
      done
    fi
  fi
else
  note "session-ritual check skipped — set BASE_REF=<sha> to run it (CI does this for you)"
fi

echo
if [ "$fail" -gt 0 ]; then
  printf '%sFAILED%s — %s problem(s), %s warning(s)\n' "$RED" "$OFF" "$fail" "$warn"; exit 1
fi
printf '%sGREEN%s — documents are consistent%s\n' "$GRN" "$OFF" "$([ "$warn" -gt 0 ] && echo " ($warn warning(s))")"
printf '%sOne last thing: does docs/STATE.md reflect this session?%s\n' "$DIM" "$OFF"
