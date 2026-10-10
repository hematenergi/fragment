---
id: decision-0006
title: Keep Fragment's skills.sh presence while its catalog is stale
status: active
owner: hematenergi
last-verified: 2026-10-10
---

# Keep Fragment's skills.sh presence while its catalog is stale

## Context

The `adopt-fragment` skill is available from Fragment's GitHub repository and installs with the skills CLI. Skills.sh still serves a repository listing for Fragment, but that listing shows the older `fragment` entry; the renamed detail page reports an application-level 404. The owner said removing the skills.sh link cuts Fragment off from its platform presence.

## Decision

Keep a link to `https://www.skills.sh/hematenergi/fragment` on Fragment's public install pages. Show it beside the working `adopt-fragment` install command and canonical source link, and state that the listing is stale while it shows the old entry.

## Why

This preserves Fragment's discoverability and platform association without telling visitors that the unavailable detail page works. Skills.sh says leaderboard position comes from anonymous install telemetry, so growth should come from real users choosing to install the skill.

## Consequences

The repository listing remains visible even though its contents are stale. The README and homepage must keep the current CLI install command and source link easy to find. No synthetic installs or unsupported catalog controls are used.

## To change this

Update the links and note after skills.sh's listing shows the current skill, or if the owner asks to remove the platform link.
