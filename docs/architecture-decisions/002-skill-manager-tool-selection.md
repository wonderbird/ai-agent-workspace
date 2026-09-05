# 002: Centralizing Skills Across Coding Agents

- Status: Proposed
- Date: 2026-09-04

## Executive Summary

This document records how to centralize skill definitions, prompt rules, and MCP
configuration in one store and select a per-project subset of them across our
coding agents. Each agent loads skills from
a different directory with a different schema, so a skill has to be maintained
several times and there is no single place from which a project can pick the
subset it needs. This ADR frames the problem, sets the decision drivers, and
evaluates the realistic options — from doing nothing, through a hand-rolled
script, to adopting one of the surveyed open-source tools, buying a product, or
extending/forking a base. **The decision has not been made yet.** The purpose of
this document is to let the stakeholder make a well-informed choice.

A source-code evaluation of the five candidate tools underpins the analysis
below; see [skill-manager-evaluation.md](skill-manager-evaluation.md). That evaluation scored
fit against OpenCode / Claude Code / Cursor. Two rounds of stakeholder interviews
then reshaped the [Decision Drivers](#decision-drivers): the top priority is now
**per-project skill selection** (a central store from which each repository
activates only a chosen subset), followed by **Claude Code working out of the
box**, with **OpenCode, GitHub Copilot, and Copilot CLI added later** rather than
day-one requirements. A verification round re-checked the clones (source-verified)
and researched each agent's real instruction mechanism (web-verified). Key
results, which drive the recommendation:

- **The day-one need is already met off the shelf, several ways.**
  `VictorTomaili/skill-cli` has the best per-project `allow`/`deny` activation model
  (d1) and Claude Code support (d2) — but delivers by injecting a bootstrap and
  relying on the model *pulling* skills at runtime, not native skills-dir loads, a
  real caveat. `lijianru` and `skill-factory` do per-project + Claude by copying
  into native dirs; and a plain symlink script into `.claude/skills/` (Option 2)
  may cover the day-one case almost for free. **`mode-io` has no per-project scope
  at all** (global-only) and so fails the #1 driver.
- **The real tension is d1 vs. d3, not "the top two".** No tool combines
  per-project selection (d1) with cheap extensibility to the further agents (d3).
  For skill-cli, that gap is narrower than first thought: **OpenCode is likely a
  cheap injection-target addition; only the file-based Copilot / Copilot CLI need
  real new work** (a spike hypothesis, not asserted). mode-io owns the
  extensibility/delivery breadth (d3) but has no per-project scope. So the lead is
  **adopt a day-one tool now** (skill-cli leading, with its delivery caveat) and
  **extend or fork when the further agents are actually needed** — *which base*
  the open question, and its migration cost explicit (see Consequences).
- **The wanted targets span two delivery shapes.** Claude Code and OpenCode (and
  nice-to-haves pi and Antigravity) use the SKILL.md **skills-directory** standard
  — symlink-friendly. GitHub Copilot and Copilot CLI are **file-based**
  (`*.instructions.md`), needing generation, not a symlinked dir. Any extension
  must handle both.
- **Commercial products exist after all** (correcting an earlier assumption): see
  [Option 7](#7-buy-a-commercial-product).

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

This diverges from the source evaluation, which scored fit against OpenCode /
Claude Code / **Cursor**, and treats coverage differently from the earlier draft
of this ADR: only Claude Code must work immediately; the rest are judged by how
cheaply they can be *added*. Verification found no functional Copilot support in
any candidate (only one nominal, wrong-path attempt) and no Copilot CLI target at
all — consistent with treating them as added-later rather than off-the-shelf.

This ADR is intended for the project stakeholder (the developer) and any future
contributor.

## Decision Drivers

The choice will be guided by the following principles, in priority order (1 =
most important), confirmed with the stakeholder through a short interview.

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

1. **Do nothing / accept the status quo** — keep maintaining skills separately
   per agent directory. See [Detailed Analysis](#1-do-nothing--status-quo).
2. **Manual workaround: a hand-rolled symlink/copy script** — a small in-house
   shell/Node script that links a central folder into each agent dir. See
   [Detailed Analysis](#2-manual-workaround-hand-rolled-script).
3. **Adopt `mode-io/skill-manager`** — central store, declarative targets, symlink
   + file-codec delivery; Claude Code + OpenCode native but **no per-project
   scope**. See [Detailed Analysis](#3-adopt-mode-ioskill-manager).
4. **Adopt `lijianru/skills-manager`** — a Node CLI that copies a chosen skill
   subset into per-project dirs (does driver 1 by copy, but clobbers edits,
   hardcoded). See [Detailed Analysis](#4-adopt-lijianruskills-manager).
5. **Adopt `VictorTomaili/skill-cli`** — best per-project `allow`/`deny` model +
   Claude Code out of the box; the strongest day-one adopt. See
   [Detailed Analysis](#5-adopt-victortomailiskill-cli).
6. **Adopt another surveyed tool** — `24KaratAu/openhub` or `lexler/skill-factory`.
   See [Detailed Analysis](#6-adopt-another-surveyed-tool-openhub--skill-factory).
7. **Buy / adopt a commercial product** — real paid options exist (SkillReg,
   Packmind, Tessl), none confirmed for per-project subset + OpenCode/Copilot CLI.
   See [Detailed Analysis](#7-buy-a-commercial-product).
8. **Extend a base without forking** — consume `mode-io` (or another tool) as a
   dependency and add a thin per-project layer on top, without owning a fork. See
   [Detailed Analysis](#8-extend-a-base-without-forking).
9. **Fork / build** — hard-fork the strongest base (skill-cli or mode-io) and
   extend it to satisfy all drivers. See [Detailed Analysis](#9-fork--build).

## Recommendation (pending decision)

Under the re-prioritized drivers (1 per-project subset, 2 Claude Code
out-of-the-box, 3 cheap extensibility to further agents, 4 safe delivery, 5
health), the day-one drivers (d1 + d2) *are* satisfiable off the shelf, by more
than one tool, each with a caveat:

- **`VictorTomaili/skill-cli`** has the strongest per-project model — an
  `allow`/`deny` activation config over a central store (`config.js:78-113`) — and
  Claude Code support. **Caveat (delivery):** it writes nothing into the agent's
  skills directory; it injects a bootstrap block into the agent's instruction file
  and relies on the model *pulling* skills at runtime, with no enforcement. So its
  d2/d4 are real but by a prompt-dependent mechanism, not native skills-dir loads.
- **`lijianru`** copies a chosen subset into the *native* per-project skills dirs
  (so the agent loads them normally), but overwrites edits (fails d4), is hardcoded
  and untested (fails d5).
- **Native mechanisms + a small copy/symlink** (Option 2) may already give d1+d2
  for Claude Code almost for free — worth ruling out before adopting any tool.

The conflict the drivers expose is **d1 vs. d3**, but more narrowly than the first
draft claimed. d3 is not uniformly hard for skill-cli: **OpenCode is instruction-
file driven too, so adding it is plausibly another array/target entry
(`paths.js:16-22`), not a delivery rebuild** — this is a spike hypothesis, not a
verified fact. Only the **file-based Copilot / Copilot CLI** need a new generation
mechanism. `mode-io` sits opposite: it owns the extensibility/delivery
breadth (data catalog + symlink and file codecs, OpenCode native, crash-safe,
tested — d2–d5) but has **no per-project scope at all** (global-only), failing d1.

Because only Claude Code is required on day one, the path is staged:

1. **Adopt a day-one tool now** for per-project selection on Claude Code.
   `skill-cli` leads on the *selection model* (subject to the pull-delivery
   caveat); `lijianru` or native+copy are alternatives with native delivery but
   weaker safety/health. A one-day spike picks between them.
2. **Extend when the further agents are needed** — Option 8 (wrapper) or Option 9
   (fork), base chosen then, not now.

The seam: skill-cli (config + injection) and mode-io (catalog + symlink) are
**incompatible models**, so "extend later" may mean either rebuilding delivery
inside a skill-cli fork *or* migrating off skill-cli to a mode-io base —
discarding the skill-cli config investment and possibly running two tools in the
interim. Day-one value is modest and does not buy down that later cost; adopting
now is justified by getting value early, not by making extension cheaper.
**Commercial products** (Option 7) deserve a trial in case one covers everything
and removes the extension question. This ADR is a *proposal only* — decision open.

Note a reversal from the source evaluation, which is deliberate: skill-cli scored
Fit = 2 ("weak fit, architecturally off-target") there because that evaluation
judged global coverage of three agents. Under the reprioritized drivers
(per-project selection first, Claude-first), its activation model moves it to the
day-one lead. Same evidence, different question.

Coverage below is source-verified. Driver columns follow the re-prioritized set.

| Option | Per-project subset (d1) | Claude Code OOTB (d2) | Cheap extensibility (d3) | Safe delivery (d4) | Health (d5) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 Do nothing | none (manual) | manual | n/a | manual, error-prone | n/a |
| 2 Hand-rolled script | you build it | you build it | you own it | you build it | you own it |
| 3 mode-io/skill-manager | **no (global-only)** | yes (+ OpenCode) | **best** (data catalog + symlink & file codec) | crash-safe, reversible | CI + 61 tests, pre-1.0/private |
| 4 lijianru/skills-manager | yes (copy subset to project) | yes (native dir) | poor (hardcoded switch) | copy overwrites edits | no tests, bus-factor 1 |
| 5 skill-cli | **best** (`allow`/`deny` project config) | yes, but via injection/pull (no enforcement) | OpenCode likely cheap; Copilot needs file-gen | store safe, but delivery is prompt-dependent | 227 tests but ~6h burst, effectively unmaintained |
| 6a openhub | no | no (CC label-only) | poor | fake-success installs | placeholder tests |
| 6b skill-factory | yes (project-local copy) | yes (native dir) | poor (constants, Claude-only) | defensive but 1 target | no CI/tests, bus-factor 1 |
| 7 Commercial product | unknown (trial needed) | yes (SkillReg/Packmind) | vendor-controlled | product feature | vendor-supported |
| 8 Extend a base (no fork) | add via wrapper layer | inherit from base | inherit from base | inherit from base | shared with upstream |
| 9 Fork/build | by design | inherit from base | by design | inherit from base | you co-own it |

The decisive columns are d1 (per-project) and d3 (cheap extensibility): the
scarcity is the *combination* — several tools do d1, mode-io leads d3, none does
both — which is why the recommendation adopts for day-one value now and defers the
extension (and its migration cost) to a spike.

## Detailed Analysis of Options

### 1. Do nothing / status quo

Keep maintaining each skill separately in each agent's directory by hand.

- Good, because it requires no new tool, no dependency, and no learning curve.
- Good, because there is zero risk from third-party code health or abandonment.
- Bad, because every skill is duplicated across three directories and edits
  drift out of sync.
- Bad, because there is no single switch to enable/disable a skill everywhere —
  the exact capability we want.
- Bad, because the manual effort and error rate grow with the number of skills.

Mitigation of negatives: a naming convention and a checklist reduce drift
somewhat, but they do not remove the duplication or provide global toggling; the
core problem remains unsolved.

### 2. Manual workaround: hand-rolled script

Write a small in-house script that symlinks (or copies) a chosen subset from a
central store into each agent's **native** per-project location — for Claude Code
`.claude/skills/`, for Copilot `.github/instructions/`, etc. The agents already
have per-project mechanisms; this option just feeds them, so the day-one target
(per-project subset for Claude Code) may be nearly free — a few lines that symlink
selected store entries into a repo's `.claude/skills/`.

- Good, because it is fully under our control, has no external dependency, and for
  the day-one case (Claude Code, native skills-dir) is trivial — which raises the
  bar every other option must clear.
- Good, because it uses each agent's native loading, so there is no enforcement/
  pull caveat (unlike skill-cli) and no schema translation for skills-dir agents.
- Bad, because we take on all maintenance, cross-platform edge cases (Windows
  junctions, synced folders), and correctness (collision handling, safe removal).
- Bad, because the file-based Copilot / Copilot CLI schema (`.instructions.md`
  with `applyTo`) and Cursor `.mdc` still have to be generated by us — the same
  work the tools defer.
- Bad, because as it grows to cover the further agents it reinvents what the
  candidate tools already do.

Mitigation of negatives: keep it symlink-only and Claude/OpenCode-first to limit
scope. This is the honest baseline for the day-one drivers — any adopted tool must
justify itself against "a symlink script into `.claude/skills/`"; a tool earns its
place mainly by carrying the later, harder file-based targets, not the easy one.

### 3. Adopt `mode-io/skill-manager`

A central content store with declarative per-agent binding profiles and symlink
adapters. Winner of the source evaluation — but no longer the ADR's lead once
per-project selection became the top driver, which this tool does not provide.

- **Bad, because it has no per-project scope — failing driver 1, the top
  priority.** All its binding scopes point at global/home locations
  (`catalog.py:106-286`); there is no mechanism for a repository to activate a
  chosen subset. This is the decisive weakness for our reprioritized use case.
- Good, because Claude Code works out of the box (driver 2), along with OpenCode
  and Cursor, modeled natively with correct roots and env overrides
  (`catalog.py:139,207,172`).
- Good, because targets are declarative data (binding-profile catalog,
  `catalog.py:93`) **and** it already ships a frontmatter-rewriting codec for
  slash-commands (`codecs.py`), so it has both a symlink adapter and a
  file-generating adapter — the two delivery shapes the wanted targets need. This
  makes it the strongest base for driver 3 (extensibility): adding Copilot /
  Copilot CLI is a new binding profile plus reuse of the file codec, not a rewrite.
- Bad, because it does not target Copilot today — "GitHub Copilot" is only an
  unchecked roadmap box (`README.md:405`), and Copilot CLI is absent — so that
  adapter work, though well-supported by the architecture, is still work we must
  do or sponsor.
- Good, because mutations are crash-safe (preflight link validation, backup
  dirs, rollback) and it has real CI and 61 tests (drivers 4–5).
- Bad, because symlink delivery breaks on filesystems or synced dirs that cannot
  follow links, unless the copy fallback is used.
- Bad, because the repo is pre-1.0 (v0.3.1), marked private, and authored mostly
  by two people — a bus-factor and contract-stability risk.

Mitigation of negatives: the missing per-project scope and the Copilot targets
are exactly what an extension would add (see [Option 8](#8-extend-a-base-without-forking)
or [Option 9](#9-fork--build)) — this tool is the strongest *base*, not a finished
answer. Pin to a known-good version/commit
and vendor or fork it to remove the "private repo could disappear" risk; use the
built-in materialize-to-copy path on non-symlink-friendly locations. The
frontmatter gap for skills (only slash-commands are rewritten) is acceptable
between Claude Code and OpenCode, which share the same `name`/`description`
SKILL.md frontmatter; GitHub Copilot's file-based format is part of the extension
work.

### 4. Adopt `lijianru/skills-manager`

A lightweight Node CLI that copies a chosen skill subset into a hardcoded set of
target dirs. Like skill-cli (Option 5) it does per-project selection and Claude
Code out of the box, but by copying rather than a config toggle, and less cleanly.

- Good, because it does driver 1: an interactive checkbox picks which skills
  (`selectedSkills`, `link-manager.ts:55-70`) and copies just that subset into a
  chosen project directory / `process.cwd()` (`:142,171`) — a real per-project
  subset, though realized by copying rather than a re-flippable toggle.
- Good, because Claude Code works out of the box (driver 2), and it has built-in
  cases for OpenCode, Cursor, **and** Copilot, Gemini/Antigravity, Codex
  (`link-manager.ts:105-170`) — and is simple to run and understand.
- Good, because it keeps a central config registry and can re-sync copies with
  an `update` command.
- Bad, because its Copilot and Gemini paths are **wrong**: it writes to
  `~/.copilot/skills` / `.github/skills` (`link-manager.ts:122,162`) and
  `~/.gemini/antigravity/skills` (`:113`), but Copilot reads
  `.github/instructions/*.instructions.md` and Antigravity reads
  `~/.gemini/config/skills/` — so that coverage is nominal and likely
  non-functional until verified/fixed. It also has no distinct Copilot CLI target.
- Bad, because the targets are a hardcoded switch (`link-manager.ts:82,105,145`),
  so correcting those paths or adding Copilot CLI is a source edit, not config.
- Bad, because delivery is copy-with-overwrite that can silently clobber local
  edits, with no conflict detection — failing driver 4.
- Bad, because it has no tests, a single author over ~11 days, and a wrong
  hardcoded version string — failing driver 5.
- Bad, because it does no per-agent schema translation, so its file-based Copilot
  delivery cannot be made correct without real work.

Mitigation of negatives: treat target dirs as machine-managed (never hand-edit
them) so overwrite-on-update is harmless; wrap it with our own backup step; pin
the version. It is a fallback to skill-cli (Option 5) if that tool's pull-delivery
model is judged unsuitable — but it is the weaker of the two off-the-shelf
per-project options.

### 5. Adopt `VictorTomaili/skill-cli`

The strongest per-project *activation* model in the set, and the leading day-one
adopt — but with a delivery-model caveat and a maintenance caveat that keep it
from being a clean winner.

- Good, because it does driver 1 cleanly: a project `skill.config` with
  `inherit`/`allow`/`deny` where `deny:["*"] + allow:[X]` yields "only X"
  (`config.js:78-113`) — a re-flippable per-project subset over one central store,
  not a copy.
- Good, because Claude Code is supported out of the box (driver 2) and the store
  itself is never clobbered (part of driver 4), with 227 tests and CI on 3 OS × 2
  node versions.
- **Bad (delivery caveat, affects d2 and d4), because it puts nothing in the
  agent's skills directory.** It injects a bootstrap block into the agent's global
  instruction file and relies on the model *pulling* skills at runtime via the
  `skill` CLI — with no enforcement if the model ignores the bootstrap
  (`agents-md.js:79-101`). So "Claude Code works" means "Claude Code is told to
  pull," which is weaker and less verifiable than a native skills-dir load.
- **Bad (health caveat, driver 5), because it is effectively unmaintained**: the
  entire history is a single ~6-hour burst by one author, bus-factor 1, no
  sustained activity. 227 tests indicate quality at that snapshot, not upkeep — a
  real risk for a tool a solo developer must rely on long-term.
- Bad, because of the wanted targets it has **only Claude Code**; OpenCode and
  Copilot are absent (`paths.js:16-22`).
- Mixed on driver 3: because delivery is instruction-file injection, **adding
  OpenCode is plausibly cheap** — another instruction-file target entry
  (`paths.js:16-22`), a spike hypothesis to verify — whereas the **file-based
  Copilot / Copilot CLI need a new generation mechanism**. The earlier "rebuild the
  whole delivery layer" framing overstated this; only Copilot does.

Mitigation of negatives: adopt it now for day-one per-project selection on Claude
Code, pin/vendor the version to blunt the unmaintained risk, and confirm the pull
behavior actually works (see [Confirmation](#confirmation)) rather than assuming
it. If the pull-delivery model proves unreliable in practice, `lijianru` (native
per-project copy) or a native+copy script (Option 2) are fallbacks.

### 6. Adopt another surveyed tool (openhub / skill-factory)

- **`24KaratAu/openhub`** — verification found only **OpenCode** is real (installs
  via `opencode get`, `opencode-market_v2.py:171`); the Claude Code and Cursor
  rows in its README have **no corresponding code**. It fails the day-one Claude
  Code driver, has no per-project selection, and records fake "success" when the
  target binary is absent. Poor fit.
- **`lexler/skill-factory`** — supports per-project selection by local copy and
  Claude Code (`skills:13-14`), but is Claude-Code-only with no extensibility
  path; it is a skill-*authoring* factory.

Mitigation of negatives: neither closes the multi-agent gap without substantial
work, so neither is a serious distributor choice — however, `skill-factory`'s
authoring layer is worth harvesting *separately* as a complement to whichever
distributor we pick, since creating good skills is a different problem from
distributing them.

### 7. Buy a commercial product

Correcting an earlier assumption in this ADR: a commercial market *does* exist
(nascent, 2025–2026, no incumbent). Named products found:

- **SkillReg** (skillreg.dev) — private SKILL.md registry across Claude Code,
  Codex, Cursor, Copilot; versioning, permissions, scanning, audit. Paid SaaS
  (Free / $29 / $99 per month).
- **Packmind** (packmind.com) — "ContextOps" that *generates per-agent files*
  (`.claude/rules`, `.cursor/rules`, `.github/instructions`, `AGENTS.md`, …) for
  Claude Code, Cursor, Copilot, and others; OSS core plus paid enterprise.
- **Tessl** (tessl.io) — enterprise "Agent Enablement Platform" with a skills
  registry and governance; Claude Code, Cursor, Copilot, Gemini.

- Good, because a vendor carries maintenance, cross-platform correctness, and
  governance we would otherwise build; Packmind in particular already emits the
  file-based `.github/instructions` shape Copilot needs.
- Bad, because **none of them lists OpenCode or Copilot CLI**, and none documents
  a per-project subset model (driver 1), so our top requirements are unconfirmed
  and may be unmet — now behind a paywall.
- Bad, because they add cost, external dependency, and potential lock-in/data
  governance concerns for a solo-developer workflow.

Mitigation of negatives: a short trial of SkillReg and Packmind would cheaply
confirm whether either does per-project selection and covers OpenCode + Copilot
CLI; if one does, its maintenance/testing/support could beat both the OSS options
and a self-owned fork. This is an actionable option, not a dead end.

### 8. Extend a base without forking

Consume an existing tool as an unmodified dependency and add a thin per-project
layer on top — distinct from a hard fork (Option 9, we own and modify the source)
and from a from-scratch script (Option 2). Most credible with `mode-io`, whose
targets are declarative data and whose delivery adapters are pluggable
([evaluation](skill-manager-evaluation.md)), so a wrapper could add a per-project
activation layer and new target profiles without patching upstream.

- Good, because it keeps upstream updates flowing (no rebase burden) while still
  closing the per-project (d1) and further-target (d3) gaps.
- Good, because the surface we own is small — a wrapper — lowering maintenance vs.
  a fork.
- Bad, because it depends on the base exposing stable extension points; `mode-io`
  is pre-1.0 and private, so its API/frontmatter contracts may shift under us.
- Bad, because if the needed hook does not exist (e.g. no way to inject a
  per-project scope without touching internals), this collapses back into a fork.

Mitigation of negatives: a spike confirms whether `mode-io` (or another base)
exposes the hooks a wrapper needs; if it does, this is strictly cheaper than
Option 9; if it does not, fall back to Option 9.

### 9. Fork / build

Hard-fork the strongest base and extend it to satisfy all five drivers. Needed
only if no off-the-shelf tool suffices and Option 8's wrapper approach proves
infeasible. The open question is *which base to fork*:

- **Fork `skill-cli`** — inherit its tested per-project `allow`/`deny` activation
  engine (d1 — several tools do d1, but skill-cli's config model is the cleanest)
  and Claude Code support; then build skills-directory + file-generating delivery
  and add the OpenCode / Copilot / Copilot CLI targets. Cost centre: delivery.
- **Fork `mode-io`** — inherit its data-driven target catalog, both delivery
  shapes, OpenCode/Cursor/Codex targets, crash-safe delivery, and tests (drivers
  2–5 largely solved); then add a per-project scope + activation layer. Cost
  centre: building driver 1 onto a global-only model.

- Good, because a fork covers all wanted targets *and* per-project selection by
  design — the combination no off-the-shelf option offers.
- Good, because it removes the third-party/private/pre-1.0 dependency risk — we
  own the fork.
- Bad, because we take on long-term maintenance and must track upstream.
- Bad, because whichever base we pick, the capability it lacks (delivery for
  skill-cli; per-project scope for mode-io) is real design work, and Copilot's
  file-based model may not map cleanly onto a skills-directory abstraction.

Mitigation of negatives: prefer Option 8 (wrapper) first; fork only if it fails.
Keep the fork minimal and rebase periodically; deliver Copilot via a generate-file
adapter alongside a symlink adapter. Decide the base with the feasibility spike
named in [Open questions](#open-questions) — building per-project onto mode-io vs.
building delivery onto skill-cli.

## Consequences

- Adopting a day-one tool now delivers per-project selection on Claude Code
  immediately, with no forking — value first, commitment later.
- **Migration/throwaway cost is real and must be accepted.** If we adopt skill-cli
  and later base the extension on mode-io (incompatible models: config+injection
  vs. catalog+symlink), the skill-cli `allow`/`deny` config investment is largely
  discarded and there may be a period of **running two tools / two stores** during
  the switch. Day-one value is modest and does *not* buy down this later cost.
- Alternatively, staying on a skill-cli fork avoids migration but commits us to
  building its entire delivery layer ourselves — the cost simply moves, it does not
  vanish.
- No single tool has both per-project selection (d1) and cheap extensibility (d3),
  so an extension step is unavoidable eventually; adopting now sequences value
  ahead of that cost rather than removing it.
- The file-based Copilot/Copilot CLI targets need a generate strategy regardless
  of base; symlink-based delivery requires care on non-symlink-friendly locations
  (cloud-synced folders, Windows without junction support) — any solution must
  handle both delivery shapes.
- The chosen tool becomes the owner of the agent skill/instruction locations; we
  must stop hand-editing them and treat the central store as the source of truth.
- If a spike shows the native+copy baseline (Option 2) covers the day-one need,
  adopting any tool now may be premature — the cheapest honest path could be a
  symlink script until the further agents force a real tool.
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

- For **skills-directory / file delivery** (native+copy, lijianru, mode-io,
  Copilot file generation): inspect the agent's target location and confirm it
  holds exactly the selected subset.
- For **injection/pull delivery** (skill-cli): the skills directory stays empty by
  design, so instead confirm end-to-end that a live agent session actually loads
  the selected skills and none of the deselected ones — i.e. that the pull
  bootstrap is honored in practice, not just written. A tool whose selection is
  correct on disk but unreliable at runtime does **not** pass.

Nice-to-have agents (Cursor, pi, Gemini/antigravity, Codex) are a bonus, not a
pass/fail condition.

## Open questions

The decision drivers and their priority are now confirmed (see
[Decision Drivers](#decision-drivers)). The remaining open questions before a
final decision are:

- **Extend vs. fork, and which base (the pivotal question) — deferred until the
  further agents are actually needed.** Does `mode-io` expose stable hooks for a
  no-fork wrapper (Option 8) to add a per-project scope + new targets? If yes,
  wrap it. If not, hard-fork (Option 9), and choose the base by two spikes: (a) how
  hard to add a per-project `allow`/`deny` scope onto `mode-io`'s global-only
  model? (b) how hard to add skills-directory + file (`*.instructions.md`) delivery
  and the OpenCode/Copilot targets onto `skill-cli`'s injection model?
- **Copilot delivery feasibility.** Can a file-generating adapter emit
  `*.instructions.md` into `.github/instructions/` and `~/.copilot/instructions/`
  (honoring `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`) cleanly? `mode-io` already has a
  slash-command file codec to build on; `skill-cli` would start this from scratch.
- **Commercial trial.** Do **SkillReg** or **Packmind** support per-project subset
  selection and cover OpenCode + Copilot CLI? Their marketing lists neither
  OpenCode nor Copilot CLI, so they likely fall short of d1+d3 as well — but a
  brief hands-on trial is cheap and, if one does cover everything, would remove the
  extend/fork work entirely.
- **Verify, don't trust, `lijianru`'s extra targets.** If Option 4 is
  reconsidered, confirm whether its Copilot/Gemini paths were corrected — as
  verified, they are wrong and likely non-functional.
- **Base licensing / stability.** `mode-io` is marked private and pre-1.0; confirm
  licensing and a vendoring strategy before wrapping or forking it.

## More Information

- Full source-code evaluation of all five tools, with per-tool scorecards, a
  verified comparison matrix, and the ranked recommendation:
  [skill-manager-evaluation.md](skill-manager-evaluation.md).
- The evaluation prompt/method:
  [skill-manager-evaluation-prompt.md](skill-manager-evaluation-prompt.md).
- Prior background survey:
  [llm_agent_skill_managers_research.md](llm_agent_skill_managers_research.md).
- Method references: MADR (https://adr.github.io/madr/), Michael Nygard's ADRs
  (https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
  arc42 section 9 (https://docs.arc42.org/section-9/).
