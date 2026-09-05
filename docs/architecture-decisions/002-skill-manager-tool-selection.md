# 002: Centralizing Skills Across Coding Agents

- Status: Proposed
- Date: 2026-09-04

## Executive Summary

This document records how to centralize skill definitions, prompt rules, and MCP
configuration in one store and select a per-project subset of them across our
coding agents. Each agent loads skills from a different directory with a different
schema, so a skill has to be maintained several times and there is no single place
from which a project can pick the subset it needs. This ADR frames the problem,
sets the decision drivers, and evaluates the realistic options — from doing
nothing, through a hand-rolled script, to adopting one of the surveyed open-source
tools, buying a product, or extending/forking a base. **The decision has not been
made yet.** The purpose of this document is to let the stakeholder make a
well-informed choice.

A source-code evaluation of five tools underpins the early analysis; see
[skill-manager-evaluation.md](skill-manager-evaluation.md). The drivers were then
reprioritized over two stakeholder interviews: top priority is **per-project skill
selection** (a central store from which each repository activates a chosen subset),
then **Claude Code out of the box**, with **OpenCode, GitHub Copilot, and Copilot
CLI added later** rather than day-one requirements. A verification round checked
the clones (source-verified) and each agent's real instruction mechanism
(web-verified). Finally, a **landscape scan (2026-09-05)** widened the search and
source-verified six further open-source tools. Key results:

- **Per-project selection is common; safe native delivery + extensibility is
  rare.** Off the shelf, `skill-cli`, `lijianru`, `skill-factory`, and the newly
  found `skills-mgr`, `omrikais/sm` (partial/additive), and `sklm` all do
  per-project subsets; `mode-io` does not (global-only). The differentiators are
  *how* they deliver
  (symlink vs. copy vs. runtime-pull) and how safely.
- **The landscape scan found stronger day-one candidates than the original five.**
  `Leonezz/skills-mgr` (per-project profiles with inheritance, data-driven agent
  table, SQLite-tracked reversible delivery) and `omrikais/sm` (symlink into native
  dirs, doctor/backups, recent HEAD — sustained activity unverified) both deliver
  into native agent directories — removing the runtime-pull/enforcement caveat that
  limited `skill-cli`. The day-one lead is therefore now contested.
- **The wanted targets span two delivery shapes.** Claude Code, OpenCode, pi, and
  Antigravity use the SKILL.md **skills-directory** standard (symlink-friendly);
  GitHub Copilot and Copilot CLI are **file-based** (`*.instructions.md`), needing
  generation. No verified tool emits the modern Copilot `.instructions.md` shape.
- **Commercial products exist** (SkillReg, Packmind, Tessl); none confirmed for
  per-project subset + OpenCode + Copilot CLI. See [Option 11](#11-buy-a-commercial-product).

Because a new day-one lead is not being crowned unilaterally, the recommendation
presents `skills-mgr` and `omrikais/sm` as day-one **co-candidates** (with
`skill-cli` as a fallback and Option 2's native script as a control)
to be settled by a spike; the decision stays open.

## Context and Problem Statement

We maintain a growing set of agent skills, prompt rules, and MCP server configs.
We want them to live in one canonical central store and be **selected per
project**: when starting a new repository, activate only the subset of skills
that repository needs, and nothing else. The central store is the single source
of truth; each project declares its own view onto it.

The obstacle is that each agent loads skills from its own target directory with
its own conventions:

- Claude Code: `~/.claude/skills/` — SKILL.md skills-directory standard.
- OpenCode: `$XDG_CONFIG_HOME/opencode/skills/` — SKILL.md skills-directory.
- GitHub Copilot: `.github/instructions/*.instructions.md` (repo) — a **file** per
  instruction, YAML frontmatter with an `applyTo` glob; repo-wide
  `.github/copilot-instructions.md`; personal `~/.copilot/instructions/`.
- GitHub Copilot CLI: same `.github/...` plus user-global
  `~/.copilot/instructions/`, extendable via the `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`
  environment variable; per-file toggling via its `/instructions` command.
- (Nice-to-have) Cursor: `~/.cursor/` rules in `.mdc` format; pi and Antigravity
  both use the same SKILL.md skills-directory standard (`~/.pi/agent/skills/`,
  `~/.gemini/config/skills/`); Codex reads `AGENTS.md`.

Two delivery shapes are in play. Claude Code, OpenCode, pi, and Antigravity share
the **SKILL.md skills-directory** model, which a symlink can serve. GitHub Copilot
and Copilot CLI are **file-based**: content must be emitted as `*.instructions.md`
files, so they cannot be served by symlinking a skills directory — they require
generating/translating files. They differ, in other words, not only in path but
in schema and in delivery mechanism. Without a central mechanism, every skill is
duplicated per agent, edits drift, and there is no single point of selection.

The target set for this decision, elicited from the stakeholder over two
interviews, is tiered by *when* each target must work:

- **Required out of the box:** Claude Code.
- **Added later by extension (not required day one):** OpenCode, GitHub Copilot,
  GitHub Copilot CLI.
- **Nice to have (same extensibility path):** Cursor, pi, Gemini (antigravity),
  Codex.

This ADR is intended for the project stakeholder (the developer) and any future
contributor.

## Decision Drivers

The choice will be guided by the following principles, in priority order (1 =
most important), confirmed with the stakeholder through two short interviews.

1. 🔀 **Per-project skill selection.** From one central store holding many skills,
   each project must be able to activate only a chosen subset — enable/disable
   skills per repository — so a new project gets exactly the skills it needs and
   nothing else. Machine-wide global toggling is still useful but is no longer a
   ranked driver.
2. 🟢 **Claude Code out of the box.** Claude Code must be supported immediately,
   with no forking or custom work — this is the one target that must work on day
   one and deliver value before anything else is added.
3. 🧩 **Cheap extensibility to further agents.** The remaining wanted targets —
   OpenCode, GitHub Copilot, and GitHub Copilot CLI — need not ship today; what
   matters is that they can be added cheaply, by whatever mechanism (declarative
   data-driven targets and a pluggable delivery layer, so that adding one is a
   configuration/adapter change, not a rewrite). This is solution-neutral: it does
   not presume a fork. Nice-to-haves (Cursor, pi, Gemini/antigravity, Codex) ride
   on the same extensibility.
4. 🛡️ **Safe, correct delivery.** Installing or updating a skill must not
   silently clobber local edits or report success for work it did not do; the
   link/copy strategy should be understandable and reversible.
5. 🧘 **Long-term trust / project health.** For a solo developer, the tool should
   be healthy enough to rely on — tested, active, released, and not a
   one-commit throwaway — with minimal ongoing tuning.

## Considered Options

1. **Do nothing / accept the status quo.** See [Detailed Analysis](#1-do-nothing--status-quo).
2. **Manual workaround: a hand-rolled symlink/copy script** into agents' native
   per-project dirs. See [Detailed Analysis](#2-manual-workaround-hand-rolled-script).
3. **Adopt `mode-io/skill-manager`** — no per-project scope (global-only). See
   [Detailed Analysis](#3-adopt-mode-ioskill-manager).
4. **Adopt `lijianru/skills-manager`** — per-project by copy, clobbers, hardcoded.
   See [Detailed Analysis](#4-adopt-lijianruskills-manager).
5. **Adopt `VictorTomaili/skill-cli`** — best selection model, runtime-pull
   delivery caveat. See [Detailed Analysis](#5-adopt-victortomailiskill-cli).
6. **Adopt `Leonezz/skills-mgr`** — per-project profiles + data-driven agents +
   strongest safe delivery (new, from the landscape scan). See
   [Detailed Analysis](#6-adopt-leonezzskills-mgr).
7. **Adopt `omrikais/skill-manager` (sm)** — symlink native delivery + strong
   safety, two hardcoded agents (new). See
   [Detailed Analysis](#7-adopt-omrikaisskill-manager-sm).
8. **Adopt `Auran0s/sklm`** — data-driven agents but destructive sync (new). See
   [Detailed Analysis](#8-adopt-auran0ssklm).
9. **Adopt `rohitg00/skillkit`** — mature cross-agent package manager, not
   central-store subset (new). See [Detailed Analysis](#9-adopt-rohitg00skillkit).
10. **Adopt another surveyed tool** — openhub, skill-factory, or the desktop-GUI
    cluster. See [Detailed Analysis](#10-adopt-another-surveyed-tool).
11. **Buy / adopt a commercial product** — SkillReg, Packmind, Tessl. See
    [Detailed Analysis](#11-buy-a-commercial-product).
12. **Extend a base without forking** — wrap a tool as a dependency + thin layer.
    See [Detailed Analysis](#12-extend-a-base-without-forking).
13. **Fork / build** — hard-fork the strongest base. See
    [Detailed Analysis](#13-fork--build).

## Recommendation (pending decision)

Under the drivers (1 per-project subset, 2 Claude Code out-of-the-box, 3 cheap
extensibility, 4 safe delivery, 5 health), d2 and at least the *activate* half of
d1 are met off the shelf by several tools; the *disable/swap* half of d1 is a live
gating question for one co-candidate (`omrikais/sm`). Deliberately, this ADR does
**not** crown a single winner — it presents day-one **co-candidates** and defers
the choice to a hands-on spike:

Two tools are genuine day-one co-candidates. They trade off cleanly — one leads
d1+d4-architecture but is stale/unlicensed; the other leads d5-freshness but has a
narrower d1 and d3 — so neither is crowned; the spike decides on live criteria.

- **`Leonezz/skills-mgr`** — per-project profiles with `includes` inheritance
  (`profiles.rs:56-88`), Claude Code at both scopes (`presets.rs:9-13`),
  data-driven agents (`config.rs:145-157`), and the richest safe-delivery design:
  SQLite-tracked placements, `doctor`, conflict-bail, ref-counted reversible
  deactivate (`placements.rs:338-354`), rollback on failure (`:278-289`).
  **Against it:** HEAD is `fded9c6` dated **2026-04-15 — ~5 months stale** at scan
  time (possibly dormant); single author, 1★; MIT declared in `Cargo.toml` but
  **no LICENSE file**; delivery is copy (not symlink), so edited sources need a
  `refresh`; Rust, a higher extension barrier for a Node/Python developer; no
  Copilot `.instructions.md` transform.
- **`omrikais/sm`** — symlink into native agent dirs (`src/fs/links.ts:19-66`),
  per-project profiles, and a strong safe-delivery surface (no-clobber via
  conflict-refusal, atomic temp+rename, doctor, backups, non-destructive rollback).
  **On d5 it strictly beats skills-mgr:** HEAD `970fb64` dated **2026-09-03 (fresh)**,
  clean MIT LICENSE file, 4★, dependabot, 84 test files — though *sustained*
  activity is unverifiable (shallow clone), so "recent HEAD" is the honest claim,
  not "actively maintained". **Against it:** profile switching is **additive-only**
  — it deploys but never undeploys the prior set (`install.ts:35-57`), so it
  **fails the disable/re-select half of driver 1** until a prune exists (a spike
  gating question, not a footnote); and targets are hardcoded to Claude Code +
  Codex (`src/fs/paths.ts:85`), so adding agents (d3) is a source edit.

`skill-cli` is now a **fallback**, not a co-candidate: its `allow`/`deny` selection
model (`config.js:78-113`) is the cleanest, but it delivers by runtime pull with no
enforcement and is effectively unmaintained (single ~6h burst) — the two tools
above remove the reason to accept its delivery caveat. `lijianru` (copy, clobbers)
and `sklm` (destructive `rmtree` sync, `_sync.py:38-40`) are weaker still. `mode-io`
remains the best *extensibility* base (data catalog + file codec) but fails d1.
`skillkit` is the healthiest project (1470★, Apache-2.0, ~1537 test assertions) but
is a package manager, not central-store subset selection. Desktop GUIs
(xingkongliang 4270★, jiweiyeah 971★) are **GUI-only, not headless**, unusable for
an automated pipeline.

Staged path, unchanged in shape:

1. **Adopt a day-one tool now** — decided by the spike below (co-candidates
   skills-mgr and omrikais/sm, with the native symlink baseline of Option 2 as a
   control arm, and skill-cli only as a fallback).
2. **Extend when the further agents are needed** — Option 12 (wrapper) or Option
   13 (fork), base chosen then.

The migration seam still applies: the selection/delivery models differ across
these tools, so "extend later" may mean discarding the day-one tool's config and
running two tools briefly. Adopting now is justified by early value, not by making
extension cheaper. **Commercial products** (Option 11) deserve a trial in case one
covers everything. This ADR is a *proposal only* — decision open.

A note on reversals: skill-cli scored Fit = 2 in the source evaluation (which
judged global three-agent coverage); the per-project-first drivers promoted it to
last round's lead; the landscape scan now shows tools that match its selection
model without its delivery caveat. Same evidence base, evolving question.

Coverage below is source-verified. Driver columns follow the priority set.

| Option | Per-project subset (d1) | Claude Code OOTB (d2) | Cheap extensibility (d3) | Safe delivery (d4) | Health (d5) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 Do nothing | none (manual) | manual | n/a | manual, error-prone | n/a |
| 2 Hand-rolled script | you build it | you build it (trivial) | you own it | native loads, no clobber | you own it |
| 3 mode-io/skill-manager | **no (global-only)** | yes (+ OpenCode) | **best** (data catalog + symlink & file codec) | crash-safe, reversible | CI + 61 tests, pre-1.0/private |
| 4 lijianru/skills-manager | yes (copy subset) | yes (native dir) | poor (hardcoded switch) | copy overwrites edits | no tests, bus-factor 1 |
| 5 skill-cli | best (`allow`/`deny`) | yes, via injection/pull (no enforcement) | OpenCode likely cheap; Copilot needs file-gen | store safe, delivery prompt-dependent | 227 tests but ~6h burst, unmaintained |
| 6 skills-mgr (Leonezz) | **yes (profiles + includes)** | yes (both scopes) | data-driven (`agents.toml`); Rust | **strongest** (SQLite, doctor, reversible, rollback) | 80 tests / CI / 1★ / HEAD ~5mo stale / no LICENSE file |
| 7 omrikais/sm | partial — deploys but no clean disable/swap (additive-only) | yes (symlink native) | poor (hardcoded cc\|codex) | **strong** (no-clobber, atomic, doctor, backups, rollback) | MIT / 84 tests / 4★ / HEAD fresh (2026-09-03); sustained activity unverified |
| 8 sklm | yes (config) | yes (project-only) | **data-driven (30 YAML)** | **unsafe (rmtree clobbers foreign)** | MIT / 184 tests / CI |
| 9 skillkit (rohitg00) | partial (pkg-mgr) | yes | data-driven 46 + `translate` | decent (skip-existing, scan) | Apache-2.0 / ~1537 tests / 1470★ |
| 10 openhub / skill-factory / GUIs | mixed | mixed | poor | mixed | see analysis |
| 11 Commercial product | unknown (trial) | yes (SkillReg/Packmind) | vendor-controlled | product feature | vendor-supported |
| 12 Extend a base (no fork) | add via wrapper | inherit | inherit | inherit | shared with upstream |
| 13 Fork/build | by design | inherit | by design | inherit | you co-own it |

The decisive columns are d1 (per-project), d4 (safe delivery), and d3 (cheap
extensibility). skills-mgr leads d1+d4 with data-driven d3; omrikais/sm leads d4
with symlink delivery but weak d3; skill-cli leads the selection model but has the
delivery caveat. No candidate also solves the file-based Copilot targets, so an
extension step (Option 12/13) remains eventual regardless.

## Detailed Analysis of Options

### 1. Do nothing / status quo

Keep maintaining each skill separately in each agent's directory by hand.

- Good, because it requires no new tool, no dependency, and no learning curve.
- Good, because there is zero risk from third-party code health or abandonment.
- Bad, because every skill is duplicated across agent directories and edits drift.
- Bad, because there is no per-project subset selection — the capability we want.
- Bad, because manual effort and error rate grow with the number of skills.

Mitigation of negatives: a naming convention and a checklist reduce drift, but do
not remove the duplication or provide per-project selection; the core problem
remains unsolved.

### 2. Manual workaround: hand-rolled script

Write a small in-house script that symlinks (or copies) a chosen subset from a
central store into each agent's **native** per-project location — `.claude/skills/`
for Claude Code, `.github/instructions/` for Copilot, etc. The agents already have
per-project mechanisms; this option just feeds them, so the day-one target
(per-project subset for Claude Code) may be nearly free.

- Good, because it is fully under our control, has no external dependency, and for
  the day-one case (Claude Code, native skills-dir) is trivial — which raises the
  bar every other option must clear.
- Good, because it uses each agent's native loading, so there is no enforcement/
  pull caveat and no schema translation for skills-dir agents.
- Bad, because we take on all maintenance, cross-platform edge cases (Windows
  junctions, synced folders), and correctness (collision handling, safe removal).
- Bad, because the file-based Copilot / Copilot CLI schema (`.instructions.md`
  with `applyTo`) and Cursor `.mdc` still have to be generated by us.
- Bad, because as it grows to cover the further agents it reinvents what the
  candidate tools already do.

Mitigation of negatives: keep it symlink-only and Claude/OpenCode-first. This is
the honest baseline for the day-one drivers — any adopted tool must justify itself
against "a symlink script into `.claude/skills/`"; a tool earns its place mainly
by carrying the later, harder file-based targets.

### 3. Adopt `mode-io/skill-manager`

A central content store with declarative per-agent binding profiles and symlink
adapters. Winner of the source evaluation, but it does not do per-project
selection.

- **Bad, because it has no per-project scope — failing driver 1.** All binding
  scopes point at global/home locations (`catalog.py:106-286`); no repository can
  activate a chosen subset.
- Good, because Claude Code works out of the box (d2), with OpenCode and Cursor,
  modeled natively (`catalog.py:139,207,172`).
- Good, because targets are declarative data (`catalog.py:93`) **and** it ships a
  frontmatter-rewriting codec for slash-commands (`codecs.py`) — both a symlink
  adapter and a file-generating adapter, the two shapes the wanted targets need.
  This makes it the strongest base for driver 3.
- Bad, because it does not target Copilot today (roadmap box, `README.md:405`).
- Good, because mutations are crash-safe and it has CI + 61 tests (d4–d5).
- Bad, because symlink delivery breaks on non-symlink-friendly locations unless
  the copy fallback is used; and the repo is pre-1.0, private, two authors.

Mitigation of negatives: mode-io is a strong *base* for Options 12–13, not a
day-one answer; its missing per-project scope is exactly what a wrapper/fork would
add. Pin/vendor the version.

### 4. Adopt `lijianru/skills-manager`

A Node CLI that copies a chosen subset into a hardcoded set of target dirs.

- Good, because it does driver 1 by copy: a checkbox picks skills
  (`link-manager.ts:55-70`) copied into a project dir / `process.cwd()`
  (`:142,171`); and Claude Code works out of the box into a native dir (d2).
- Bad, because its Copilot/Gemini paths are wrong (`link-manager.ts:122,162,113`)
  vs. the agents' real locations — nominal, likely non-functional.
- Bad, because targets are a hardcoded switch (`:82,105,145`); copy-with-overwrite
  clobbers local edits (fails d4); no tests, single author (fails d5).

Mitigation of negatives: treat target dirs as machine-managed and pin the version;
it is a weaker off-the-shelf per-project distributor than skills-mgr/omrikais-sm.

### 5. Adopt `VictorTomaili/skill-cli`

The strongest per-project *activation* model, and last round's lead — but with a
delivery-model caveat and a maintenance caveat.

- Good, because it does driver 1 cleanly: a project `skill.config` with
  `inherit`/`allow`/`deny` where `deny:["*"] + allow:[X]` yields "only X"
  (`config.js:78-113`).
- Good, because Claude Code is supported out of the box (d2) and the store is
  never clobbered (part of d4), with 227 tests and CI on 3 OS × 2 node versions.
- **Bad (delivery caveat, affects d2 and d4), because it puts nothing in the
  agent's skills directory.** It injects a bootstrap into the agent's instruction
  file and relies on the model *pulling* skills at runtime, with no enforcement
  (`agents-md.js:79-101`) — weaker and less verifiable than a native load. The
  newly found skills-mgr and omrikais/sm avoid this by delivering into native dirs.
- **Bad (health caveat, d5), because it is effectively unmaintained**: a single
  ~6-hour burst by one author, bus-factor 1. 227 tests show quality at a snapshot,
  not upkeep.
- Bad, because of the wanted targets it has only Claude Code (`paths.js:16-22`).
- Mixed on driver 3: OpenCode is plausibly a cheap injection-target add
  (`paths.js:16-22`, a spike hypothesis); only the file-based Copilot / Copilot CLI
  need a new generation mechanism.

Mitigation of negatives: a day-one **fallback** (not a co-candidate) for its
selection model, used only if the native-delivery tools (Option 6 or 7)
disappoint; pin/vendor, and confirm the pull behavior actually works (see
[Confirmation](#confirmation)).

### 6. Adopt `Leonezz/skills-mgr`

Rust CLI (plus Tauri GUI and MCP). Found in the landscape scan; source-verified at
HEAD `fded9c6`. The best architectural fit on d1+d4, but with real health and
toolchain caveats that stop it being an outright pick.

- Good, because it does driver 1 richly: per-project **profiles** with transitive,
  cycle-checked `includes` and a `base` (`profiles.rs:56-88`); `activate <profile>
  <project>` places only the resolved subset, and the DB tracks per-project active
  profiles (`placements.rs:229,306-308`), composable across profiles.
- Good, because Claude Code works out of the box at **both** project and global
  scopes (`presets.rs:9-13`) — d2.
- Good, because agents are data-driven (`config.rs:145-157` `agents.toml`) with an
  `agent add --project-path/--global-path` command (`main.rs:263-273`) — d3 by
  configuration, not code (presets are convenience shortcuts only).
- Good, because it has the **strongest safe delivery** of any candidate (d4):
  SQLite-tracked placements, `doctor` (`main.rs:524`), `check-conflicts`,
  ref-counted reversible deactivate that keeps shared skills
  (`placements.rs:338-354`), conflict-bail unless `--force`, rollback on copy
  failure (`:278-289`), and dry-run.
- Bad, because delivery is directory **copy** (`placements.rs:278`), not symlink,
  so every source edit needs a `refresh`/`replace` to propagate — added friction
  for a developer iterating on skills, versus a symlink that updates live.
- Bad (d5), because it is single-author, 1★, and **its HEAD `fded9c6` is dated
  2026-04-15 — ~5 months before the scan, so it may be dormant**; MIT is declared
  in `Cargo.toml:13` but there is **no LICENSE file** — confirm licensing before use.
- Bad, because it is **Rust**: for a Node/Python-oriented developer, extending or
  forking it later (Options 12–13) is a higher barrier than the TypeScript tools.
- Bad, because it does not emit Copilot's `.instructions.md` (`presets.rs:30` maps
  copilot to `.github/skills` only) — the file-based targets remain extension work.

Mitigation of negatives: confirm the MIT license (add/verify a LICENSE file with
upstream) and pin a commit; the copy-staleness is workable via `refresh`. It is a
day-one **co-candidate**, not a settled pick — the spike weighs its d1+d4 strength
against its staleness, licensing gap, and Rust toolchain.

### 7. Adopt `omrikais/skill-manager` (sm)

Node/TS CLI (`bin: sm`) plus MCP. Found in the landscape scan; source-verified at
HEAD `970fb64`. A *different* author from `mode-io/skill-manager`.

- **Partial on driver 1 — it fails the disable/re-select half.** It has per-project
  `.skills.json` with named profiles (`manifest.ts:7-59`) and delivers by
  **directory symlink into native agent dirs** (`src/fs/links.ts:19-66`) — d2
  without skill-cli's pull caveat. But profile switching is **additive-only**:
  `install --profile` deploys and never undeploys the prior set
  (`install.ts:35-57`), so you can activate a subset but **cannot cleanly swap or
  disable one** without a manual prune. Driver 1 explicitly requires per-repo
  enable/disable, so this is a gap in the #1 driver, not a footnote — a spike
  gating question.
- Good, because safe delivery is the strongest of the symlink tools (d4): no
  clobber (non-symlink targets are reported as conflicts and repair refuses to
  overwrite, `src/fs/links.ts:94-96,132-135`), atomic temp+rename (`src/fs/links.ts:32-35`),
  doctor, `sync --repair`, timestamped backups + restore, version history +
  non-destructive rollback (`versioning.ts:45-116`).
- Good on d5, and **fresher than skills-mgr**: HEAD `970fb64` dated 2026-09-03,
  clean MIT LICENSE file, 4★, dependabot, 84 test files. Honest caveat: *sustained*
  activity is unverifiable from a shallow clone — the verified claim is "recent
  HEAD", not "actively maintained".
- **Bad, because d3 is hardcoded**: deploy targets are a TypeScript `'cc' |
  'codex'` union (`src/fs/paths.ts:85`), so only Claude Code and Codex exist and
  adding OpenCode/Copilot is a source + type change, not configuration.
- Bad, because it does not emit Copilot's `.instructions.md`.

Mitigation of negatives: a good day-one choice *if* the additive-only prune gap on
driver 1 is acceptable and extensibility can wait; the hardcoded target set makes
it a poorer *base* for Options 12–13 than skills-mgr or mode-io. Day-one
co-candidate: strongest on d5-freshness and delivery safety, weaker on the d1
disable/swap gap and on d3.

### 8. Adopt `Auran0s/sklm`

Python CLI. Found in the landscape scan; source-verified at HEAD `0c29fb6`.

- Good, because it does driver 1 (central store `~/.sklm/store`, per-project
  `.sklm/sklm.yaml` tracking `resources` + activated `links`, re-flippable —
  `workspace.py:67-113`, `linking.py:14-52`).
- Good, because agents are the most **data-driven** of all: 30+ agents as YAML rows
  and a `GenericAdapter` that serves any `.<dir>/skills/` layout with zero code
  (`agents.yaml:1-63`, `generic.py:16-35`) — d3 by one YAML row for standard
  layouts. MIT, 184 tests, CI (d5 signals).
- **Bad, because delivery is unsafe (fails d4):** sync does `shutil.rmtree` on the
  target and removes any dir in the agent's skills path not in the linked set
  (`_sync.py:38-40,30-33`), destroying hand-authored skills and local edits, with
  no backup or conflict detection.
- Bad, because Claude Code is project-only (no user-level `~/.claude`), and Copilot
  is `.github/skills`, not `.instructions.md` (`github_copilot.py:29-30`).

Mitigation of negatives: the destructive sync is the disqualifier for a solo
developer with hand-authored skills; its data-driven agent table is worth studying
as a design reference for Options 12–13 even if the tool itself is not adopted.

### 9. Adopt `rohitg00/skillkit`

TypeScript monorepo CLI (`skillkit`/`sk`) on npm. Found in the landscape scan;
source-verified at HEAD `d2e5c34`. The healthiest project found.

- Good, because it is by far the most mature: Apache-2.0, ~1537 test assertions +
  e2e, CI, 1470★ (d5), and the strongest d3 machinery — a real 46-agent data table
  (`agent-config.ts`) plus a `translate` FormatTranslator that converts SKILL.md
  into per-agent formats.
- **Bad, because it is a package manager, not central-store subset selection
  (d1 partial):** `install owner/repo` clones and `cpSync`-copies a chosen subset
  into a project, and the `enabled` flag lives in each skill's own `.skillkit.json`
  (`config.ts:122-134`), so a shared skill's enable-state is global, not per-repo.
- Bad, because many of the 46 agents are config-only stubs rather than fully wired
  adapters (`agents/index.ts` wires a subset; the table is broader than the
  adapters).
- Bad, because Copilot output is the legacy `.github/copilot-instructions.md` only
  (`translator/formats/copilot.ts:198-207`), not `.instructions.md`.

Mitigation of negatives: not a fit for the per-project-subset model, but its
`translate` layer is the best existing reference for the file-based Copilot target;
worth mining in Options 12–13.

### 10. Adopt another surveyed tool

- **`24KaratAu/openhub`** — only OpenCode is real (`opencode-market_v2.py:171`);
  Claude Code/Cursor rows have no code; fake "success" when the binary is absent.
  Fails the day-one Claude Code driver.
- **`lexler/skill-factory`** — per-project by local copy, Claude-Code-only
  (`skills:13-14`), no extensibility path; really a skill-*authoring* factory whose
  authoring layer is worth harvesting separately.
- **Desktop-GUI cluster (landscape scan):** `xingkongliang/skills-manager`
  (4270★, MIT, 0 tests) and `jiweiyeah/Skills-Manager` (971★, 33 tests) are
  **Tauri GUIs with no headless surface** — no CLI bin, no MCP server; delivery
  logic lives in `src-tauri` commands invoked only from the webview. High stars
  but unusable for an automated per-project pipeline. Excluded on that basis.

Mitigation of negatives: none of these fits the headless per-project use case;
skill-factory's authoring layer is the only reusable piece.

### 11. Buy a commercial product

A commercial market exists (nascent, 2025–2026, no incumbent):

- **SkillReg** (skillreg.dev) — private SKILL.md registry across Claude Code,
  Codex, Cursor, Copilot; versioning, permissions, scanning. Paid SaaS.
- **Packmind** (packmind.com) — generates per-agent files (`.claude/rules`,
  `.cursor/rules`, `.github/instructions`, `AGENTS.md`) for several agents; OSS core
  plus paid enterprise.
- **Tessl** (tessl.io) — enterprise agent-enablement platform + skills registry.

- Good, because a vendor carries maintenance and cross-platform correctness;
  Packmind already emits the file-based `.github/instructions` shape Copilot needs.
- Bad, because none lists OpenCode or Copilot CLI, and none documents a per-project
  subset model (d1) — our top requirements are unconfirmed, now behind a paywall.
- Bad, because of cost, external dependency, and lock-in for a solo-dev workflow.

Mitigation of negatives: a short trial of SkillReg and Packmind would confirm
per-project support and OpenCode + Copilot CLI coverage; their marketing lists
neither, so temper expectations, but if one covers everything it removes the
extend/fork work.

### 12. Extend a base without forking

Consume an existing tool as an unmodified dependency and add a thin per-project
layer on top — distinct from a hard fork (Option 13) and a from-scratch script
(Option 2). Credible bases: `mode-io` (declarative targets, pluggable adapters) or
`skills-mgr` (data-driven agents, already per-project).

- Good, because it keeps upstream updates flowing (no rebase burden) while closing
  the remaining gaps (per-project for mode-io; Copilot file-gen for skills-mgr).
- Good, because the owned surface is small — a wrapper — lowering maintenance.
- Bad, because it depends on the base exposing stable extension points; mode-io is
  pre-1.0/private and skills-mgr is pre-1.0, so contracts may shift.
- Bad, because if the needed hook is missing, this collapses into a fork.

Mitigation of negatives: a spike confirms whether the chosen base exposes the
hooks a wrapper needs; if so, strictly cheaper than Option 13.

### 13. Fork / build

Hard-fork the strongest base and extend it to satisfy all five drivers. Needed
only if no off-the-shelf tool suffices and Option 12 proves infeasible. Candidate
bases, by what they already solve:

- **`skills-mgr`** — already per-project + data-driven agents + safe delivery; the
  fork adds Copilot `.instructions.md` generation and hardens health. Smallest gap
  to the full driver set.
- **`mode-io`** — best delivery/extensibility breadth and file codec; the fork adds
  a per-project scope + activation layer.
- **`skill-cli`** — best selection model; the fork rebuilds delivery into native
  dirs + adds targets.

- Good, because a fork covers all wanted targets *and* per-project selection by
  design.
- Good, because it removes the third-party dependency risk — we own the fork.
- Bad, because we take on long-term maintenance and must track upstream.
- Bad, because whichever base we pick, its missing capability is real design work,
  and Copilot's file-based model may not map cleanly onto a skills-directory
  abstraction.

Mitigation of negatives: prefer Option 12 first; fork only if it fails. Decide the
base with the spike named in [Open questions](#open-questions); `skills-mgr` now
looks like the smallest-gap base.

## Consequences

- Adopting a day-one tool now delivers per-project selection on Claude Code
  immediately. The landscape scan improved the options: native-delivery tools
  (skills-mgr, omrikais/sm) avoid skill-cli's runtime-pull enforcement risk.
- **Migration/throwaway cost is real.** The co-candidates use different
  selection/delivery models, so if the day-one tool is later replaced by a
  different extension base, its config investment is largely discarded and two
  tools may run briefly. Day-one value does not buy down this later cost.
- No candidate emits the file-based Copilot / Copilot CLI `.instructions.md` shape,
  so an extension step (Option 12/13) is unavoidable eventually regardless of the
  day-one pick.
- Symlink delivery (omrikais/sm, mode-io) needs care on non-symlink-friendly
  locations; copy delivery (skills-mgr, lijianru) needs a refresh step to avoid
  stale copies. Any solution must handle both delivery shapes for the full target
  set.
- The chosen tool becomes the owner of the agent skill/instruction locations; we
  must stop hand-editing them and treat the central store as the source of truth.
- If a spike shows the native symlink baseline (Option 2) covers the day-one need,
  adopting any tool now may be premature.
- Health remains a solo-developer risk, and it is asymmetric between the two
  co-candidates: `skills-mgr` has the better architecture (d1+d4) but a
  ~5-months-stale HEAD, only a declared-not-filed MIT license, and 1★;
  `omrikais/sm` is fresh (HEAD 2 days old), cleanly MIT-licensed, and 4★, but
  weaker on d1 (additive-only) and d3 (hardcoded). The only high-health project
  (skillkit) is the wrong shape. Pinning/vendoring is mandatory whichever is
  chosen.
- Deferring the whole decision (Option 1) leaves the duplication and
  per-project-drift problem unsolved and grows the eventual migration cost.

## Confirmation

The decision will be considered correctly implemented when, in a fresh project,
selecting a subset of skills from the central store makes exactly that subset —
and no more — actually usable by **Claude Code** (the day-one target), and later
by OpenCode, GitHub Copilot, and Copilot CLI, with no manual per-agent duplication
and no clobbered local edits.

"Actually usable" must be checked against the delivery model, because it differs
by tool:

- For **skills-directory / file delivery** (Option-2 native baseline, lijianru,
  mode-io, skills-mgr, omrikais/sm, Copilot file generation): inspect the agent's
  target
  location and confirm it holds exactly the selected subset, and that a sync does
  not delete unrelated skills (the sklm failure mode).
- For **injection/pull delivery** (skill-cli): the skills directory stays empty by
  design, so confirm end-to-end that a live agent session actually loads the
  selected skills and none of the deselected ones — selection correct on disk but
  unreliable at runtime does **not** pass.

Nice-to-have agents (Cursor, pi, Gemini/antigravity, Codex) are a bonus, not a
pass/fail condition.

## Open questions

- **Day-one spike (the immediate question).** Compare `skills-mgr` and `omrikais/sm`
  hands-on against d1–d5 in a real repo, with the **Option-2 native symlink baseline
  as a control arm** (does a tool beat a symlink into `.claude/skills/`?) and
  `skill-cli` as a fallback if both native-delivery tools disappoint. Rather than a
  fixed preference order, decide by resolvable gates, in driver priority — each is a
  question the spike answers, sometimes via a workaround, not the tool's current
  state alone:
  - **d1 gate:** can you activate AND cleanly disable/swap a subset per repo,
    including a small prune workaround if needed? (`skills-mgr` clears it natively;
    `omrikais/sm` is additive-only today, so the spike must confirm a prune is
    feasible.)
  - **d4 gate:** does delivery avoid clobbering hand-authored/edited skills, and is
    it reversible? (both clear it; sklm fails, hence excluded.)
  - **health gate:** can the license be confirmed and is the project not
    effectively dormant? (`skills-mgr` needs its declared MIT confirmed with
    upstream and its ~5-month-stale HEAD weighed; `omrikais/sm` already has a clean
    MIT LICENSE and a fresh HEAD.)
  Pick whichever tool clears all three gates after the spike; if both do, prefer the
  one whose weakest driver is least costly to live with. **If neither clears all
  three** (e.g. no feasible prune AND license unconfirmable), fall through to the
  `skill-cli` fallback if its runtime pull proves reliable, else the Option-2
  native baseline. Do not pre-commit to a name here.
- **License confirmation.** `Leonezz/skills-mgr` declares MIT in `Cargo.toml` but
  ships no LICENSE file; confirm with upstream before adoption.
- **Extend vs. fork, and which base (deferred until the further agents are
  needed).** Does the chosen base expose stable hooks for a no-fork wrapper
  (Option 12)? If not, fork (Option 13) — skills-mgr now looks the smallest-gap
  base (already per-project + data-driven agents).
- **Copilot delivery feasibility.** Can a file-generating adapter emit
  `*.instructions.md` into `.github/instructions/` and `~/.copilot/instructions/`
  (honoring `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`)? `mode-io`'s slash-command codec
  and `skillkit`'s `translate` layer are the best references.
- **Commercial trial.** Do SkillReg or Packmind do per-project subset selection and
  cover OpenCode + Copilot CLI? Their marketing lists neither, so likely not — but
  a cheap trial settles it.

## More Information

- Source-code evaluation of the original five tools:
  [skill-manager-evaluation.md](skill-manager-evaluation.md).
- Evaluation prompt/method:
  [skill-manager-evaluation-prompt.md](skill-manager-evaluation-prompt.md).
- Prior background survey:
  [llm_agent_skill_managers_research.md](llm_agent_skill_managers_research.md).
- Landscape scan of six further tools, source-verified with pinned HEADs and
  per-driver scorecards:
  [skill-manager-landscape-scan-2026-09-05.md](skill-manager-landscape-scan-2026-09-05.md).
- Method references: MADR (https://adr.github.io/madr/), Michael Nygard's ADRs
  (https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
  arc42 section 9 (https://docs.arc42.org/section-9/).
