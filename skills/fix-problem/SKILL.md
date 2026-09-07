---
name: fix-problem
description: >
    Remediation protocol for resolving obstacles one at a time via hypothesize,
    test, fix, and document. Use when an unexpected obstacle prevents progress.
---
# Remediation Protocol

This protocol must be activated immediately upon discovering any unexpected
obstacle that prevents progress.

## Examples of Obstacles

- An unexpected test failure.
- A regression in functionality.
- A drop in code quality metrics (e.g., surviving mutants).
- An error or incorrect behavior from a command-line tool.

## Principle: One Obstacle at a Time

All work must be reduced to resolving a single, isolated obstacle. Attempting to
solve multiple issues simultaneously is strictly forbidden.

## Workflow

1. **STOP and Document:** Immediately stop the current primary task. Create a
   new task representing the problem, blocking the original task. Claim the new
   task and move it to in progress.

2. **Isolate and Prioritize:**
    - List all identified obstacles in the new task
    - Select **only the first obstacle** from the list. The remaining obstacles
      must be ignored until the first is fully resolved.

3. **Execute a Single Fix Cycle:**
    - **Hypothesize:** Formulate a specific, testable hypothesis for the cause
      of the single obstacle.
    - **Test Hypothesis (Red/Verification):** Create the minimal change
      required to test the hypothesis.
        - For a **code bug**, this is a minimal failing test (the "Red" step).
        - For a **tooling bug**, this is a minimal command execution to see if
          the new syntax works.
    - **Verify Outcome:** Run the test or command.
        - If it behaves as expected (e.g., the test fails, the command succeeds),
          the hypothesis is likely correct. Proceed to the next step.
        - If it does not behave as expected, the hypothesis is wrong. Revert the
          change and return to the "Hypothesize" step to formulate a new one.
    - **Implement Fix (Green):**
        - For a **code bug**, write the minimal production code to make the test
          pass.
        - For a **tooling bug**, the fix was already verified in the previous
          step. No further action is needed.
    - **Verify Fix:** Run the relevant tests or commands to confirm the obstacle
      is resolved and no regressions were introduced.

4. **Commit and Document:** Use the commit skill in a sub-agent to commit the
   change with a message that clearly states which specific obstacle was
   resolved. Update the task description to reflect the resolved obstacle and
   any remaining ones.

5. **Repeat or Resume:**
    - If there are more obstacles in the list from step 2, return to step 2 and
      select the next one.
    - If all obstacles are resolved, announce that the remediation is complete.
      Close the remediation task and resume the original, primary task.
