---
name: commit
description: Prepares and executes a git commit
---
Create a commit following the rules below:

## Git is the source of version and author information

NEVER add version history related information to documents, because git is
the trusted source of such information.

## Mandatory structure of a commit message

Commit messages consist of the subject line, the body and the trailers.
Trailers are also known as footers.

Subject and trailers are mandatory. Body is optional.

Subject, body and trailers MUST be separated by an empty line.

If the commit message consists of only subject and trailers, then the trailers
MUST be separated from the subject by a single empty line.

## Coding agent harness as "Assisted-by:" trailer

Whenever you helped creating the commit, then the Assisted-by trailer MUST
be added to the commit message. The trailer MUST comply to the format

```text
Assisted-by: YOUR_AGENT_NAME
```

The following agent names are known so far:

- OpenCode
- Cursor
- Claude Code
- GitHub Copilot

Derive your name from your agent harness. Exclude the concrete LLM model and
the current type of agent, i.e. exclude "Sisyphus", "architect", "Claude Sonnet"
and alike.

If you are unsure, then you MUST suggest an appropriate value and ask for
confirmation from the user.

## Beads issue ID as "Refs: <issue-id>"

When committing changes associated with an issue in an issue tracker like
JIRA, Azure DevOps, beads, always Append the issue id as an "Refs: <issue-id>"
trailer to the commit message.

## Commit conventions

Your commits MUST use one of the following conventional commit prefixes:
`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `ci:`, `build(deps):`, `ai:`.
If the correct prefix is unclear, ask the user.

All your commits MUST represent a small, coherent and working increment.
If these criteria are not met, ask the user how to proceed.

The headline of a `feat:` commit explains the new capability of the project
in short. The headline of such a commit does not tell what you have done to
achieve this. Example: You would write "feat: show hello message on startup"
instead of "feat: implement printing hello on startup".

The headline of a `fix:` commit describes the most important symptom of the
problem in past tense. The commit message body describes the problem and its
root cause. It may also contain the major steps required to fix the problem.

The headline of a `test:` commit describes the capability under test in short.
Formulate the headline like a requirement using how the subject under test
should behave (as in behavior driven development).

The headline of a `ci:` commit describes the new capability of the CI/CD
pipeline in short.

The headline of a `build:` commit describes changes to the build toolchain
and process.

The headline of a `build(deps):` commit describes changes and updates to the
build related files, e.g. project dependencies in `*.csproj`, `pubspec.*`,
`package.*` and similar files.

The headline of an `ai:` commit describes changes to documentation, rules, or
skills whose audience is AI agents — for example, files under
`.claude/skills/`, `.claude/rules/`, `AGENTS.md`, `CLAUDE.md`, agent rule
files, or constitution updates that govern agent behavior. Use `ai:` instead
of `docs:` when the audience is an AI agent rather than a human reader. An
optional scope MAY be added to narrow the area, e.g. `ai(skills):`,
`ai(rules):`.

A commit changing only documentation files is always a `docs:` commit, never
a `refactor:` commit.

The brief description of a commit body shall not exceed 50 words.

## Git command line tool usage

If you request git history information, you MUST ALWAYS use the `--no-pager`
flag as the very first option to git. This avoids blocking git commands
waiting for the user to terminate the pager.
