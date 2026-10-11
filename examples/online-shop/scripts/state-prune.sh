#!/usr/bin/env bash
# Move older dated entries and explicitly closed plan rows out of STATE's hot tier.
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/state-prune.sh [--keep COUNT | --budget BYTES] [--apply]

By default this previews a prune. --keep archives all but the newest COUNT
(default 20) dated entries. --budget archives dated entries, then linked plan
rows confirmed as done/superseded, then parked rows, until STATE fits the
UTF-8 byte limit. --apply writes the archive. The default archive is
docs/_attic/STATE-session-archive.md.
Set DOCS_ROOT, STATE_FILE or STATE_ARCHIVE_FILE to repo-relative alternatives.
USAGE
}

keep=20
keep_set=0
budget=''
auto=0
apply=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --apply) apply=1; shift ;;
    --dry-run) apply=0; shift ;;
    -n|--keep)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      keep="$2"; keep_set=1; shift 2 ;;
    --budget)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      budget="$2"; auto=1; shift 2 ;;
    -*) printf 'unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *) printf 'unexpected argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$auto" -eq 1 ] && [ "$keep_set" -eq 1 ]; then
  printf '%s\n' '--keep and --budget cannot be combined' >&2
  exit 2
fi
if [ "$auto" -eq 0 ] && ! [[ "$keep" =~ ^[1-9][0-9]*$ ]]; then
  printf 'keep must be a positive integer: %s\n' "$keep" >&2
  exit 2
fi
if [ "$auto" -eq 1 ] && ! [[ "$budget" =~ ^[1-9][0-9]*$ ]]; then
  printf 'budget must be a positive byte limit: %s\n' "$budget" >&2
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
plan_base=''
if [ "$state_parent" != "." ]; then plan_base="$state_parent/"; fi
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
has_heading=0
for ((i=0; i<${#lines[@]}; i++)); do
  case "${lines[$i]}" in '## '*) has_heading=1 ;; esac
done
if [ "$has_heading" -eq 0 ]; then
  printf 'STATE has no level-two section to prune\n' >&2
  exit 2
fi

# Candidate records are structural, not tied to a section name or position.
# Wrapped Markdown list continuations remain attached to their dated bullet.
date_re='^[-*][[:space:]]+(`)?[0-9]{4}-[0-9]{2}-[0-9]{2}(`)?([[:space:]]|$)'
date_value_re='^[-*][[:space:]]+`?([0-9]{4}-[0-9]{2}-[0-9]{2})`?([[:space:]]|$)'
items=()
item_types=()
item_dates=()
item_starts=()
item_ends=()
session_order=()
terminal_order=()
parked_order=()
plan_status=''
plan_verified=''
trim_plan_value() {
  local value="$1"
  value=$(printf '%s\n' "$value" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  case "$value" in
    \"*\") value=${value#\"}; value=${value%\"} ;;
    \'*\') value=${value#\'}; value=${value%\'} ;;
  esac
  printf '%s' "$value"
}
normalize_repo_path() (
  local input="$1" component path=''
  local components=() parts=()
  local count=0 i
  IFS='/' read -r -a components <<< "$input"
  for component in "${components[@]+"${components[@]}"}"; do
    case "$component" in
      ''|.) ;;
      ..)
        [ "$count" -gt 0 ] || return 1
        unset 'parts[count-1]'
        count=$((count - 1)) ;;
      *) parts[count]="$component"; count=$((count + 1)) ;;
    esac
  done
  for ((i=0; i<count; i++)); do
    if [ -z "$path" ]; then path="${parts[$i]}"; else path+="/${parts[$i]}"; fi
  done
  printf '%s' "$path"
)
relative_repo_path() (
  local from="$1" to="$2" common=0 i path=''
  local from_parts=() to_parts=() relative_parts=()
  IFS='/' read -r -a from_parts <<< "$from"
  IFS='/' read -r -a to_parts <<< "$to"
  while [ "$common" -lt "${#from_parts[@]}" ] \
    && [ "$common" -lt "${#to_parts[@]}" ] \
    && [ "${from_parts[$common]}" = "${to_parts[$common]}" ]; do
    common=$((common + 1))
  done
  for ((i=common; i<${#from_parts[@]}; i++)); do relative_parts+=(..); done
  for ((i=common; i<${#to_parts[@]}; i++)); do relative_parts+=("${to_parts[$i]}"); done
  for ((i=0; i<${#relative_parts[@]}; i++)); do
    if [ -z "$path" ]; then path="${relative_parts[$i]}"; else path+="/${relative_parts[$i]}"; fi
  done
  printf '%s' "$path"
)
rebase_archive_links() {
  local remaining="$1" output='' link_re='\]\(([^)]*)\)' match before target link_path link_title link_suffix suffix path_part
  local wrapped new_target source_base archive_base normalized_target normalized_archive relative_target
  source_base=$(dirname "$state_rel")
  archive_base=$(dirname "$archive_rel")
  while [[ "$remaining" =~ $link_re ]]; do
    match=${BASH_REMATCH[0]}
    target=${BASH_REMATCH[1]}
    before=${remaining%%"$match"*}
    remaining=${remaining#*"$match"}
    link_path=$target
    link_title=''
    wrapped=0
    case "$link_path" in
      '<'*'>') wrapped=1; link_path=${link_path#<}; link_path=${link_path%>} ;;
    esac
    if [ "$wrapped" -eq 0 ] && [[ "$link_path" =~ ^([^[:space:]]+)([[:space:]].*)$ ]]; then
      link_title=${BASH_REMATCH[2]}
      link_path=${BASH_REMATCH[1]}
    fi
    link_suffix=''
    path_part=$link_path
    case "$path_part" in *'#'*) suffix=${path_part#*#}; path_part=${path_part%%#*}; link_suffix="#$suffix" ;; esac
    case "$path_part" in *'?'*) suffix=${path_part#*\?}; path_part=${path_part%%\?*}; link_suffix="?$suffix$link_suffix" ;; esac
    case "$path_part" in
      ''|\#*|/*|http:*|https:*|mailto:*|data:*|tel:*)
        output+="$before$match"
        continue ;;
    esac
    case "$path_part" in *[[:space:]]*)
      [ "$wrapped" -eq 1 ] || {
        output+="$before$match"
        continue
      } ;;
    esac
    normalized_target=$(normalize_repo_path "$source_base/$path_part") || {
      output+="$before$match"
      continue
    }
    normalized_archive=$(normalize_repo_path "$archive_base") || {
      output+="$before$match"
      continue
    }
    relative_target=$(relative_repo_path "$normalized_archive" "$normalized_target")
    [ -n "$relative_target" ] || relative_target='.'
    new_target="$relative_target$link_suffix$link_title"
    [ "$wrapped" -eq 0 ] || new_target="<$new_target>"
    output+="$before]($new_target)"
  done
  printf '%s%s' "$output" "$remaining"
}
read_plan_metadata() {
  local plan="$1" line opened=0 closed=0
  plan_status=''; plan_verified=''
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$opened" -eq 0 ]; then
      [ "$line" = '---' ] || return 1
      opened=1
      continue
    fi
    if [ "$line" = '---' ]; then closed=1; break; fi
    case "$line" in
      status:*) plan_status=$(trim_plan_value "${line#status:}") ;;
      last-verified:*) plan_verified=$(trim_plan_value "${line#last-verified:}") ;;
    esac
  done < "$plan"
  [ "$closed" -eq 1 ] && [ -n "$plan_status" ]
}

for ((i=0; i<${#lines[@]}; i++)); do
  line=${lines[$i]}
  if [[ "$line" =~ $date_re ]]; then
    first_line=$line
    [[ "$first_line" =~ $date_value_re ]] || continue
    record_date=${BASH_REMATCH[1]}
    item_text=$line
    item_end=$i
    j=$((i + 1))
    while [ "$j" -lt "${#lines[@]}" ]; do
      continuation=${lines[$j]}
      if [[ "$continuation" =~ ^[[:space:]][[:space:]]+[^[:space:]] ]]; then
        item_text+=$'\n'"$continuation"
        item_end=$j
      elif [ -z "$continuation" ] && [ "$((j + 1))" -lt "${#lines[@]}" ] \
        && [[ "${lines[$((j + 1))]}" =~ ^[[:space:]][[:space:]]+[^[:space:]] ]]; then
        item_text+=$'\n'"$continuation"
        item_end=$j
      else
        break
      fi
      j=$((j + 1))
    done
    items+=("$item_text")
    item_types+=(session-record)
    item_dates+=("$record_date")
    item_starts+=("$i")
    item_ends+=("$item_end")
    session_order+=("$((${#items[@]} - 1))")
  fi

  # Only a standalone Markdown table cell can carry the status. A linked plan
  # must confirm that same status in YAML frontmatter before its row is eligible.
  row_status=$(printf '%s\n' "$line" | tr '|' '\n' \
    | sed -nE 's/^[[:space:]]*`(done|parked|superseded)`[[:space:]]*$/\1/p' | head -1)
  [ -n "$row_status" ] || continue
  plan_rel=$(printf '%s\n' "$line" | sed -nE \
    's#.*\]\(<(plans/[^>]*\.md)>\).*#\1#p; s#.*\]\((plans/[^)]*\.md)\).*#\1#p' | head -1)
  [ -n "$plan_rel" ] || continue
  case "$plan_rel" in plans/*) ;; *) continue ;; esac
  case "$plan_rel" in *'/../'*|../*|*/..) continue ;; esac
  plan_file=$(repo_path "$docs_root/$plan_base$plan_rel") || continue
  [ -f "$plan_file" ] || continue
  path_has_symlink "$plan_file" && continue
  read_plan_metadata "$plan_file" || continue
  [ "$plan_status" = "$row_status" ] || continue
  [[ "$plan_verified" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || plan_verified='9999-99-99'
  items+=("$line")
  item_types+=(terminal-plan-row)
  item_dates+=("$plan_verified")
  item_starts+=("$i")
  item_ends+=("$i")
  if [ "$plan_status" = parked ]; then
    parked_order+=("$((${#items[@]} - 1))")
  else
    terminal_order+=("$((${#items[@]} - 1))")
  fi
done

state_size=$(wc -c < "$state_file" | tr -d '[:space:]')
if [ "$auto" -eq 1 ] && [ "$state_size" -le "$budget" ]; then
  printf 'STATE is %s/%s bytes; no pruning needed.\n' "$state_size" "$budget"
  exit 0
fi
if [ "${#items[@]}" -eq 0 ]; then
  if [ "$auto" -eq 1 ]; then
    printf 'STATE is %s bytes, over the %s-byte budget, with no eligible history to archive; no files changed.\n' "$state_size" "$budget" >&2
    exit 3
  fi
  printf 'STATE has no dated session entries; nothing to prune.\n'
  exit 0
fi

# Sort each tier by ISO date, then reverse file position for ties. Archive older
# dated entries first, preserve the newest one if possible, then prune terminal
# plan rows. The newest session is the final history fallback.
sort_candidates() {
  local tier="$1" item_index old_index inserted
  local source=() sorted=() next_order=()
  case "$tier" in
    session) source=("${session_order[@]+"${session_order[@]}"}") ;;
    terminal) source=("${terminal_order[@]+"${terminal_order[@]}"}") ;;
    parked) source=("${parked_order[@]+"${parked_order[@]}"}") ;;
  esac
  for item_index in "${source[@]+"${source[@]}"}"; do
    inserted=0
    next_order=()
    if [ "${#sorted[@]}" -gt 0 ]; then
      for old_index in "${sorted[@]+"${sorted[@]}"}"; do
        if [ "$inserted" -eq 0 ] \
          && { [[ "${item_dates[$item_index]}" < "${item_dates[$old_index]}" ]] \
            || { [ "${item_dates[$item_index]}" = "${item_dates[$old_index]}" ] && [ "$item_index" -gt "$old_index" ]; }; }; then
          next_order+=("$item_index")
          inserted=1
        fi
        next_order+=("$old_index")
      done
    fi
    [ "$inserted" -eq 1 ] || next_order+=("$item_index")
    sorted=("${next_order[@]+"${next_order[@]}"}")
  done
  case "$tier" in
    session) session_order=("${sorted[@]+"${sorted[@]}"}") ;;
    terminal) terminal_order=("${sorted[@]+"${sorted[@]}"}") ;;
    parked) parked_order=("${sorted[@]+"${sorted[@]}"}") ;;
  esac
}
sort_candidates session
sort_candidates terminal
sort_candidates parked

remove_item=()
for ((i=0; i<${#items[@]}; i++)); do remove_item+=(0); done
remove_line=()
for ((i=0; i<${#lines[@]}; i++)); do remove_line+=(0); done
remove_count=0
removed_sessions=0
removed_plans=0
mark_removed() {
  local item_index="$1" line_index
  [ "${remove_item[$item_index]}" -eq 0 ] || return 0
  remove_item[item_index]=1
  remove_count=$((remove_count + 1))
  case "${item_types[$item_index]}" in
    session-record) removed_sessions=$((removed_sessions + 1)) ;;
    terminal-plan-row) removed_plans=$((removed_plans + 1)) ;;
  esac
  for ((line_index=item_starts[item_index]; line_index<=item_ends[item_index]; line_index++)); do
    remove_line[line_index]=1
  done
}

if [ "$auto" -eq 0 ]; then
  if [ "${#session_order[@]}" -le "$keep" ]; then
    printf 'STATE has %s dated session record(s); keep=%s, nothing to prune.\n' "${#session_order[@]}" "$keep"
    exit 0
  fi
  manual_remove_count=$((${#session_order[@]} - keep))
  for ((i=0; i<manual_remove_count; i++)); do mark_removed "${session_order[$i]}"; done
fi

has_archive_ref=0
for line in "${lines[@]}"; do
  case "$line" in *"$archive_link"*) has_archive_ref=1 ;; esac
done
render_state() {
  local destination="$1" j inserted=0 opening=0
  {
    for ((j=0; j<${#lines[@]}; j++)); do
      [ "${remove_line[$j]}" -eq 1 ] || printf '%s\n' "${lines[$j]}"
      if [ "$has_archive_ref" -eq 0 ] && [ "$inserted" -eq 0 ]; then
        if [ "$opening" -eq 0 ] && [ "${lines[$j]}" = '---' ]; then
          opening=1
        elif [ "$opening" -eq 1 ] && [ "${lines[$j]}" = '---' ]; then
          printf '%s\n' "$archive_ref"
          inserted=1
        fi
      fi
    done
  } > "$destination"
}

preview_file=$(mktemp "${TMPDIR:-/tmp}/fragment-prune.XXXXXX") || exit 2
new_state=''
new_archive=''
trap 'rm -f "$preview_file" "$new_state" "$new_archive"' EXIT
if [ "$auto" -eq 1 ]; then
  fit=0
  # Keep the newest dated entry hot while older history, closed plan rows and
  # parked rows can still make the budget. The newest entry is the final fallback.
  session_count=${#session_order[@]}
  for ((i=0; i<session_count-1; i++)); do
    mark_removed "${session_order[$i]}"
    render_state "$preview_file" || exit 2
    candidate_size=$(wc -c < "$preview_file" | tr -d '[:space:]')
    if [ "$candidate_size" -le "$budget" ]; then fit=1; break; fi
  done
  if [ "$fit" -eq 0 ]; then
    for oldest_index in "${terminal_order[@]+"${terminal_order[@]}"}"; do
      mark_removed "$oldest_index"
      render_state "$preview_file" || exit 2
      candidate_size=$(wc -c < "$preview_file" | tr -d '[:space:]')
      if [ "$candidate_size" -le "$budget" ]; then fit=1; break; fi
    done
  fi
  if [ "$fit" -eq 0 ]; then
    for oldest_index in "${parked_order[@]+"${parked_order[@]}"}"; do
      mark_removed "$oldest_index"
      render_state "$preview_file" || exit 2
      candidate_size=$(wc -c < "$preview_file" | tr -d '[:space:]')
      if [ "$candidate_size" -le "$budget" ]; then fit=1; break; fi
    done
  fi
  if [ "$fit" -eq 0 ] && [ "$session_count" -gt 0 ]; then
    mark_removed "${session_order[$((session_count - 1))]}"
    render_state "$preview_file" || exit 2
    candidate_size=$(wc -c < "$preview_file" | tr -d '[:space:]')
    [ "$candidate_size" -le "$budget" ] && fit=1
  fi
  if [ "$fit" -eq 0 ]; then
    printf 'STATE fixed content still exceeds the %s-byte budget after %s dated entries, %s closed plan rows and %s parked rows are considered; no files changed.\n' "$budget" "${#session_order[@]}" "${#terminal_order[@]}" "${#parked_order[@]}" >&2
    exit 3
  fi
else
  render_state "$preview_file" || exit 2
  candidate_size=$(wc -c < "$preview_file" | tr -d '[:space:]')
fi

archive_existing=0
[ -f "$archive_file" ] && archive_existing=1
if [ "$apply" -eq 0 ]; then
  if [ "$auto" -eq 1 ]; then
    printf 'Would archive %s oldest dated session record(s) and %s plan row(s) to %s; STATE would be %s/%s bytes; no files changed. Pass --apply to write.\n' \
      "$removed_sessions" "$removed_plans" "$archive_rel" "$candidate_size" "$budget"
  else
    printf 'Would move %s older session record(s) to %s and keep %s in %s; no files changed. Pass --apply to write.\n' \
      "$remove_count" "$archive_rel" "$(( ${#session_order[@]} - remove_count ))" "$state_rel"
  fi
  exit 0
fi

archive_dir=$(dirname "$archive_file")
mkdir -p "$archive_dir" || exit 2
state_dir=$(dirname "$state_file")
new_state=$(mktemp "$state_dir/.state-prune.XXXXXX") || exit 2
new_archive=$(mktemp "$archive_dir/.state-archive.XXXXXX") || exit 2
if [ "$archive_existing" -eq 1 ]; then
  cp -p "$archive_file" "$new_archive" || exit 2
else
  printf '# Archived STATE session history\n\n' > "$new_archive" || exit 2
  chmod 644 "$new_archive" || exit 2
fi
for ((i=0; i<${#items[@]}; i++)); do
  [ "${remove_item[$i]}" -eq 1 ] || continue
  key=$(printf '%s\n' "${items[$i]}" | cksum)
  marker="<!-- ${item_types[$i]}:$key -->"
  if ! grep -Fq -- "$marker" "$new_archive"; then
    archive_item=$(rebase_archive_links "${items[$i]}")
    printf '%s\n%s\n\n' "$marker" "$archive_item" >> "$new_archive" || exit 2
  fi
done
cp -p "$state_file" "$new_state" || exit 2
render_state "$new_state" || exit 2
mv "$new_archive" "$archive_file" || exit 2
mv "$new_state" "$state_file" || exit 2
if [ "$auto" -eq 1 ]; then
  printf 'Archived %s dated session record(s) and %s plan row(s) to %s; STATE is now %s bytes within the %s-byte budget.\n' \
    "$removed_sessions" "$removed_plans" "$archive_rel" "$candidate_size" "$budget"
else
  printf 'Archived %s older session record(s) to %s; kept %s in %s.\n' \
    "$remove_count" "$archive_rel" "$(( ${#session_order[@]} - remove_count ))" "$state_rel"
fi
