#!/usr/bin/env bash
# Fragment — tests for the guard.
#
# The guard is the load-bearing part of this repo. A guard nobody has seen fail
# is not trusted, and a guard nobody re-tests will quietly stop failing.
#
#   bash tests/run.sh
#
# Every case installs a clean template into a throwaway git repo, breaks exactly
# one thing, and asserts the guard's verdict.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export NO_COLOR=1
TODAY=$(date '+%Y-%m-%d')

pass=0; failed=0
ok()   { printf '  ok    %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  FAIL  %s\n' "$1"; failed=$((failed+1)); }

# --- a repo that the guard is happy with -----------------------------------
fixture() {
  d="$TMP/$1"; rm -rf "$d"; mkdir -p "$d"
  git -C "$d" init -q .
  git -C "$d" config user.email t@t; git -C "$d" config user.name t
  bash "$ROOT/install.sh" "$d" >/dev/null 2>&1

  # fill every <PLACEHOLDER> and stamp every date
  for f in "$d"/CLAUDE.md "$d"/AGENTS.md "$d"/START-HERE.md "$d"/docs/*.md "$d"/docs/*/*.md; do
    [ -f "$f" ] || continue
    perl -pi -e 's/<YYYY-MM-DD>/'"$TODAY"'/g; s/<[A-Z][^>]*>/filled in/g;' "$f"
  done
  perl -pi -e 's/^owner: unassigned$/owner: tester/' \
    "$d"/docs/AGENT-PROTOCOL.md "$d"/docs/STATE.md "$d"/docs/README.md

  # one real fragment, on the board and in the index
  cat > "$d/docs/plans/01-example.md" <<EOF
---
id: plan-01
title: "Example fragment"
status: todo
owner: tester
last-verified: $TODAY
depends-on: []
---

# 01 — Example fragment

## Work
- [ ] do the thing

## Done when
- [ ] the thing is done

## Validation

\`\`\`bash
echo ok
\`\`\`

## Session log
- \`$TODAY\` · tester · built the example · next: nothing
EOF
  printf '| 01 | [Example](plans/01-example.md) | `todo` | — |\n' >> "$d/docs/STATE.md"
  printf '| [`plans/01-example.md`](plans/01-example.md) | Example |\n' >> "$d/docs/README.md"

  git -C "$d" add -A >/dev/null 2>&1
  git -C "$d" commit -qm "fixture" >/dev/null 2>&1
  echo "$d"
}

# NOTE: this script runs under `set -o pipefail`, and the guard exits 1 by
# design. Never pipe its output straight into grep -- the pipeline would
# inherit the guard's exit code. Capture first, then match.
OUT=''; CODE=0
capture() { OUT=$( cd "$1" && BASE_REF="${2:-}" bash scripts/docs-check.sh 2>&1 ); CODE=$?; }
has()     { printf '%s\n' "$OUT" | grep -qF -- "$1"; }
dump()    { printf '%s\n' "$OUT" | head -"${1:-6}" | sed 's/^/        /'; }

expect_fail()  { # dir, label, [substring], [base_ref]
  capture "$1" "${4:-}"
  if [ "$CODE" -ne 1 ]; then bad "$2  (expected FAILED, got exit $CODE)"; dump; return; fi
  if [ $# -lt 3 ] || has "$3"; then ok "$2"; else
    bad "$2  (failed, but not for the stated reason)"; dump; fi
}
expect_green() { # dir, label, [substring], [base_ref]
  capture "$1" "${4:-}"
  if [ "$CODE" -ne 0 ]; then bad "$2  (expected green, got exit $CODE)"; dump 8; return; fi
  if [ $# -lt 3 ] || has "$3"; then ok "$2"; else
    bad "$2  (green, but the expected line was absent)"; dump; fi
}
expect_warn() { expect_green "$1" "$2" "$3" "${4:-}"; }

echo "Fragment — guard tests"
echo

# ---------------------------------------------------------------------------
echo "adoption"
# ---------------------------------------------------------------------------
raw="$TMP/raw"; mkdir -p "$raw"; git -C "$raw" init -q .
bash "$ROOT/install.sh" "$raw" >/dev/null 2>&1
expect_fail "$raw" "an untouched install is NOT green — the guard is the to-do list" "template placeholders"
has 'no fragment yet'   && ok "  ... and it asks for a first fragment" || bad "  ... first-fragment check"
has 'owner: unassigned' && ok "  ... and for a named owner"            || bad "  ... owner check"
has 'last-verified'     && ok "  ... and for real dates"               || bad "  ... date check"

base="$(fixture base)"
expect_green "$base" "a filled-in install is green"

d="$(fixture nocolor)"; capture "$d"
printf '%s' "$OUT" | grep -q $'\033' && bad "no ANSI codes when output is not a tty" || ok "no ANSI codes when output is not a tty"

# ---------------------------------------------------------------------------
echo; echo "index and frontmatter"
# ---------------------------------------------------------------------------
d="$(fixture idx)"; printf -- '---\nid: t\ntitle: t\nstatus: active\nowner: t\nlast-verified: %s\n---\n' "$TODAY" > "$d/docs/architecture/tmp.md"
expect_fail "$d" "an unindexed document fails" "not listed in docs/README.md"

d="$(fixture idx2)"; printf -- '---\nid: t\ntitle: t\nstatus: active\nowner: t\nlast-verified: %s\n---\n' "$TODAY" > "$d/docs/architecture/aXmd.md"
printf '\n| x | architectureXaXmdXmd |\n' >> "$d/docs/README.md"
expect_fail "$d" "index matching is literal, not regex (dots are dots)" "not listed"

d="$(fixture fm1)"; perl -pi -e 's/^last-verified: .*/last-verified: banana/' "$d/docs/GLOSSARY.md"
expect_fail "$d" "a non-date last-verified fails" "is not a date"

d="$(fixture fm2)"; perl -pi -e 's/^owner: .*/owner:/' "$d/docs/GLOSSARY.md"
expect_fail "$d" "an empty frontmatter value fails" "is empty"

d="$(fixture fm3)"; perl -pi -e 's/^status: active$/status: whatever/' "$d/docs/GLOSSARY.md"
expect_fail "$d" "an unknown status fails" "unknown status"

d="$(fixture fm4)"
perl -pi -e 's/^last-verified: .*/last-verified: 2020-01-01/' "$d/docs/GLOSSARY.md"
git -C "$d" commit -aqm touch
expect_warn "$d" "content newer than last-verified warns" "last-verified says 2020-01-01"

# ---------------------------------------------------------------------------
echo; echo "links"
# ---------------------------------------------------------------------------
d="$(fixture lk1)"; printf '\n[x](./missing.md)\n' >> "$d/docs/STATE.md"
expect_fail "$d" "a dangling link fails" "dangling link"

d="$(fixture lk2)"; printf '\n[x](./missing.md#section)\n' >> "$d/docs/STATE.md"
expect_fail "$d" "a dangling link WITH an anchor also fails" "dangling link"

d="$(fixture lk3)"; printf '\n[ok](STATE.md#phase) [ext](https://example.com/a.md)\n' >> "$d/docs/README.md"
expect_green "$d" "a live anchor link and an external link are left alone"

d="$(fixture lk4)"
printf '\n```markdown\n[example](path/to/nothing.md)\n```\n' >> "$d/docs/README.md"
expect_green "$d" "a link inside a code fence is documentation, not a link"

# ---------------------------------------------------------------------------
echo; echo "front doors"
# ---------------------------------------------------------------------------
d="$(fixture fd1)"; rm "$d/CLAUDE.md"
expect_fail "$d" "a missing front door FAILS (it is not a warning)" "CLAUDE.md is missing"

d="$(fixture fd2)"; perl -pi -e 's/AGENT-PROTOCOL/SOMETHING-ELSE/g' "$d/AGENTS.md"
expect_fail "$d" "a front door that stops pointing at the protocol fails" "does not point at"

# ---------------------------------------------------------------------------
echo; echo "fragments"
# ---------------------------------------------------------------------------
d="$(fixture fr1)"
mk() { printf -- '---\nid: p%s\ntitle: p\nstatus: in-progress\nowner: t\nlast-verified: %s\n---\n# %s\n' "$1" "$TODAY" "$1" > "$2"; }
mk 02 "$d/docs/plans/02-a.md"; mkdir -p "$d/docs/plans/epic"; mk 03 "$d/docs/plans/epic/03-b.md"
printf '| 02 | [a](plans/02-a.md) | `in-progress` | — |\n| 03 | [b](plans/epic/03-b.md) | `in-progress` | — |\n' >> "$d/docs/STATE.md"
printf '| [`plans/02-a.md`](plans/02-a.md) | a |\n| [`plans/epic/03-b.md`](plans/epic/03-b.md) | b |\n' >> "$d/docs/README.md"
expect_fail "$d" "two in-progress fragments fail, even across subdirectories" "2 fragments in-progress"

d="$(fixture fr2)"; perl -pi -e 's/^status: todo$/status: done/' "$d/docs/plans/01-example.md"
expect_fail "$d" "a fragment whose status disagrees with the board fails" "says otherwise"

d="$(fixture fr3)"
perl -pi -e 's/^status: todo$/status: done/' "$d/docs/plans/01-example.md"
perl -pi -e 's/`todo`/`done`/' "$d/docs/STATE.md"
expect_fail "$d" "status: done with an unticked box fails" "checkbox(es) still unticked"

d="$(fixture fr4)"
perl -pi -e 's/^status: todo$/status: done/; s/^- \[ \]/- [x]/' "$d/docs/plans/01-example.md"
perl -pi -e 's/`todo`/`done`/' "$d/docs/STATE.md"
expect_green "$d" "status: done with every box ticked and commands recorded is green"

d="$(fixture fr5)"
perl -pi -e 's/^status: todo$/status: done/; s/^- \[ \]/- [x]/; s/^```.*$//' "$d/docs/plans/01-example.md"
perl -pi -e 's/`todo`/`done`/' "$d/docs/STATE.md"
expect_fail "$d" "status: done that records no commands fails" "records no commands"

d="$(fixture fr6)"; rm "$d/docs/plans/01-example.md"
perl -ni -e 'print unless /01-example/' "$d/docs/README.md"
expect_fail "$d" "a fragment on the board but missing from disk is caught" "dangling link"

# ---------------------------------------------------------------------------
echo; echo "secrets"
# ---------------------------------------------------------------------------
sec() { d="$(fixture "sec$1")"; printf '\n%s\n' "$2" >> "$d/docs/STATE.md"; expect_fail "$d" "$3" "$4"; }
sec 3 '- k AKIAIOSFODNN7EXAMPLQ' "an AWS access key id is caught" "AWS access key"
sec 4 '- k ghp_16C7e42F292c6912E7710c838347Ae178B4a' "a GitHub token is caught" "GitHub token"
sec 5 '- k 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80' \
      "a bare 32-byte hex secret is caught" "If it is a SECRET"
sec 6 '- api_key = sk-abcdefghijklmnopqrstuvwxyz012345' "an api_key assignment is caught" "credential"

d="$(fixture sec7)"
printf '\n- commit hash 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80\n' >> "$d/docs/STATE.md"
expect_green "$d" "the same hex, named as a hash, is left alone"

# ---------------------------------------------------------------------------
echo; echo "local rules (the domain-specific extension point)"
# ---------------------------------------------------------------------------
d="$(fixture loc1)"
cat > "$d/scripts/docs-check.local.sh" <<'LOCAL'
scan 'northwind' | grep -q . && err "client name in a document"
LOCAL
printf '\n- the northwind migration\n' >> "$d/docs/STATE.md"
expect_fail "$d" "a local rules file is sourced and can fail the run" "client name in a document"

d="$(fixture loc2)"
cat > "$d/scripts/docs-check.local.sh" <<'LOCAL'
scan 'northwind' | grep -q . && warnf "client name in a document"
LOCAL
printf '\n- the northwind migration\n' >> "$d/docs/STATE.md"
expect_warn "$d" "  ... and can warn instead of failing" "client name in a document"

d="$(fixture loc3)"
expect_green "$d" "  ... and its absence changes nothing"

d="$(fixture loc4)"
printf '\n- contract 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984 and host db01.internal\n' >> "$d/docs/STATE.md"
expect_green "$d" "the shipped guard has no opinion about any particular domain"

# ---------------------------------------------------------------------------
echo; echo "session ritual (CI)"
# ---------------------------------------------------------------------------
d="$(fixture ci1)"; b=$(git -C "$d" rev-parse HEAD)
printf '\n## note\n' >> "$d/docs/GLOSSARY.md"; git -C "$d" commit -aqm edit
expect_fail "$d" "docs changed without STATE.md fails" "STATE.md did not" "$b"
has 'gained no Session log' && bad "  ... and says only that (no contradictory second line)" \
                            || ok "  ... and says only that (no contradictory second line)"

d="$(fixture ci2)"; b=$(git -C "$d" rev-parse HEAD)
printf '\n## note\n' >> "$d/docs/GLOSSARY.md"; printf '\n- x · x\n' >> "$d/docs/STATE.md"
git -C "$d" commit -aqm cheat
expect_fail "$d" "a two-character session line is rejected as too thin" "too thin to be a handoff" "$b"

d="$(fixture ci3)"; b=$(git -C "$d" rev-parse HEAD)
printf '\n## note\n' >> "$d/docs/GLOSSARY.md"
printf '\n- `%s` · claude · 01 · glossary gained a term for the fill model · next: nothing\n' "$TODAY" >> "$d/docs/STATE.md"
git -C "$d" commit -aqm ritual
expect_green "$d" "a real session line passes" "" "$b"

d="$(fixture ci4)"
expect_green "$d" "an unusable BASE_REF says so out loud instead of passing silently" \
  "SKIPPED" "0000000000000000000000000000000000000000"

# stale board: rewrite the fixture commit with an old COMMITTER date (%ct is
# what the guard reads; --date only moves the author date).
d="$(fixture ci5)"
OLD=$(date -v-40d '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -d '40 days ago' '+%Y-%m-%dT%H:%M:%S')
( cd "$d" && GIT_COMMITTER_DATE="$OLD" GIT_AUTHOR_DATE="$OLD" git commit -q --amend --no-edit --allow-empty )
expect_green "$d" "a stale board warns, using git dates not file mtime" "unchanged for"
c="$TMP/clone"; rm -rf "$c"; git clone -q "$d" "$c" 2>/dev/null
expect_green "$c" "  ... and survives a fresh clone (i.e. it works in CI)" "unchanged for"

# ---------------------------------------------------------------------------
echo; echo "published example"
# ---------------------------------------------------------------------------
expect_green "$ROOT/examples/online-shop" "the filled-in example is green"

# The example vendors the guard rather than forking it. That is the rule this
# project preaches, and it broke here once already during extraction.
if cmp -s "$ROOT/examples/online-shop/scripts/docs-check.sh" "$ROOT/template/scripts/docs-check.sh"; then
  ok "  ... and its guard is a verbatim copy of the canonical one"
else
  bad "  ... example guard has drifted from template/scripts/docs-check.sh"
fi

d="$TMP/exlocal"; rm -rf "$d"; cp -R "$ROOT/examples/online-shop" "$d"
perl -pi -e "s/^Tested by:.*\$/(removed)/" "$d/docs/runbooks/take-the-shop-offline.md"
expect_fail "$d" "  ... and its local rules actually bite" "no 'Tested by:' line"

d="$TMP/exphone"; rm -rf "$d"; cp -R "$ROOT/examples/online-shop" "$d"
printf '\n- she called from +6281234567890\n' >> "$d/docs/STATE.md"
expect_fail "$d" "  ... including the one that keeps customer details out" "shaped like a phone number"

d="$TMP/exdate"; rm -rf "$d"; cp -R "$ROOT/examples/online-shop" "$d"
printf '\n- settled on 2026-08-24, revisited 2026-08-26\n' >> "$d/docs/STATE.md"
expect_green "$d" "  ... and a date is not mistaken for one"

echo
if [ "$failed" -gt 0 ]; then printf 'FAILED — %s passed, %s failed\n' "$pass" "$failed"; exit 1; fi
printf 'GREEN — %s tests passed\n' "$pass"
