# Architectural Evaluation of Skill-Chooser Tools

## Context & method

We want to centralize prompt rules, MCP configs, and skill definitions in one
repository and select/deselect skills globally for coding agents, across three
canonical target agents: **OpenCode, Claude Code, Cursor**. Five open-source
tools claim to solve this. This document is an evidence-based evaluation grounded
in each tool's real source code, not the prior survey's blurbs.

**How it was done.** Each of the five repositories was cloned fresh (full clone,
not shallow) into `$HOME/Documents/Cline/skill-chooser-eval-repos/`, a persistent
folder verified to be outside any enclosing git repository. Five specialist
sub-agents analyzed exactly one tool each, in parallel, read-only, and returned
a fixed report template. The orchestrator then spot-checked at least one claim
per tool against the cited source, and reconciled the prior survey's metadata
against git reality.

**Pinned revisions (authoritative HEADs).** Results are pinned to these commits.
Re-cloning later will drift; cite these hashes.

| Tool | HEAD commit | HEAD date |
| :--- | :--- | :--- |
| lexler/skill-factory | `80173337304a5f6e861afe1ff74eb2f3f2c8fb1b` | Wed Aug 26 13:22:07 2026 +0200 |
| mode-io/skill-manager | `6ca969cbbc2e6b9a0de719858a68b33b3c37844a` | Thu Jul 30 19:10:13 2026 +0800 |
| 24KaratAu/openhub | `716bfbcb4e9c326a949004a815cd889a7808279d` | Wed Aug 12 21:06:31 2026 +0530 |
| lijianru/skills-manager | `e2c09a907d834a062494c5a706fdef3f3aa511ca` | Sun Feb 8 10:40:30 2026 +0800 |
| VictorTomaili/skill-cli | `566c99233284c5e77517185823978846e278fc50` | Wed Jul 8 03:51:38 2026 +0300 |

**Scoring rubric (1–5, identical for all tools).** 1 = unusable / feature
absent; 2 = poor; 3 = adequate; 4 = strong; 5 = exemplary (justified with
`file:line`). Four dimensions: (1) Code quality, (2) Architecture/design,
(3) Maintainability/health, (4) Fit for our use case.

## Per-tool scorecard

### mode-io/skill-manager

- **Code quality: 5** — `skill_manager/application/skills/adapters.py:136-152` — preflight-link + backup-dir + rollback, atomic writes, file locks, typed dataclasses, 61 test files.
- **Architecture/design: 5** — `skill_manager/harness/catalog.py:97-291` + `adapters.py:97-122` — declarative per-harness binding profiles (FileTree/ConfigSubtree/CommandFile) drive a central shared store plus symlink adapters; targets are pure data, adapters pure mechanism.
- **Maintainability/health: 4** — `.github/workflows/ci.yml` (Python 3.11–3.14 matrix), release.yml, 90 commits over ~4 months, 6 authors — real CI/release hygiene, but authorship concentrates in 2–3 people and `package.json` marks the repo `"private": true`, pre-1.0 (v0.3.1).
- **Fit (OpenCode/Claude Code/Cursor): 5** — `catalog.py:135-206,225-233` — first-class definitions for claude (`~/.claude/skills`), cursor (`~/.cursor/skills`), opencode (`$XDG_CONFIG_HOME/opencode/skills`) with per-target env overrides and global enable/disable via symlink.

**Strengths.** Central content store decoupled from delivery (`store.py:53-82`, `adapters.py:97-112`); all three canonical targets modeled natively (`catalog.py:135,175,209-233`); crash-safe mutations with rollback (`adapters.py:124-152`); cross-platform link primitive — POSIX symlink and Windows junction via `mklink /J` (`skill_manager/directory_links.py:19,26`); per-harness slash-command codecs for schema differences (`codecs.py:85`).

**Risks.** `_binding_path` scans every category dir per lookup — O(dirs) (`adapters.py:212-220`); symlink delivery breaks silently on filesystems that cannot follow links (OneDrive/synced dirs), mitigated only by opt-in materialize-to-copy; bus factor — 63 of 90 commits by two identities; repo private and pre-1.0.

**Link/delivery strategy (verified): symlink (with optional copy).** `enable_shared_package` creates a directory symlink (POSIX) or junction (Windows) from the harness skill root to the shared-store package — `directory_links.py:19` `link.symlink_to(...)`, `:26` `mklink /J`. Disable removes the link (`adapters.py:114-122`). A copy path exists via `materialize_binding`/`adopt_local_copy` (`shutil.copytree`). No frontmatter-rewrite is applied to skill bodies — SKILL.md is delivered verbatim by link; per-harness rewriting exists only for slash-commands (`codecs.py:85`), not skills.

**Dependencies & tests.** Python >=3.11 backend (FastAPI, uvicorn, ruamel.yaml, tomli-w); React 19 + Vite frontend; lean runtime footprint. Tests: **yes** — 61 pytest files (unit/integration) plus vitest; covers adapters, store concurrency, directory links, harness catalog, HTTP API.

**Fit verdict.** Strong fit — purpose-built to centralize skills in one store and globally enable/disable them per agent via symlink across the exact three targets, with clean target abstraction and crash-safe installs; main caveat is symlink delivery on non-symlink-friendly filesystems and a pre-1.0/private, few-author project.

### lijianru/skills-manager

- **Code quality: 3** — `src/core/linker.ts:15-21`, `src/index.ts:24` — clean small TypeScript, strict mode, but zero tests, confused comments, and a hardcoded wrong version string `.version('0.0.1')` while package.json is 1.0.4.
- **Architecture/design: 3** — `src/core/link-manager.ts:103-170` — reasonable command/service separation, but IDE targets are a hardcoded switch duplicated for global vs project, not an extensible target abstraction.
- **Maintainability/health: 2** — 10 commits, single author over ~11 days (2026-01-28 → 2026-02-08), one tag (1.0.2), no tests, only a publish-on-release workflow (`.github/workflows/publish.yml`) — bus factor 1.
- **Fit (OpenCode/Claude Code/Cursor): 3** — `src/core/link-manager.ts:106-119,146-159` — all three canonical targets have built-in global+project paths, but delivery is raw folder copy with **no** frontmatter/schema translation.

**Strengths.** All three canonical targets built in — Cursor `~/.cursor/skills`, OpenCode `~/.config/opencode/skills`, Claude `~/.claude/skills` (`link-manager.ts:106-119`); selective sub-skill install via interactive checkbox (`:35-73`); central hub + config registry enabling `update` re-sync (`config-manager.ts:5-22`, `update.ts:50-65`); local skill scaffolding with SKILL.md template (`create.ts:50-62`).

**Risks.** No tests anywhere; copy with `overwrite: true` silently clobbers user edits, no conflict detection (`linker.ts:20`); hardcoded IDE switch duplicated global/project (`link-manager.ts:105-130` & `145-170`); version-string lie (CLI reports 0.0.1 vs package 1.0.4); no path/name sanitization on custom targets or URL-derived repo names; silent config-load failures fall back to defaults (`config-manager.ts:43-46`).

**Link/delivery strategy (verified): copy.** `src/core/linker.ts:15-21` `copySkill` calls `fs.copy(source, target, { overwrite: true })` — recursive file copy, no symlink, no frontmatter rewrite. README ("Uses file copying instead of symlinks") and commit `015891a` confirm a deliberate switch from symlink to copy.

**Dependencies & tests.** Node ESM + TypeScript 5.9; runtime commander, inquirer, execa (shells out to `git`), fs-extra, chalk, ora. Tests: **no** — none found, no test script.

**Fit verdict.** Marginal fit — copies skill folders to correct global paths for all three targets, but raw copy with no per-agent frontmatter/schema rewrite, no toggling (only add/remove), and no symlink option; it centralizes distribution but not the schema adaptation the multi-agent use case needs.

### VictorTomaili/skill-cli

- **Code quality: 4** — `src/lib/store.js:42-49`, `src/lib/npx.js:40-48` — clean ESM, small single-purpose modules, pure/testable helpers, security-conscious (name sanitization, shell-injection guards), 227 tests.
- **Architecture/design: 3** — `src/lib/paths.js:16-22`, `src/lib/agents-md.js:71-101` — good lib/commands split and one canonical store, but the multi-agent layer is a hardcoded array + one shared instruction block, no per-agent frontmatter adapter, no link-strategy abstraction.
- **Maintainability/health: 3** — `.github/workflows/ci.yml` (3 OS × node 22/24), release.yml, dependabot; 35/44 commits one author, entire history 2026-07-07→07-08 (~6h) — solid hygiene but bus factor 1 and no sustained activity.
- **Fit (OpenCode/Claude Code/Cursor): 2** — `src/lib/paths.js:16-22` — of the three canonical targets only Claude Code is supported; Cursor explicitly unsupported ("adapter later", `paths.js:15`), OpenCode absent entirely, and delivery puts nothing in target skill dirs.

**Strengths.** Path-traversal defense (`store.js:42-49`); cross-platform shell-injection hardening incl. CVE-2024-27980 workaround (`npx.js:40-48,67-69`); fetch isolated to a temp cwd and cleaned in `finally` (`install.js:26-31,79-81`); idempotent non-destructive bootstrap injection with BEGIN/END markers (`agents-md.js:71-92`); three-layer activation model with ReDoS-capped glob (`config.js:78-113`).

**Risks.** Cursor unimplemented despite being canonical (`paths.js:15`); install correctness fully delegated to external `npx skills add` at runtime, no pinned version, network required (`npx.js:44`); agent target set hardcoded (`paths.js:16-22`); whole project a single ~6h burst by one author; effectiveness depends on the agent obeying a natural-language START GATE prompt, no enforcement (`agents-md.js:26-66`).

**Link/delivery strategy (verified): other (runtime pull-based).** Skills are copied once into a single canonical store `~/.skill-cli/store/<name>/` via `cpSync` (`install.js:53-59`). Nothing is written into agent skill dirs. Instead `skill init -g` injects a bootstrap block into each agent's *global instruction file* (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/.pi/agent/AGENTS.md` — `agents-md.js:79-101`), instructing the agent to pull content at runtime via `skill active`/`skill cat`/`skill trigger`. Selection is config-driven, not filesystem-driven.

**Dependencies & tests.** Node >=22, ESM; runtime @inquirer/core, @inquirer/prompts, picocolors, yaml; install delegates to external `npx skills`. Tests: **yes** — 227 `node --test` unit + CLI tests, network-free via a fixture seam; CI on 3 OS × node 22/24, plus opt-in e2e.

**Fit verdict.** Weak fit — well-built and secure but supports only Claude Code of the three canonical targets (Cursor unimplemented, OpenCode absent), and its runtime-pull model installs nothing into target skill dirs, so it does not implement the symlink/copy/frontmatter-rewrite delivery the use case centers on.

### 24KaratAu/openhub

- **Code quality: 3** — `app/installer.py:32-48` — readable, typed, modular Textual app, but marred by simulated/mock installs that record fake success and a placeholder test.
- **Architecture/design: 2** — `app/exporter.py:33-104` — export is a hardcoded broadcast that writes identical content to every target dir at once; no target abstraction, no selection layer, no strategy pluggability.
- **Maintainability/health: 3** — 9 commits, 4 tags (v0.1.0–v0.1.3), CI matrix (3.10–3.12) + release workflow, small deps — but single-author bus-factor-1 and stray duplicate root files.
- **Fit (OpenCode/Claude Code/Cursor): 2** — `app/exporter.py:45-56` — writes OpenCode + Claude dirs, but Cursor gets no real path (no `.cursor/rules/*.mdc`), and there is no global select/deselect nor central rule/MCP store.

**Strengths.** Clean SQLite cache layer with upsert-preserving-scores (`app/cache.py:13-56,83-119`); deterministic classifier with unit coverage (`app/classifier.py:66-67`); correct conditional frontmatter injection (`app/exporter.py:61-70`); async subprocess install with concurrent stream capture (`app/installer.py:58-88`); CI matrix + release workflow.

**Risks.** **Fake install** — when the `opencode` binary is absent it simulates and still calls `add_installed_package(... "installed")` + reports `[SUCCESS]` (`app/installer.py:44-48`); placeholder `test_env_detector` asserts a self-defined dict, exercises nothing (`tests/test_core.py:56-66`); blind multi-dir broadcast pollutes tools the user may not use (`app/exporter.py:33-56`); dead duplicate monoliths at repo root (`opencode-market_v1.py`/`_v2.py`); half-finished rename (package `openhub-tui`, module `app`, loggers still `opencode-hub`).

**Link/delivery strategy (verified): copy + frontmatter-rewrite (no symlink).** Export generates new SKILL.md/agent `.md` with synthesized YAML frontmatter and writes copies to hardcoded dirs (`app/exporter.py:58-104`); env sync duplicates skill dirs via `shutil.copytree(..., dirs_exist_ok=True)` (`app/env_detector.py:100`). No `os.symlink` anywhere. Cursor `.cursor/rules/*.mdc` is never written — "Cursor" is only a curated-collection label (`app/main.py:290,474`).

**Dependencies & tests.** Python 3.10+; runtime textual, httpx, rapidfuzz. Tests: **yes** — unittest suite (4 tests) but one is a non-functional placeholder.

**Fit verdict.** Poor fit — a GitHub discovery/browse TUI that one-way copies auto-generated SKILL.md into OpenCode/Claude dirs; no central rule/MCP store, no global select/deselect, no per-target schema handling, no real Cursor delivery.

### lexler/skill-factory

- **Code quality: 3** — `skills:69-120` — clean single-file stdlib Python with symlink/type guards, but the 380-line installer has zero tests (tests exist only for helper scripts).
- **Architecture/design: 2** — `skills:11-14` — hardcoded to exactly one target (`~/.claude/skills/` and `./.claude/skills/`); no target abstraction, no per-agent frontmatter, no MCP handling.
- **Maintainability/health: 2** — 426/427 commits by one author, no tags/releases, no `.github/` CI — very active but bus-factor 1 with no release hygiene or automated checks.
- **Fit (OpenCode/Claude Code/Cursor): 2** — `skills:13-14`, `README.md:1-3` — solid for Claude Code alone; OpenCode and Cursor are entirely absent from the installer, so 2 of 3 canonical targets are unsupported.

**Strengths.** Defensive global install refuses to clobber a non-symlink target and cleans stale symlinks before relinking (`skills:75-84`); two deliberate delivery modes — symlink for global, copytree for local (`skills:83,108`); cross-category collision detection (`skills:22-35`); usable curses TUI picker (`skills:241-320`); strong authoring/knowledge layer with vendored docs and eval infrastructure (`docs/map.md:19-40`).

**Risks.** Single-target coupling via module-level constants makes multi-agent support a rewrite (`skills:11-14`); `is_installed` only recognizes symlinks (`skills:56-61`); local install lacks collision safeguards beyond blanket `rmtree` (`skills:104-108`); no CI and no installer tests; fundamentally a skill-*creation* factory, not a distributor (`docs/project.md:3-11`).

**Link/delivery strategy (verified): symlink (global) + copy (local).** Global install symlinks the source into `~/.claude/skills/` via `target.symlink_to(source)` (`skills:83`); local install copies via `shutil.copytree` (`skills:108`). No frontmatter rewriting or schema translation anywhere — skills are delivered verbatim as authored for Claude Code.

**Dependencies & tests.** Python >=3.11 run via `uv`; installer uses only stdlib (`curses`, `shutil`, `pathlib`). Tests: **partial** — pytest for helper scripts only; the installer itself has none.

**Fit verdict.** Poor fit as-is — a Claude-Code-only symlink/copy installer with no target abstraction, no frontmatter-rewrite, and no MCP handling; its real strength is authoring high-quality skills, not multi-agent distribution.

## Comparison matrix

Verified reality (this evaluation) side by side with the prior survey's
unverified claims.

| Tool | HEAD (verified) | Commits: survey / real | Stars: survey / real | Link strategy: survey / verified | Multi-agent (canonical 3): survey / verified |
| :--- | :--- | :--- | :--- | :--- | :--- |
| lexler/skill-factory | `8017333` (Aug 26 2026) | 427 / **427** | 231 / **232** | Symlinks / **symlink (global) + copy (local)** | "Claude native; configurable OpenCode/Cursor" / **Claude Code only** (OpenCode & Cursor absent) |
| mode-io/skill-manager | `6ca969c` (Jul 30 2026) | 48 / **90** | 117 / **7** | Symlinks & frontmatter rewrite / **symlink (+ optional copy); frontmatter-rewrite for slash-commands only, NOT skills** | OpenCode/Claude/Cursor/Codex / **all 3 canonical native** |
| 24KaratAu/openhub | `716bfbc` (Aug 12 2026) | 9 / **9** | 22 / **21** | Direct export/sync / **copy + frontmatter-rewrite (no symlink)** | OpenCode/Claude/Cursor/Windsurf / **OpenCode + Claude only; Cursor is a label, not a real path** |
| lijianru/skills-manager | `e2c09a9` (Feb 8 2026) | 10 / **10** | 18 / **4** | Deep copying / **copy** | OpenCode/Cursor/Windsurf/Claude / **all 3 canonical (copy only, no schema xlate)** |
| VictorTomaili/skill-cli | `566c992` (Jul 8 2026) | 41 / **41** | 4 / **4** | Central store + bootstrapping / **other: runtime pull + instruction-file injection** | OpenCode/Claude/Gemini/Cursor / **Claude Code only** (Cursor stubbed, OpenCode absent) |

Scores (1–5), all four dimensions:

| Tool | Code quality | Architecture | Maintainability | Fit |
| :--- | :---: | :---: | :---: | :---: |
| mode-io/skill-manager | 5 | 5 | 4 | **5** |
| lijianru/skills-manager | 3 | 3 | 2 | **3** |
| VictorTomaili/skill-cli | 4 | 3 | 3 | **2** |
| 24KaratAu/openhub | 3 | 2 | 3 | **2** |
| lexler/skill-factory | 3 | 2 | 2 | **2** |

## Ranked recommendation

**Weighting.** Rank primarily by dimension 4 (Fit). Break ties with dimensions
1 (Code quality), then 2 (Architecture), then 3 (Maintainability), in that order.

Fit tiers: mode-io (5) > lijianru (3) > {skill-cli, openhub, skill-factory all
at 2}. The three-way tie at Fit=2 breaks on Code quality: skill-cli (4) beats
openhub (3) and skill-factory (3); openhub vs skill-factory tie on Code (3) and
Architecture (2), so Maintainability breaks it — openhub (3) over skill-factory
(2).

Final ranking:

1. **mode-io/skill-manager — WINNER.** The only tool purpose-built for exactly
   this problem: a central shared store with declarative per-harness binding
   profiles and symlink adapters covering all three canonical targets
   (`catalog.py:135,175,209-233`), global enable/disable, crash-safe installs,
   real CI and 61 tests. It is the sole tool scoring 5 on Fit and it also tops
   Code quality and Architecture. Trade-offs: symlink delivery breaks on
   filesystems that cannot follow links (mitigated by opt-in copy); repo is
   pre-1.0 and marked private with a concentrated author base — adopt with an
   eye on version-pinning and contributor risk.
2. **lijianru/skills-manager — runner-up.** Distant second. It is the only other
   tool that natively targets all three canonical agents
   (`link-manager.ts:106-119`), but it is copy-only with no schema translation,
   no toggling beyond add/remove, no tests, and bus-factor 1. Usable as a plain
   distributor if mode-io is rejected, but it does not solve schema adaptation.
3. **VictorTomaili/skill-cli.** Best-engineered codebase in the set (security
   hardening, 227 tests) but architecturally off-target: runtime-pull via
   instruction-file injection, Claude-only, Cursor stubbed, OpenCode absent.
4. **24KaratAu/openhub.** A discovery TUI, not a centralizer; blind multi-dir
   broadcast, fake-success installs, no real Cursor path.
5. **lexler/skill-factory.** A high-quality skill-*authoring* factory, Claude
   Code only; strong for creating skills, not for cross-agent distribution.

**Bottom line.** Adopt **mode-io/skill-manager**; it is the only tool whose
architecture matches the centralize-and-select-across-three-agents requirement.
Keep **lijianru/skills-manager** as a lightweight fallback. Consider harvesting
skill-factory's *authoring* layer separately — it solves a different, complementary
problem (creating good skills) rather than distributing them.

## Caveats

- **Agent-type substitution.** The prompt specified `oh-my-claudecode:architect`
  sub-agents. That agent type was not available in this environment; per the
  prompt's Preconditions the five specialists ran as `general-purpose` agents,
  used read-only (no sub-agent modified the cloned source). Read-only was
  enforced by instruction, not by a tool-permission sandbox.
- **Survey metadata discrepancies (survey values were unverified by definition).**
  - **Stars are badly wrong for the two mid-pack tools.** mode-io claimed 117,
    actual **7**; lijianru claimed 18, actual **4**. skill-factory (231→232),
    openhub (22→21), and skill-cli (4→4) are close/exact.
  - **mode-io commit count** claimed 48, actual **90** (survey undercounted).
  - **mode-io "first commit Nov 2025"** is wrong — the real first commit is
    Apr 11 2026; latest Jul 30 2026.
  - **Link-strategy claims were loose.** skill-factory is not "configurable
    OpenCode/Cursor" — it is Claude-only. mode-io's "frontmatter rewriting"
    applies to slash-commands, not skill bodies. openhub's "Cursor" support is a
    label with no real `.cursor/rules` path. skill-cli's "Gemini/Cursor" support
    is stubbed/absent for the canonical set.
  - Survey dates were implausibly future-dated in places; the verified HEAD
    dates in the matrix above are authoritative.
- **Minor citation slips in sub-agent reports (content correct on spot-check).**
  mode-io's symlink primitive lives at `skill_manager/directory_links.py`, not
  `application/skills/directory_links.py` as one citation implied. lijianru's
  version string is at `src/index.ts:24`, not `:31`. Both underlying claims were
  verified true against source.
- **No clone failures.** All five repositories cloned successfully (full clone);
  no repo was dead, renamed, or network-blocked. Star counts were retrieved from
  the GitHub API (network available).
- **Pinning.** All findings are pinned to the HEAD commits listed in Context &
  method. A later re-clone may drift from these revisions.
