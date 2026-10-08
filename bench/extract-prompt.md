# KB Extraction Prompt — Fragment Benchmark (Draupnir)

**Purpose:** mechanically extract a Fragment knowledge base from a repo snapshot.
No invention. No cleanup. No editorializing.

**Committed before any benchmark question is written** (see `FragmentBenchmarkSpec.md` §4,
§7). This file's commit timestamp is the proof of ordering.

---

## Snapshot

- Repo: `the-draupnir-project/Draupnir`
- Pinned commit SHA: `[FILL AT CLONE — §7 step 5]`
- Extraction model + version: `[FILL AT RUN]`
- Extraction date: `[FILL AT RUN]`

## Inputs (all from the pinned SHA)

- `CHANGELOG.md` (full history)
- `docs/` directory
- Merged PRs: titles + descriptions (+ linked issues where referenced)

## Outputs (write under `kb/`)

1. `decisions/` — one Markdown file per extracted decision: `YYYY-MM-DD-short-slug.md`
   - Frontmatter: `date`, `source` (PR number / CHANGELOG version / docs path),
     `tags` (3–8 keywords), `status` (`adopted` | `superseded` | `unknown`)
   - `status` states a historical fact, not present validity — every value
     needs a citation:
     - `adopted`: the source states this decision was adopted (cite it;
       `date` is the adoption date).
     - `superseded`: the source explicitly states it was reversed or replaced
       (e.g. a PR writing "reverts #123", a CHANGELOG entry saying
       "replaces X") — cite that statement.
     - `unknown`: anything else. Never infer.
   - Body: what was decided + why (quote or close paraphrase of the source).
2. `lessons/` — one file per lesson stated in the sources (postmortems,
   "learned", "note that", retrospective PR descriptions). Same frontmatter;
   `status` always `adopted` (the source states the lesson; `date` = source date).
3. `STATE.md` — current-state summary: what the repo is, main components,
   how to build/test, open threads. Facts only; every bullet cites its source.

## Rules

- Every claim cites its source (PR number, CHANGELOG version, file path).
  No source → don't write it.
- **Do NOT resolve contradictions.** If decision X was later reversed by PR #N,
  record BOTH. The older one gets `status: superseded` only with an explicit,
  cited source statement; otherwise `status: unknown`. This is intentional —
  trap questions depend on agents doing the reasoning themselves, not reading
  a pre-computed status field. (If the extractor inferred statuses, trap
  questions would be trivial in every condition and the measured delta
  would vanish.) Present validity is not the extractor's job — that's
  hash-pinned staleness (v0.7).
- Do NOT invent tags beyond what's evident in the sources; prefer terms the
  sources themselves use.
- Do NOT summarize away specifics. Version numbers, file paths, config keys stay.
- Keep each file short (under 40 lines). Quantity over prose.
- If a source is ambiguous, record it as ambiguous. Don't guess.
- Frontmatter is required on every file — it feeds `/recall` (v0.6 item 1).

## Non-goals

- This is not documentation improvement. Ugly but faithful beats clean but lossy.
- Do not write questions, quizzes, or evaluations. Those come later, from the
  repo's own history, after this extraction is frozen.
