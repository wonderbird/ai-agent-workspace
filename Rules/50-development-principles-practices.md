# Development Principles and Practices

## Clean Code

**Avoid duplication:** You MUST avoid duplication in documentation and in implementation code so that code and documentation is easy to maintain. In tests duplication may be allowed. If in doubt, ask the user.

**Keep it simple:** You MUST keep modifications, configuration and options at the absolute minimum to achieve the current goal. You MUST focus on simplicity to achieve a high level of maintainability and robustness.

**Work diligently:** You MAY mark only those tasks completed that have been actually verified by the user. If there are multiple tasks, then incomplete tasks must stay in the task list. If the status of a task is unclear, then you MUST ask for clarification.

**Linebreak at end of file:** Whenever you change the last line of a file, you MUST ensure that the line ends with a linebreak.

## Maximum Size of Change Sets

**Small increments:** When planning tasks you MUST consider the following constraints:

- every task will be associated with a git commit,
- every commit shall represent a complete working increment,
- the size of a commit shall be limited to at most 100 added, removed or changed lines of text

After at most 2 commits, you MUST ask the user for review. Then wait for the user's answer before proceeding.

**Test and commit at milestones:** When reaching significant milestones, you SHOULD:

1. Suggest running relevant tests to verify the changes work
2. Recommend creating a git commit after successful testing
3. Only proceed to the next major task after the commit is complete

This ensures each milestone represents a verified, working state that can be safely returned to.
