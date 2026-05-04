# AGENTS.md - AI Agent Rules for the AI Agent Workspace

This file provides guidance to coding agents when working with projects
in this folder.

## Collaboration with the User

- **Language**: chat is in English.
- **One question at a time**: when asking the user a question, ask one
  question at a time so they can focus.
- **Avoid ambiguity**: if instructions are unclear, contradictory, or
  conflict with rules or earlier instructions, describe the situation and
  ask clarifying questions before proceeding.
- **Custom instructions**: when the user says "follow your custom
  instructions", use the `/memory-bank-by-cline` skill to understand the
  memory bank concept. If no memory bank exists, ask for clarification.
  Otherwise read the memory bank, identify the next action, read the
  applicable rules, summarize understanding ending with the next immediate
  action, then ask whether to execute it.
- **Hidden files**: the LS tool does not show hidden files; use
  `ls -la <path>` via Bash to check for hidden files or directories.

