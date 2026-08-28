**What breaks without this?**

**If this changes `template/scripts/docs-check.sh`:**

- [ ] A case in `tests/run.sh` that fails before and passes after
- [ ] It does not depend on an English heading
- [ ] It adds no dependency beyond `bash` and `git`
- [ ] `bash tests/run.sh` is green

**If it changes the template documents:** new files under `template/docs/` are
listed in `template/docs/README.md`.
