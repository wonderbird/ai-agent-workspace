---
name: review-rules
description: >
  Review and fix all agent-facing context files for consistency, clarity, and
  token efficiency. Constitution is ground truth. Use when rules files may be
  out of sync, redundant, or contradictory.
argument-hint: "[Refined scope (optional): e.g. a single file]"
model: opus
effort: high
context: fork
agent: general-purpose
---

# Goal

Review and fix all agent-facing context files. Constitution is ground truth.
All other files must align to it — no duplication, no contradiction.

# Files

Always present:
- `CLAUDE.md` — first file read by any agent; must direct to AGENTS.md and
  constitution; no rules of its own beyond that direction

Check existence; skip if absent:
- `AGENTS.md` — detailed agent instructions
- Files explicitly linked from any of the above (one level deep) —
  typically ADRs

ADRs / linked-only files: read for context. Reviewed solely for
contradictions with constitution. No internal quality review. Never edited.

# Refined Scope

This section may contain a stricter definition of the files to review, if
text follows the colon:

$ARGUMENTS

# Quality criteria

`CLAUDE.md` — must:
- Direct agents to AGENTS.md and constitution
- Contain no rules of its own beyond that direction

Constitution — must be:
- Token-efficient, unambiguous, complete
- Internally consistent
- Scoped correctly: primary rules inline; optional detail in linked ADRs

All other files — must be:
- Token-efficient, unambiguous, complete
- Internally consistent
- Correctly scoped:
  - `AGENTS.md` → detailed instructions not duplicating constitution
  - `.claude/rules/**/*.md` → Claude-specific rules

Cross-file properties (verified in Step 3 only):
- No duplication of constitution content in other files
- No contradictions between files

# Finding types

- `redundancy` — repeated content within or across files
- `ambiguity` — multiple valid interpretations
- `inconsistency` — internal contradiction
- `wrong-scope` — content in wrong file
- `token-waste` — verbose phrasing, filler
- `contradicts-constitution` — file disagrees with constitution
- `missing-constitution-link` — `.claude/rules` file not linked from
  constitution
- `missing-required-pointer` — required direction absent (e.g., CLAUDE.md
  not directing to AGENTS.md or constitution)
- `requires-invention` — fix would require inventing content; flag only,
  never auto-fix

**Hard constraint: do not invent rules. Do not change intended meaning.
Auto-fix all types except `requires-invention`.**

# Execution

## Step 1 — Discover files

Check existence of AGENTS.md, `.claude/rules/**/*.md`, `.claude/skills/**/*.md`
and `.claude/commands/**/*.md`.
Collect linked files from all existing files (one level deep).
Constitution and CLAUDE.md always included.

## Step 2 — Per-file deep review (parallel, model: opus)

Spawn one sub-agent per non-ADR file. Each sub-agent:
1. Reads file and all files it directly links to
2. Reviews against per-file quality criteria (no cross-file checks)
3. Returns structured findings:

```
FILE: <path>
FINDING: <section or line ref> | <type> | <description> | <proposed fix>
```

ADR sub-agents: scan only for `contradicts-constitution`. Skip other types.

## Step 3 — Cross-file alignment review (model: opus)

Spawn one sub-agent with full content of all files plus Step 2 findings.
Verify cross-file properties above. Same finding format. Tag source file
per finding.

## Step 4 — Fix findings

### Step 4a — Cross-file moves (sequential, single agent)

For findings that move content between files: one agent applies all moves
sequentially.

### Step 4b — Per-file fixes (parallel, one sub-agent per file)

Group remaining findings by target file. Spawn one executor per file.
Each sub-agent applies fixes, writes to disk.

`requires-invention` findings: never auto-fixed; forwarded to Step 5.

## Step 5 — Summary

- Files changed
- Fix count by type
- `requires-invention` findings (flagged for human review)
