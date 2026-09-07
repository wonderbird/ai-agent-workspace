---
name: my-omc-show-next
description: >
  Triage open issues down to the single next action. Scopes to in-progress
  work (or the current branch as proxy), renders a compact
  actionable-vs-blocked graph, and names the one issue to claim next with
  rationale. Invoke on "what's next", "show next", "what should I work on",
  or any triage-summary request.
model: sonnet
---

# Show-Next: Next Immediate Action

Produce a focused next-action analysis. First output line is the graph
header — no preamble.

## Authoritative rule (bd v1.0.4)

`bd ready` is the ONLY source of actionable issues. `bd blocked` is the ONLY
source of blocked issues. `dep tree`, `dep list`, and `--parent` are
display-only views — they NEVER override readiness. Only `bd dep add` creates
a real blocker.

Validated against bd v1.0.4 — re-check if a newer bd changelog touches
parent-child gating or `bd ready` behaviour. If `bd ready` and `bd blocked`
look contradictory, suspect a `--parent`/`bd dep add` antiparallel cycle;
audit with `bd dep list <id> --direction up|down`.

## Step 1 — Gather state (run in parallel)

```bash
bd list --status=in_progress
git branch --show-current
bd ready
bd blocked
```

## Step 2 — Scope to WIP

- **in_progress issues exist** → scope to them plus their blockers/dependents
  as reported by `bd ready`/`bd blocked`; finish these before starting new work.
- **none** → use the current branch as WIP proxy; its name identifies the epic.

Keep only open issues whose readiness comes from `bd ready` / `bd blocked`
membership. Drop closed issues, unrelated epics, and unblocked backlog with no
edge into WIP.

Findings always attach to WIP. A finding not tied to active WIP becomes a
normal feature request (headline drops "Finding"; description may keep
provenance).

## Step 3 — Render graph

```
WIP: <branch>   [or: <issue-id> — <title>]
<one-line status / proxy note>

ACTIONABLE (bd ready)             BLOCKED (bd blocked)
[id] P<n> <title>                 [id] P<n> <title>  ← waits on [id],[id]
[id] P<n> <title>                 [id] P<n> <title>  ← waits on [id]
```

- Left column: actionable issues, P-sorted (P1 first).
- Right column: blocked issues, each with its open blocker ids (from
  `bd blocked` / `bd show <id>`, never the graph views) after `← waits on`.
- Titles ≤50 chars. Box-drawing or plain text only — no Mermaid, no HTML.

## Step 4 — State the next action

One paragraph, ≤4 sentences: name the issue to claim, why it is next (by
precedence: unblocks the most > P1 > branch-aligned), the concrete action
(file, command, or deliverable), and what closing it unblocks. End with:

`**Next immediate action: \`<id>\` [then \`<id>\`].**`

## Step 5 — Autonomous assessment

Output this block verbatim:

---

> **What is the concrete next action? What can you do autonomously? For which tasks do you need me?**
> *(Check the MCP tools, plugins and skills available to you)*

---

Then answer in three parts:

- **Autonomous** — steps doable without the user (file edits, shell, gh API,
  bd operations via MCP or CLI).
- **Needs user** — steps needing a decision, approval, credentials, or a GitHub
  UI action not exposed by the API.
- **Recommendation** — one of: 2+ independent autonomous tasks → suggest
  `my-omc-parallel-work`; exactly one autonomous task → claim and run it
  directly; any actionable task needs the user first → list those so the user
  can unblock them.

## Output constraints

- Prose is caveman-mode; the graph and issue ids are structured, not caveman.
- No preamble — start with the graph header.
