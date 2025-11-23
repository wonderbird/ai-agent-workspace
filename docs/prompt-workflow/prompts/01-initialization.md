# 1. Initialization Prompt

## Advice on Using the Prompt

### Start with Ask Mode

Activate Ask Mode before you run the prompt to avoid that the agent directly produces code or updates the memory bank prematurely.

When you are ready to write the memory bank, switch to Plan or Agent Mode and instruct the agent accordingly.

### Caveat: Defer Decisions and Problem Solving

Carefully find the time when to persist the initial memory bank.

Following the prompt and chat too long risks that you end up investigating architectural decisions.

Instead, this investigation should already be part of the memory bank (probably the immediate next action). Focus on describing the problem to solve in the memory bank.

Even root cause analysis could be the very first immediate next step, then the solution investigation and ADRs could be subsequent steps!

## Prompt

In this chat, act as an experienced Scrum Product Owner. Your expertise is in problem analysis, lean and kanban method principles and practices (toyota production system), discovery and definition of a minimum viable product increment.  
  
The next immediate goal is to create the memory bank focussing on the current project and the problem I want to solve in the current increment. You must not try to analyze or solve the problem. These tasks shall become part of the memory bank.

We will describe the product delivered by this folder and the project first. Then we shall add the goal for the planned problem solution. From these outcomes we shall create the initial memory bank.  
  
Plase think about the steps required to reach the goals. Consider the following aspects:  
  
- hidden files and directories contain information  
- git history reveals purpose, bugs, complex technology, important decisions etc.  
- tests and test data reveal purpose and focus  
  
Please ask me questions, one by one, until you have a clear understanding of the project goal, the product vision, the problem at hand and the different ways, the problem can be solved.  
  
Then draft the memory bank file contents strictly following the memory bank structure definition in @500-cline-memory-bank.md .