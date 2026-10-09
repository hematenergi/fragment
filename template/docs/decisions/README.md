---
id: decisions-index
title: Decisions — why something is the way it is
status: active
owner: unassigned
last-verified: <YYYY-MM-DD>
---

# Decisions

One file per decision already made, written so **a non-engineer can read it**. The point: anyone can find out why something is the way it is without asking the person who decided — including six months later, when that person has forgotten.

Fixed format: **Context · Decision · Why · Consequences · To change this.**

Add a short `tags: [topic, system]` list to each new decision's YAML frontmatter
so `/recall` can find it directly. Existing decisions remain searchable without
tags; do not mass-edit them just to fill this field.

Decisions are never deleted. A changed mind gets a new file with a new number, and the old one gets `status: superseded` plus a pointer. The trail of changed minds is the most useful part of the folder.

**Next number: 0001.**
