# CLAUDE.md

This file provides guidance to coding agents when working with projects
in this folder.

## Rules are stored in .cursor/rules

Rules describing the interaction between the coding agent and the user
are stored in the .cursor/rules directory and in contained subdirectories.

Read `.cursor/rules/general/020-rule-confirmation.mdc` — it applies to
every response you produce.

Read `.cursor/rules/general/310-collaboration.mdc` — it governs all interaction
with the user.

If rules conflict, then you MUST ask the user for clarification before
proceeding. The full collaboration rules (language, one-question-at-a-time,
avoiding ambiguity) are in `.cursor/rules/general/310-collaboration.mdc`.

## How to follow your custom instructions

Whenever the user says "follow your custom instructions", then you must read
`.cursor/rules/general/500-cline-memory-bank.mdc`.

If there is no memory bank, then you MUST ask the user for clarification
before proceeding.

Then read the memory bank and identify the immediate next action.

Afterwards, identify the applicable rules and read them.

Finally, confirm readiness as described in `.cursor/rules/general/900-confirm-readiness.mdc`.

## LS tool does not show hidden files

When you want to check whether a hidden file or directory exists, then
you MUST use the Bash tool to run `ls -la <path>`. The LS tool does not handle
hidden files.

## Rule index

The table below lists every rule file in `.cursor/rules/general/` with the
description from its frontmatter. Use it to decide which rules to read for
your current task.

| Rule | When to read |
| --- | --- |
| [020-rule-confirmation.mdc](.cursor/rules/general/020-rule-confirmation.mdc) | Always applied |
| [310-collaboration.mdc](.cursor/rules/general/310-collaboration.mdc) | Always applied |
| [330-git-usage.mdc](.cursor/rules/general/330-git-usage.mdc) | Use for documenting version information and when committing to git |
| [380-remediation-protocol.mdc](.cursor/rules/general/380-remediation-protocol.mdc) | Use when an unexpected obstacle prevents progress |
| [400-markdown-formatting.mdc](.cursor/rules/general/400-markdown-formatting.mdc) | Use after creating or modifying a markdown file (`*.md`, `*.mdc`) |
| [500-cline-memory-bank.mdc](.cursor/rules/general/500-cline-memory-bank.mdc) | Use when following 'follow your custom instructions' to understand the memory bank concept |
| [600-documentation-strategy.mdc](.cursor/rules/general/600-documentation-strategy.mdc) | Use when creating and updating documentation |
| [900-confirm-readiness.mdc](.cursor/rules/general/900-confirm-readiness.mdc) | Use when responding to the "follow your custom instructions" command |
