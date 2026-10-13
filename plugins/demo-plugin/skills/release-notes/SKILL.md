---
name: release-notes
description: Write a CHANGELOG.md entry from the git commits since the latest tag. Use when the user asks for release notes or a changelog entry.
argument-hint: [version]
disable-model-invocation: true
allowed-tools: Bash(collect-commits:*), Read, Edit, Write
---

# Release notes

Commit data, collected by a script before you saw this prompt:

!`collect-commits`

If the section above is empty or shows an error, run `collect-commits` yourself with the Bash tool.
If it says there are no commits in the range, tell the user and stop.

## Steps

1. Version: use "$ARGUMENTS" if given, otherwise `Unreleased`. Date: use TODAY from the commit data.
   Never guess the date.
2. Classify each commit:
   - `feat` → Added
   - `fix` → Fixed
   - `refactor`, `perf`, or behavior changes → Changed
   - removals and `revert` → Removed
   - `chore`, `test`, `ci`, `docs`, `style`, `build` → skip unless clearly user-facing
   - Commits without a conventional prefix: infer from the subject. If you can't tell, put them
     in a list of uncertain commits for the user instead of guessing.
3. Rewrite each entry for a reader of the changelog: what changed for them, not how it was
   implemented. One line per entry. Merge commits that describe the same change.
   Do not invent anything the commits don't say.
4. Format the entry exactly as in [template.md](template.md). Omit empty sections.
5. Insert the entry at the top of `CHANGELOG.md`, directly below the file header. If the file
   doesn't exist, create it with the header from the template.
6. Do not commit, tag or push.
7. Finish by showing the entry and listing any uncertain or skipped commits with their hashes.
