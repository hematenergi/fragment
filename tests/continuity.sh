#!/usr/bin/env bash
# Sourced by run.sh: regression scenarios from the mature-adopter proposal.
# shellcheck disable=SC2154,SC2034
cfixture() { d="$TMP/continuity-$1"; cp -R "$base" "$d"; }
session() { OUT=$(cd "$d" && bash scripts/docs-check.sh "$@" 2>&1); CODE=$?; }
verdict() {
  if [ "$CODE" -eq "$1" ] && has "$3"; then ok "$2"; else bad "$2 (exit $CODE)"; dump 12; fi
}
handoff() { printf '\nHasil: pengujian checkout lulus dan keputusan sudah disimpan. Berikutnya: tinjau pembayaran.\n' >> "$d/docs/STATE.md"; }

echo; echo 'continuity without administration'
cfixture quiet
session
verdict 0 'an unchanged checkout closes quietly' 'no changes in the checked range'
has 'One last thing' && bad 'unconditional ritual question survived' || ok 'no unconditional closing question'

cfixture inventory
perl -pi -e 's/^last-verified: .*/last-verified: 2020-01-01/' "$d/docs/STATE.md"
for ((i=0; i<160; i++)); do printf '\n' >> "$d/docs/AGENT-PROTOCOL.md"; done
git -C "$d" commit -aqm 'mechanical metadata'
session --max-warnings 0
verdict 0 'historical hints do not consume the warning budget' 'no changes in the checked range'
session --inventory --max-warnings 0
verdict 0 'inventory remains available outside the budget' 'INVENTORY'
has 'last-verified says 2020-01-01' && has '>150' && ok 'inventory retains dates and size' || bad 'inventory lost historical evidence'

for kind in unstaged staged new committed; do
  cfixture "$kind"
  printf 'first\n' > "$d/app.txt"
  git -C "$d" add app.txt; git -C "$d" commit -qm initial
  start=$(git -C "$d" rev-parse HEAD)
  case "$kind" in
    new) printf 'new work\n' > "$d/new.txt" ;;
    *) printf 'second\n' >> "$d/app.txt" ;;
  esac
  [ "$kind" = staged ] && git -C "$d" add app.txt
  [ "$kind" = committed ] && git -C "$d" commit -aqm work
  if [ "$kind" = committed ]; then export BASE_REF="$start"; fi
  session
  verdict 1 "$kind code without a handoff fails" 'handoff'
  handoff
  [ "$kind" = committed ] && git -C "$d" commit -aqm handoff
  session
  verdict 0 "$kind code with Indonesian handoff body passes" 'handoff body updated'
  unset BASE_REF
done

cfixture metadata
printf 'work\n' > "$d/app.txt"
perl -pi -e 's/^last-verified: .*/last-verified: 2020-01-01/' "$d/docs/STATE.md"
session
verdict 1 'a date stamp is not a handoff' 'handoff'
printf '\n- · · · · · · · · · · · · · · · · · · · ·\n' >> "$d/docs/STATE.md"
session
verdict 1 'separators are not handoff evidence' 'handoff'

cfixture scoped
mkdir -p "$d/generated" "$d/other"
printf 'cache\n' > "$d/generated/build.txt"
printf 'other session\n' > "$d/other/work.txt"
session -- . ':!generated/**' ':!other/**'
verdict 0 'explicit exclusions remove generated and parallel work' 'no changes in the checked range'
printf 'our work\n' > "$d/app.txt"
session -- app.txt
verdict 1 'selected work still requires evidence' 'handoff'
handoff
session -- app.txt
verdict 0 'handoff destination need not be inside the selected work paths' 'handoff body updated'

cfixture destinations
printf 'work\n' > "$d/app.txt"
session --handoff notes.md --handoff task.md
verdict 1 'missing checkout handoff destinations fail' 'notes.md'
printf 'Hasil: semua pengujian checkout lulus. Berikutnya: tinjau alur pembayaran.\n' > "$d/notes.md"
session --handoff notes.md --handoff task.md
verdict 1 'partial handoff names the remaining destination' 'task.md'
cp "$d/notes.md" "$d/task.md"
session --handoff notes.md --handoff task.md
verdict 0 'multiple selected destinations work without STATE edits' 'handoff body updated'

cfixture historical
printf 'Old narrative without metadata. [missing](gone.md)\n' > "$d/docs/old.md"
git -C "$d" add docs/old.md; git -C "$d" commit -qm history
session
verdict 0 'historical documents need no mass migration' 'no changes in the checked range'
session --inventory
verdict 0 'historical structural findings are inventory, not session failures' 'docs/old.md'
session --check-doc docs/old.md
verdict 1 'a historical contract selected for current decisions is checked' 'no frontmatter'

cfixture invalid
export BASE_REF=0000000000000000000000000000000000000000
session
verdict 1 'invalid explicit comparison fails' 'BASE_REF'
unset BASE_REF

cfixture empty
# These paths exist only inside this disposable test fixture.
rm -rf "$d/.git"
rm "$d/docs/plans/01-example.md"
perl -ni -e 'print unless /01-example/' "$d/docs/STATE.md" "$d/docs/README.md"
session
verdict 0 'no git history and no work do not require a dummy fragment' 'session comparison unavailable'

cfixture modifiedguard
printf '\n# local change\n' >> "$d/scripts/docs-check.sh"
OUT=$(bash "$ROOT/install.sh" --dry-run --upgrade "$d" 2>&1); CODE=$?
verdict 0 'same version with custom bytes is reported honestly' 'customised or unknown'
has 'Nothing to upgrade' && bad 'version number falsely certified identity' || ok 'installer does not equate version with identity'

cfixture staged-reversal
printf 'initial\n' > "$d/app.txt"
git -C "$d" add app.txt; git -C "$d" commit -qm initial
printf 'staged work\n' >> "$d/app.txt"; git -C "$d" add app.txt
printf 'initial\n' > "$d/app.txt"
session
verdict 1 'staged work is detected even when the worktree reverts it' 'handoff'

cfixture ci-pending
start=$(git -C "$d" rev-parse HEAD)
printf 'work\n' > "$d/app.txt"
git -C "$d" add app.txt; git -C "$d" commit -qm work
handoff
export BASE_REF="$start"
session
verdict 1 'unstaged handoff cannot satisfy committed CI evidence' 'handoff'
session --worktree
verdict 0 'explicit worktree comparison includes the pending handoff' 'handoff body updated'
unset BASE_REF

cfixture spaced
mv "$d/docs" "$d/project docs"
git -C "$d" add -A; git -C "$d" commit -qm relocate
OUT=$(cd "$d" && DOCS_ROOT='project docs' bash scripts/docs-check.sh); CODE=$?
verdict 0 'a nonstandard docs directory may contain spaces' 'no changes in the checked range'
printf 'work\n' > "$d/app.txt"
printf 'Hasil: pengujian checkout lulus. Berikutnya: tinjau pembayaran.\n' > "$d/session notes.md"
OUT=$(cd "$d" && DOCS_ROOT='project docs' bash scripts/docs-check.sh --handoff 'session notes.md'); CODE=$?
verdict 0 'evidence destinations may contain spaces' 'handoff body updated'

cfixture conflicting-rows
printf '| 01 | [Example](plans/01-example.md) | `done` | — |\n' >> "$d/docs/STATE.md"
session
verdict 1 'a matching row cannot conceal a contradictory status row' 'says otherwise'

cfixture stale-status
perl -pi -e 's/^status: todo$/status: parked\nreason: stopped deliberately/' "$d/docs/plans/01-example.md"
git -C "$d" commit -aqm 'inconsistent close'
session
verdict 1 'an open board keeps a contradictory closed task in daily scope' 'says otherwise'

cfixture current-conflict
printf '\n[contract](missing-contract.md)\n' >> "$d/docs/plans/01-example.md"
handoff
session
verdict 1 'handoff evidence does not silence an active broken reference' 'dangling link'

cfixture clean-idle
OLD=$(date -v-40d '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -d '40 days ago' '+%Y-%m-%dT%H:%M:%S')
(cd "$d" && GIT_COMMITTER_DATE="$OLD" git commit -q --amend --no-edit)
session --max-warnings 0
verdict 0 'weeks without activity create no handoff accusation' 'no changes in the checked range'

cfixture ignored
printf 'cache/\n' > "$d/.gitignore"
git -C "$d" add .gitignore; git -C "$d" commit -qm ignore
mkdir "$d/cache"; printf 'generated\n' > "$d/cache/output"
session
verdict 0 'ignored untracked outputs create no handoff obligation' 'no changes in the checked range'

cfixture combined
mkdir "$d/knowledge"
cp "$d/docs/STATE.md" "$d/knowledge/HUB.md"
perl -ni -e 'print unless /01-example/' "$d/knowledge/HUB.md"
printf 'Read knowledge/HUB.md for the protocol and project position.\n' > "$d/AGENTS.md"
cp "$d/AGENTS.md" "$d/CLAUDE.md"
git -C "$d" add -A; git -C "$d" commit -qm 'existing combined source'
OUT=$(cd "$d" && DOCS_ROOT=knowledge STATE_FILE=knowledge/HUB.md PROTOCOL_FILE=knowledge/HUB.md INDEX_FILE=knowledge/HUB.md bash scripts/docs-check.sh); CODE=$?
verdict 0 'one existing document can hold all core roles' 'no changes in the checked range'
printf 'work\n' > "$d/app.txt"
printf '\nHasil: pengujian checkout lulus. Berikutnya: tinjau pembayaran.\n' >> "$d/knowledge/HUB.md"
OUT=$(cd "$d" && DOCS_ROOT=knowledge STATE_FILE=knowledge/HUB.md PROTOCOL_FILE=knowledge/HUB.md INDEX_FILE=knowledge/HUB.md bash scripts/docs-check.sh); CODE=$?
verdict 0 'the selected position document is the default handoff destination' 'handoff body updated'

session --handoff ../private-daily.md
verdict 2 'external evidence paths are not treated as checkout writes' 'repo-relative'

for arg in --max-warnings --handoff --check-doc; do
  session "$arg"
  verdict 2 "$arg without a value fails promptly" 'requires a value'
done
session --max-warnings 3oops
verdict 2 'mixed numeric warning budgets are rejected' 'integer'

cfixture log-date
printf 'work\n' > "$d/app.txt"
perl -pi -e 's/`[0-9]{4}-[0-9]{2}-[0-9]{2}`/`2020-01-01`/g' "$d/docs/STATE.md"
session
verdict 1 'changing only a log date does not establish a new handoff' 'handoff'

cfixture mature
for ((i=1; i<=121; i++)); do
  cat > "$d/docs/history-$i.md" <<EOF
---
id: history-$i
title: Historical note $i
status: active
owner: tester
last-verified: 2020-01-01
---
Existing context remains in its original place.
EOF
  printf '[history-%s](history-%s.md)\n' "$i" "$i" >> "$d/docs/README.md"
done
for ((i=0; i<160; i++)); do printf '\n' >> "$d/docs/AGENT-PROTOCOL.md"; done
git -C "$d" add -A; git -C "$d" commit -qm 'adopt without rewriting history'
session --max-warnings 0
verdict 0 'the mature-adopter pattern closes quietly with zero warning budget' 'no changes in the checked range'
session --inventory --max-warnings 0
verdict 0 'the 122 clues remain accessible on request' 'INVENTORY'
clues=$(printf '%s\n' "$OUT" | grep -c -E 'last-verified says 2020-01-01|>150')
[ "$clues" -eq 122 ] && ok '121 date discrepancies plus one size clue, not 122 bugs' || bad "expected 122 clues, got $clues"

cfixture upgrade-minimal
rm "$d/docs/GLOSSARY.md" "$d/START-HERE.md"
OUT=$(bash "$ROOT/install.sh" --upgrade "$d" 2>&1); CODE=$?
verdict 0 'upgrading does not install omitted optional templates' 'not added by --upgrade'
[ ! -e "$d/docs/GLOSSARY.md" ] && [ ! -e "$d/START-HERE.md" ] \
  && ok 'upgrade creates no optional documentation backlog' || bad 'upgrade reinstalled optional templates'
