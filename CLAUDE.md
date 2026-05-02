# CLAUDE.md

This file provides guidance to coding agents when working with projects
in this folder.

## Collaboration between you and the user

### Language

The chat uses English.

### One question after another

Whenever you want to ask the user questions, then ask one question after
another, so that the user can focus on a single question at a time.

### Avoid Ambiguity

If your instructions are unclear, ambiguous, inconsistent or contradicting to
the rules or to previous instructions, you must describe this situation and
ask the user clarifying questions before proceeding.

## How to follow your custom instructions

Whenever the user says "follow your custom instructions", then use the
/memory-bank-by-cline skill to understand the memory bank concept and structure.

If there is no memory bank, then you MUST ask the user for clarification
before proceeding.

Then read the memory bank and identify the immediate next action.

Afterwards, identify the applicable rules and read them.

After having read the memory bank, you must summarize your current
understanding. The summary shall end with the next immediate action.

Finally, ask whether you should execute the next immediate action.

## LS tool does not show hidden files

When you want to check whether a hidden file or directory exists, then
you MUST use the Bash tool to run `ls -la <path>`. The LS tool does not handle
hidden files.
