#!/usr/bin/env bash
# Move older dated session entries out of STATE's hot tier without deleting them.
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/state-prune.sh [--keep COUNT] [--apply]

By default this previews a prune. --apply archives older dated session records
from the final level-two section of STATE_FILE, keeping the newest COUNT
(default 20). The archive defaults to docs/_attic/STATE-session-archive.md.
Set DOCS_ROOT, STATE_FILE or STATE_ARCHIVE_FILE to repo-relative alternatives
if needed.
USAGE
}

keep=20
apply=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --apply) apply=1; shift ;;
    --dry-run) apply=0; shift ;;
    -n|--keep)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      keep="$2"; shift 2 ;;
    -*) printf 'unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *) printf 'unexpected argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! [[ "$keep" =~ ^[1-9][0-9]*$ ]]; then
  printf 'keep must be a positive integer: %s\n' "$keep" >&2
  exit 2
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 2
root=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null) || {
  printf 'state pruning requires a Git checkout containing %s\n' "$script_dir" >&2
  exit 2
}
root=$(cd -P "$root" 2>/dev/null && pwd -P) || exit 2

repo_path() {
  case "$1" in
    /*)
      case "$1" in
        "$root"/*)
          relative=${1#"$root"/}
          case "$relative" in ../*|*/../*|*/..|..) return 1 ;; esac
          printf '%s\n' "$1" ;;
        *) return 1 ;;
      esac ;;
    ../*|*/../*|*/..|..) return 1 ;;
    *) printf '%s/%s\n' "$root" "$1" ;;
  esac
}

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

docs_root=${DOCS_ROOT:-docs}
case "$docs_root" in /*|../*|*/../*|*/..|..) printf 'DOCS_ROOT must be a repo-relative path\n' >&2; exit 2 ;; esac
state_rel=${STATE_FILE:-$docs_root/STATE.md}
archive_rel=${STATE_ARCHIVE_FILE:-$docs_root/_attic/STATE-session-archive.md}
state_file=$(repo_path "$state_rel") || { printf 'STATE_FILE must resolve inside the checkout\n' >&2; exit 2; }
archive_file=$(repo_path "$archive_rel") || { printf 'STATE_ARCHIVE_FILE must resolve inside the checkout\n' >&2; exit 2; }
[ -f "$state_file" ] || { printf 'STATE file not found: %s\n' "$state_rel" >&2; exit 2; }
if path_has_symlink "$state_file"; then
  printf 'refusing a STATE path that passes through a symlink: %s\n' "$state_rel" >&2
  exit 2
fi
if path_has_symlink "$archive_file"; then
  printf 'refusing an archive path that passes through a symlink: %s\n' "$archive_rel" >&2
  exit 2
fi
[ "$state_file" != "$archive_file" ] || { printf 'STATE and archive paths must differ\n' >&2; exit 2; }
state_rel=${state_file#"$root"/}
archive_rel=${archive_file#"$root"/}
case "$state_rel" in "$docs_root"/*) state_in_docs=${state_rel#"$docs_root"/} ;; *) printf 'STATE_FILE must be inside DOCS_ROOT\n' >&2; exit 2 ;; esac
case "$archive_rel" in "$docs_root"/*) archive_in_docs=${archive_rel#"$docs_root"/} ;; *) printf 'STATE_ARCHIVE_FILE must be inside DOCS_ROOT\n' >&2; exit 2 ;; esac
state_parent=$(dirname "$state_in_docs")
up=''
if [ "$state_parent" != "." ]; then
  rest=$state_parent
  while [ -n "$rest" ]; do
    up+='../'
    case "$rest" in */*) rest=${rest#*/} ;; *) rest='' ;; esac
  done
fi
archive_link=${up}${archive_in_docs}
archive_link=${archive_link// /%20}
case "$archive_link" in *%20*) archive_target="<$archive_link>" ;; *) archive_target=$archive_link ;; esac
archive_ref="Archived session history: [open archive]($archive_target)"

lines=()
while IFS= read -r line || [ -n "$line" ]; do lines+=("$line"); done < "$state_file"
last_heading=-1
for ((i=0; i<${#lines[@]}; i++)); do
  case "${lines[$i]}" in '## '*) last_heading=$i ;; esac
done
if [ "$last_heading" -lt 0 ]; then
  printf 'STATE has no level-two section to prune\n' >&2
  exit 2
fi

# A session entry is a Markdown bullet beginning with an ISO date, optionally
# wrapped in backticks. The section heading text may be localized.
date_re='^[-*][[:space:]]+(`)?[0-9]{4}-[0-9]{2}-[0-9]{2}(`)?([[:space:]]|$)'
prefix=()
records=()
record=''
found=0
for ((i=last_heading+1; i<${#lines[@]}; i++)); do
  line=${lines[$i]}
  if [[ "$line" =~ $date_re ]]; then
    if [ "$found" -eq 1 ]; then records+=("$record"); fi
    record=$line
    found=1
  elif [ "$found" -eq 1 ]; then
    # Wrapped legacy entries stay attached to their dated record. Empty lines
    # are formatting only and are dropped when the section is rewritten.
    [ -n "$line" ] && record+=$'\n'"$line"
  else
    prefix+=("$line")
  fi
done
[ "$found" -eq 0 ] || records+=("$record")

if [ "${#records[@]}" -le "$keep" ]; then
  printf 'STATE has %s dated session record(s); keep=%s, nothing to prune.\n' "${#records[@]}" "$keep"
  exit 0
fi

archive_dir=$(dirname "$archive_file")
archive_existing=0
[ -f "$archive_file" ] && archive_existing=1
already_archived=0
to_archive=0
for ((i=keep; i<${#records[@]}; i++)); do
  key=$(printf '%s\n' "${records[$i]}" | cksum)
  marker="<!-- session-record:$key -->"
  if [ "$archive_existing" -eq 1 ] && grep -Fq -- "$marker" "$archive_file"; then
    already_archived=$((already_archived + 1))
  else
    to_archive=$((to_archive + 1))
  fi
done

remove_count=$((${#records[@]} - keep))
if [ "$apply" -eq 0 ]; then
  printf 'Would move %s older session record(s) to %s and keep %s in %s; no files changed. Pass --apply to write.\n' \
    "$remove_count" "$archive_rel" "$keep" "$state_rel"
  exit 0
fi

mkdir -p "$archive_dir" || exit 2
state_dir=$(dirname "$state_file")
new_state=$(mktemp "$state_dir/.state-prune.XXXXXX") || exit 2
new_archive=$(mktemp "$archive_dir/.state-archive.XXXXXX") || { rm -f "$new_state"; exit 2; }
trap 'rm -f "$new_state" "$new_archive"' EXIT

if [ "$archive_existing" -eq 1 ]; then
  cp -p "$archive_file" "$new_archive" || exit 2
else
  printf '# Archived STATE session history\n\n' > "$new_archive" || exit 2
  chmod 644 "$new_archive" || exit 2
fi
for ((i=keep; i<${#records[@]}; i++)); do
  key=$(printf '%s\n' "${records[$i]}" | cksum)
  marker="<!-- session-record:$key -->"
  if ! grep -Fq -- "$marker" "$new_archive"; then
    printf '%s\n%s\n\n' "$marker" "${records[$i]}" >> "$new_archive" || exit 2
  fi
done

cp -p "$state_file" "$new_state" || exit 2
has_archive_ref=0
if [ "${#prefix[@]}" -gt 0 ]; then
  for line in "${prefix[@]}"; do
    case "$line" in *"$archive_link"*) has_archive_ref=1 ;; esac
  done
fi
{
  for ((i=0; i<=last_heading; i++)); do printf '%s\n' "${lines[$i]}"; done
  [ "$has_archive_ref" -eq 1 ] || printf '%s\n' "$archive_ref"
  if [ "${#prefix[@]}" -gt 0 ]; then
    for line in "${prefix[@]}"; do printf '%s\n' "$line"; done
  fi
  for ((i=0; i<keep; i++)); do printf '%s\n' "${records[$i]}"; done
} > "$new_state" || exit 2

mv "$new_archive" "$archive_file" || exit 2
mv "$new_state" "$state_file" || exit 2
printf 'Archived %s older session record(s) to %s; kept %s in %s.\n' \
  "$remove_count" "$archive_rel" "$keep" "$state_rel"
