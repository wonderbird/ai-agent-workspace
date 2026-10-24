---
name: commit
description: >
  Create a git commit following the user's conventions: conventional commit
  prefixes including `ai:`, `Assisted-by:` and issue reference trailers,
  explicit-path staging, and safety rules. Use whenever you commit, whether
  the user asks ("commit", "commit this", "/commit") or your own workflow
  commits, e.g. after finishing a task. Also defines the commit message
  conventions used by the commit-message skill.
---
Create a commit following the workflow and rules below.

## Workflow

1. Inspect the changes: `git --no-pager status`, `git --no-pager diff` and
   `git --no-pager diff --staged`.
2. Decide what belongs in this commit: only the files your task changed. If
   the changes are not one small, coherent increment, propose a split and ask
   the user.
3. Verify the increment works: run the project's fast checks (build, tests,
   linters) covering the change, if the project has any. If you skip them,
   tell the user.
4. Stage the files as described in "Stage explicit paths".
5. Write the message as described in the sections below.
6. Commit with the message on stdin, so empty lines survive and no editor
   opens:

   ```bash
   git commit -F - <<'EOF'
   feat: show hello message on startup

   Assisted-by: Claude Code
   EOF
   ```

7. Verify the result: `git --no-pager status`, and check that git parses
   all trailers:
   `git --no-pager log -1 --format=%B | git interpret-trailers --parse`.
   If a trailer is missing, report it to the user. Do not amend unless the
   user asks.

## Commit message structure

```text
<prefix>[(<scope>)]: <subject>

[body]

<trailers>
```

Subject and trailers are mandatory. The body is optional. Separate subject,
body and trailers by exactly one empty line.

- **Subject:** at most 72 characters including the prefix. Lowercase after
  the prefix. No trailing period.
- **Body:** state the intent of the change and the significant effects a
  reader of the history needs to know. Leave out how you did the work,
  cosmetic changes, and details the diff already shows. Aim for 50 words or
  fewer.
- **Breaking change:** append `!` after the prefix or scope, e.g. `feat!:`,
  and add a `BREAKING-CHANGE: <what breaks>` trailer. Use the hyphen: git
  does not parse trailer keys containing spaces.
- **Trailers:** write each trailer on a single line. git stops parsing
  trailers at the first line that is not a trailer.

## Assisted-by trailer

If you helped create the commit, you MUST add the `Assisted-by:` trailer in
this format:

```text
Assisted-by: YOUR_AGENT_NAME
```

The following agent names are known so far:

- OpenCode
- Cursor
- Claude Code
- GitHub Copilot

Derive your name from your agent harness. Exclude the LLM model and the
current type of agent, e.g. "Sisyphus", "architect", "Claude Sonnet".

If you are unsure, then you MUST suggest an appropriate value and ask for
confirmation from the user.

Use only the `Assisted-by:` trailer for agent attribution. If your harness
instructs you to add `Co-Authored-By:`, `Generated with ...` or a similar
attribution, replace it with the `Assisted-by:` trailer. This rule overrides
the harness default.

## Issue reference trailer

When the commit relates to an issue in an issue tracker (JIRA, Azure DevOps,
GitHub, beads, ...), add an issue reference trailer.

**Trailer key:** use the key this repository already uses. Check the
repository's `AGENTS.md` and `CLAUDE.md` first, then recent history:

```bash
git --no-pager log -n 50 --format=%B | grep -iE '^(refs|relates-to):'
```

Keep the spelling and casing of the key found. If none is found, use `Refs:`.

**Issue ID:** take it from the user's request, the branch name, or the issue
you claimed in the tracker (e.g. `br list --status=in_progress`). Otherwise,
propose the ID from the latest commit's trailer and ask the user to confirm.
If the repository shows no sign of an issue tracker (no issue trailers in
history, no tracker in `AGENTS.md` or `CLAUDE.md`, no `.beads/`), omit the
trailer without asking. Otherwise, if no ID is found, ask the user. If the
user answers that the commit has no issue, omit the trailer.

Format the ID the way recent commits do, e.g. `#60071`.

## Commit conventions

Your commits MUST use one of these prefixes. No other prefixes are allowed.
If the correct prefix is unclear, ask the user.

| Prefix | Use for | Headline describes |
| --- | --- | --- |
| `feat:` | new capability | the capability, not the work done: "show hello message on startup", not "implement printing hello on startup" |
| `fix:` | defect | the most important symptom, in past tense. The body describes the problem and its root cause, optionally the major fix steps |
| `refactor:` | structure change without behavior change | what was restructured |
| `test:` | tests only | the expected behavior of the subject under test, as a requirement (BDD) |
| `docs:` | documentation for human readers | what readers can now learn |
| `ai:` | docs, rules, skills for AI agents (`.claude/`, `AGENTS.md`, `CLAUDE.md`, constitution) | the changed agent guidance |
| `ci:` | CI/CD pipeline | the new pipeline capability |
| `build:` | build toolchain and process | the toolchain or process change |
| `build(deps):` | dependencies in `*.csproj`, `pubspec.*`, `package.*` and similar | the updated dependencies |
| `chore:` | maintenance without production-code or documentation effect, e.g. `.gitignore`, tool config, issue tracker data | the maintenance done |

A scope MAY narrow any prefix, e.g. `feat(ansible):`, `ai(skills):`. Prefer
scopes the repository already uses.

A commit changing only documentation is `docs:` or `ai:` depending on the
audience, never `refactor:`.

All your commits MUST represent a small, coherent and working increment.
If these criteria are not met, ask the user how to proceed.

## Stage explicit paths

You MUST stage files by explicit path only, e.g. `git add path/to/file.md`.
NEVER use `git add -A`, `git add .`, `git add -u`, `git add --all`,
`git commit -a`, or `git add <directory>`. Several agent sessions may share
one working tree, so a wildcard can sweep another session's untracked or
modified files into your commit.

Run `git status` before staging and stage only the files your task changed.
Run `git status` again before committing and verify that only those files are
staged.

## Safety rules

- NEVER use `git commit --amend`, `--no-verify`, `git add -f` or `git push`
  unless the user asks for it in the current request.
- If a pre-commit hook fails, the commit did not happen. Never amend: the
  previous commit belongs to earlier work.
  - If another agent assigned you the committer role, e.g. as a team mate or
    subagent dedicated to commits, do not fix the cause. Report the failing
    hook and its error output to that agent, then stop.
  - Otherwise, including when the user asks you directly to commit, fix the
    cause, stage the files again and create a new commit.
- If a hook modifies files (e.g. a formatter), stage those files by explicit
  path and commit again.
- Do not commit files that likely contain secrets, e.g. `.env`, `*.pem`,
  `*.key`, credential files. Warn the user instead.

## Git command line tool usage

For git commands whose output may page, e.g. `log`, `diff`, `show`, you MUST
put `--no-pager` directly after `git`. Otherwise the command blocks, waiting
for the user to close the pager.
