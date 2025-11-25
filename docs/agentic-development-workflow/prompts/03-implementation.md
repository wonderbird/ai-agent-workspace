# 3. Implementation Prompt

## Advice on Using the Prompt

### Establish Clean Code Rules

Before executing the prompt, link the [Clean Code Rules](../../../rules-banks/clean-code/) into your agent rules directory.

### Configuring the Prompt

Configure the agent and model name in the section "Your Name".

If the memory bank contains multiple iterations, I explicitly state which iteration to work on by naming the headline in the goal section of the prompt.

### Executing the Prompt

Activate Agent Mode before you run the prompt.

In the beginning, double check that the agent creates a task list and that it reads the applicable rules files.

## Prompt

### Your Name

For git commits consider that you are Cursor Agent with the Claude Sonnet 4.5 model.

### Goal: Implement Iteration Goal from Memory Bank

Please implement the tasks planned in the memory bank.

### Constraints

- You must follow strict TDD with small steps as described in @600-strict-tdd.mdc.
- Make sure that you follow the remediation protocol as soon as you encounter an obstacle.
- If you find a problem you cannot cure, e.g. a missing tool, then stop and ask me for advice.
- There is no need to pause and wait for my feedback in between. I can review your work in parallel, because you will create commits after every green step and after each refactoring step.

### How to Achieve the Goal

Please create a task list to break down the work first.

Once you have created the task list, think about which rules to consider. For this purpose, list the rules files, analyze the yaml header of each rule file and check whether it is applicable. Then extend your task list as needed to ensure that all rules are considered appropriately.

At this stage, extend the task list such, that after each commit you think hard about the current status and things you have learned in order to identify required task list updates.

The final task of the task list must be a code review. The final code review must check compliance with the rules. Findings from the code review must lead to additional tasks in the task list, which must be implemented next, again following the appropriate rules.

Now execute the task list.
