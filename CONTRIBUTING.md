# Contributing

## The one rule that matters

**`template/scripts/docs-check.sh` is the load-bearing file in this repo.** Nothing
in it changes without a test in `tests/run.sh`, in the same commit, that fails
before your change and passes after.

That is not ceremony. This project's entire claim is that conventions which
depend on people remembering will decay — and the guard is the only thing
standing between that claim and hypocrisy.

```bash
bash tests/run.sh
```

43 cases, no dependencies beyond `bash`, `git` and `perl`.

## Rules for the guard itself

1. **No new runtime dependencies.** `bash` + `git` + POSIX tools. Not Node, not
   Python, not `jq`. A harness you cannot run on a teammate's laptop at 1am is
   not a harness.
2. **Nothing may depend on an English heading.** The templates ship in English;
   real repos are written in whatever language the team speaks. A check that
   reads `## Validation` breaks the moment someone writes `## Validasi`. Use
   frontmatter, checkbox syntax, code fences, link syntax — structure, not prose.
   (This is not hypothetical: it is exactly how the first version of the
   `status: done` check produced a false positive on a real repo.)
3. **Failures must be actionable.** Every `err` says what to do, not just what
   is wrong. If you cannot write that sentence, it is a warning, not a failure.
4. **Warnings must be rare.** A run with six warnings trains people to ignore
   the seventh.
5. **macOS and Linux both.** `date`, `sed -i`, `grep -o` all differ. CI runs
   ubuntu, macos and Windows/Git Bash; so should your assumption.

## Changing the template documents

Any new file under `template/docs/` needs a line in `template/docs/README.md`,
or the guard will reject the very template it ships. Run the tests — they
install the template into a scratch repo and check exactly this.

## Reporting that it did not work

There are three issue templates, and the third one matters most.

**Fragment didn't prevent this** is for the case where the harness was installed,
the guard was green, and a session still started blind or re-opened something
already settled. That report is hard to write and easy to skip, because it does
not feel like a bug — it feels like an ordinary bad day. It is the only evidence
that separates a check which works from a check which merely passes.

You are not expected to diagnose it. What happened, who was picking the work up,
and whether the guard was green at the time is enough.

Anything you would rather talk through than file goes in
[Discussions](https://github.com/hematenergi/fragment/discussions).

## What this project will not accept

- A check that cannot fail. If you cannot write the test that trips it, it is
  decoration.
- Growth in `AGENT-PROTOCOL.md`. It has a 150-line cap for a reason. New rules
  come with an argument about what leaves.
- A second place where the rules live. That is the failure the whole design
  exists to prevent.
