---
id: decision-0007
title: Restore the Fragment skills.sh skill slug
status: active
owner: hematenergi
last-verified: 2026-10-10
---

# Restore the Fragment skills.sh skill slug

## Context

Fragment renamed its agent skill from `fragment` to `adopt-fragment` to create a
distinct skills.sh detail page. The renamed detail route rendered an
application-level 404, while the owner wants Fragment's skills.sh presence and
approved restoring the original `fragment` slug, including the
`/hematenergi/fragment/fragment` route.

## Decision

Publish exactly one root skills CLI skill named `fragment` at
`skills/fragment/SKILL.md`. Link public install pages to
`https://www.skills.sh/hematenergi/fragment/fragment` and use
`npx skills add hematenergi/fragment --skill fragment`. Keep the separately
packaged native plugin identifiers such as `adopt-fragment` unchanged.

## Why

The skills CLI derives the detail route from the repository and skill names.
Restoring the existing skill slug makes the public page and the install command
refer to the same skill while retaining one canonical CLI entry.

## Consequences

The root skill source and its plugin-package copy must stay identical. After the
default branch changes, verify the live skills.sh detail page before claiming
that the platform has refreshed. Do not create synthetic installs to affect
catalog telemetry or ranking.

## To change this

The owner can choose another skills CLI slug, or skills.sh can publish a
documented rename or reindex control that makes a different slug reliable.
