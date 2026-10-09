#!/usr/bin/env bash
# Emit STATE plus the highest-ranked whole records that fit a hard byte bound.
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/load-context.sh --budget TOKENS QUERY... [--limit COUNT]

Always emits STATE first, then whole decisions/lessons ranked by recall.sh.
The UTF-8 byte cap is a conservative upper bound on text-token count; this
does not include the agent's system prompt or API message framing.
USAGE
}

budget=''
limit=20
query_parts=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --budget)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      budget="$2"; shift 2 ;;
    -n|--limit)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      limit="$2"; shift 2 ;;
    --) shift; query_parts+=("$@"); break ;;
    -*) printf 'unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *) query_parts+=("$1"); shift ;;
  esac
done

if ! [[ "$budget" =~ ^[1-9][0-9]*$ ]]; then
  printf 'budget must be a positive integer token limit\n' >&2
  exit 2
fi
if ! [[ "$limit" =~ ^[1-9][0-9]*$ ]]; then
  printf 'limit must be a positive integer: %s\n' "$limit" >&2
  exit 2
fi
if [ "${#query_parts[@]}" -eq 0 ]; then usage >&2; exit 2; fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 2
root=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null) || {
  printf 'context loading requires a Git checkout containing %s\n' "$script_dir" >&2
  exit 2
}
root=$(cd -P "$root" 2>/dev/null && pwd -P) || exit 2

docs_root=${DOCS_ROOT:-docs}
case "$docs_root" in /*|../*|*/../*|*/..|..) printf 'DOCS_ROOT must be a repo-relative path\n' >&2; exit 2 ;; esac
state_rel=${STATE_FILE:-$docs_root/STATE.md}
case "$state_rel" in
  /*)
    case "$state_rel" in
      "$root"/*)
        relative=${state_rel#"$root"/}
        case "$relative" in ../*|*/../*|*/..|..) printf 'STATE_FILE must stay inside the checkout\n' >&2; exit 2 ;; esac
        state_file=$state_rel ;;
      *) printf 'STATE_FILE must be inside the checkout\n' >&2; exit 2 ;;
    esac ;;
  ../*|*/../*|*/..|..) printf 'STATE_FILE must stay inside the checkout\n' >&2; exit 2 ;;
  *) state_file="$root/$state_rel" ;;
esac
[ -f "$state_file" ] || { printf 'STATE file not found: %s\n' "$state_rel" >&2; exit 2; }
state_rel=${state_file#"$root"/}

path_has_symlink() {
  local path="$1" relative component current logical physical last_dir last_rel git_prefix expected_prefix
  case "$path" in "$root"/*) relative=${path#"$root"/} ;; *) return 1 ;; esac
  current=$root
  last_dir=$root
  last_rel=''
  while [ -n "$relative" ]; do
    component=${relative%%/*}
    if [ -n "$component" ]; then
      current="$current/$component"
      [ ! -L "$current" ] || return 0
      if [ -d "$current" ]; then
        last_dir=$current
        last_rel=${current#"$root"/}
        logical=$(cd -L "$current" 2>/dev/null && pwd -L) || return 0
        physical=$(cd -P "$current" 2>/dev/null && pwd -P) || return 0
        [ "$logical" = "$physical" ] || return 0
      fi
    fi
    case "$relative" in */*) relative=${relative#*/} ;; *) relative='' ;; esac
  done
  # Git Bash can traverse a Windows directory junction without marking it -L.
  git_prefix=$(git -C "$last_dir" rev-parse --show-prefix 2>/dev/null) || return 0
  expected_prefix=''
  [ -z "$last_rel" ] || expected_prefix="${last_rel%/}/"
  [ "$git_prefix" = "$expected_prefix" ] || return 0
  return 1
}

if path_has_symlink "$state_file"; then
  printf 'STATE_FILE must not pass through a symlink inside the checkout\n' >&2
  exit 2
fi

recall_output=$(bash "$script_dir/recall.sh" --limit "$limit" "${query_parts[@]}") || exit 2
output_tmp=$(mktemp "${TMPDIR:-/tmp}/fragment-context.XXXXXX") || exit 2
chunk_tmp=$(mktemp "${TMPDIR:-/tmp}/fragment-chunk.XXXXXX") || { rm -f "$output_tmp"; exit 2; }
trap 'rm -f "$output_tmp" "$chunk_tmp"' EXIT

write_chunk() {
  printf '# Source: %s\n' "$1" > "$2" &&
    cat "$3" >> "$2" &&
    printf '\n' >> "$2"
}

write_chunk "$state_rel" "$output_tmp" "$state_file" || exit 2
used=$(wc -c < "$output_tmp" | tr -d '[:space:]')
if [ "$used" -gt "$budget" ]; then
  printf 'STATE alone needs a %s-byte upper bound; budget is %s. Nothing emitted.\n' "$used" "$budget" >&2
  exit 3
fi

selected=1
omitted=0
while IFS=$'\t' read -r _score rel; do
  [ -n "${rel:-}" ] || continue
  case "$rel" in /*|../*|*/../*|..)
    printf 'recall returned an unsafe repository path: %s\n' "$rel" >&2
    exit 2 ;;
  esac
  file="$root/$rel"
  [ -f "$file" ] || continue
  write_chunk "$rel" "$chunk_tmp" "$file" || exit 2
  chunk_bytes=$(wc -c < "$chunk_tmp" | tr -d '[:space:]')
  if [ $((used + chunk_bytes)) -le "$budget" ]; then
    cat "$chunk_tmp" >> "$output_tmp"
    used=$((used + chunk_bytes))
    selected=$((selected + 1))
  else
    omitted=$((omitted + 1))
  fi
done <<< "$recall_output"

cat "$output_tmp" || exit 2
printf 'Loaded %s source(s), %s-byte upper bound under the %s-token cap; skipped %s ranked record(s).\n' \
  "$selected" "$used" "$budget" "$omitted" >&2
