# Git version control rules

## Git is the source of version and author information

NEVER add version history related information to documents, because git is the trusted source of such information.

## Mandatory structure of a commit message

Commit messages consist of the subject line, the body and the trailers. Trailers are also known as footers.

Only the subject is mandatory. Body and trailers are optional.

Subject, body and trailers MUST be separated by an empty line.

If the commit message consists of only subject and trailers, then the trailers MUST be separated from the subject by two empty lines.

## Name the Coding Agent as Co-Author for commits

If a commit body is present, then you MUST add the following line at the end of the body:

```text
🤖 Generated with [YOUR_MODEL_NAME](URL_OF_MODEL_VENDOR)
```

If you helped creating the commit, then the Co-Authored-By trailer MUST be added to the commit message. The trailer MUST comply to the format

```text
Co-authored-by: YOUR_MODEL_NAME <YOUR_EMAIL>
```

The following valid combinations have been established for the placeholders:

| YOUR_AGENT_NAME | YOUR_VENDOR_URL | YOUR_EMAIL |
| --- | --- | --- |
| Cursor Agent (automatic mode) | https://cursor.com/home | cursoragent@cursor.com |
| Claude Code | https://claude.ai/code | noreply@anthropic.com |
| GitHub Copilot | https://github.com/copilot | 175728472+Copilot@users.noreply.github.com |

If you are not contained in the valid combinations, then you MUST suggest appropriate values for YOUR_AGENT_NAME, YOUR_VENDOR_URL and YOUR_EMAIL. Show the suggested commit message and ask whether your should proceed.

## Commit conventions

Your commits MUST use one of the following conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`. If the correct prefix is unclear, ask the user.

All your commits MUST represent a small, coherent and working increment. If these criteria are not met, ask the user how to proceed.

The headline of a `feat:` commit explains the new capability of the project in short. The headline of such a commit does not tell what you have done to achieve this. Example: You would write "feat: show hello message on startup" instead of "feat: implement printing hello on startup".

The headline of a `fix:` commit describes the most important symptom of the problem in past tense. The commit message body describes the problem and its root cause. It may also contain the major steps required to fix the problem.

A commit changing only documentation files is always a `docs:` commit, never a `refactor:` commit.

The brief description of a commit body shall not exceed 50 words.

## Memory bank updates are part of a task

Before you actually commit, you MUST update the memory bank. If that has not been done yet, ask the user whether you should update the memory bank considering the structure described in 500-cline-memory-bank.md.

You MUST commit memory bank updates together with the task. Memory bank updates are part of a task. The changes outside the memory bank determine the conventional commit prefix.

However, if a commit only contains files inside the memory bank, it uses the `docs: ` conventional commit prefix.

## Git command line tool usage

If you request git history information, you MUST ALWAYS use the `--no-pager` flag as the very first option to git. This avoids blocking git commands waiting for the user to terminate the pager.
