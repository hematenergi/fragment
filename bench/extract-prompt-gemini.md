# KB Extraction Prompt — Fragment Gemini Benchmark (Draupnir)

**Purpose:** mechanically extract a Fragment knowledge base from one pinned repository snapshot. No invention, cleanup, or editorializing.

This is a new prompt for the Gemini benchmark. It does not modify or replace the frozen GPT prompt at `bench/extract-prompt.md`. Commit and push this prompt before any Draupnir extraction or question writing.

## Snapshot

- Repository: `the-draupnir-project/Draupnir`
- Pinned commit SHA: `[FILL AFTER FINAL CLONE]`
- Extraction model/version: `[FILL AFTER PINNING; RECORD RESPONSE modelVersion]`
- Extraction date: `[FILL AT EXTRACTION]`

## Inputs (from the pinned SHA only)

- `CHANGELOG.md` (full history)
- `docs/`
- Merged pull requests: titles and descriptions, plus linked issues where referenced

## Outputs (under `kb/`)

1. `decisions/` — one Markdown file per extracted decision, named `YYYY-MM-DD-short-slug.md`.
   - Frontmatter: `date`, `source` (PR number, CHANGELOG version, or docs path), `tags` (3–8 source-grounded keywords), and `status` (`adopted`, `superseded`, or `unknown`).
   - `status` records a historical fact, not current validity. Every status needs a citation. Use `adopted` only when the source says the decision was adopted. Use `superseded` only when a source explicitly says it was reversed or replaced. Otherwise use `unknown`; never infer.
   - Body: what was decided and why, quoted briefly or closely paraphrased from the source.
2. `lessons/` — one file per lesson stated in the sources, with the same frontmatter. `status` is `adopted` because the source explicitly states the lesson; `date` is the source date.
3. `STATE.md` — concise current-state summary: repository purpose, main components, build/test instructions, and open threads. Every bullet cites its source.

## Rules

- Cite every claim with a PR number, CHANGELOG version, or file path. No source means omit the claim.
- Do not resolve contradictions. Keep both sides. Mark the older side `superseded` only with an explicit cited statement; otherwise `unknown`.
- Do not invent tags. Prefer words used in the source.
- Keep exact versions, file paths, and configuration keys. Each output file must be under 40 lines.
- Preserve ambiguity. Do not guess.
- Do not write quiz questions, answer keys, rubrics, or evaluation tasks. Those are written only after the extracted KB is frozen.

## Non-goals

This is not documentation improvement. Faithful extraction is more important than polish. Do not execute repository code or inspect files outside the pinned snapshot.
