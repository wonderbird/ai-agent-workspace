# 002: Centralizing Skills Across Coding Agents

- Status: Accepted
- Date: 2026-09-04 (proposed), 2026-09-06 (decided)

## Executive Summary

**Problem.** We maintain skills, prompt rules, and MCP configs that each coding agent
loads from its own directory, so every skill is duplicated per agent and there is no
single place from which a project activates the subset it needs.

**Decision (2026-09-06).** Adopt **`omrikais/skill-manager` (`sm`)** as the skill
manager — it installs a per-project subset from a central store into both
`.claude/skills` and the universal `.agents/skills`, covering every wanted agent
(Claude Code, OpenCode, GitHub Copilot incl. Copilot CLI, and others) with no file
generation. Use **`vercel-labs/skills` (`npx skills find`)** only to *discover*
skills. Pin and vendor `sm`.

**Why it fits the drivers** (priority order): it does **per-project activate/disable**
(`.skills.json` manifest + TUI); **Claude Code works out of the box**; **further
agents come for free** because they read `.agents/skills`; **delivery is safe and
reversible** (no-clobber symlinks, backups); the only real cost is `sm`'s
**solo-maintainer health**, mitigated by pin + vendor with a hand-rolled symlink
script as the exit path.

See [Decision Outcome](#decision-outcome) for the full rationale and scorecard, the
[Detailed Analysis of Options](#detailed-analysis-of-options) for the alternatives
weighed, and [docs/research/skill-manager/](../research/skill-manager/README.md) for
the source-verified evidence.

## Context and Problem Statement

We maintain a growing set of agent skills, prompt rules, and MCP server configs.
We want them to live in one canonical central store and be **selected per
project**: when starting a new repository, activate only the subset of skills
that repository needs, and nothing else. The central store is the single source
of truth; each project declares its own view onto it.

The obstacle is that each agent loads skills from its own target directory, though
most now converge on the SKILL.md skills-directory standard. The authoritative
per-agent paths (from `vercel-labs/skills` `src/agents.ts`, cross-checked with each
vendor's docs) are:

| Agent | Project dir | Global/personal dir |
| :--- | :--- | :--- |
| Claude Code | `.claude/skills` | `~/.claude/skills` (or `$CLAUDE_CONFIG_DIR`) |
| OpenCode | `.agents/skills` | `~/.config/opencode/skills` |
| GitHub Copilot (+ Copilot CLI) | `.agents/skills` (also `.github/skills`, `.claude/skills`) | `~/.copilot/skills` (or `~/.agents/skills`) |
| Antigravity (Gemini) | `.agents/skills` | `~/.gemini/antigravity/skills` |
| Cursor | `.agents/skills` | `~/.cursor/skills` |
| Codex | `.agents/skills` | `~/.codex/skills` (or `$CODEX_HOME`) |
| pi | `.pi/skills` | `~/.pi/agent/skills` |

The decisive fact is that **`.agents/skills` is a universal project directory**: at
project level OpenCode, GitHub Copilot (incl. Copilot CLI), Antigravity, Cursor, and
Codex all read it; only **Claude Code (`.claude/skills`)** and **pi (`.pi/skills`)**
use a dedicated project dir. So delivering a project's skills into `.agents/skills`
*plus* `.claude/skills` covers every wanted agent with no file generation — exactly
what `omrikais/sm` does. (Copilot's legacy `.github/instructions/*.instructions.md`
and `.github/copilot-instructions.md` are a *separate custom-instructions* feature,
not the skills mechanism —
[GitHub docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills).)

The wanted agents thus share **one delivery shape** a symlink can serve; what remains
is only that each looks in a slightly different path. Without a central mechanism,
every skill is duplicated per agent, edits drift, and there is no single point of
selection.

The target set for this decision, elicited from the stakeholder over two
interviews, is tiered by *when* each target must work:

- **Required out of the box:** Claude Code.
- **Not required day one:** OpenCode, GitHub Copilot, GitHub Copilot CLI. Note that
  because all three read a SKILL.md skills directory (Copilot via its agent-skills
  `.agents/skills`/`.claude/skills` path), a tool that delivers into `.agents/skills`
  covers them for free — no per-agent extension work is needed for these.
- **Nice to have (same skills-directory delivery):** Cursor, Codex, and Antigravity
  (all via `.agents/skills`), plus pi (`.pi/skills`).

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
14. **Adopt `vercel-labs/skills` (`npx skills`)** — per-project canonical store +
    symlink delivery + data-driven agents + by far the healthiest project (surfaced
    by the packaging-standards research). See
    [Detailed Analysis](#14-adopt-vercel-labsskills-npx-skills).

## Decision Outcome

**Chosen: adopt `omrikais/skill-manager` (`sm`) as the day-one skill manager, and
use `vercel-labs/skills` (`npx skills find`) only as a skill-discovery aid.** Pin
and vendor `sm`; use `vercel-labs/skills` unpinned since it is non-critical
(discovery only). This was decided on 2026-09-06 after the hands-on spike recorded
in [hands-on-spike.md](../research/skill-manager/hands-on-spike.md).

**Pinned version:** record the exact `sm` commit vendored, once installed. The
landscape scan pinned HEAD `970fb64` (2026-09-03) as the source-verified reference
(Option 7); confirm and record the actual in-use commit here at vendoring time.

### Why this over the pre-spike lead

The pre-spike analysis (see [Prior Recommendation](#prior-recommendation-pre-spike-analysis))
made `vercel-labs/skills` the day-one lead on health (d5) with `omrikais/sm` a
challenger weakened by an assumed additive-only d1 gap and a hardcoded `cc|codex`
target set. The spike changed both findings:

- **`vercel-labs/skills` fails the reconstruction/restore path the chosen workflow
  depends on (d1/d4).** A fresh `npx skills add` *does* install into `.claude/`, so
  first-time delivery works; what fails is *reconstruction* — the chosen workflow
  does not commit `.claude/`/`.agents/` and rebuilds them after clone, and vercel's
  project restore (`experimental_install`) is flagged *experimental*, re-links only
  into `.agents/`, never `.claude/`, and cannot restore global skills at all. A store
  you cannot reliably reconstruct into Claude Code's native dir does not meet the
  day-one workflow. (The stakeholder wrote a `restore-claude-skills` bash script to
  bridge the `.agents/`→`.claude/` gap, confirming it is real.)
- **`omrikais/sm` meets the need (d1, d2, d4).** In the spike it installed local and
  global skills into both `.claude/skills/` and `.agents/skills/` (the latter covering
  OpenCode and the other SKILL.md-standard harnesses — note this observed behavior
  differs from the pre-spike source read of a hardcoded `cc|codex` target set; see
  Option 7 and [Open questions](#open-questions) for the reconciliation), and tracks
  the per-project set in `.skills.json`. On the pre-spike "additive-only" concern,
  two distinct disable paths exist and should not be conflated: (a) **per-skill
  disable via the `sm` TUI removes the skill from the local dirs** — attested by the
  stakeholder in the decision-session interview (2026-09-06), not yet pinned to a
  source line and not written up in the spike doc, so it is a citation gap to close;
  and (b) the spike doc's manual `rm -rv .claude/skills/*; .agents/skills/*` +
  `sm install` (spike doc §"Usage") is a *different* operation — pruning
  globally-linked skills that are not in the project manifest, because `sm install`
  is additive. Driver 1's per-project activate+disable is met **via path (a)**; the
  residual open item is **manifest** add/remove granularity (see
  [Open questions](#open-questions)). Profiles act as project templates.

### How the workflow runs

1. Discover a skill with `npx skills find` / `npx skills find "<name>"` (vercel).
2. Install it via `sm install <owner/repo> "<skill>"`; the source lands in
   `~/.skill-manager/sources.json` + `~/.skill-manager/sources/<slug>/`.
3. Link it into the project (and/or globally) with the `sm` TUI.
4. Persist the project's skill set: `rm -f .skills.json && sm init --from-current`,
   then commit `.skills.json`. The `.claude/` and `.agents/` dirs are **not**
   committed; they are reconstructed after clone with `sm install`.

Operational constraints observed and accepted: `sm install` adds but never deletes
(prune by disabling in the TUI, or by clearing the skill dirs and re-installing);
`sm install` also links the manifest's *global* skills, which is usually desirable;
and skill repositories are distinguished **by repo name only, not owner**, so repo
names must be unique across sources. Because `vercel find` widens the pool of
candidate repos, treat this as a guardrail, not just an accepted constraint: before
`sm install`, check `~/.skill-manager/sources.json` for a name collision, and adopt
a naming/prefix convention for vendored sources so two same-named repos from
different owners cannot silently shadow each other.

### Driver scorecard for the decision

| Driver | Verdict for `sm` (+ vercel `find`) |
| :--- | :--- |
| d1 per-project subset | Met in practice. Activate per project + per-skill disable via the `sm` TUI (interview-attested 2026-09-06; source-pin + write-up is an open citation gap); `.skills.json` manifest. Residual to confirm: no direct manifest add/remove granularity — see open questions. |
| d2 Claude Code OOTB | Met. Native delivery into `.claude/skills/`. |
| d3 cheap extensibility | Largely satisfied by `.agents/skills` delivery. OpenCode, GitHub Copilot (incl. Copilot CLI, via its agent-skills path), and other SKILL.md harnesses read that dir, so they are covered without per-agent work — no `.instructions.md` generation is required (the former file-based-Copilot gap is retired). Coverage to be double-checked; any non-skills-directory target would still be Option 12/13 work. |
| d4 safe delivery | Met. Symlink into native dirs, no-clobber, backups, reversible (per landscape scan + spike). |
| d5 health | Solo-maintainer risk accepted, mitigated by pin + vendor of `sm`; vercel `find` is non-critical. |

The migration seam (Option 12/13) is unchanged and deferred; see
[Open questions](#open-questions). The previously separate "file-based Copilot
target" is no longer a distinct concern — Copilot reads the agent-skills directory.

## Prior Recommendation (pre-spike analysis)

Superseded by the [Decision Outcome](#decision-outcome). Before the hands-on spike,
this ADR did not crown a winner: it treated `vercel-labs/skills` as the day-one
health leader, with `Leonezz/skills-mgr` and `omrikais/sm` as challengers and a
hand-rolled symlink script (Option 2) as the control. The spike reversed that —
`vercel-labs/skills` cannot reconstruct project skills into `.claude/` — and selected
`omrikais/sm`. The per-option driver comparison that informed the pre-spike view
lives in [Detailed Analysis of Options](#detailed-analysis-of-options) and the
source-verified [research docs](../research/skill-manager/README.md); the full
pre-spike prose and driver matrix remain in this file's git history.

## Detailed Analysis of Options

Full source-verified evaluations (pinned HEADs, test counts, delivery mechanics)
live in the [research docs](../research/skill-manager/README.md); each surveyed tool
is summarised to one verdict here. Correcting an earlier draft: GitHub Copilot reads
the agent-skills skills directory (`.agents/skills` / `.github/skills`), so targeting
a skills dir *covers* Copilot — only emitting the legacy
`.github/copilot-instructions.md` is the outdated shape.

### 1. Do nothing / status quo

Maintain each skill by hand per agent. No dependency and no third-party health risk,
but the duplication and the absence of per-project selection are exactly the problem
to solve. Rejected.

### 2. Manual workaround: hand-rolled script

A small in-house script that symlinks a chosen subset from a central store into
`.claude/skills` and the universal `.agents/skills` (which covers OpenCode, Copilot,
Cursor, Codex, Antigravity). Trivial for the day-one case and fully under our
control, so it is the **baseline every tool must beat** — and the exit path if `sm`
is abandoned. Cost: we own cross-platform correctness (Windows junctions, collision
handling, safe removal).

### 3. Adopt `mode-io/skill-manager`

Best extensibility base (declarative targets + symlink/codec adapters, crash-safe,
CI + 61 tests) but **global-only — no per-project scope, failing driver 1**. A
candidate base for Options 12/13, not a day-one answer.
[source-code-evaluation.md](../research/skill-manager/source-code-evaluation.md).

### 4. Adopt `lijianru/skills-manager`

Per-project by copy, but copy-with-overwrite clobbers local edits (fails d4),
hardcoded/incorrect target paths, no tests, bus-factor 1. Weak.
[source-code-evaluation.md](../research/skill-manager/source-code-evaluation.md).

### 5. Adopt `VictorTomaili/skill-cli`

Cleanest allow/deny per-project selection model and 227 tests, but delivers by
**runtime pull** (injects a bootstrap into the instruction file, writes nothing to
the skills dir, no enforcement) and is effectively unmaintained (one ~6h burst).
Day-one **fallback** only, if native-delivery tools disappoint.
[source-code-evaluation.md](../research/skill-manager/source-code-evaluation.md).

### 6. Adopt `Leonezz/skills-mgr`

Strong challenger: best architecture on d1 (per-project profiles with inheritance)
and d4 (SQLite-tracked, reversible, rollback, doctor), data-driven agents. Against
it: Rust (higher extension barrier for a Node/Python developer), copy delivery (needs
a `refresh` after each source edit), and a ~5-months-stale single-author HEAD
(`fded9c6`) with MIT declared in `Cargo.toml` but no LICENSE file. Smallest-gap base
should a fork ever be needed.
[landscape-scan.md](../research/skill-manager/landscape-scan.md).

### 7. Adopt `omrikais/skill-manager` (sm)

**Chosen.** Node/TS CLI (`sm`) + MCP; source-verified at HEAD `970fb64`. Symlinks a
per-project `.skills.json` subset into `.claude/skills` **and** `.agents/skills`, so
it covers Claude Code plus every `.agents/skills` agent (OpenCode, Copilot incl.
Copilot CLI, Cursor, Codex, Antigravity) with no file generation. Safe reversible
delivery (no-clobber, atomic, backups, rollback); per-project activate plus TUI
disable. Health: fresh MIT HEAD, 84 tests, but solo-maintainer (mitigated by pin +
vendor). Two items to confirm — manifest add/remove granularity, and `.agents`
coverage vs the pinned-HEAD `cc|codex` source read — are tracked in
[Open questions](#open-questions). Full rationale in
[Decision Outcome](#decision-outcome); evidence in
[landscape-scan.md](../research/skill-manager/landscape-scan.md).

### 8. Adopt `Auran0s/sklm`

Data-driven 30-agent table and per-project selection, but **disqualified on safety**:
sync `rmtree`s the target and deletes unrelated skills (fails d4).
[landscape-scan.md](../research/skill-manager/landscape-scan.md).

### 9. Adopt `rohitg00/skillkit`

Healthiest project (Apache-2.0, ~1537 tests, 1470★, 46-agent table with a `translate`
layer) but **wrong shape**: a package manager whose enable-state is per-skill, not
per-repo, so it is not central-store subset selection.
[landscape-scan.md](../research/skill-manager/landscape-scan.md).

### 10. Adopt another surveyed tool

`24KaratAu/openhub` (fake-success installs, OpenCode-only), `lexler/skill-factory`
(Claude-only skill-*authoring* tool), and the Tauri desktop GUIs
`xingkongliang/skills-manager` / `jiweiyeah/Skills-Manager` (GUI-only, no CLI/MCP) —
none fits the headless per-project use case; only skill-factory's authoring layer is
worth harvesting.
[source-code-evaluation.md](../research/skill-manager/source-code-evaluation.md),
[landscape-scan.md](../research/skill-manager/landscape-scan.md).

### 11. Buy a commercial product

SkillReg, Packmind, and Tessl exist (nascent market). A vendor carries maintenance,
but none documents a per-project subset model or OpenCode/Copilot-CLI coverage, and
all add cost and lock-in. Kept as a dormant future option (see
[Open questions](#open-questions)).

### 12. Extend a base without forking

Wrap an unmodified base tool with a thin per-project layer. Deferred: with `sm`
covering the wanted agents via `.agents/skills`, no extension is needed today. If a
future non-skills-directory target appears, a wrapper over a data-driven base is the
cheaper path than a fork — provided the base exposes stable hooks.

### 13. Fork / build

Hard-fork a base to satisfy all drivers. Needed only if no tool suffices and Option
12 is infeasible; `skills-mgr` (already per-project + data-driven agents + safe
delivery) is the smallest-gap base. Removes third-party risk at the cost of long-term
maintenance. Prefer Option 12 first.

### 14. Adopt `vercel-labs/skills` (`npx skills`)

**Kept as a discovery aid** (`npx skills find`), not the manager. Best skill search
and the healthiest project (MIT, CI, active commits; ~30k★ web-observed 2026-09-05,
though PR merges are single-gated). Rejected as the manager because its project
restore is experimental — it re-links only `.agents/`, not `.claude/`, and cannot
restore global skills — so it fails reconstruction; and its "central store" is a
distribution (package-manager) model, not a single local store.
[vercel-labs-scorecard.md](../research/skill-manager/vercel-labs-scorecard.md).

## Consequences

- Adopting `sm` delivers per-project selection immediately — into `.claude/skills`
  for Claude Code and `.agents/skills` for the other agents — via native symlink
  delivery, avoiding skill-cli's runtime-pull enforcement risk.
- **Migration/throwaway cost is real.** If `sm` is later replaced by a different
  base (a wrapper or fork, Options 12/13), its `.skills.json`/config investment is
  largely discarded and two tools may run briefly; the committed manifest and the
  Option-2 symlink baseline limit the blast radius.
- The wanted agents (Claude Code, OpenCode, GitHub Copilot incl. Copilot CLI) all
  read the SKILL.md skills-directory standard, and Copilot's agent-skills feature
  reads `.agents/skills`, so `.agents/skills` delivery covers them with no file
  generation. An extension step (Option 12/13) is therefore only needed for a future
  target that is *not* a skills-directory agent — not for Copilot, as an earlier
  draft assumed.
- Symlink delivery (omrikais/sm, mode-io) needs care on non-symlink-friendly
  locations; copy delivery (skills-mgr, lijianru) needs a refresh step to avoid
  stale copies. Any solution must handle both delivery shapes for the full target
  set.
- The chosen tool becomes the owner of the agent skill/instruction locations; we
  must stop hand-editing them and treat the central store as the source of truth.
- If a spike shows the native symlink baseline (Option 2) covers the day-one need,
  adopting any tool now may be premature.
- Health remains a solo-maintainer risk for the adopted `omrikais/sm` (fresh HEAD,
  cleanly MIT-licensed, but sustained activity unverifiable) and for
  `vercel-labs/skills` (single merger; no merges Jul–Sep 2026). **Accepted
  mitigation:** pin *and* vendor `sm`; use `vercel-labs/skills` unpinned since it is
  non-critical (discovery only). If `sm` is abandoned, its delivery is plain symlinks
  into native dirs, so the Option-2 hand-rolled script reproduces the core behavior
  as an exit path.
- Deferring the whole decision (Option 1) leaves the duplication and
  per-project-drift problem unsolved and grows the eventual migration cost.
- **Keep the central store SKILL.md-native to preserve a distribution path.** The
  store already uses the `agentskills.io` SKILL.md standard, and every serious
  candidate consumes it. Staying native keeps open — without committing to it now —
  a future team-scale distribution path via **Agent Skills as OCI artifacts**
  (`application/vnd.agent-skills.skill.v1`, distributable through any OCI registry
  with Sigstore/Cosign signing). This is enterprise supply-chain machinery, out of
  scope for a solo developer today; the only present-day consequence is to avoid a
  proprietary store format that would foreclose it. The **Agent Packaging Standard
  (APS)** targets whole autonomous agents/sub-agents run outside IDEs — a different
  problem than per-project skill selection — and is parked as not applicable.

## Confirmation

The decision is correctly implemented when, in a fresh project, selecting a subset
of skills from the central store makes exactly that subset — and no more — actually
usable by **Claude Code** (the day-one target), and later by OpenCode, GitHub
Copilot, and Copilot CLI, with no manual per-agent duplication and no clobbered
local edits.

Because the chosen delivery is `omrikais/sm` (symlink into native dirs) with
`vercel-labs/skills` used only for discovery, confirmation exercises the `sm`
workflow specifically — the contested d1 loop and the reconstruction path the
"don't-commit-the-dirs" decision depends on. Each step below marks what the spike
already **observed** versus what remains a **formal check to run** before treating
the decision as fully verified (the spike was exploratory, not a scripted acceptance
run, so the load-bearing checks are re-listed to be repeated deliberately):

1. **Activate a subset.** From the central store, link a chosen set into the project
   via `sm`; inspect `.claude/skills/` **and** `.agents/skills/` and confirm each
   holds exactly the selected subset. *Spike observed:* `sm` delivered into both
   `.claude/` and `.agents/`. *To formalise:* record which target populates each dir
   (re-checks the d3 `.agents/` coverage claim).
2. **Disable/swap.** Using the `sm` TUI, disable one skill and confirm it is gone
   from **both** native dirs, and that unrelated hand-authored skills are untouched
   (guards the additive-only / sklm `rmtree` failure modes). *Decision-session
   observed (interview-attested):* the TUI disable removed the skill from the local
   dirs. *To
   formalise:* re-run and confirm removal from both dirs plus non-clobber of unrelated
   skills, and pin the behavior to a source line. This is the load-bearing d1 check.
3. **Persist + reconstruct.** Run `rm -f .skills.json && sm init --from-current`,
   commit `.skills.json`, then in a clean clone (with `.claude/`/`.agents/` absent)
   run `sm install` and confirm the exact subset — local *and* the intended global
   skills — is rebuilt into `.claude/skills/`, not only `.agents/skills/` (the exact
   gap on which `vercel-labs/skills` was rejected). *Spike observed:* the
   persist+`sm install` reconstruction workflow, into `.claude/` as well as `.agents/`
   (the symmetric success vercel lacked). *To formalise:* exercise it from a truly
   clean clone and confirm global-skill reconstruction explicitly.
4. **Collision guard.** Confirm the repo-name-uniqueness guardrail: two same-named
   repos from different owners do not silently shadow each other in
   `~/.skill-manager/sources.json`. *Not yet exercised — prospective check.*

Later targets (OpenCode, GitHub Copilot, Copilot CLI) reuse step 1's inspection at
their own dirs when they are added; because Copilot's agent-skills feature reads
`.agents/skills`, confirming that dir already exercises it — no `.instructions.md`
generation is required. Nice-to-have agents (Cursor, pi, Gemini/antigravity, Codex)
are a bonus, not a pass/fail condition.

Superseded delivery models — vercel-labs/skills distribution/registry-pull and
skill-cli injection/pull — are no longer the chosen path; their confirmation
recipes are archived in the git history of this file and omitted here.

## Open questions

- **Day-one spike — RESOLVED (2026-09-06).** The spike was run; it adopted
  `omrikais/sm` + `vercel-labs/skills` `find` (see [Decision Outcome](#decision-outcome)).
  `vercel-labs/skills` lost the delivery role because its project restore is
  experimental (`.agents/` only, no `.claude/`, no global). The original spike brief
  is preserved below for context.
- **Manifest add/remove limitation — evaluate.** `sm` appears to offer no direct
  way to add or remove individual skills in a project's `.skills.json`; the observed
  workaround is `rm -f .skills.json && sm init --from-current`. The stakeholder is
  unsure whether a direct manifest-edit feature was missed. Confirm before
  treating this as a real limitation.
- **d3 coverage double-check + source reconciliation.** The spike observed `sm`
  writing to both `.claude/skills/` and `.agents/skills/`, but the pinned-HEAD source
  read (Option 7, `src/fs/paths.ts:85`) says targets are a hardcoded `cc|codex` union.
  Reconcile these: at the installed version, confirm which targets `sm` actually writes
  (does `.agents/skills/` get populated, and via which target?), and verify that
  coverage reaches the wanted SKILL.md harnesses (OpenCode et al.). If coverage is
  insufficient, revisit extensibility (Option 12/13).
- ~~**Day-one spike (the immediate question, original brief).**~~ Compare
  `vercel-labs/skills` (lead), `skills-mgr`, and `omrikais/sm` hands-on against
  d1–d5 in a real repo, with the
  **Option-2 native symlink baseline as a control arm** (does a tool beat a symlink
  into `.claude/skills/`?) and `skill-cli` as a fallback. For `vercel-labs/skills`
  the spike must also answer a model-fit gate: **can the canonical store be realised
  as a private git skills repo / npm package the projects `add` from**, and does
  that source-repo shape satisfy the "one central store" intent (it is a
  distribution model, not a local symlink-select store)? Rather than a fixed
  preference order, decide by resolvable gates, in driver priority — each is a
  question the spike answers, sometimes via a workaround, not the tool's current
  state alone:
  - **d1 gate:** can you activate AND cleanly disable/swap a subset per repo,
    including a small prune workaround if needed — and, for `vercel-labs/skills`,
    does the central-store-as-source-repo shape satisfy the single-store intent?
    (`skills-mgr` clears both natively; `omrikais/sm` is additive-only today, so the
    spike must confirm a prune is feasible; `vercel-labs/skills` clears the mechanics
    but must clear the store-shape question.)
  - **d4 gate:** does delivery avoid clobbering hand-authored/edited skills, and is
    it reversible? (all three clear it; sklm fails, hence excluded.)
  - **health gate:** can the license be confirmed and is the project not
    effectively dormant? (`skills-mgr` needs its declared MIT confirmed with
    upstream and its ~5-month-stale HEAD weighed; `omrikais/sm` already has a clean
    MIT LICENSE and a fresh HEAD; `vercel-labs/skills` has verified MIT + active
    cadence, but **re-confirm the ~30k★/issue counts live** since those are
    web-observed, not clone-derived.)
  Pick whichever tool clears all three gates after the spike; if more than one does,
  prefer the one whose weakest driver is least costly to live with (e.g. weigh
  `vercel-labs/skills`'s re-sync tax and store-shape against `skills-mgr`'s literal
  d1 fit but staler/unlicensed health). **If none clears all three** (e.g. no
  feasible prune AND license unconfirmable AND store-shape unacceptable), fall
  through to the `skill-cli` fallback if its runtime pull proves reliable, else the
  Option-2 native baseline. Do not pre-commit to a name here.
- **License confirmation (moot — not adopted).** `Leonezz/skills-mgr` declares MIT
  in `Cargo.toml` but ships no LICENSE file; this only matters if it is ever
  reconsidered. `omrikais/sm` (adopted) ships a clean MIT LICENSE file.
- **Extend vs. fork, and which base (deferred until the further agents are
  needed).** Does the chosen base expose stable hooks for a no-fork wrapper
  (Option 12)? If not, fork (Option 13) — skills-mgr now looks the smallest-gap
  base (already per-project + data-driven agents).
- **Copilot delivery — resolved (no longer a gap).** Copilot's agent-skills feature
  reads the SKILL.md skills-directory standard, including `.agents/skills`
  ([GitHub docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)),
  so `.agents/skills` delivery covers it with no `.instructions.md` generation. Only
  confirm that Copilot picks up `.agents/skills` in practice; the legacy
  file-generating-adapter question is dropped.
- **Commercial trial (dormant, kept as a future option).** A working OSS solution
  (`sm` + vercel `find`) is now in hand, so no trial is planned. Kept on record in
  case per-project subset + OpenCode + Copilot CLI coverage is ever wanted from a
  vendor: do SkillReg or Packmind do per-project subset selection and cover OpenCode
  + Copilot CLI? Their marketing lists neither, so likely not — but a cheap trial
  would settle it.
- **Distribution path (future, not day-one).** If the store ever needs signed,
  versioned team-scale distribution, does packaging SKILL.md folders as OCI
  artifacts (see the [ThomasVitale spec](https://github.com/ThomasVitale/agents-skills-oci-artifacts-spec)
  and `agentskills/agentskills` discussion #292) + Cosign fit the chosen day-one
  tool, or is it a separate layer? Out of scope until team-scale is real.

## More Information

All supporting research (the spike, the source-code evaluation, the landscape scan,
the vercel-labs scorecard, the packaging-standards review, and the superseded initial
survey) lives in
[docs/research/skill-manager/](../research/skill-manager/README.md) — that folder's
README is the index, with reading order, per-document status, and freshness.

- Method references: MADR (https://adr.github.io/madr/), Michael Nygard's ADRs
  (https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
  arc42 section 9 (https://docs.arc42.org/section-9/).
