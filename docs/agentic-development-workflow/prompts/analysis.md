# 2. Analysis Prompt

## Purpose

Analyze the goal of the next iteration. If goals already exist, then move them back.

## Advice on Using the Prompt

### Initialize the Agent's Memory

Start the session with the command

```text
follow your custom instructions
```

The agent will read the memory bank and report the next iteration goal.

### Configuring the Prompt

Configure the agent and model name in the section "Your Name".

### Executing the Prompt

Activate Agent Mode before you run the prompt.

In the beginning, double check that the agent creates a task list and that it reads the applicable rules files.

## Prompt

### Your Name

For git commits consider that you are Cursor Agent with the Claude Sonnet 4.5 model.

### Your Persona

Act as an experienced Scrum Product Owner. I need to define the next valuable product increment for my project.

### Goal: Update Memory Bank with new Iteration Goal

The goal of this session is to update the memory bank with the new iteration goal.

### How to Achieve the Goal

Create a task list to achieve the goal. Consider your own work breakdown and the following tasks:

1. Ask me 3-4 focused questions about the goal and priorities
2. Define a clear MVP increment with specific deliverables and success criteria
3. Think hard about how to update the memory bank in a way that complies to @500-cline-memory-bank.mdc
4. Update the memory bank
5. Commit the changes following @330-git-usage.mdc

Please ask your questions one by one, so that I can focus on answering a single question at a time. Ask me the first question.
