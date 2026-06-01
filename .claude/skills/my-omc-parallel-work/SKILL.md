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
- **Autonomous**: no "awaiting user review" or "needs approval"
  (`bd show <id>` to verify)
- **Independent**: no dependency between selected tasks, different files

Exclude tasks needing user input — handle those interactively first.

### Pre-flight: check for uncommitted main-worktree changes

Before spawning any agents, run:

```bash
git status --porcelain
```

If output is non-empty, **stop immediately** and tell the user:

> Uncommitted changes detected in the main worktree. Parallel agents run
> in isolated worktrees and will not see these changes. Commit or stash
> before spawning agents:
>
> ```bash
> git add -p && git commit -m "wip: stash before parallel run"
> # or: git stash
> ```

Do NOT spawn agents until the working tree is clean.

## Step 2 — Select agent type per task

For each qualifying task, apply these rules (use `bd show <id>` if more
detail is needed):

| Signal from issue | Agent type |
| --- | --- |
| type: bug, or mentions test/molecule/CI failure | `ralph` |
| type: task/chore/feature with concrete spec | `executor` |
| root cause unknown, needs investigation | `debugger` |
| large epic needing decomposition into subtasks | `team N:executor` |

Default to `executor` when signal is ambiguous. Prefer `ralph` over
`executor` when a test suite must pass — the retry loop handles
test-fix-retry cycles without user intervention.

## Step 3 — Present execution plan

Before spawning, output the plan:

```text
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
5. **PR instruction**: after pushing, open a PR targeting the default
   branch of `origin`. If the repo has an `upstream` remote, `origin` is
   a fork — target `origin` only, never `upstream`.
   Do NOT merge the PR — leave it open for user review.

**PR rules (encode in every agent prompt):**

- Determine target:
  `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
- Target repo: `origin` (run `git remote get-url origin` to confirm)
- Never open PR against `upstream` remote
- No squash merges — regular merge commits only
- Do NOT merge the PR — the user merges explicitly

Do NOT include session close protocol — CLAUDE.md auto-loads in each
worktree and instructs the agent to read AGENTS.md, which contains the
mandatory `bd close`, `bd dolt push`, `git push` sequence.

Example agent prompt structure:

```text
Claim and complete Beads issue ansible-all-my-things-<id>: "<title>".

1. bd update ansible-all-my-things-<id> --claim
2. <concrete implementation steps from bd show description>
3. <verification command>
4. Push the branch and open a PR against the default branch of origin:
   DEFAULT=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
   gh pr create --base "$DEFAULT" --title "<title>" --body "<summary>"
   Do NOT merge the PR. Leave it open for user review.

CLAUDE.md and AGENTS.md will load automatically. Follow the session
completion protocol they specify.
```

## Step 5 — Show agent output in tmux panes

If `$TMUX` is set, open one pane per agent for real-time progress. Skip if
not inside tmux.

### 5a — Enable pane border labels (once per window)

```bash
tmux set-option pane-border-status top
tmux set-option pane-border-format '#{pane_index}: #{pane_title}'
```

### 5b — Per agent: split, title, tail, refocus

Run once per agent. Replace `<id>` with the Beads issue ID and
`<short-title>` with a 2–4-word label.

```bash
LOG=/tmp/omc-agent-<id>.log
touch "$LOG"

tmux split-window -h          # use -v to split below instead of right
tmux select-pane -T '<id> — <short-title>'
tmux send-keys "tail -f $LOG" Enter
tmux select-pane -L           # return focus to main pane
```

### 5c — Log instruction to add to each agent prompt (Step 4)

Append this line to every agent prompt so progress appears in the pane:

```text
Append progress lines to /tmp/omc-agent-<id>.log:
  echo "<status>" >> /tmp/omc-agent-<id>.log
```

### Convenience: all panes at once

```bash
for AGENT_ID in <id1> <id2> <id3>; do
  LOG=/tmp/omc-agent-${AGENT_ID}.log
  touch "$LOG"
  tmux split-window -v
  tmux select-pane -T "${AGENT_ID}"
  tmux send-keys "tail -f $LOG" Enter
done
tmux set-option pane-border-status top
tmux set-option pane-border-format '#{pane_index}: #{pane_title}'
tmux select-pane -t 0         # return focus to main pane
```

## Step 6 — Monitor and report

After all agents complete, report:

```text
Parallel execution complete:

  [id] <title> — closed ✓  PR open: <url>
  [id] <title> — closed ✓  PR open: <url>

PRs are open for your review. Merge when ready (no squash).
```

If any agent fails or leaves work incomplete, report what failed and
whether a retry or user intervention is needed.

### Post-completion cleanup

**Branches must NOT be deleted until the PR is merged by the user.**

After the user merges a PR:

**Step 1 — verify the worktree branch is reachable from main.**

```bash
git log --oneline origin/main..worktree-agent-<id>
```

- Empty output → merged → safe to delete
- Non-empty → NOT merged → do not delete; tell the user

**Step 2 — prune worktrees and delete merged branches.**

```bash
git worktree remove --force .claude/worktrees/agent-<id>   # for each worktree
git worktree prune
git branch | sed 's/^[* +]*//' | grep 'worktree-agent-' | xargs -r git branch -d
```

Do NOT use `-D`. If `-d` fails the branch has unmerged commits — stop and
investigate. Do NOT force-delete (confirmed incident: r1c exa MCP work
lost this way).

**Step 3 — delete remote agent branches (after merge only).**

```bash
git branch -r | grep 'origin/worktree-agent-' | sed 's|origin/||' | xargs -r git push origin --delete
```

## Notes

- `bd dolt push` is mandatory per AGENTS.md — agents omitting it leave
  Beads state stranded locally. AGENTS.md enforces this; no need to repeat.
- Never spawn more than 3 agents, regardless of how many tasks qualify.
- Agent type is a judgment call — when uncertain, prefer `ralph`.
- **PR target is always `origin`'s default branch** — never `upstream`.
  If an `upstream` remote exists, the repo is a fork; always target `origin`.
- **No squash merges.** Regular merge commits only.
- **Agents never merge PRs.** Only the user merges, when explicitly instructed.
- **Never delete a branch before its PR is merged** — deletion before merge
  silently discards committed work (confirmed incident: r1c exa MCP server).
