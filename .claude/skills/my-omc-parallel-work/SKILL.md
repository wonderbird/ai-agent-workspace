---
name: my-omc-parallel-work
description: >
  Spawn parallel sub-agents in isolated git worktrees for independent Beads
  tasks. Use when triage shows 2+ independent actionable tasks suited for
  autonomous execution. Invoke when user says "execute in parallel",
  "delegate to agents", "run parallel agents", or show-next-task recommends it.
aliases: [pw]
---

# Parallel Work Skill

Orchestrate parallel sub-agents for independent Beads tasks, each running
in its own isolated git worktree.

## When to invoke

- 2–3 independent actionable tasks identified by triage
- All selected tasks are autonomous (no user input required mid-execution)
- Tasks touch different files (no branch/file conflict risk)

If fewer than 2 tasks qualify → do NOT spawn parallel agents. Work directly
on the single task instead.

**Maximum 3 parallel agents.** If more than 3 tasks qualify, select the 3
highest-priority ones (P1 first, then by unblock chain length). Queue the
rest for the next session.

## Step 1 — Identify tasks

Use the actionable tasks already identified by `show-next-task` in this
session. Do NOT re-run `bv` — the triage context is in the conversation.

If invoked standalone without prior `show-next-task` triage, run first:
```bash
bv --robot-plan
```

From the task list, confirm each candidate is:
- **Actionable**: no open blockers
- **Autonomous**: no "awaiting user review" or "needs approval" (`bd show <id>` to verify)
- **Independent**: no dependency between selected tasks, different files

Exclude tasks needing user input — handle those interactively first.

## Step 2 — Select agent type per task

For each qualifying task, apply these rules (use `bd show <id>` if more
detail is needed):

| Signal from issue | Agent type |
|-------------------|------------|
| type: bug, or mentions test/molecule/CI failure | `ralph` |
| type: task/chore/feature with concrete spec | `executor` |
| root cause unknown, needs investigation | `debugger` |
| large epic needing decomposition into subtasks | `team N:executor` |

Default to `executor` when signal is ambiguous. Prefer `ralph` over
`executor` when a test suite must pass — the retry loop handles
test-fix-retry cycles without user intervention.

## Step 3 — Present execution plan

Before spawning, output the plan:

```
Parallel execution plan (N agents, N worktrees):

  [id] <title>
       Agent: <type>  Reason: <one-line rationale>

  [id] <title>
       Agent: <type>  Reason: <one-line rationale>

Spawning now...
```

Do not wait for confirmation unless the user has explicitly requested it.

## Step 4 — Spawn agents simultaneously

Spawn all Agent calls in the same response (parallel execution).
Each agent uses `isolation: "worktree"`.

Each agent prompt must include:

1. **Claim instruction**: `bd update ansible-all-my-things-<id> --claim`
   before starting work
2. **Issue context**: title and description from `bd show`
3. **Task scope**: what files or systems to touch
4. **Verification**: what command confirms the work is correct

Do NOT include session close protocol — CLAUDE.md auto-loads in each
worktree and instructs the agent to read AGENTS.md, which contains the
mandatory `bd close`, `bd dolt push`, `git push` sequence.

Example agent prompt structure:
```
Claim and complete Beads issue ansible-all-my-things-<id>: "<title>".

1. bd update ansible-all-my-things-<id> --claim
2. <concrete implementation steps from bd show description>
3. <verification command>

CLAUDE.md and AGENTS.md will load automatically. Follow the session
completion protocol they specify.
```

## Step 5 — Monitor and report

After all agents complete, report:

```
Parallel execution complete:

  [id] <title> — closed ✓  branch pushed ✓
  [id] <title> — closed ✓  branch pushed ✓

Run bv --robot-triage to confirm no remaining blockers.
```

If any agent fails or leaves work incomplete, report what failed and
whether a retry or user intervention is needed.

## Notes

- `bd dolt push` is mandatory per AGENTS.md — agents omitting it leave
  Beads state stranded locally. AGENTS.md enforces this; no need to repeat.
- Never spawn more than 3 agents, regardless of how many tasks qualify.
- Agent type is a judgment call — when uncertain, prefer `ralph`.
