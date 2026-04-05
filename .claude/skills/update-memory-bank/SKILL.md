---
name: update-memory-bank
description: >
  Keeps the memory bank current for the active feature branch. Invoke after
  completing significant milestones, making key decisions, or before ending a
  session. The VM may be destroyed at any time — the memory bank is the sole
  continuity mechanism for the next agent session.
---

The virtual machine may be destroyed at any time. The memory bank must always
reflect the current state so a fresh agent can resume work in a new session without
loss of context.

Read `.cursor/rules/general/500-cline-memory-bank.mdc` to understand the required
structure and file conventions.

Create a task list with one task per memory bank file. For each file:

1. Check whether the file exists and whether its content still accurately reflects
   the current state.
2. If the file is outdated or missing, think hard about the optimal content given
   these quality requirements:
   - Focused on the current iteration goal, not the full project history.
   - Written for AI agents as the target audience, not humans.
   - Captures everything a fresh agent needs to resume in a new session: product
     context, project state, active context, system patterns, technical context,
     task status, and the next immediate action.
   - Minimises context token consumption when read by an agent.
3. Update or create the file. Skip files whose content is still accurate.

When all files are current, reflect: what did you learn during this session
that is not yet captured? Check your memory for any relevant learnings. Update
the memory bank files accordingly.
