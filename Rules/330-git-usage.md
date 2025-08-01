# Git version control rules

## Git branching strategy

Before modifying any file, you MUST ensure that the current branch is appropriate. You MUST ask the user if you are unsure. The user may want you to create a branch, if you are on an inappropriate branch.

Only the first commit is allowed on the `main` branch.

All commits after the first require a feature branch (`feat/feature-name`) or a bugfix branch (`fix/bug-name`). A branch name MUST NOT contain suffixes like "-docs".

Whenever you merge a feature branch into `main`, you MUST ALWAYS use a merge commit by specifying the `--no-ff` flag.

## Commit conventions

Your commits MUST use one of the following conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`. If the correct prefix is unclear, ask the user.

All your commits MUST represent a small, coherent and working increment. If these criteria are not met, ask the user how to proceed.

The headline of a `feat:` commit explains the new capability of the project in short. The headline of such a commit does not tell what you have done to achieve this. Example: You would write "feat: show hello message on startup" instead of "feat: implement printing hello on startup".

The headline of a `fix:` commit describes the most important symptom of the problem in past tense. The commit message body describes the problem and its root cause. It may also contain the major steps required to fix the problem.

The brief description of a commit body shall not exceed 50 words.

## One commit per task

Whenever you intend to mark a task as done, you MUST create a git commit to document the finished work.

Whenver you have commited finished work, you MUST update your memory bank.

Whenever you have updated your memory bank, you MUST commit the updated memory bank to git using the `docs: ` conventional commit prefix.

## Git command line tool usage

If you request git history information, you MUST ALWAYS use the `--no-pager` flag as the very first option to git. This avoids blocking git commands waiting for the user to terminate the pager.
