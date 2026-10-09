#!/usr/bin/env bash
# Deterministically rank decisions and lessons by query tags, titles and text.
# No model, network call, index or generated state is required.
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/recall.sh [-n LIMIT|--limit LIMIT] QUERY...

Ranks Markdown files in docs/decisions/ and docs/lessons/. Higher scores mean
more matches: exact tag token (+5), title token (+3), and up to three body
occurrences (+1 each). Records without tags remain searchable.
USAGE
}

limit=5
query_parts=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -n|--limit)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      limit="$2"; shift 2 ;;
    --) shift; query_parts+=("$@"); break ;;
    -*) printf 'unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *) query_parts+=("$1"); shift ;;
  esac
done

if ! [[ "$limit" =~ ^[1-9][0-9]*$ ]]; then
  printf 'limit must be a positive integer: %s\n' "$limit" >&2
  exit 2
fi
if [ "${#query_parts[@]}" -eq 0 ]; then usage >&2; exit 2; fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 2
root=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null) || {
  printf 'recall requires a Git checkout containing %s\n' "$script_dir" >&2
  exit 2
}
docs_root=${DOCS_ROOT:-docs}
case "$docs_root" in
  /*|../*|*/../*|*/..|..) printf 'DOCS_ROOT must be a repo-relative path\n' >&2; exit 2 ;;
esac
docs_dir="$root/$docs_root"

path_has_symlink() {
  local path="$1" relative component current
  case "$path" in "$root"/*) relative=${path#"$root"/} ;; *) return 1 ;; esac
  current=$root
  while [ -n "$relative" ]; do
    component=${relative%%/*}
    if [ -n "$component" ]; then
      current="$current/$component"
      [ ! -L "$current" ] || return 0
    fi
    case "$relative" in */*) relative=${relative#*/} ;; *) relative='' ;; esac
  done
  return 1
}

if path_has_symlink "$docs_dir"; then
  printf 'DOCS_ROOT must not pass through a symlink inside the checkout\n' >&2
  exit 2
fi

# Split punctuation into separators and fold case. Keep one copy of each query
# token so repeated words cannot inflate a document's score.
terms=()
while IFS= read -r term; do
  [ -n "$term" ] || continue
  seen=0
  if [ "${#terms[@]}" -gt 0 ]; then
    for existing in "${terms[@]}"; do
      [ "$existing" = "$term" ] && seen=1 && break
    done
  fi
  [ "$seen" -eq 1 ] || terms+=("$term")
done < <(printf '%s\n' "${query_parts[*]}" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cs '[:alnum:]' '\n')

if [ "${#terms[@]}" -eq 0 ]; then
  printf 'query contains no searchable words\n' >&2
  exit 2
fi

ranked=()
for dir in "$docs_dir/decisions" "$docs_dir/lessons"; do
  [ -d "$dir" ] || continue
  while IFS= read -r -d '' file; do
    header=$(sed -n '2,/^---$/p' "$file")
    title=$(printf '%s\n' "$header" | sed -n 's/^title:[[:space:]]*//p' | head -1)
    title=${title#\"}; title=${title%\"}; title=${title#\'}; title=${title%\'}
    title=$(printf '%s' "$title" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cs '[:alnum:]' ' ')
    tags_raw=''
    in_tags=0
    while IFS= read -r header_line; do
      if [[ "$header_line" =~ ^tags:[[:space:]]*(.*)$ ]]; then
        tags_value=${BASH_REMATCH[1]}
        tags_raw+=" $tags_value"
        [ -n "$tags_value" ] && in_tags=0 || in_tags=1
      elif [ "$in_tags" -eq 1 ]; then
        if [[ "$header_line" =~ ^[[:space:]]*-[[:space:]]*(.*)$ ]]; then
          tags_raw+=" ${BASH_REMATCH[1]}"
        elif [[ "$header_line" =~ ^[[:alnum:]_-]+: ]]; then
          in_tags=0
        fi
      fi
    done <<< "$header"
    tags=$(printf '%s' "$tags_raw" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cs '[:alnum:]' ' ')
    body=$(sed '1,/^---$/d' "$file" | LC_ALL=C tr '[:upper:]' '[:lower:]')

    score=0
    for term in "${terms[@]}"; do
      case " $tags " in *" $term "*) score=$((score + 5)) ;; esac
      case " $title " in *" $term "*) score=$((score + 3)) ;; esac
      count=$(printf '%s\n' "$body" | grep -owiF -- "$term" | wc -l | tr -d '[:space:]')
      count=${count:-0}
      [ "$count" -gt 3 ] && count=3
      score=$((score + count))
    done

    if [ "$score" -gt 0 ]; then
      rel=${file#"$root"/}
      ranked+=("$score$(printf '\t')$rel")
    fi
  done < <(find "$dir" -type f -name '*.md' ! -name 'README.md' -print0 2>/dev/null)
done

if [ "${#ranked[@]}" -eq 0 ]; then
  printf 'No decisions or lessons matched.\n'
  exit 0
fi

tab=$(printf '\t')
  printf '%s\n' "${ranked[@]}" | LC_ALL=C sort -t "$tab" -k1,1nr -k2,2 | head -n "$limit" |
  while IFS="$tab" read -r score path; do
    printf '%s\t%s\n' "$score" "$path"
  done
