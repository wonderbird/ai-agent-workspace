# 002: Centralizing Skills Across Coding Agents

- Status: Proposed
- Date: 2026-09-04

## Executive Summary

This document records the decision-making process for how to centralize skill
definitions, prompt rules, and MCP configuration in one place and
select/deselect them globally across our coding agents. Each agent loads skills
from a different directory with a different schema, so a skill has to be
maintained several times and there is no single switch to turn one on or off
everywhere. This ADR frames the problem, sets the decision drivers, and
evaluates the realistic options — from doing nothing, through a hand-rolled
script, to adopting one of five open-source tools already surveyed in depth.
**The decision has not been made yet.** The purpose of this document is to let
the stakeholder make a well-informed choice.

A full, evidence-based source-code evaluation of the five candidate tools already
exists and underpins the analysis below; see
[skill-manager-evaluation.md](skill-manager-evaluation.md). That evaluation scored
fit against OpenCode / Claude Code / Cursor. The stakeholder's actual must-cover
set (see [Decision Drivers](#decision-drivers)) is **Claude Code, OpenCode, GitHub
Copilot, and GitHub Copilot CLI**, so a second verification round re-checked the
clones (source-verified) and researched each agent's real instruction mechanism
(web-verified). Key results, which reshape the decision:

- **No tool covers the full must-set functionally.** `mode-io/skill-manager` has
  no Copilot target (only a roadmap checkbox). `lijianru/skills-manager` *does*
  write to Copilot/Gemini/Codex paths, but those paths do **not** match where
  those agents actually read instructions (see below) — so its extra coverage is
  nominal, not verified-functional. **No tool** targets Copilot CLI as a distinct
  destination.
- **The must-set spans two delivery shapes.** Claude Code and OpenCode (and the
  nice-to-haves pi and Antigravity) use the SKILL.md **skills-directory** standard
  — symlink-friendly. GitHub Copilot and Copilot CLI are **file-based**: they read
  `*.instructions.md` files, so a centralizer must *generate/translate* files for
  them, not symlink a skills dir. Any winning approach must handle both shapes.
- **Commercial products exist after all** (correcting an earlier assumption): see
  [Option 6](#6-buy-a-commercial-product).

## Context and Problem Statement

We maintain a growing set of agent skills, prompt rules, and MCP server configs.
We want them to live in one canonical repository and be globally selectable —
turn a skill on and it appears for every agent that should have it; turn it off
and it is gone everywhere.

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
duplicated per agent, edits drift, and there is no single point to enable or
disable a skill across the toolset.

The target set for this decision, elicited from the stakeholder, is:

- **Must cover:** Claude Code, OpenCode, GitHub Copilot, GitHub Copilot CLI.
- **Nice to have:** Cursor, pi, Gemini (antigravity), Codex.

This diverges from the source evaluation, which scored fit against OpenCode /
Claude Code / **Cursor**. Cursor is now only nice-to-have, and **GitHub Copilot
and Copilot CLI — both must-haves — were never scored.** Verification found no
functional Copilot support in any candidate (only one nominal, wrong-path
attempt) and no Copilot CLI target at all. Meeting the must-set therefore
requires either a tool that is easy to extend with correct new targets, or
building/forking one.

This ADR is intended for the project stakeholder (the developer) and any future
contributor.

## Decision Drivers

The choice will be guided by the following principles, in priority order (1 =
most important), confirmed with the stakeholder through a short interview.

1. 🎯 **Agent coverage — and the extensibility to reach it.** The solution must
   deliver skills to the **must-cover** agents — Claude Code, OpenCode, GitHub
   Copilot, and GitHub Copilot CLI — with **Cursor, pi, Gemini (antigravity),
   and Codex** as nice-to-have bonuses. Verification confirmed *no candidate
   covers the full must-set functionally* — Copilot CLI is nobody's target, and
   Copilot needs file generation nobody does correctly — so the practical form of
   this driver is extensibility: how cheaply a correct new target (especially the
   file-based Copilot pair) can be added, ideally by configuration/data plus a
   file-generating adapter, not a source rewrite.
2. 🔀 **True global select / deselect.** It must let us enable or disable a skill
   once, centrally, and have that take effect across every covered agent from a
   single store — not merely copy files in and out per agent.
3. 🛡️ **Safe, correct delivery.** Installing or updating a skill must not
   silently clobber local edits or report success for work it did not do; the
   link/copy strategy should be understandable and reversible.
4. 🧘 **Long-term trust / project health.** For a solo developer, the tool should
   be healthy enough to rely on — tested, active, released, and not a
   one-commit throwaway — with minimal ongoing tuning.
5. 🚀 **Low-effort adoption.** It should be usable without a rewrite of our
   existing workflow.

## Considered Options

1. **Do nothing / accept the status quo** — keep maintaining skills separately
   per agent directory. See [Detailed Analysis](#1-do-nothing--status-quo).
2. **Manual workaround: a hand-rolled symlink/copy script** — a small in-house
   shell/Node script that links a central folder into each agent dir. See
   [Detailed Analysis](#2-manual-workaround-hand-rolled-script).
3. **Adopt `mode-io/skill-manager`** — a central store with declarative per-agent
   binding profiles and symlink delivery; natively covers Claude Code + OpenCode
   (+ Cursor, Codex). See [Detailed Analysis](#3-adopt-mode-ioskill-manager).
4. **Adopt `lijianru/skills-manager`** — a lightweight Node CLI that copies skill
   folders into a hardcoded set of agent dirs (widest nominal coverage, some paths
   wrong). See [Detailed Analysis](#4-adopt-lijianruskills-manager).
5. **Adopt one of the other surveyed tools** — `VictorTomaili/skill-cli`,
   `24KaratAu/openhub`, or `lexler/skill-factory`. See
   [Detailed Analysis](#5-adopt-another-surveyed-tool-skill-cli--openhub--skill-factory).
6. **Buy / adopt a commercial product** — real paid options exist (SkillReg,
   Packmind, Tessl), though none confirmed for our full must-set. See
   [Detailed Analysis](#6-buy-a-commercial-product).
7. **Fork / build (extend Option 3)** — cover the full must-set, including GitHub
   Copilot and Copilot CLI, by extending a candidate rather than starting from
   zero. See [Detailed Analysis](#7-fork--build-extend-option-3).

## Recommendation (pending decision)

Against the *interviewed* drivers and the verified coverage, no candidate meets
the full must-set (**Claude Code, OpenCode, Copilot, Copilot CLI**), so the top
driver reduces to *how cheaply the missing, file-based Copilot targets can be
added correctly.* Two options lead, for opposite reasons:

- **Option 3, `mode-io/skill-manager`** — 2 of 4 must-agents native (Claude Code,
  OpenCode), and it is the only candidate whose targets are declarative data (a
  binding-profile catalog) *and* that already ships a frontmatter-rewriting codec
  layer for slash-commands — i.e. it has both a symlink adapter and a
  file-generating adapter, exactly the two shapes the must-set needs. It also
  wins drivers 2 (global toggle) and 3 (crash-safe, reversible). Adding Copilot is
  therefore "new binding profile + reuse the file codec," not a rewrite.
- **Option 4, `lijianru/skills-manager`** — has the widest *nominal* coverage: it
  writes to Claude Code, OpenCode, **and** Copilot/Gemini/Codex paths. But the
  Copilot and Gemini paths it uses (`~/.copilot/skills`, `.github/skills`,
  `~/.gemini/antigravity/skills`) are **not** where those agents actually read
  instructions, so that coverage is unverified/likely non-functional; and it is a
  hardcoded switch (fixing the paths is a source edit), copies with overwrite
  (fails driver 3), and has no tests (fails driver 4).

So Option 3 leads on the drivers despite lower nominal coverage, with **Option 7
(fork Option 3 to add a correct Copilot file-adapter)** the serious runner-up
because Copilot's file shape may not fit the skills-directory abstraction
cleanly. Option 4 is a weaker fallback. **Commercial products now also exist**
(Option 6) and deserve evaluation. This ADR carries these forward as a *proposal
only* — the decision is still open.

Coverage below is source-verified; "nominal" = the tool writes files there but
the path does not match where that agent actually reads (so functionally suspect).

| Option | Must-set (CC/OC/Cop/CopCLI) | Add a new target | Global toggle (driver 2) | Safe delivery (driver 3) | Health (driver 4) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 Do nothing | none (all manual) | manual | none | manual, error-prone | n/a |
| 2 Hand-rolled script | whatever you script | you code it | you build it | you build it | you own it |
| 3 mode-io/skill-manager | CC + OC (2/4); Cursor+Codex bonus | **data + existing file codec (easiest)** | yes (symlink) | crash-safe, reversible | CI + 61 tests, pre-1.0/private |
| 4 lijianru/skills-manager | CC + OC + Cop*(nominal)* (~2.5/4) | hardcoded switch (source edit) | add/remove copies only | copy overwrites edits | no tests, bus-factor 1 |
| 5a skill-cli | CC (1/4); pi+Gemini+Codex bonus | data array, but injects into instruction files (pull model) | config-driven (pull) | isolated, safe | 227 tests, ~6h history |
| 5b openhub | OC (1/4); CC label-only | hardcoded to `opencode get` | none | fake-success installs | placeholder tests |
| 5c skill-factory | CC (1/4) | constants (rewrite) | TUI toggle | defensive but 1 target | no CI/tests, bus-factor 1 |
| 6 Commercial product | varies; none lists OC or CopCLI | vendor-controlled | product feature | product feature | vendor-supported |
| 7 Fork/build (of Option 3) | design to all 4 | you design it | inherit from Option 3 | inherit from Option 3 | you co-own it |

No candidate targets Copilot CLI as a distinct destination, and only Option 3
already has both delivery mechanisms (symlink + file generation) the must-set
requires — which is why "add a new target" is the decisive column.

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

Write a small in-house script that symlinks (or copies) a central skills folder
into each agent's directory, with a per-agent path map.

- Good, because it is fully under our control and has no external dependency to
  trust or track.
- Good, because it can be as small and simple as our exact need, and can start
  with symlinks for live edits.
- Bad, because we take on all maintenance, cross-platform edge cases (Windows
  junctions, synced folders), and correctness (collision handling, safe
  removal) ourselves.
- Bad, because per-agent schema/frontmatter differences (Cursor's `.mdc`,
  Copilot's file-based `.github` instructions) still have to be solved by us.
- Bad, because it reinvents most of what the mature candidate tools already do.

Mitigation of negatives: keep it symlink-only and Claude/OpenCode-first to limit
scope; borrow the defensive patterns (preflight checks, backup-before-relink)
already proven in `mode-io/skill-manager` rather than inventing them. Even so,
this converges toward re-implementing Option 3.

### 3. Adopt `mode-io/skill-manager`

A central content store with declarative per-agent binding profiles and symlink
adapters. Recommended winner of the source evaluation.

- Good, because the three originally-evaluated targets (Claude Code, OpenCode,
  Cursor) are modeled natively with correct roots and env overrides — covering 2
  of our 4 must-agents plus one nice-to-have out of the box.
- Good, because it separates a central store from per-agent delivery and enables
  global enable/disable via symlink, with an opt-in copy fallback.
- Good, because targets are declarative data (binding-profile catalog,
  `catalog.py:93`) **and** it already ships a frontmatter-rewriting codec for
  slash-commands (`codecs.py`), so it has both a symlink adapter and a
  file-generating adapter — the two shapes the must-set needs. Adding the missing
  Copilot / Copilot CLI targets is a new binding profile plus reuse of the file
  codec, not a rewrite; this directly serves the top driver.
- Bad, because it does not target Copilot today — "GitHub Copilot" is only an
  unchecked roadmap box (`README.md:405`), and Copilot CLI is absent — so that
  adapter work, though well-supported by the architecture, is still work we must
  do or sponsor.
- Good, because mutations are crash-safe (preflight link validation, backup
  dirs, rollback) and it has real CI and 61 tests.
- Bad, because symlink delivery breaks on filesystems or synced dirs that cannot
  follow links, unless the copy fallback is used.
- Bad, because the repo is pre-1.0 (v0.3.1), marked private, and authored mostly
  by two people — a bus-factor and contract-stability risk.

Mitigation of negatives: pin to a known-good version/commit and vendor or fork
it to remove the "private repo could disappear" risk; use the built-in
materialize-to-copy path on any non-symlink-friendly location. The frontmatter
gap for skills (only slash-commands are rewritten) is acceptable between Claude
Code and OpenCode, which share the same `name`/`description` SKILL.md frontmatter;
GitHub Copilot uses a different, file-based instruction format, so its schema
handling is part of the extension work, not a solved case.

### 4. Adopt `lijianru/skills-manager`

A lightweight Node CLI that copies skill folders into a hardcoded set of target
dirs. It has the **widest nominal coverage** of any candidate.

- Good, because it has built-in cases for Claude Code, OpenCode, Cursor, **and**
  GitHub Copilot, Gemini/Antigravity, and Codex (`link-manager.ts:105-170`) — on
  paper 3 of 4 must-agents — and is simple to run and understand.
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
  edits, with no conflict detection — failing driver 3.
- Bad, because it has no tests, a single author over ~11 days, and a wrong
  hardcoded version string — failing driver 4.
- Bad, because it only adds/removes copies; it does no per-agent schema
  translation and has no true global toggle beyond copy/delete.

Mitigation of negatives: treat target dirs as machine-managed (never hand-edit
them) so overwrite-on-update is harmless; wrap it with our own backup step; pin
the version. This makes it usable as a plain distributor if Option 3 is rejected.

### 5. Adopt another surveyed tool (skill-cli / openhub / skill-factory)

- **`VictorTomaili/skill-cli`** — the best-engineered codebase in the set (227
  tests, security hardening). Of the must-set it covers **only Claude Code**;
  OpenCode and Copilot are absent. It *does* have nice-to-have targets for pi,
  Gemini, and Codex (`paths.js:17-21`), but via **instruction-file injection**
  (a bootstrap block in each agent's global instruction file), not skill
  delivery, and it installs nothing into agent skill dirs. Good engineering,
  wrong shape for the must-set.
- **`24KaratAu/openhub`** — verification found only **OpenCode** is real (installs
  via `opencode get`, `opencode-market_v2.py:171`); the Claude Code and Cursor
  rows in its README have **no corresponding code**. So it covers 1 of 4
  must-agents, has no central select/deselect, and records fake "success" when
  the target binary is absent. Poor fit.
- **`lexler/skill-factory`** — a high-quality skill-*authoring* factory for
  Claude Code only (`skills:13-14`); excellent for creating skills, not for
  cross-agent distribution.

Mitigation of negatives: none of the three closes the multi-agent gap without
substantial work, so mitigation is not the point — however, `skill-factory`'s
authoring layer is worth harvesting *separately* as a complement to whichever
distributor we pick, since creating good skills is a different problem from
distributing them.

### 6. Buy a commercial product

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
- Bad, because **none of them lists OpenCode or Copilot CLI** as a target, so our
  exact must-set is unconfirmed and may be unmet — the same coverage gap as the
  OSS tools, now behind a paywall.
- Bad, because they add cost, external dependency, and potential lock-in/data
  governance concerns for a solo-developer workflow.

Mitigation of negatives: a short trial of SkillReg and Packmind would cheaply
confirm whether either actually covers OpenCode + Copilot CLI; if one does, it may
dominate the OSS options on drivers 3–4 (maintained, tested, supported). This is
now an actionable option, not a dead end.

### 7. Fork / build (extend Option 3)

A purpose-built centralizer with a proper target abstraction and schema adapters
covering all four must-agents — realistically produced by **forking Option 3**
rather than greenfielding, since no candidate covers Copilot/Copilot CLI off the
shelf.

- Good, because it would cover the full must-set (Claude Code, OpenCode, GitHub
  Copilot, Copilot CLI) by design — the one thing no off-the-shelf option does.
- Good, because forking `mode-io/skill-manager` inherits its store, declarative
  target catalog, global toggle, and crash-safe delivery, so this is "extend,"
  not "build from zero."
- Good, because it removes the private/pre-1.0 dependency risk — we own the fork.
- Bad, because we take on long-term maintenance and must track upstream.
- Bad, because Copilot's in-repo, file-based instruction model may not map
  cleanly onto a skills-directory abstraction, so some real design work remains.

Mitigation of negatives: keep the fork minimal — add only the Copilot/Copilot CLI
binding profiles and rebase periodically; if the file-based model resists the
abstraction, deliver Copilot via a generate-file adapter alongside the existing
symlink adapter. Decide fork-vs-adopt with the feasibility spike named in
[Open questions](#open-questions).

## Consequences

- Whatever we pick, **no functional GitHub Copilot or Copilot CLI support exists
  yet** (one tool writes to wrong Copilot paths; none targets Copilot CLI), so it
  must be added; this unavoidable work biases the choice toward an extensible,
  data-driven tool (Option 3) or a fork of one (Option 7).
- Choosing Option 3 or 4 introduces a third-party dependency whose health we must
  monitor and version-pin; in exchange we get working Claude Code + OpenCode
  delivery quickly, before extending to Copilot.
- Choosing symlink-based delivery (Option 3) means being deliberate about
  non-symlink-friendly locations (cloud-synced folders, Windows without junction
  support). Note Copilot instructions are plain markdown files in-repo, which may
  need a copy/generate strategy rather than a symlinked skills dir — a further
  reason the target abstraction must be flexible.
- Any adopted tool becomes the owner of the agent skill directories; we must stop
  hand-editing those directories and treat the central store as the source of
  truth.
- Deferring the decision (Option 1) leaves the duplication and drift problem
  unsolved and grows the eventual migration cost.

## Confirmation

The decision will be considered correctly implemented when, from a single central
store, enabling a skill makes it available in **all four must-cover agents —
Claude Code, OpenCode, GitHub Copilot, and GitHub Copilot CLI** — and disabling
it removes it from all four, verified by inspecting each agent's target location
and by the agent actually loading the skill, with no manual per-agent duplication
and no clobbered local edits. Coverage of the nice-to-have agents (Cursor, pi,
Gemini/antigravity, Codex) is a bonus, not a pass/fail condition.

## Open questions

The decision drivers and their priority are now confirmed (see
[Decision Drivers](#decision-drivers)). The remaining open questions before a
final decision are:

- **Copilot / Copilot CLI feasibility (the pivotal question).** Can
  `mode-io/skill-manager`'s binding-profile catalog + its slash-command file codec
  be combined into a new adapter that emits `*.instructions.md` into
  `.github/instructions/` and `~/.copilot/instructions/` (and honors
  `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`)? A short spike settles Option 3 vs. Option 7:
  if the file codec generalizes to Copilot, Option 3 wins; if the file-based model
  resists the skills-directory abstraction, Option 7 (fork) is the realistic path.
- **Verify, don't trust, `lijianru`'s extra targets.** If Option 4 is
  reconsidered, confirm whether its Copilot/Gemini paths were corrected to the
  agents' real locations — as verified, they are wrong and likely non-functional.
- **Commercial trial.** Do **SkillReg** or **Packmind** actually cover OpenCode
  and Copilot CLI? A brief hands-on trial would confirm; if either does, Option 6
  may beat the OSS options on drivers 3–4.
- **Private/pre-1.0 risk.** `mode-io/skill-manager` is marked private and pre-1.0;
  confirm licensing and a vendoring/pinning strategy before depending on it.

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
