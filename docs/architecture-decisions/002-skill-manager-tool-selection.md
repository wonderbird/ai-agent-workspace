# 002: Centralizing Skills Across Coding Agents

- Status: Accepted
- Date: 2026-09-04 (proposed), 2026-09-06 (decided)

## Executive Summary

This document records how to centralize skill definitions, prompt rules, and MCP
configuration in one store and select a per-project subset of them across our
coding agents. Each agent loads skills from a different directory with a different
schema, so a skill has to be maintained several times and there is no single place
from which a project can pick the subset it needs. This ADR frames the problem,
sets the decision drivers, and evaluates the realistic options — from doing
nothing, through a hand-rolled script, to adopting one of the surveyed open-source
tools, buying a product, or extending/forking a base. **The decision is now made
(2026-09-06), after a hands-on spike.** The stakeholder adopted
**`omrikais/skill-manager` (`sm`)** as the day-one skill manager and uses
**`vercel-labs/skills` (`npx skills find`)** only as a discovery aid. The spike
that settled this is recorded in
[hands-on-spike.md](../research/skill-manager/hands-on-spike.md);
see [Decision Outcome](#decision-outcome). The body below preserves the full option
analysis that led here.

A source-code evaluation of five tools underpins the early analysis; see
[source-code-evaluation.md](../research/skill-manager/source-code-evaluation.md). The drivers were then
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
  limited `skill-cli`. (This "lead is contested between these two" framing is
  superseded below: a later review surfaced `vercel-labs/skills`.)
- **The wanted targets now share one delivery shape.** Claude Code, OpenCode, pi,
  Antigravity, **and GitHub Copilot (including the Copilot CLI)** all use the SKILL.md
  **skills-directory** standard (symlink-friendly). Copilot's agent-skills feature
  reads `.github/skills`, `.claude/skills`, or `.agents/skills`
  ([GitHub docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)),
  so it is served by the same `.agents/skills` delivery — the earlier "file-based
  `.instructions.md`" framing is superseded, and no file generation is required.
- **Commercial products exist** (SkillReg, Packmind, Tessl); none confirmed for
  per-project subset + OpenCode + Copilot CLI. See [Option 11](#11-buy-a-commercial-product).
- **A later packaging-standards review reshaped the field.** A whitepaper on
  enterprise skill packaging ([packaging-standards.md](../research/skill-manager/packaging-standards.md))
  surfaced **`vercel-labs/skills` (`npx skills`)**, missed by the earlier scans:
  per-project subset with both activate and disable *mechanics*, native symlink
  delivery, a data-driven 20+-agent table, and the strongest project health in the
  survey. Source-verified at HEAD `435076e` (code paths, MIT LICENSE, 58 test files,
  CI, and — after deepening the clone — active multi-author commit cadence); its
  ~30k★ is **web-observed** (2026-09-05), not clone-derived. It is now the day-one
  **lead on health (d5)**, but that is the lowest-priority driver and its "central
  store" is a distribution/registry model that does **not** match d1's literal
  single-store framing — a driver-priority inversion the spike weighed and resolved
  in favour of `omrikais/sm` (see [Decision Outcome](#decision-outcome)). See
  [Option 14](#14-adopt-vercel-labsskills-npx-skills) and its
  source-verified scorecard
  ([vercel-labs-scorecard.md](../research/skill-manager/vercel-labs-scorecard.md)).
  The same review confirmed
  three real distribution standards (the Agent Skills SKILL.md standard at
  `agentskills.io`, Agent Skills as OCI artifacts, and the Agent Packaging Standard);
  their relevance is scoped in [Consequences](#consequences) and
  [Open questions](#open-questions), not folded in as tool evidence.

Because the field had a clear health leader but an unresolved model-fit question,
the earlier draft presented `vercel-labs/skills` as the day-one **lead** with
`skills-mgr` and `omrikais/sm` as **challengers** (with `skill-cli` as a fallback
and Option 2's native script as a control), to be settled by a spike. **The spike
reversed that lead.** `vercel-labs/skills` searches skills excellently but its
project-skill *restore* is experimental and incomplete — it re-links only into
`.agents/`, not `.claude/`, and cannot restore global skills — so it fails the
delivery half of the day-one need. `omrikais/sm` delivered into both `.claude/` and
`.agents/` (the latter covering OpenCode and the other SKILL.md harnesses), managed
local and global skills, and supported per-project disable via its TUI. The
decision (below) therefore adopts `sm` as the manager and keeps `vercel-labs/skills`
purely for discovery.

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
what `omrikais/sm` does. (Corrections vs. an earlier draft: Copilot is not a
file-based `.instructions.md` target; Antigravity is `.agents/skills` /
`~/.gemini/antigravity/skills`, not `~/.gemini/config/skills`; and Cursor and Codex
are skills-directory agents via `.agents/skills`, not merely `.mdc`/`AGENTS.md`. The
legacy Copilot `.github/instructions/*.instructions.md` and `.github/copilot-instructions.md`
are a *separate custom-instructions* feature, not the skills mechanism —
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

The pre-spike analysis (retained below) made `vercel-labs/skills` the day-one lead
on health (d5) with `omrikais/sm` a challenger weakened by an assumed additive-only
d1 gap and a hardcoded `cc|codex` target set. The spike changed both findings:

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
  `sm install` (spike doc §"Bedienung") is a *different* operation — pruning
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

*Retained for the record; superseded by [Decision Outcome](#decision-outcome).*

Under the drivers (1 per-project subset, 2 Claude Code out-of-the-box, 3 cheap
extensibility, 4 safe delivery, 5 health), d2 and at least the *activate* half of
d1 are met off the shelf by several tools; the *disable/swap* half of d1 is a live
gating question for one co-candidate (`omrikais/sm`). Deliberately, this ADR does
**not** crown a single winner — it presents day-one **co-candidates** and defers
the choice to a hands-on spike:

The packaging-standards research ([packaging-standards.md](../research/skill-manager/packaging-standards.md))
then surfaced a candidate the earlier scans missed — **`vercel-labs/skills`
(`npx skills`)** — which changes the shape of the field. It clears the
**activate/disable mechanics of d1** (`--skill` to select, `remove` to
disable/swap, with a mass-delete guard), Claude Code out of the box (d2), native
canonical-store + symlink delivery (d4), a data-driven 20+-agent table (d3), and —
decisively — **the strongest health (d5)**: MIT with a filed LICENSE, 58 test
files, CI, and active multi-author cadence (30 commits in 2026-07, 17 in 2026-08),
all source-verified at HEAD `435076e`; its ~30k★ is web-observed (2026-09-05), not
clone-derived, and would make it the most-starred tool in the survey by far — hence
stated as an observation, not folded into the source-verified bundle. That health
largely retires the solo-developer risk that shadowed the two prior co-candidates.
Two genuine reservations temper the lead: (i) the "central store" is a
*distribution* model (install *from* a source repo/registry into each project), so
it does **not** match d1's literal single-store framing — on that framing
`skills-mgr` fits d1 better, and editing the one central source still requires a
re-sync into each project (the same staleness class flagged for `skills-mgr`); and
(ii) it too fails to emit Copilot's `.instructions.md`. So it leads on **d5, the
lowest-priority driver**, while carrying an open question on d1's own premise — a
priority inversion the spike must resolve, not a clean win. On the pre-spike
evidence it *was* the **day-one lead**, with the two tools below as challengers —
but the spike reversed this (`vercel-labs/skills`'s restore path could not
reconstruct into `.claude/`), so `omrikais/sm` was chosen; see
[Decision Outcome](#decision-outcome).

The two prior day-one co-candidates trade off cleanly — one leads
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

1. **Adopt a day-one tool now** — decided by the spike below (lead
   `vercel-labs/skills`, co-candidates skills-mgr and omrikais/sm, with the native
   symlink baseline of Option 2 as a control arm, and skill-cli only as a fallback).
2. **Extend when the further agents are needed** — Option 12 (wrapper) or Option
   13 (fork), base chosen then.

The migration seam still applies: the selection/delivery models differ across
these tools, so "extend later" may mean discarding the day-one tool's config and
running two tools briefly. Adopting now is justified by early value, not by making
extension cheaper. **Commercial products** (Option 11) deserve a trial in case one
covers everything. *(Superseded: this was the proposal-only stance; the decision was
taken 2026-09-06 — see [Decision Outcome](#decision-outcome).)*

A note on reversals: skill-cli scored Fit = 2 in the source evaluation (which
judged global three-agent coverage); the per-project-first drivers promoted it to
last round's lead; the landscape scan now shows tools that match its selection
model without its delivery caveat. Same evidence base, evolving question.

Coverage below is source-verified and reflects the **pre-spike** read; where the
spike revised a verdict (notably the `omrikais/sm` d1 and d3 rows), the authoritative
statement is the [Decision Outcome](#decision-outcome) scorecard. Also note the d3
cells mentioning "Copilot needs file-gen" / "no Copilot file-gen" are **obsolete**:
Copilot now reads the agent-skills skills directory (`.agents/skills`), so no file
generation is required for it. Driver columns
follow the priority set.

| Option | Per-project subset (d1) | Claude Code OOTB (d2) | Cheap extensibility (d3) | Safe delivery (d4) | Health (d5) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 Do nothing | none (manual) | manual | n/a | manual, error-prone | n/a |
| 2 Hand-rolled script | you build it | you build it (trivial) | you own it | native loads, no clobber | you own it |
| 3 mode-io/skill-manager | **no (global-only)** | yes (+ OpenCode) | **best** (data catalog + symlink & file codec) | crash-safe, reversible | CI + 61 tests, pre-1.0/private |
| 4 lijianru/skills-manager | yes (copy subset) | yes (native dir) | poor (hardcoded switch) | copy overwrites edits | no tests, bus-factor 1 |
| 5 skill-cli | best (`allow`/`deny`) | yes, via injection/pull (no enforcement) | OpenCode likely cheap; Copilot needs file-gen | store safe, delivery prompt-dependent | 227 tests but ~6h burst, unmaintained |
| 6 skills-mgr (Leonezz) | **yes (profiles + includes)** | yes (both scopes) | data-driven (`agents.toml`); Rust | **strongest** (SQLite, doctor, reversible, rollback) | 80 tests / CI / 1★ / HEAD ~5mo stale / no LICENSE file |
| 7 omrikais/sm *(pre-spike read; superseded — see Decision scorecard)* | partial — deploys but no clean disable/swap (additive-only) | yes (symlink native) | poor (hardcoded cc\|codex) | **strong** (no-clobber, atomic, doctor, backups, rollback) | MIT / 84 tests / 4★ / HEAD fresh (2026-09-03); sustained activity unverified |
| 8 sklm | yes (config) | yes (project-only) | **data-driven (30 YAML)** | **unsafe (rmtree clobbers foreign)** | MIT / 184 tests / CI |
| 9 skillkit (rohitg00) | partial (pkg-mgr) | yes | data-driven 46 + `translate` | decent (skip-existing, scan) | Apache-2.0 / ~1537 tests / 1470★ |
| 10 openhub / skill-factory / GUIs | mixed | mixed | poor | mixed | see analysis |
| 11 Commercial product | unknown (trial) | yes (SkillReg/Packmind) | vendor-controlled | product feature | vendor-supported |
| 12 Extend a base (no fork) | add via wrapper | inherit | inherit | inherit | shared with upstream |
| 13 Fork/build | by design | inherit | by design | inherit | you co-own it |
| 14 vercel-labs/skills | mechanics yes (`--skill` + `remove`); but store is a distribution model, not d1's single local store | yes (native) | data-driven (20+ agents); no Copilot file-gen | **strong** (canonical + ref-counted symlink, guarded delete) | **strongest**: MIT+LICENSE / 58 test files / CI / active cadence (verified); ~30k★ (web-observed 2026-09-05) |

The decisive columns are d1 (per-project), d4 (safe delivery), and d3 (cheap
extensibility). On the pre-spike reading, **vercel-labs/skills led on d5 while
matching or beating the others on d2/d4** (the activate/disable mechanics of d1,
native symlink, guarded delete) — though on d1's literal single-store framing
`skills-mgr` fit better; skills-mgr led d1+d4-architecture with data-driven d3;
omrikais/sm led symlink-delivery safety but read as additive-only on d1 and weak on
d3; skill-cli led the selection model but had the delivery caveat. *(Two later
corrections apply to this pre-spike reading: the spike overturned the ranking —
vercel's restore path could not reconstruct into `.claude/`, and omrikais/sm's d1/d3
read improved on hands-on use; and the "file-based Copilot" premise is obsolete —
Copilot reads the agent-skills skills directory, so it needs no file generation. See
[Decision Outcome](#decision-outcome).)*

## Detailed Analysis of Options

> **Correction (applies throughout this section):** several per-option notes below
> treat GitHub Copilot as a *file-based* `.instructions.md` target and count a tool's
> lack of `.instructions.md` generation — or its mapping of Copilot to `.github/skills`
> — as a limitation. That premise is **obsolete**: Copilot's agent-skills feature
> reads the SKILL.md skills-directory standard (`.github/skills`, `.claude/skills`, or
> `.agents/skills`;
> [GitHub docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)).
> So delivering into `.agents/skills` (or `.github/skills`) *covers* Copilot, and a
> tool that targets those dirs is correct, not deficient. Only emitting the legacy
> `.github/copilot-instructions.md` / `.github/instructions/*.instructions.md`
> custom-instructions files is now the outdated shape.

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
- Neutral on the further agents: Copilot (incl. Copilot CLI), Cursor, Codex, and
  Antigravity all read the `.agents/skills` skills directory, so a symlink into
  `.agents/skills` serves them too — no schema generation needed (only pi's
  `.pi/skills` and any future non-skills-directory agent would need extra handling).
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
- Good for Copilot: it maps copilot to `.github/skills` (`presets.rs:30`), which is a
  valid agent-skills directory Copilot reads — so it covers Copilot (an earlier draft
  miscounted this as a file-based gap; see the section correction note).

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
  gating question. **Spike update (2026-09-06):** the additive-only reading was of
  the `install`/profile path at the pinned HEAD; in the spike the stakeholder found
  the `sm` **TUI** does disable and remove skills from the local dirs, so d1
  activate+disable works in practice. The residual gap narrowed to **manifest**
  add/remove granularity, still to be confirmed (see [Open questions](#open-questions)).
- Good, because safe delivery is the strongest of the symlink tools (d4): no
  clobber (non-symlink targets are reported as conflicts and repair refuses to
  overwrite, `src/fs/links.ts:94-96,132-135`), atomic temp+rename (`src/fs/links.ts:32-35`),
  doctor, `sync --repair`, timestamped backups + restore, version history +
  non-destructive rollback (`versioning.ts:45-116`).
- Good on d5, and **fresher than skills-mgr**: HEAD `970fb64` dated 2026-09-03,
  clean MIT LICENSE file, 4★, dependabot, 84 test files. Honest caveat: *sustained*
  activity is unverifiable from a shallow clone — the verified claim is "recent
  HEAD", not "actively maintained".
- **Bad, because d3 is hardcoded**: at the pinned HEAD `970fb64`, deploy targets are
  a TypeScript `'cc' | 'codex'` union (`src/fs/paths.ts:85`), so only Claude Code and
  Codex exist and adding OpenCode/Copilot is a source + type change, not configuration.
  **Spike update (2026-09-06):** in the spike the stakeholder observed `sm` delivering
  into both `.claude/skills/` **and** `.agents/skills/`; since `.agents/skills/` is the
  universal dir OpenCode and other SKILL.md harnesses read, this may extend coverage
  beyond `cc|codex` in practice (whether via a newer version, the `codex` target
  resolving to `.agents/`, or a stale source read). This is unreconciled against the
  pinned-HEAD source line — confirm at the installed version before relying on it
  (see [Open questions](#open-questions)).
- Good for Copilot: by delivering into `.agents/skills` it feeds Copilot's agent-skills
  path, so Copilot (incl. Copilot CLI) is covered with no `.instructions.md`
  generation — retiring what an earlier draft listed here as a gap.

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
  (`skills:13-14`), no extensibility path; a skill-*authoring* factory whose
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

### 14. Adopt `vercel-labs/skills` (`npx skills`)

TypeScript CLI on npm (`npx skills`). Surfaced by the packaging-standards research
([packaging-standards.md](../research/skill-manager/packaging-standards.md)), which the earlier
scans missed; source-verified at HEAD `435076e` (2026-08-18), with a companion
scorecard
([vercel-labs-scorecard.md](../research/skill-manager/vercel-labs-scorecard.md))
matching the landscape-scan evidence format. It uses the native canonical-store +
symlink delivery the drivers favour, and leads the survey on health (d5).

- Good, because it does the **activate/disable mechanics of driver 1**. Activate:
  project scope is the default (skills land in the canonical `.agents/skills/`, `-g`
  for global) and `--skill <names>` selects a subset (`install.ts:31-32`, `add.ts`).
  Disable/swap: `remove` takes named skills, `--all`, `*`, or an interactive
  multiselect (`remove.ts:166-195`), with a footgun-guard that refuses `--all`
  combined with named skills so an agent cannot mass-delete by accident
  (`remove.ts:79-90`). This clears the disable/re-select gap that limits
  `omrikais/sm` — but see the store-model reservation below, which is why d1 is not
  an unqualified pass.
- Good, because Claude Code works out of the box (d2): `claude-code` is a native
  entry (`agents.ts:152-159`) and universal agents resolve to the canonical dir.
- Good, because *within a project* delivery is a **canonical store + symlink into
  native agent dirs**, the shape the drivers prefer: one canonical copy under
  `.agents/skills/` (`installer.ts:98`), symlinked out per agent and edited live
  without a refresh step. **This live-edit benefit is within-project only** — it
  does not extend across the central-store→project boundary (see the store-model
  reservation below).
- Good, because safe delivery is strong (d4): canonical removal is **ref-counted**
  so uninstalling from one agent does not break another (`remove.ts:281-298`,
  issues #287/#1718), lock-tracked, ENOENT-tolerant scans, atomic, and the
  interactive path confirms before deleting.
- Good, because agents are **data-driven** (d3): the `agents` record holds 20+
  entries (Claude Code, GitHub Copilot, Gemini, Antigravity, and more; upstream
  advertises 75+, only the 20+ source-confirmed), so adding a skills-directory agent
  is a data entry.
- Good, because it is the **healthiest candidate** (d5), and the health claim is now
  split by evidence class: **source-verified** at the pinned HEAD — MIT with a filed
  LICENSE, 58 test files, CI, and (after deepening the clone) active multi-author
  cadence, 30 commits in 2026-07 and 17 in 2026-08 across ~10+ contributors, so
  bus-factor is clearly >1 unlike the 1★/4★ solo priors; **web-observed** (2026-09-05,
  not clone-derived) — ~30.4k★ and hundreds of open issues/PRs, which if accurate
  make it the most-starred tool in the survey by an order of magnitude, hence stated
  as an observation rather than a verified fact. **Spike caveat (2026-09-06):** the
  spike found *merge* activity dries up where commit activity did not — a single
  merger and **no PR merges Jul–Sep 2026** (spike doc; and Consequences) — so the
  "bus-factor clearly >1" reading is qualified: many contributors open work, but one
  person gates it. This does not change the decision (vercel was rejected on the
  restore gap, not on health), but the health claim is not the unqualified win the
  pre-spike text implied.
- **Bad, because the "central store" is a distribution model, not a single local
  store — so d1 is not an outright pass.** It installs skills *from* remote sources /
  a registry into each project's canonical dir (a package-manager shape, like
  `skillkit`), so the canonical central store must be realised as a git repo or
  registry that projects `add` from — not the "one local store, symlink a per-project
  view" model of `skills-mgr` (which fits d1's literal framing better). It satisfies
  the *mechanics* of driver 1; the spike must confirm the source-repo store shape is
  acceptable. Note the workflow cost: **editing the one central source repo requires
  a re-`add`/`sync` into every consuming project** — the same copy-staleness class
  this ADR penalized `skills-mgr` for, not a one-time reframing.
- Good for Copilot: `github-copilot` maps to a skills *directory* (`agents.ts:350-357`),
  which is exactly what Copilot's agent-skills feature reads — so this covers Copilot
  rather than being "nominal". (An earlier draft treated Copilot as file-based and
  called this a gap; that premise is obsolete — see the correction note at the top of
  this section.)

Mitigation of negatives: model the central store as a private git skills repo (or
npm package) the projects `add` from; pin the version; accept the re-`add`/`sync`
step on every central-store edit (the distribution-tax cost is detailed above; the
Copilot "file-gen gap" once listed here no longer applies — Copilot reads the
agent-skills directory). It is the day-one **lead on d5
(health)**, but because d5 is the lowest-priority driver and d1's store-shape gate
is open, the lead is a spike hypothesis, not a settled pick.

## Consequences

- Adopting a day-one tool now delivers per-project selection on Claude Code
  immediately. The landscape scan improved the options: native-delivery tools
  (skills-mgr, omrikais/sm) avoid skill-cli's runtime-pull enforcement risk.
- **Migration/throwaway cost is real.** The co-candidates use different
  selection/delivery models, so if the day-one tool is later replaced by a
  different extension base, its config investment is largely discarded and two
  tools may run briefly. Day-one value does not buy down this later cost.
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

All supporting research lives in
[../research/skill-manager/](../research/skill-manager/README.md) (see that folder's
README for reading order and freshness):

- Hands-on spike that settled the decision (`sm` + vercel `find`):
  [hands-on-spike.md](../research/skill-manager/hands-on-spike.md).
- Source-code evaluation of the original five tools:
  [source-code-evaluation.md](../research/skill-manager/source-code-evaluation.md).
- Evaluation prompt/method:
  [evaluation-method.md](../research/skill-manager/evaluation-method.md).
- Prior background survey (superseded):
  [initial-tool-survey.md](../research/skill-manager/initial-tool-survey.md).
- Landscape scan of six further tools, source-verified with pinned HEADs and
  per-driver scorecards:
  [landscape-scan.md](../research/skill-manager/landscape-scan.md).
- Source-verified scorecard for the pre-spike day-one lead `vercel-labs/skills`
  (pinned HEAD
  `435076e`, evidence split into source-verified vs web-observed):
  [vercel-labs-scorecard.md](../research/skill-manager/vercel-labs-scorecard.md).
- Enterprise packaging & distribution standards review (background; surfaced
  `vercel-labs/skills`):
  [packaging-standards.md](../research/skill-manager/packaging-standards.md).
  Referenced standards, verified to exist: Agent Skills SKILL.md standard
  (https://agentskills.io), Agent Skills as OCI artifacts
  (https://github.com/ThomasVitale/agents-skills-oci-artifacts-spec), Agent
  Packaging Standard (https://agentpackaging.org), `vercel-labs/skills`
  (https://github.com/vercel-labs/skills).
- Method references: MADR (https://adr.github.io/madr/), Michael Nygard's ADRs
  (https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
  arc42 section 9 (https://docs.arc42.org/section-9/).
