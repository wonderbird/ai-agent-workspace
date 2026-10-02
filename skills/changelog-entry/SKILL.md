---
name: changelog-entry
description: >
  Create or update the `CHANGELOG.md` entries that describe the current pull
  request, following Keep a Changelog 2.0.0. Use when a pull request is ready
  for review, when asked to add or revise a changelog entry, or when a branch
  changes operator-visible behaviour and the changelog does not yet mention it.
argument-hint: "[pr-number]"
allowed-tools: Read Write Edit Grep Bash(rtk git *) Bash(git *) Bash(gh pr *) Bash(gh repo *)
---
# Changelog Entries From the Current Pull Request

Produce the `CHANGELOG.md` entries for the pull request under `$ARGUMENTS`, or
for the current branch when no pull request number is given.

`CHANGELOG.md` lives in the repository root. It is a durable artefact, so it
obeys the constitution: Principle X (no bare tracker ID standing in for the
substance), Principle XI (no restating what the code or the spec already
says), Principle VI (lint-clean Markdown), and the Documentation Standards
rule "Write Against Intent, Not Against Implementation Details".

For the format rules, the category decision table, and worked examples, read
[reference.md](reference.md). Read it before writing the first entry.

## Procedure

1. **Collect the change set.**

   ```bash
   rtk gh pr view <number> --json title,body,commits,files   # when a number is known
   rtk git log --oneline main..HEAD                          # otherwise
   rtk git diff --stat main...HEAD
   ```

   Read the diff of every file that the summary does not already explain. The
   commit subjects are an index into the change, not the entry text.

2. **Read the current `CHANGELOG.md`.** If the file does not exist, create it
   from the template in [reference.md](reference.md). If it exists, read the
   whole `## [Unreleased]` section, so an existing entry is revised instead of
   duplicated.

3. **Decide what is worth an entry.** One entry per user-visible or
   operator-visible outcome — not one per commit and not one per file. Skip
   changes that no reader of the changelog can observe; the reference file
   lists which kinds those are.

   When nothing in the change set is observable, add no entry. Report that
   result instead of inventing one.

4. **Assign each entry a category.** Use only `Added`, `Changed`,
   `Deprecated`, `Removed`, `Fixed`, `Security`. One change may need entries in
   two categories; a removal that replaces a feature needs both `Added` and
   `Removed`.

5. **Write each entry.** One sentence, present tense, active voice, naming the
   role, playbook, or profile the operator invokes. State the new behaviour and
   stop: no previous behaviour, no rationale, no mechanism. Add a second
   sentence only to state a migration step. Ten to fifteen words is the target,
   two wrapped lines the ceiling — [reference.md](reference.md) carries the cut
   list and a compression example.

6. **Insert the entries** into `## [Unreleased]`, under the matching category
   heading. Create a category heading only when it has an entry, and keep the
   headings in the canonical order above. Append within a category, so the
   existing order is preserved.

7. **Verify.**
   - No entry exceeds two lines, and none carries a contrast, rationale, or
     mechanism clause.
   - Every entry is traceable to a change in the diff.
   - No entry duplicates one already present in `## [Unreleased]`.
   - The result survives the Principle X strip test: delete every beads ID and
     every issue number, and each entry still states its own substance.
   - Re-running this skill on the same pull request produces no new entries.

8. **Close out.** Invoke the `review-documentation-here` skill, then the
   `format-markdown` skill, per the AGENTS.md skill index.

## Releases

The repository publishes no version tags yet, so `## [Unreleased]` is the only
section that grows. Do not invent a version number and do not move entries into
a version section. Cutting a release is a separate, human-initiated step;
[reference.md](reference.md) records how it is done when the time comes.
