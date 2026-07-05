# Agent Instructions

<!-- markdownlint-disable MD013 MD022 MD025 MD031 MD032 MD034 -->
<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%). Format flags (-c, -l, -L, -o, -Z) run raw.
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ccf33ec3 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**NEVER run `bd list --all`** — at ~350 issues it enters an unbounded output loop (5.6 GB,
100% CPU, SIGKILL, nearly fills the 17 GB agent disk). For bulk reads, query
`.beads/issues.jsonl` directly with `grep`/`jq`. For live queries use only scoped
commands: `bd ready`, `bd list --status <s>`, `bd list --priority <p>`, `bd show <id>`.
If unavoidable, bound it: `timeout 20 bd list --all`. (Bug tracked: 1fg7)

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
<!-- markdownlint-enable MD013 MD022 MD025 MD031 MD032 MD034 -->

## Beads: Data Safety and Workflow Rules

### Export after every mutation (bd v1.0.4)

<!-- bd-version: 1.0.4 -->

On bd v1.0.4 every command prints `auto-importing N bytes ... into empty
database` and rehydrates the working DB from `.beads/issues.jsonl`. A mutation
not yet flushed to the JSONL file is **silently reverted** by the next
command's re-import. Observed data loss: a `bd dep rm` rolled back before the
next command saw it; a later `bd dep add` then reported a phantom cycle.

**Mandatory workaround (bd 1.0.4 only):** export after **every** mutation —
never bundle exports at the end of a response:

```bash
bd export --all -o .beads/issues.jsonl   # run after EACH bd mutation
```

Re-evaluate when a bd release fixes auto-import without the v1.0.5 regression.

### Never commit `.beads/issues.jsonl`

`.beads/issues.jsonl` is gitignored and MUST NOT be `git add`ed or committed,
even though the export step above still writes it locally on every mutation.
It regenerates on every single issue create/claim/close; committing it
drowns real code changes in noise commits. bd's Dolt-backed sync
(`refs/dolt/data`) is the actual cross-machine sync mechanism — this file is
a local-only convenience export, redundant with it.

### Suppress git-add warning

If you see `auto-export: git add failed: exit status 1` after a bd mutation,
the cause is `export.git-add=true` (default) trying to stage
`.beads/issues.jsonl`, which is gitignored. Fix permanently:

```yaml
# .beads/config.yaml
export:
  git-add: false
```

This keeps local export (beads viewer stays in sync) while disabling git
staging.

### Findings are always tied to WIP

A finding discovered during implementation must be filed as an issue and
connected to the active WIP (`in_progress` issue or current branch). A finding
not tied to active WIP must be converted to a normal feature request: its
headline must **not** contain the word "Finding", though the description may
note provenance.

### Findings gates are closed by humans only

**AI agents MUST NOT close a findings gate.** A findings gate is a human
review checkpoint — it signals that a set of findings has been collected and
is awaiting human sign-off. Only the human reviewer closes it after confirming
each child finding has been addressed. This applies regardless of how many
child tasks have been closed.

## Beads: Issue Types and Dependency Rules

### Issue Types

Built-in types and when to use each:

| Type        | Use when                                              |
|-------------|-------------------------------------------------------|
| `task`      | Default. General work item. (default when omitted)    |
| `bug`       | Something broken that must be fixed.                  |
| `feature`   | New user-facing capability.                           |
| `chore`     | Maintenance, cleanup, non-functional work.            |
| `epic`      | Large body of work grouping child issues.             |
| `spike`     | Timeboxed investigation to reduce uncertainty.        |
| `story`     | User story (user-centric feature description).        |
| `decision`  | Architectural or design decision to document.         |
| `milestone` | Marks completion of a set of related issues.          |
| `gate`      | Async coordination checkpoint (blocks until cleared). |
| `molecule`  | Beads work template — NOT Ansible Molecule testing.   |

### Attaching Issues to Epics (epics cannot be gated)

`bd dep add` connects **any pair of issue types except `epic`** — an epic
connects only to another epic. So an epic cannot be gated out of `bd ready`
by its non-epic children:

- `bd dep add` between an epic and a non-epic is rejected in **both**
  directions (`<epic> <non-epic>` and `<non-epic> <epic>`), each printing
  `Error: epics can only block other epics, not tasks` (the message always
  says "not tasks", whatever the real type). A non-epic therefore cannot block
  its epic. Epic↔epic edges ARE permitted; non-epic pairs gate normally (a
  task can block a task, a feature, etc.).
- `--parent` attaches a child for display/scope only. It does NOT gate
  readiness and does NOT exclude the parent from `bd ready`.

```shell
bd update <child-id> --parent <epic-id>
```

An epic with open children therefore REMAINS in `bd ready`. Do not rely on
`bd ready` exclusion to track epic scope — read the epic's CHILDREN section
via `bd show <epic-id>` instead. See
[triage.md](docs/architecture/concepts/issue-tracking/triage.md) for the
validated dep-add type matrix and `--parent` / `bd ready` semantics
(bd v1.0.4).

### Beads Dependency Wiring — Cross-Tree Follow-Ups

Operationalizes Principle VIII (cross-tree blocking). When a policy or review
decision constrains in-flight work in another tree, wire the blocking dep
**immediately** — but mind the type rule: `bd dep add` cannot make an `epic`
block a non-epic (rejected; see "Attaching Issues to Epics" above). If the
follow-up is tracked as an epic, use a **non-epic** issue as the actual
blocker — a concrete task under that epic, or a `gate` checkpoint (verified:
a `gate` blocks a non-epic and gates it out of `bd ready`). Wire it as
`bd dep add <in-flight-issue> <non-epic-blocker>` (in-flight depends on
blocker).

**Signal the next action for the next session**: after wiring the deps, claim
both the blocked issue and the immediate actionable follow-up:

```bash
bd update <blocked-issue> --claim   # signals "this goal is in flight"
bd update <follow-up> --claim       # signals "work on this next"
```

Without claiming, triage ranks by graph score. A high-impact unrelated issue
will outrank the follow-up you actually need to work on, causing the next
session to pick up the wrong work.

## Collaboration with the User

- **Language**: English throughout. Apply the caveman skill by audience —
  `caveman full` for user-facing content (chat, code, comments, documentation,
  beads issues); `caveman wenyan-ultra` for internal and inter-agent content
  (thinking, subagents, MCP, tool calls, all files under `.omc/`). Code blocks,
  commit messages, and security warnings stay in normal English regardless of
  mode. The skills define each mode.
- **One question at a time**: when asking the user a question, ask one
  question at a time so they can focus.
- **Avoid ambiguity**: if instructions are unclear, contradictory, or
  conflict with rules or earlier instructions, describe the situation and
  ask clarifying questions before proceeding.
- **Hidden files**: the LS tool does not show hidden files; use
  `ls -la <path>` via Bash to check for hidden files or directories.

