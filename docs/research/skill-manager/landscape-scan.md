# Landscape Scan — Open-Source Skill Managers (2026-09-05)

> **Frozen research** behind
> [ADR 002](../../architecture-decisions/002-skill-manager-tool-selection.md).
> Point-in-time as of 2026-09-05; pinned HEADs recorded inside. Not maintained.

Companion evidence for [002-skill-manager-tool-selection.md](../../architecture-decisions/002-skill-manager-tool-selection.md).
A second web-research round widened the search beyond the original five tools (see
[source-code-evaluation.md](source-code-evaluation.md)) and source-verified six
further candidates against the decision drivers: (1) per-project subset selection,
(2) Claude Code out of the box, (3) cheap extensibility to further agents,
(4) safe delivery, (5) long-term health.

## Method

A discovery agent searched GitHub, npm/PyPI, awesome-lists, and HN/Reddit (queries
recorded below). Candidates plausibly meeting drivers 1–2 were cloned and
source-verified by a read-only agent (or inline where an agent could not report),
each pinned to a HEAD commit. Claims are grounded in `file:line`; results are
pinned to the recorded HEADs and will drift if re-cloned.

Discovery queries (exa + WebSearch): "centralize Claude Code skills per project /
SKILL.md manager"; "cross-agent rules sync AGENTS.md CLAUDE.md generate from single
source"; "claude code skills manager central registry per-project symlink"; "agent
skills manager registry install per project"; "github topics skills-manager"; test
signals ("pytest / cargo test / vitest").

## Verified candidates

### Leonezz/skills-mgr — HEAD fded9c6 (2026-04-15)
Rust CLI + Tauri GUI + MCP.
- d1 per-project: **yes** — per-project profiles with transitive cycle-checked
  `includes` + `base` (`crates/skills-core/src/profiles.rs:56-88`); `activate
  <profile> <project>` places the resolved subset, DB tracks per-project active
  profiles (`placements.rs:229,306-308`).
- d2 Claude Code OOTB: **yes**, both scopes — `presets.rs:9-13`
  (`.claude/skills`, `~/.claude/skills`).
- d3 extensibility: **data-driven** — `config.rs:145-157` (`agents.toml`
  `AgentDef{project_path,global_path,enabled}`) + `agent add --project-path/
  --global-path` (`main.rs:263-273`). Presets are shortcuts only.
- d4 safe delivery: **strongest** — SQLite placements; `doctor` (`main.rs:524`),
  `check-conflicts`; ref-counted reversible deactivate keeps shared
  (`placements.rs:338-354`); conflict-bail unless `--force`; rollback on failure
  (`:278-289`); dry-run.
- d5 health: MIT declared (`Cargo.toml:13`) but **no LICENSE file**; 80 test fns;
  CI (`ci.yml` fmt+clippy+test, ubuntu-only) + `release.yml`; single author; 1★;
  young. Commit history unverifiable (shallow clone).
- Delivery shape: directory **copy** (`placements.rs:278`), not symlink.
- Copilot `.instructions.md`: **no** — `presets.rs:30` copilot=`.github/skills`.

### omrikais/skill-manager (sm) — HEAD 970fb64 (2026-09-03)
Node/TS CLI (`bin: sm`) + MCP. Different author from `mode-io/skill-manager`.
- d1 per-project: **partial** — `.skills.json` manifest with named profiles +
  `activeProfile`; `resolveActiveSkills` merges base+active (`manifest.ts:7-59`).
  But `install --profile` only deploys and never undeploys the prior set
  (`install.ts:35-57`), so switching subsets is additive, not a clean swap.
- d2 Claude Code OOTB: **yes** — symlink to `~/.claude/skills/<slug>`
  (`fs/paths.ts:24-26`, `engine.ts:79-82`).
- d3 extensibility: **hardcoded** — `ToolName='cc'|'codex'` (`fs/paths.ts:85`,
  `core/meta.ts:14-17`, `manifest.ts:9`); only Claude Code + Codex; adding an agent
  edits paths/meta/manifest/engine. Delivery formats are modular (skill /
  legacy-command / legacy-prompt) but tools are not.
- d4 safe delivery: **strong** — no clobber (non-symlink targets reported as
  conflicts, repair refuses to overwrite, `links.ts:94-96,132-135`); atomic
  temp+rename (`links.ts:32-35`); doctor (`doctor.ts:21-203`); `sync --repair`
  (`sync.ts:109-175`); timestamped backups + restore (`backup.ts`); version
  history + non-destructive rollback (`versioning.ts:45-116`).
- d5 health: MIT (`LICENSE`); 84 test files (~774 assertions, vitest);
  CI (`ci.yml`, node 20/22, provenance publish); dependabot enabled (HEAD is
  dependabot merge PR #48); 4★; single author; commits/history unverifiable
  (shallow clone).
- Delivery shape: directory **symlink** (Windows junction fallback)
  (`fs/links.ts:19-66`).
- Copilot `.instructions.md`: **no** — absent.

### Auran0s/sklm — HEAD 0c29fb6 (2026-07-01)
Python CLI.
- d1 per-project: **yes** — central store `~/.sklm/store`, project `.sklm/sklm.yaml`
  tracks `resources` + activated `links`, re-flippable link/unlink
  (`core/workspace.py:67-113`, `core/linking.py:14-52`).
- d2 Claude Code OOTB: **project-only** — `<root>/.claude/skills/`
  (`agents/agents.yaml:4-5`, `agents/generic.py:27-28`); no user-level `~/.claude`.
- d3 extensibility: **data-driven (most)** — 30+ agents as YAML rows;
  `GenericAdapter` serves any `.<dir>/skills/` with zero code
  (`agents/agents.yaml:1-63`, `agents/generic.py:16-35`); non-standard layouts need
  a subclass (`agents/registry.py:67-69`).
- d4 safe delivery: **unsafe** — sync does `shutil.rmtree(target_dir)` per skill and
  removes any dir in the agent skills path not in the linked set
  (`agents/_sync.py:38-40,30-33`), destroying hand-authored skills/local edits; no
  backup, no conflict detection.
- d5 health: MIT (`LICENSE`); 184 test fns; CI (`publish.yml` runs pytest).
  Commits/authors unverifiable (shallow clone).
- Delivery shape: mixed — symlink store→`.sklm/links`, then **copy**
  (`copytree`) links→agent dir (`_sync.py:49`).
- Copilot `.instructions.md`: **no** — `github_copilot.py:29-30` = `.github/skills`.

### rohitg00/skillkit — HEAD d2e5c34 (2026-06-02)
TypeScript monorepo CLI (`skillkit`/`sk`) on npm. The healthiest project found.
- d1 per-project: **partial** — a cross-agent package manager: `install owner/repo`
  clones and `cpSync`-copies a chosen subset into a project (`config.ts:84-93`);
  `--skills` subset filter + `enable`/`disable`. But the `enabled` flag lives in
  each skill's own `.skillkit.json` (`config.ts:122-134`), so a shared skill's
  enable-state is global, not per-repo. Not central-store subset activation.
- d2 Claude Code OOTB: **yes** — `agent-config.ts:42-53`.
- d3 extensibility: **data-driven** — `AGENT_CONFIG` real 46-row table
  (`agent-config.ts`), plus a `translate` FormatTranslator (SKILL.md → per-agent
  formats). Best d3 machinery of the batch; but only ~a subset of rows have wired
  adapters (`agents/index.ts`), the rest are config-only stubs.
- d4 safe delivery: **decent** — skip-existing unless `--force`
  (`install.ts:557-559`); path-traversal guard (`:186-189`); security scan gate
  (`:432-435`); marker-idempotent sync. No content-integrity lockfile.
- d5 health: **Apache-2.0** (`LICENSE`); ~1537 test assertions + 11 e2e; CI
  (ci/publish/auto-publish); 1470★; sole author; commit history unverifiable
  (shallow clone).
- Delivery shape: git-clone → copy subset into agent dir + `.skillkit.json` → sync
  renders enabled skills into the config file between markers; separate `translate`.
- Copilot `.instructions.md`: **no (legacy only)** — `translator/formats/
  copilot.ts:198-207` emits `.github/copilot-instructions.md`, not the per-file
  `.instructions.md` form.

### xingkongliang/skills-manager — HEAD bb926d0 (2026-09-05)
Tauri desktop GUI. MIT (`LICENSE`). **GUI-only, no headless surface** — no CLI
`bin`, no MCP server; delivery logic lives in `src-tauri/src/commands/*.rs`
invoked only from the webview. 0 tests. 4270★. Unusable for an automated
per-project pipeline despite popularity.

### jiweiyeah/Skills-Manager — HEAD e866b01 (2026-08-25)
Tauri desktop GUI. LICENSE present. **GUI-only, no headless surface** — no CLI
`bin`; `src-tauri/src/commands/cli.rs` invokes external CLIs rather than exposing
one. 33 tests. 971★. Same limitation as above.

## Summary

- New native-delivery per-project tools (`skills-mgr`, `omrikais/sm`) remove the
  runtime-pull enforcement caveat that limited `skill-cli`, making the day-one lead
  contested.
- `skills-mgr` is the best architectural fit (per-project profiles + data-driven
  agents + strongest safe delivery); caveats are health (young/1★) and a missing
  LICENSE file.
- `sklm` is disqualified on safe delivery (destructive `rmtree` sync); `skillkit`
  is the healthiest but the wrong shape (package manager); the desktop GUIs are
  unusable headless.
- No verified tool emits the modern Copilot `.instructions.md` shape; that remains
  extension work regardless of the day-one pick.
