# KB Extraction Prompt — Fragment Gemini R4

**Purpose:** mechanically extract a Fragment knowledge base from one pinned repository snapshot. No invention, cleanup, or editorializing.

This prompt belongs only to the separately frozen Gemini R4 Free Tier benchmark. It does not replace the frozen GPT prompt or the Gemini R1/R2/R3 extraction prompts. Commit and push this prompt before extracting Draupnir or writing its questions.

## Snapshot

- Repository: the-draupnir-project/Draupnir
- Pinned commit SHA: fill after the R4 final clone
- Extraction model/version: gemini-3.8-flash; record the successful response modelVersion
- Extraction date: fill at extraction

## Inputs

Use only the pinned SHA:

- CHANGELOG.md full history
- docs/
- Merged pull requests, titles and descriptions, plus linked issues where referenced

## Outputs

Write under kb/:

1. decisions/: one Markdown file per extracted decision, named YYYY-MM-DD-short-slug.md.
   - Frontmatter: date, source, tags, and status.
   - Status is a historical fact. Use adopted only when the source explicitly says it was adopted. Use superseded only when a source explicitly says it was reversed or replaced. Otherwise use unknown. Cite every status.
   - Body: what was decided and why, quoted briefly or closely paraphrased from the source.
2. lessons/: one file per lesson stated in sources, with the same frontmatter. Use adopted only when the source explicitly states the lesson; use superseded only with an explicit reversal/replacement; otherwise use unknown. Cite every status.
3. STATE.md: concise repository purpose, main components, build/test instructions, and open threads. Cite every bullet.

## Rules

- Cite every claim with a PR number, changelog version, or file path. Omit unsupported claims.
- Do not resolve contradictions. Keep both sides. Mark an older side superseded only with an explicit cited statement; otherwise use unknown.
- Do not invent tags. Prefer terms from the source.
- Preserve exact versions, paths, and configuration keys. Keep each output file under 40 lines.
- Preserve ambiguity. Do not guess.
- Do not write quiz questions, answer keys, rubrics, or evaluation tasks. Those are written only after the extracted KB is frozen.
- Do not execute repository code or inspect files outside the pinned snapshot.
