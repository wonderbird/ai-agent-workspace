# Collaboration, Principles, Practices

## Avoid Ambiguity

If my instructions are unclear, ambiguous or inconsistent, I describe this situation and ask clarifying questions before proceeding.

## Important Principles

**Avoid duplication:** I avoid duplication in documentation and in implementation code so that code and documentation is easy to maintain. In tests duplication may be allowed. If in doubt, I ask the user.

**Small increments:** When planning tasks I consider the following constraints:

- every task will be associated with a git commit,
- every commit shall represent a complete working increment,
- the size of a commit shall be limited to at most 100 added, removed or changed lines of text

After at most 2 commits, I ask the user for review. I wait for the user's answer before proceeding.

**Keep it simple:** I must keep modifications, configuration and options at the absolute minimum to achieve the current goal. I focus on simplicity to achieve a high level of maintainability and robustness.

**Work diligently:** I mark only those tasks completed that have been actually verified by the user. If there are multiple tasks, then incomplete tasks must stay in the task list. If the status of a task is unclear, then I ask for clarification.

## Git version control rules

### Git branching strategy

Before modifying any file, I ensure that I am on an appropriate branch. I ask the user if I am unsure. The user may want me to create a branch, if I am on an inappropriate branch.

Only the first commit is allowed on the `main` branch.

All commits after the first require a feature branch (`feat/feature-name`) or a bugfix branch (`fix/bug-name`). A branch name MUST NOT contain suffixes like "-docs".

Whenever I merge a feature branch into `main`, I ALWAYS use a merge commit by specifying the `--no-ff` flag. Then I create a tag for the commit. The tag name follows the pattern `v1` where `1` represents an increasing integer number starting at 1.

### One commit per task

Whenever I intend to mark a task as done, I create a git commit to document the finished work. I keep memory bank updates separate from this commit.

If files outside the memory bank were modified by the task, my immediate next actions are:

  1. update the memory bank to show the status after completing the task,
  2. amend the git commit to include the updated memory bank.

### Commit conventions

My commits must use one of the following conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`. If the correct prefix is unclear, I ask the user.

The size of my commits is such, that an experienced developer would need about 10 - 30 minutes to create a similar commit.

All my commits represent a small, coherent and working increment.

The headline of a `feat:` commit explains the new capability of the project in short. The headline of such a commit does not tell what I have done to achieve this. Example: I would write use "feat: show hello message on startup" instead of "feat: implement printing hello on startup".

The headline of a `fix:` commit describes the most important symptom of the problem in past tense. The commit message body describes the problem and its root cause. It may also contain the major steps required to fix the problem.

The brief description of a commit body shall not exceed 50 words.

### Git command line tool usage

I ALWAYS use the `--no-pager` flag as the very first option to git, when I request git history information. This avoids blocking git commands waiting for the user to terminate the pager.

## Code style

**Linebreak at end of file:** Whenever I change the last line of a file, I ensure that the line ends with a linebreak.
