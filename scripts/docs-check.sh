#!/usr/bin/env bash
# Fragment — the document guard.
#
# Pure bash + git. No Node, no Python, no package manager. It never reads your
# source code, so it works the same in any stack.
#
#   Local:  bash scripts/docs-check.sh
#   CI:     BASE_REF=<sha> bash scripts/docs-check.sh    (committed range)
#
#   --version            print the Fragment version this copy came from
#   --max-warnings N     fail if more than N warnings survive
#   --inventory          include historical documentation clues
#   --handoff path       checkout evidence destination (repeatable; default STATE)
#   --check-doc path     contract used for this work (repeatable)
#   --worktree           include pending work when BASE_REF is supplied
#   -- pathspec...       Git scope, including exclusions for other/generated work
#   DOCS_ROOT=<dir>      documents live somewhere other than docs/
#
# Exit 0 = green. Exit 1 = at least one failure. Warnings never fail the build
# unless --max-warnings says they do.
set -uo pipefail

# Stamped so an installed copy can say where it came from. Without this a repo
# that adopted Fragment has no way to answer "which version is this?", and
# neither does anyone helping them.
FRAGMENT_VERSION="0.5.0"

for arg in "$@"; do
  case "$arg" in
    --version) printf 'fragment %s\n' "$FRAGMENT_VERSION"; exit 0 ;;
  esac
done

MAX_WARNINGS=""; INVENTORY=0; WORKTREE=0
handoffs=(); selected_docs=(); scope=()
while [ $# -gt 0 ]; do
  case "$1" in
    --max-warnings|--handoff|--check-doc)
      [ $# -ge 2 ] && [ -n "$2" ] || { printf '%s requires a value\n' "$1" >&2; exit 2; }
      case "$1" in
        --max-warnings) MAX_WARNINGS="$2" ;;
        --handoff) handoffs+=("$2") ;;
        --check-doc) selected_docs+=("$2") ;;
      esac
      shift 2 ;;
    --max-warnings=*) MAX_WARNINGS="${1#*=}"; shift ;;
    --inventory) INVENTORY=1; shift ;;
    --worktree) WORKTREE=1; shift ;;
    --version) shift ;;
    --) shift; scope=("$@"); break ;;
    *) printf 'unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done
case "$MAX_WARNINGS" in
  *[!0-9]*) printf '%s\n' '--max-warnings expects a non-negative integer' >&2; exit 2 ;;
esac

cd "$(dirname "$0")/.." || exit 1

# Where documents live. Hardcoding `docs/` kept this guard out of every repo
# that had settled on another name, and out of monorepos entirely.
DOCS="${DOCS_ROOT:-docs}"
DOCS="${DOCS%/}"

# How long a `todo` may sit before the guard asks about it.
STALE_TODO_DAYS="${STALE_TODO_DAYS:-30}"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else
  RED=''; YEL=''; GRN=''; DIM=''; OFF=''
fi
fail=0; warn=0; historical=0; inventory_count=0
inventory() {
  [ "$INVENTORY" = 1 ] || return 0
  if [ "$inventory_count" = 0 ]; then
    printf 'INVENTORY — documentation clues; not a session-readiness verdict.\n'
  fi
  printf '  %s\n' "$1"; inventory_count=$((inventory_count+1))
}
err()   {
  if [ "$historical" = 1 ]; then inventory "$1"; return; fi
  printf '%s✗%s %s\n' "$RED" "$OFF" "$1"; fail=$((fail+1))
}
warnf() {
  if [ "$historical" = 1 ]; then inventory "$1"; return; fi
  printf '%s!%s %s\n' "$YEL" "$OFF" "$1"; warn=$((warn+1))
}
note()  { printf '%s·%s %s\n' "$DIM" "$OFF" "$1"; }

STATE="${STATE_FILE:-$DOCS/STATE.md}"
PROTOCOL="${PROTOCOL_FILE:-$DOCS/AGENT-PROTOCOL.md}"
INDEX="${INDEX_FILE:-$DOCS/README.md}"
[ -f "$INDEX" ] || { err "$INDEX (the index) is missing"; exit 1; }

HAVE_GIT=0
git rev-parse --verify -q HEAD >/dev/null 2>&1 && HAVE_GIT=1
git_prefix=$(git rev-parse --show-prefix 2>/dev/null || true)

# Paths always refer to this checkout, never through symlinks to private notes.
checkout_path() {
  local part="$1"
  case "$part" in /*|..|../*|*/../*|*/..|./*|-*|'') return 1 ;; esac
  while :; do
    [ ! -L "$part" ] || return 1
    case "$part" in */*) part="${part%/*}" ;; *) break ;; esac
  done
}
for p in "$DOCS" "$STATE" "$PROTOCOL" "$INDEX" "${handoffs[@]+"${handoffs[@]}"}" "${selected_docs[@]+"${selected_docs[@]}"}"; do
  if ! checkout_path "$p"; then
    printf 'use a repo-relative checkout path without symlinks: %s\n' "$p" >&2; exit 2
  fi
done
[ "${#handoffs[@]}" -gt 0 ] || handoffs=("$STATE")
[ "${#scope[@]}" -gt 0 ] || scope=(.)
comparison=""; end=(); changed=(); working_docs=()
session_result='session comparison unavailable (no Git history)'
if [ -n "${BASE_REF:-}" ]; then
  comparison=$(git rev-parse --verify -q --end-of-options "${BASE_REF}^{commit}") \
    || { err "BASE_REF is not an available commit: $BASE_REF. Fetch the intended comparison; do not silently substitute another range."; exit 1; }
  [ "$WORKTREE" = 1 ] || end=(HEAD)
elif [ "$HAVE_GIT" = 1 ]; then
  comparison=HEAD
fi
if [ -n "$comparison" ]; then
  # Validate pathspecs and the range before reading a process substitution,
  # whose exit status bash would otherwise hide.
  git diff --relative --name-only "$comparison" "${end[@]+"${end[@]}"}" -- "${scope[@]}" >/dev/null \
    || { err 'cannot compare the selected Git range or paths'; exit 1; }
  while IFS= read -r -d '' p; do changed+=("$p"); done < <(
    git diff --relative --name-only -z "$comparison" "${end[@]+"${end[@]}"}" -- "${scope[@]}"
    if [ "${#end[@]}" = 0 ]; then
      git diff --relative --cached --name-only -z "$comparison" -- "${scope[@]}"
      git ls-files --others --exclude-standard -z -- "${scope[@]}"
    fi
  )
fi
# Structural checks inspect the available checkout. This includes dirty docs
# even when the chosen handoff comparison covers committed work only.
if [ "$HAVE_GIT" = 1 ]; then
  while IFS= read -r -d '' p; do working_docs+=("$p"); done < <(
    git diff --relative --name-only -z HEAD -- "${scope[@]}"
    git diff --relative --cached --name-only -z HEAD -- "${scope[@]}"
    git ls-files --others --exclude-standard -z -- "${scope[@]}"
  )
fi

# Portable "date -> epoch seconds" for YYYY-MM-DD. GNU and BSD disagree; try both.
to_epoch() {
  date -j -f '%Y-%m-%d' "$1" '+%s' 2>/dev/null || date -d "$1" '+%s' 2>/dev/null || echo ''
}

# One frontmatter field, unquoted. The document loop and the fragment loop both
# need `last-verified`; two copies of this expression are two chances for them
# to disagree about what the field says.
fm() {  # $1 = key, $2 = file
  grep -m1 "^$1:" "$2" 2>/dev/null \
    | sed "s/^$1:[[:space:]]*//; s/[[:space:]]*\$//; s/^[\"']//; s/[\"']\$//"
}
NOW=$(date '+%s')

# What counts as a fragment, defined once. Section 3 finds the same set with
# `find`; keeping the rule in one predicate is what stops the two from drifting
# apart — a fragment the vocabulary check treats as a document, or the reverse,
# is exactly how a file ends up impossible to satisfy.
# The two vocabularies, written once.
#
#   documents  active | draft | superseded
#   fragments  todo | in-progress | done | parked | superseded
#
# `superseded` belongs to both: a document it replaced, and a fragment the world
# overtook. Everything downstream derives from these two lists — the board check
# included — so neither can accept a value the other refuses. That divergence is
# exactly what made `active` unsatisfiable in 0.1.0, and it was invisible because
# the two lists were written out separately.
FRAGMENT_STATUSES="todo in-progress done parked superseded"
DOCUMENT_STATUSES="active draft superseded"
FRAGMENT_STATUS_RE=$(printf '%s' "$FRAGMENT_STATUSES" | tr ' ' '|')

in_list() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# Fragments may sit in subdirectories (docs/plans/epic/03-b.md), so the test is
# on the prefix and the basename, not on a single glob.
is_fragment() {
  case "$1" in
    "$DOCS"/plans/*) ;;
    *) return 1 ;;
  esac
  case "${1##*/}" in
    [0-9]*.md) return 0 ;;
    *) return 1 ;;
  esac
}

current_doc() {
  local p
  case "$1" in "$STATE"|"$INDEX"|"$PROTOCOL") return 0 ;; esac
  if is_fragment "$1" && [ "${1##*/}" != 00-template.md ]; then
    case "$(fm status "$1")" in
      done|parked|superseded)
        # A board that still claims this work is open makes a contradictory
        # closed file relevant even in an otherwise clean checkout.
        if grep -F -- "${1##*/}" "$STATE" 2>/dev/null | grep -qE '`(todo|in-progress)`'; then return 0; fi ;;
      *) return 0 ;;
    esac
  fi
  for p in "${changed[@]+"${changed[@]}"}" "${working_docs[@]+"${working_docs[@]}"}" \
    "${selected_docs[@]+"${selected_docs[@]}"}" "${handoffs[@]}"; do
    [ "$1" != "$p" ] || return 0
  done
  return 1
}
doc_paths() {
  find "$DOCS" -name '*.md' -not -path "$DOCS/_attic/*"
  printf '%s\n' "$STATE" "$PROTOCOL" "$INDEX"
  for p in "${selected_docs[@]+"${selected_docs[@]}"}"; do printf '%s\n' "$p"; done
}
index_target() {
  local parent="${INDEX%/*}" up=''
  [ "$parent" != "$INDEX" ] || parent=.
  while [ "$parent" != . ]; do
    case "$1" in "$parent"/*) printf '%s%s\n' "$up" "${1#"$parent"/}"; return ;; esac
    up="../$up"
    case "$parent" in */*) parent="${parent%/*}" ;; *) parent=. ;; esac
  done
  printf '%s%s\n' "$up" "$1"
}
for p in "$STATE" "$PROTOCOL" "${selected_docs[@]+"${selected_docs[@]}"}"; do
  [ -f "$p" ] || err "$p — required checkout document is missing"
done

# ---------------------------------------------------------------------------
# 1. every doc: real frontmatter, real values, known status, listed in the index
# ---------------------------------------------------------------------------
while IFS= read -r f; do
  rel="${f#./}"
  historical=0
  current_doc "$rel" || historical=1
  [ "$historical" = 0 ] || [ "$INVENTORY" = 1 ] || continue
  [ -f "$f" ] || continue
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
  lv=$(fm last-verified "$f")
  if [ -n "$lv" ]; then
    case "$lv" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
      '<YYYY-MM-DD>') err "$rel — last-verified is a template date; record a review when this document is used" ;;
      *) err "$rel — last-verified: '$lv' is not a date (expected YYYY-MM-DD)" ;;
    esac
  fi

  # A status is checked against the vocabulary its own kind of file uses. The
  # message names the vocabulary that was expected, so nobody is sent to the
  # board to fix something the board cannot express.
  st=$(grep -m1 '^status:' "$f" | sed 's/^status:[[:space:]]*//; s/[[:space:]]*$//')
  if is_fragment "$rel"; then
    if ! in_list "$st" "$FRAGMENT_STATUSES"; then
      if in_list "$st" "$DOCUMENT_STATUSES"; then
        err "$rel — status: $st is a document status, not a fragment one. Fragments are: $FRAGMENT_STATUSES (the one being worked on right now is 'in-progress')"
      else
        err "$rel — unknown status: '$st'"
      fi
    fi
  else
    if ! in_list "$st" "$DOCUMENT_STATUSES"; then
      if in_list "$st" "$FRAGMENT_STATUSES"; then
        err "$rel — status: $st is a fragment status, but this file is not a fragment. Documents are: $DOCUMENT_STATUSES"
      else
        err "$rel — unknown status: '$st'"
      fi
    fi
  fi

  # Closing a fragment without finishing it must still cost a sentence of truth.
  #
  # `parked` used to demand nothing at all — which made it the cheapest way for
  # anyone, agent included, to turn a red board green: park everything, explain
  # nothing. The error message even suggested it ("park the fragment and say
  # why") while never checking that a why was written.
  #
  # These are frontmatter keys rather than headings on purpose: the guard must
  # not depend on the language a team writes its documents in.
  if [ "$st" = "parked" ]; then
    r=$(grep -m1 '^reason:' "$f" | sed 's/^reason:[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')
    [ -n "$r" ] || err "$rel — status: parked needs a 'reason:' in the frontmatter. A fragment stopped without a recorded why is indistinguishable from one that was quietly abandoned"
  fi
  if [ "$st" = "superseded" ]; then
    sb=$(grep -m1 '^superseded-by:' "$f" | sed 's/^superseded-by:[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')
    [ -n "$sb" ] || err "$rel — status: superseded needs a 'superseded-by:' in the frontmatter, naming what replaced it (a fragment, a task, a commit). Superseded without a pointer is a dead end, which is the thing this repo exists to prevent"
  fi

  # Registered in the index, as an actual link. Fixed-string, so dots are dots.
  base=$(index_target "$rel")
  if [ "$rel" != "$INDEX" ] && [[ "$rel" == "$DOCS/"* ]]; then
    grep -qF -- "]($base)" "$INDEX" \
      || err "$rel — not listed in $INDEX (add a link: [\`$base\`]($base))"
  fi

  # last-verified vs reality: content newer than its last review.
  if [ "$INVENTORY" = 1 ] && [ "$HAVE_GIT" = 1 ] && [ -n "$lv" ]; then
    gd=$(git log -1 --format=%cs -- "$f" 2>/dev/null || true)
    case "$gd" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
        e_lv=$(to_epoch "$lv"); e_gd=$(to_epoch "$gd")
        if [ -n "$e_lv" ] && [ -n "$e_gd" ] && [ "$e_gd" -gt "$e_lv" ]; then
          inventory "$rel — last changed $gd but last-verified says $lv; a commit date does not establish a content change or an incorrect claim"
        fi ;;
    esac
  fi
done < <(doc_paths | sort -u)
historical=0

# ---------------------------------------------------------------------------
# 2. setup completeness — an unfilled install is not a finished install
# ---------------------------------------------------------------------------
for f in CLAUDE.md AGENTS.md "$PROTOCOL" "$STATE" "$INDEX"; do
  [ -f "$f" ] || continue
  hits=$(awk 'NR==1&&/^---$/{fm=1;next} fm&&/^---$/{fm=0;next} !fm{print NR": "$0}' "$f" \
    | grep -E '<[A-Z][^>]*>' | head -2 || true)
  if [ -n "$hits" ]; then
    err "$f — still contains template placeholders. Fill them in:"
    printf '%s\n' "$hits" | sed 's/^/    /'
  fi
done
for f in "$PROTOCOL" "$STATE" "$INDEX"; do
  [ -f "$f" ] || continue
  grep -q '^owner:[[:space:]]*unassigned[[:space:]]*$' "$f" \
    && err "$f — owner: unassigned. A load-bearing document needs a named owner"
done

# ---------------------------------------------------------------------------
# 3. fragments
# ---------------------------------------------------------------------------
if [ -d "$DOCS/plans" ]; then
  # `is_fragment` decides membership; the template is the one fragment-shaped
  # file that is not work, so it is the only exclusion.
  frags=$(find "$DOCS/plans" -name '*.md' -not -name '00-template.md' \
    | while IFS= read -r c; do is_fragment "${c#./}" && printf '%s\n' "$c"; done | sort)

  inprog=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    grep -q '^status:[[:space:]]*in-progress' "$f" && inprog=$((inprog+1))
  done < <(printf '%s\n' "$frags")
  [ "$inprog" -gt 1 ] && err "$inprog fragments in-progress — only one allowed ($DOCS/plans/)"

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    historical=0
    current_doc "$f" || historical=1
    [ "$historical" = 0 ] || [ "$INVENTORY" = 1 ] || continue
    b=$(basename "$f")
    st=$(grep -m1 '^status:' "$f" | sed 's/^status:[[:space:]]*//; s/[[:space:]]*$//')

    # 3a. every fragment is on the board
    rows=$(grep -F -- "$b" "$STATE" || true)
    if [ -z "$rows" ]; then
      err "$f — missing from the queue in $STATE"
    else
      # 3b. and the board agrees with the fragment about its status.
      #     A fragment can be named in prose too; only rows carrying a status
      #     token count as the queue row.
      statusrows=$(printf '%s\n' "$rows" | grep -E "\`($FRAGMENT_STATUS_RE)\`" || true)
      if [ -z "$statusrows" ]; then
        warnf "$f — no row in $STATE carries a \`status\` token for it"
      elif [ "$(printf '%s\n' "$statusrows" | grep -oE "\`($FRAGMENT_STATUS_RE)\`" | sort -u)" != "\`$st\`" ]; then
        err "$f — status: $st, but its row in $STATE says otherwise. One of them is lying"
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

    # 3d. a queue nobody revisits is not a queue. A `todo` left alone for a
    #     season is usually one of two things — overtaken by work that happened
    #     elsewhere, or no longer wanted — and both have somewhere to go now
    #     (`superseded`, `parked`). Warning, not error: this should prompt a
    #     decision, not block a release over a document.
    #
    #     Measured from `last-verified`, not from the file's commit date. The
    #     commit date answers "was this file touched", and a rename, a
    #     formatting pass or a frontmatter sweep answers yes for every fragment
    #     at once. That is not hypothetical: the first version of this check
    #     measured exactly that, and in the repo it was written for it never
    #     fired once — a single mechanical commit had reset the clock on
    #     fragments nobody had reconsidered in two seasons.
    #
    #     `last-verified` is the one field here that means a human confirmed
    #     this is still true. Nothing mechanical can bump it honestly, and a
    #     human bumping it is precisely the event being measured.
    if [ "$INVENTORY" = 1 ] && [ "$st" = "todo" ]; then
      flv=$(fm last-verified "$f")
      e_flv=$(to_epoch "$flv")
      if [ -n "$e_flv" ]; then
        fage=$(( (NOW - e_flv) / 86400 ))
        [ "$fage" -gt "$STALE_TODO_DAYS" ] && inventory "$f — todo, unverified for $fage days; review relevant claims when selecting this work"
      fi
    fi
  done < <(printf '%s\n' "$frags")
fi
historical=0

# ---------------------------------------------------------------------------
# 4. front doors stay thin and keep pointing at the protocol
# ---------------------------------------------------------------------------
for door in CLAUDE.md AGENTS.md; do
  if [ ! -f "$door" ]; then
    err "$door is missing — that agent has no entry point into this repo"; continue
  fi
  grep -qF -- "${PROTOCOL##*/}" "$door" || err "$door — does not point at $PROTOCOL"
  lines=$(wc -l < "$door" | tr -d ' ')
  [ "$lines" -gt 40 ] && inventory "$door — $lines lines. Front doors stay thin; rules live in $PROTOCOL"
done
proto=$(wc -l < "$PROTOCOL" 2>/dev/null | tr -d ' ')
[ "${proto:-0}" -gt 150 ] && inventory "$PROTOCOL — $proto lines (>150); size alone does not establish a continuity problem"

# ---------------------------------------------------------------------------
# 5. the board should not go stale (git commit date; file mtime is meaningless
#    in CI, where every clone is brand new)
# ---------------------------------------------------------------------------
if [ "$INVENTORY" = 1 ] && [ "$HAVE_GIT" = 1 ]; then
  last=$(git log -1 --format=%ct -- "$STATE" 2>/dev/null || true)
  if [ -n "$last" ]; then
    age=$(( (NOW - last) / 86400 ))
    [ "$age" -gt 7 ] && inventory "$STATE unchanged for $age days; elapsed time alone does not imply missing work"
  fi
fi

# ---------------------------------------------------------------------------
# 6. no dangling relative links between documents (anchors included)
# ---------------------------------------------------------------------------
while IFS= read -r f; do
  historical=0
  current_doc "$f" || historical=1
  [ "$historical" = 0 ] || [ "$INVENTORY" = 1 ] || continue
  [ -f "$f" ] || continue
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
done < <(doc_paths | sort -u)
historical=0

# ---------------------------------------------------------------------------
# 7. secrets. High-confidence patterns only.
#    This is a tripwire, not a scanner — gitleaks runs in CI and is the real one.
#    A private key and a hash are both 64 hex; the difference is context. Hashes
#    are always named on the same line, private keys never are.
# ---------------------------------------------------------------------------
# Scan $DOCS/ plus any markdown at the repo root. No eval: a security check is a
# bad place to build a command out of a string.
scan() {
  grep -rnE "$1" "$DOCS" 2>/dev/null
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
# 8. Session evidence: body additions in the selected checkout destinations.
#    This is a structural floor, not a semantic judgment of the handoff.
# ---------------------------------------------------------------------------
body_lines() {
  awk '
    NR==1 && /^---$/ {fm=1; next}
    fm && /^---$/ {fm=0; next}
    fm {next}
    /<!--/ {comment=1}
    comment {if (/-->/) comment=0; next}
    /^[[:space:]]*#/ {next}
    {
      gsub(/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/, "")
      gsub(/·|—|–/, " ")
      gsub(/[[:punct:]]/, " ")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      gsub(/[[:space:]]+/, " ")
      if (length) print
    }'
}
if [ -n "$comparison" ]; then
  session_result='no changes in the checked range'
  if [ "${#changed[@]}" -gt 0 ]; then
    session_result='handoff body updated in selected checkout destinations'
    for p in "${handoffs[@]}"; do
      before=$(git show "$comparison:$git_prefix$p" 2>/dev/null | body_lines || true)
      if [ "${#end[@]}" -gt 0 ]; then
        after=$(git show "HEAD:$git_prefix$p" 2>/dev/null | body_lines || true)
      elif [ -f "$p" ] && [ ! -L "$p" ]; then
        after=$(body_lines < "$p")
      else
        after=''
      fi
      # ponytail: new body text is a structural floor. Agents must still check
      # outcome, evidence and next step; this cannot prove prose is truthful.
      added=$(LC_ALL=C comm -13 <(printf '%s\n' "$before" | LC_ALL=C sort -u) \
                       <(printf '%s\n' "$after" | LC_ALL=C sort -u))
      if ! printf '%s\n' "$added" | awk '
        {s=$0; gsub(/·|—|–/, "", s); gsub(/[[:space:][:punct:][:digit:]]/, "", s); n+=length(s)}
        END {exit !(n>=24)}'; then
        err "$p — selected work changed but no substantive handoff body was added. Record the outcome, evidence and next step here, or select the affected checkout destination with --handoff. Metadata and separators do not establish a handoff."
      fi
    done
  fi
fi

echo
if [ "$fail" -gt 0 ]; then
  printf '%sFAILED%s — %s problem(s), %s warning(s)\n' "$RED" "$OFF" "$fail" "$warn"; exit 1
fi


# A warning nobody is required to clear stops being read. Set a budget once the
# backlog is down and the count becomes a ratchet instead of scenery.
if [ -n "$MAX_WARNINGS" ] && [ "$warn" -gt "$MAX_WARNINGS" ]; then
  printf '%sFAILED%s — %s warning(s), budget is %s\n' "$RED" "$OFF" "$warn" "$MAX_WARNINGS"
  printf '%sClear some, or raise the budget deliberately.%s\n' "$DIM" "$OFF"
  exit 1
fi

[ "$INVENTORY" != 1 ] || [ "$inventory_count" -ne 0 ] || printf 'INVENTORY — no documentation clues found.\n'
printf '%sGREEN%s — checked workflow structure; %s%s\n' "$GRN" "$OFF" "$session_result" "$([ "$warn" -gt 0 ] && echo " ($warn warning(s))")"
