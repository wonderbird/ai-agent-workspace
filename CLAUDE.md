# CLAUDE.md

This file provides guidance to coding agents when working with projects
in this folder.

## Rules are stored in .claude/rules

Rules describing the interaction between the coding agent and the user
are stored in the .claude/rules directory and in contained subdirectories.

Read `.claude/rules/general/020-rule-confirmation.mdc` — it applies to
every response you produce.

Read `.claude/rules/general/310-collaboration.mdc` — it governs all interaction
with the user.

If rules conflict, then you MUST ask the user for clarification before
proceeding. The full collaboration rules (language, one-question-at-a-time,
avoiding ambiguity) are in `.claude/rules/general/310-collaboration.mdc`.

## How to follow your custom instructions

Whenever the user says "follow your custom instructions", then use the
/memory-bank-by-cline skill to understand the memory bank concept and structure.

If there is no memory bank, then you MUST ask the user for clarification
before proceeding.

Then read the memory bank and identify the immediate next action.

Afterwards, identify the applicable rules and read them.

Finally, confirm readiness as described in `.claude/rules/general/900-confirm-readiness.mdc`.

## LS tool does not show hidden files

When you want to check whether a hidden file or directory exists, then
you MUST use the Bash tool to run `ls -la <path>`. The LS tool does not handle
hidden files.

## Rule index

The table below lists every rule file in `.claude/rules/general/` with the
description from its frontmatter. Use it to decide which rules to read for
your current task.

| Rule | When to read |
| --- | --- |
| [020-rule-confirmation.mdc](.claude/rules/general/020-rule-confirmation.mdc) | Always applied |
| [310-collaboration.mdc](.claude/rules/general/310-collaboration.mdc) | Always applied |
| [700-quality-of-agent-guidelines.mdc](.claude/rules/general/700-quality-of-agent-guidelines.mdc) | Use when creating and updating rule files and memory bank files |
| [900-confirm-readiness.mdc](.claude/rules/general/900-confirm-readiness.mdc) | Use when responding to the "follow your custom instructions" command |
