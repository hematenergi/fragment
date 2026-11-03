---
id: lesson-git-location-environment
title: Git environment overrides can redirect a nested repository's index
status: active
owner: hematenergi
last-verified: 2026-11-03
tags: [git, local, isolation, environment]
---

# Git environment overrides can redirect a nested repository's index

## Symptom

A local-mode regression passed the host repository's index through
GIT_INDEX_FILE. Commands run with git -C .fragment still inspected that index,
so the context guard saw unrelated host paths. A later successful add could
write context paths into the host index instead of the private one.

## Root cause

Changing Git's working directory does not clear explicit Git location, index
or object-directory overrides inherited from the calling environment.

## Rule

Before installing or closing an independent local context, reject inherited Git
location/index/object-directory overrides. Do not rely on -C for isolation.
The regression in tests/local-mode.sh supplies a host index and checks both
the actionable rejection and byte-for-byte preservation of that index.
