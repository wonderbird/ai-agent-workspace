# Prompt: Architectural Evaluation of Skill-Chooser Tools

> **Frozen research** behind
> [ADR 002](../../architecture-decisions/002-skill-manager-tool-selection.md). The
> reusable prompt/rubric used to produce
> [source-code-evaluation.md](source-code-evaluation.md). Point-in-time; not
> maintained.

> Paste everything below the line into a fresh **oh-my-claudecode (OMC)** agent
> session on the dedicated evaluation machine. It is fully self-contained: it
> clones all source itself, carries all data it needs inline, and depends on no
> pre-existing checkout, submodule, or workspace file. It assumes OMC is
> installed (uses OMC agents and, optionally, OMC orchestration skills).

---

## Your role

You are the **orchestrator**. You supervise a group of specialist sub-agents,
each a skilled software developer and architect. Each sub-agent analyzes the
real source code of exactly **one** tool and reports its findings back to you.
You consolidate the reports into a single ranked evaluation document.

Do not analyze the tools yourself in depth — delegate each tool to one
sub-agent, then verify and consolidate.

## Preconditions

Before starting, confirm:

- `git` is installed and outbound network access works. If `git` is missing or
  cloning is impossible, stop and report — do not fake results.
- You are running under OMC. If the `oh-my-claudecode:architect` sub-agent type
  is unavailable, fall back to the `general-purpose` agent used in a read-only
  manner (do not let it modify the cloned source), and record the substitution
  in the final document's Caveats.

## Background

We want to centralize prompt rules, MCP configs, and skill definitions in one
repository and select/deselect skills globally for coding agents. The challenge:
agents load skills from different target directories
(`~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.cursor/rules/`, …) with
differing frontmatter/schema and link strategies (symlink vs copy vs
frontmatter-rewrite).

Five open-source tools claim to solve this. A prior survey (reproduced inline
below) described them only by stars/commits/blurbs — it never judged the actual
code. Your job is an **evidence-based evaluation grounded in each tool's real
source**.

**Canonical target agents for scoring:** Fit is judged against exactly these
three targets — **OpenCode, Claude Code, Cursor**. Any other target a tool
supports (Codex CLI, Gemini CLI, Windsurf, etc.) is out of scope for the score
but may be noted as a bonus.

## Tools under evaluation

All five are cloned fresh the same way — no tool gets special treatment (even if
one happens to also exist elsewhere on this machine, ignore that copy and clone
fresh).

| Tool | Repository | Clone subdir |
| :--- | :--- | :--- |
| `lexler/skill-factory` | `https://github.com/lexler/skill-factory` | `lexler__skill-factory/` |
| `mode-io/skill-manager` | `https://github.com/mode-io/skill-manager` | `mode-io__skill-manager/` |
| `24KaratAu/openhub` | `https://github.com/24KaratAu/openhub` | `24KaratAu__openhub/` |
| `lijianru/skills-manager` | `https://github.com/lijianru/skills-manager` | `lijianru__skills-manager/` |
| `VictorTomaili/skill-cli` | `https://github.com/VictorTomaili/skill-cli` | `VictorTomaili__skill-cli/` |

## Prior survey (inline — treat every value as UNVERIFIED)

These are the prior survey's claims. Do **not** trust them; they are here only so
you can reconcile them against the real repos in Step 3. In particular the dates
look implausibly future-dated — verify against `git log`, do not copy.

| Tool | Claimed stars | Claimed commits | Claimed latest / first commit | Claimed link strategy | Claimed multi-agent support |
| :--- | :---: | :---: | :--- | :--- | :--- |
| `lexler/skill-factory` | 231 | 427 | Sep 2026 / Jan 2026 | Symlinks (`ln -s`) | Claude Code native; configurable OpenCode/Cursor |
| `mode-io/skill-manager` | 117 | 48 | Aug 2026 / Nov 2025 | Symlinks & frontmatter rewriting | OpenCode, Claude Code, Cursor, Codex CLI |
| `24KaratAu/openhub` | 22 | 9 | Aug 2026 / Feb 2026 | Direct export / sync | OpenCode, Claude Code, Cursor, Windsurf |
| `lijianru/skills-manager` | 18 | 10 | Mar 2026 / Feb 2026 | Deep copying (IDE safety) | OpenCode, Cursor, Windsurf, Claude Code |
| `VictorTomaili/skill-cli` | 4 | 41 | Aug 2026 / Jul 2026 | Central store + bootstrapping | OpenCode, Claude Code, Gemini CLI, Cursor |

Survey blurbs (also unverified — confirm or refute each against code):

- **skill-factory** — skill-generation framework + runtime manager; `./skills
  toggle` TUI picker; symlinks enabled skills into global dirs; claims a
  two-tier loading model (~100-token starter prompt, full body on invocation).
- **skill-manager (mode-io)** — Rust/TypeScript cross-agent router; interactive
  CLI selector; canonical local store; claims frontmatter translation between
  Claude Code SKILL.md, Cursor prompts, OpenCode definitions.
- **openhub** — SQLite + Python Textual TUI; keyboard-driven; universal export
  (`E` key) to `SKILL.md`; targets `~/.config/opencode/` and `~/.agents/skills/`.
- **skills-manager (lijianru)** — Node.js, Inquirer-style prompts; copies files
  instead of symlinking for cross-OS safety; claims selective sub-folder
  extraction from monorepos.
- **skill-cli** — store-and-forward isolation harness; curses/raw-terminal menu;
  master store at `~/.skill-cli/store/`; active-profile management.

## Evaluation dimensions (score all four, per tool)

Score each dimension **1–5** using these anchors (same scale for every tool, so
scores are comparable across tools):

- **1** = unusable or feature absent
- **2** = poor / significant deficiencies
- **3** = adequate / works but unremarkable
- **4** = strong / clearly above average
- **5** = exemplary — must be justified with explicit `file:line` evidence

Dimensions:

1. **Code quality** — readability, structure, modularity, tests, error
   handling, idiomatic use of the language.
2. **Architecture / design** — separation of concerns, extensibility, the link
   strategy actually implemented (symlink / copy / frontmatter-rewrite / other),
   multi-agent target abstraction, coupling.
3. **Maintainability / health** — commit activity, docs, CI, dependency
   footprint, bus-factor, release hygiene.
4. **Fit for our use case** — suitability for centralizing skills across the
   three canonical targets (OpenCode / Claude Code / Cursor).

## Procedure

### Step 1 — Prepare source (you, the orchestrator)

Use this **exact, deterministic** persistent checkout root:

```
$HOME/Documents/Cline/skill-chooser-eval-repos/
```

Rules:

- If `$HOME/Documents/Cline/` does not exist, create it. Do not pick any
  alternative location. Do not use `/tmp` or `/var/tmp` (must survive restart).
- After creating the folder, verify it is **not** inside a git repository:
  `git -C "$HOME/Documents/Cline/skill-chooser-eval-repos" rev-parse --show-toplevel`
  must **fail** (`fatal: not a git repository`). If it *succeeds* and returns any
  toplevel path, the folder is inside an enclosing git repo — stop and report;
  clones must not pollute a repo.

Clone all **five** repos into that root, one subdir per tool using the exact
`Clone subdir` names in the table above (owner-prefixed to avoid the
`skill-manager` / `skills-manager` collision):

```
$HOME/Documents/Cline/skill-chooser-eval-repos/
  ├── lexler__skill-factory/
  ├── mode-io__skill-manager/
  ├── 24KaratAu__openhub/
  ├── lijianru__skills-manager/
  └── VictorTomaili__skill-cli/
```

Do a **full clone** (NOT `--depth 1`) — the Maintainability dimension and the
survey reconciliation both need real history (commit count, dates, activity,
release tags). For each repo, record the resolved HEAD commit hash and date
(`git -C <dir> rev-parse HEAD` and `git -C <dir> log -1 --format=%cd`). This
recorded Step-1 HEAD is **authoritative**: it is the citable revision, and every
sub-agent must echo it rather than re-resolve its own. The evaluation is pinned
to these HEADs; a later re-clone may drift.

**Star counts** are not in a git clone. Query them from the GitHub API or web
(e.g. `https://api.github.com/repos/<owner>/<repo>`). If there is no network
access for this, mark stars `UNVERIFIED` and move on — do not guess.

If a clone fails (network / rename / dead repo), note it in the final document's
Caveats and continue with the rest — do not block on one failure.

### Step 2 — Fan out one specialist per tool (in parallel)

Spawn **five `oh-my-claudecode:architect` sub-agents in parallel** — one per
tool — via a single message with five Agent tool calls. `architect` is
Opus-backed and read-only, so no sub-agent can mutate the cloned source and each
brings architecture + code-quality depth. (If unavailable, use the
`general-purpose` fallback from Preconditions.)

Optionally, drive the parallel fan-out through an OMC orchestration skill
(`/ultrawork` for high-throughput parallel execution, or `/team` for coordinated
lanes on a shared task list) instead of raw parallel Agent calls — either is
acceptable, as long as each of the five tools gets its own dedicated
`architect` lane.

Give each sub-agent, in its prompt:

- The **absolute path to its one tool's clone** (and nothing else, to keep it
  focused).
- The **authoritative Step-1 HEAD hash** you recorded for that tool, to echo
  verbatim in its report's `HEAD:` field (it must not re-resolve its own).
- The Background, the canonical target-agent set, and the four dimensions with
  the 1–5 anchors — copy them verbatim so all five agents share one rubric.
- The **exact report template below**, which it must return filled in and
  unchanged in structure. No free-form report shape is allowed — identical
  structure is what lets you merge five reports into one comparable matrix.
- Instruction to ground every claim in real code with `file:line` citations —
  no hallucinated features. If something is absent, it must say so explicitly.

Required sub-agent report template (the sub-agent returns exactly this, to you,
not to the user):

```
# <tool> — evaluation
HEAD: <commit hash> (<date>)

## Scores
Code quality: <1-5> — <file:line> — <one-sentence justification>
Architecture/design: <1-5> — <file:line> — <one-sentence justification>
Maintainability/health: <1-5> — <file path, `git log` output, or CI/release-config evidence> — <one-sentence justification>
Fit (OpenCode/Claude Code/Cursor): <1-5> — <file:line> — <one-sentence justification>

## Strengths
- <bullet, each with file:line>

## Risks / code smells
- <bullet, each with file:line>

## Link / delivery strategy (verified)
Strategy: <one of: symlink | copy | frontmatter-rewrite | other | none-found>
Evidence: <file:line and short explanation of how it actually installs skills>

## Dependencies & tests
Dependencies: <runtime/toolchain + notable deps>
Tests present: <yes/no> — <what kind, where>

## Fit verdict
<one line: is this a good fit for centralizing skills across OpenCode/Claude Code/Cursor, and why>
```

### Step 3 — Consolidate (you)

- Check each report for internal consistency and that its claims cite real
  files. **Spot-check at least one surprising claim per tool** by opening the
  cited file yourself before trusting it.
- Reconcile the inline prior-survey table against what the agents actually
  found: for each tool compare claimed stars/dates/commits and claimed link
  strategy against git reality and the verified strategy, and record any
  discrepancy (the survey values are unverified by definition).

### Step 4 — Write the evaluation document

Write the document to this **exact path** (the same persistent folder from
Step 1 — do not assume any pre-existing docs directory exists):

```
$HOME/Documents/Cline/skill-chooser-eval-repos/skill-manager-evaluation.md
```

It is ADR-style in content, but it is intentionally written into the non-repo
scratch folder for self-containment; moving it into a repo's
`docs/architecture-decisions/` folder is a deliberate later, separate step and
is NOT your job here. Structure:

- **Context & method** — what was evaluated, the recorded HEAD commit + date per
  tool, and how (fresh clones, five specialist sub-agents, the shared rubric).
  State explicitly that results are pinned to those HEADs and will drift if
  re-cloned later.
- **Per-tool scorecard** — one section each: the four 1–5 scores, strengths,
  risks, the verified link/delivery strategy, dependency + test notes, fit
  verdict. Cite file paths.
- **Comparison matrix** — a verified table (real HEAD commit/date per tool, real
  link strategy) placed side by side with the prior survey's claims, plus the
  four scores per tool.
- **Ranked recommendation** — rank the tools primarily by dimension 4 (Fit);
  break ties using dimensions 1, 2, then 3 in that order. State the weighting
  used, name the winner and runner-up with rationale, and note trade-offs.
- **Caveats** — any repo that failed to clone; any agent-type substitution; any
  survey-metadata discrepancies found.

**Do NOT run the `format-markdown` skill, any formatter, or any doc-formatting
pass on the result.** Write valid markdown (well-formed syntax only) but do not
restyle, reflow, or clean it up. Formatting is deliberately deferred and will be
done explicitly in a later, separate step.

## Definition of done

- Preconditions checked; checkout folder created at the exact path, verified
  persistent and outside any git repo.
- All five sources cloned (or explicitly noted as failed) and pinned to a
  recorded HEAD before fan-out.
- Every sub-agent returned the required template; every report cites real file
  paths; you spot-checked ≥1 claim per tool against source.
- Final doc exists at
  `$HOME/Documents/Cline/skill-chooser-eval-repos/skill-manager-evaluation.md`;
  every scored tool has all four dimensions filled, a verified link-strategy
  line, appears in the ranking, and the ranking states its weighting. No
  placeholder / TODO text anywhere.
- The document is valid (well-formed) markdown and no formatter was run.
