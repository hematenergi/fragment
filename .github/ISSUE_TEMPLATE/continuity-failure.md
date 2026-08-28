---
name: Fragment didn't prevent this
about: A session lost context, re-opened a settled decision, or started blind — with Fragment installed
labels: continuity-failure
---

<!--
The most useful report this project can get, and the one nobody thinks to send.
Bugs in the guard are easy to notice. A session that quietly started from
nothing is not — it just feels like a normal bad day.

You do not need to diagnose it. Describing what happened is the whole job.
-->

**What happened.** What did the session get wrong, forget, or ask again?

**Who was picking the work up** — you, an agent, a teammate, or a teammate's
agent? Which tool, if it was an agent?

**Was it written down anywhere?**

- [ ] It was in `STATE.md` and got missed anyway
- [ ] It was in `decisions/` or a fragment, but nothing pointed at it
- [ ] It was never written down — the ritual was skipped
- [ ] Not sure

The third answer is not a failure on your part. If the ritual is skippable in
practice, that is a finding about the guard.

**Was the guard green at the time?** A green run that sat next to a real
continuity failure is the single most valuable thing you can report — it means
something is passing that should not.

```console
$ bash scripts/docs-check.sh

```

**Has this happened more than once?** Same project, or a different one? A
pattern across unrelated repos gets treated differently from a one-off.

**What would have caught it**, if you have a view? Guesses welcome. "I don't
know" is a fine answer — that is the maintainers' job, not yours.
