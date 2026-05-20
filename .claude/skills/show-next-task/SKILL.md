---
name: show-next-task
description: >
  Identify the next immediate action from open issues. Shows a focused
  ASCII dependency graph scoped to in-progress work (or current branch as
  proxy), lists required issue IDs with headlines, and states the single
  next action with rationale. Invoke when the user asks "what's next",
  "show next", "what should I work on", or wants a triage summary.
model: sonnet
---

# Show-Next: Next Immediate Action

Produce a focused, human-readable next-action analysis.

## Step 1 — Gather state (run in parallel)

```bash
bd list --status=in_progress
git branch --show-current
bv --robot-triage --format toon
```

## Step 2 — Determine WIP scope

**If in_progress issues exist**: scope the analysis to those issues and
their dependency subtrees. These are the primary focus — finish before
starting anything new.

**If no in_progress issues**: use the current git branch as WIP proxy.
The branch name identifies the associated epic (e.g.
`feature/fork-safe-docker-ci` → Docker CI epic). Run `bd show` on the
epic and its open dependencies to map the subtree.

Note: findings are always connected to WIP. A finding not tied to active
WIP must be converted to a normal feature request (headline must NOT
contain "Finding"; description may record provenance).

## Step 3 — Identify required open issues

From the WIP subtree, collect only open issues that must close before
the WIP can be shipped and verified. Exclude:

- Closed issues
- Issues in unrelated epics with no dependency edge into WIP
- Backlog items with no blocking relationship to WIP

For each open issue, determine:
- Is it **actionable** (no open blockers)?
- Or **blocked** (has open dependencies)?

## Step 4 — Render ASCII dependency graph

Use this exact format — readable in a terminal without extra tooling:

```
BRANCH: <branch-name>   [or: IN PROGRESS: <issue-id> — <title>]
<in_progress status or proxy explanation — one line>

ACTIONABLE                                    BLOCKED
──────────────────────────────────────────    ──────────────────────────────────────
[id] P<n>  <short title>               ──┬─► [id] P<n>  <short title>
[id] P<n>  <short title>               ──┤
                                         └─► [id] P<n>  <short title>

[id] P<n>  <short title>               ──┐
[id] P<n>  <short title>               ──┼─► [id] P<n>  <short title>
[id] P<n>  <short title>               ──┘

[id] P<n>  <short title>                ── (standalone note if relevant)
```

Rules:
- Left column: actionable issues (no open blockers), sorted P1 first
- Right column: blocked issues, each preceded by its open blockers
- Use `──►` for single blocker, `──┬─►` / `──┤` / `──┘` for multi-blocker fan-in
- Keep titles short enough to fit one terminal line (~50 chars max)
- Omit closed issues entirely

## Step 5 — List issues

Flat list below the graph:

```
**Issues**
- `<id>` — <full title> [*(blocked: reason)*]
```

One line per issue. Blocked issues note what they wait on.

## Step 6 — State next immediate action

One paragraph, ≤4 sentences:

- Name the single next issue to claim
- Why it is next (unblocks the most, most concrete, branch-aligned, P1)
- What the action concretely is (file, command, or deliverable)
- What it unblocks when done

Format: `**Next immediate action: \`<id>\` [then \`<id>\`].**`

## Output constraints

- Plain text + box-drawing chars only — no Mermaid, no HTML
- No preamble ("Here is the analysis…") — start with the graph header
- Caveman mode applies to prose; graph and issue list are structured, not caveman
