# Scorecard — vercel-labs/skills (`npx skills`) (2026-09-05)

> **Frozen research** behind
> [ADR 002](../../architecture-decisions/002-skill-manager-tool-selection.md).
> Point-in-time as of 2026-09-05; source-verified at pinned HEAD `435076e`, with
> ★/issue counts web-observed that day. Not maintained.

Companion evidence for [002-skill-manager-tool-selection.md](../../architecture-decisions/002-skill-manager-tool-selection.md),
Option 14. This tool was missed by the earlier scans and was surfaced by the
enterprise packaging-standards review
([packaging-standards.md](packaging-standards.md)). It is scored against
the same decision drivers as the landscape scan: (1) per-project subset selection,
(2) Claude Code out of the box, (3) cheap extensibility to further agents,
(4) safe delivery, (5) long-term health.

## Method

The repository was cloned and pinned to a HEAD commit, then read-only
source-verified; claims are grounded in `file:line` and will drift if re-cloned.
The clone was initially shallow (`--depth 1`) and then deepened
(`git fetch --deepen 200`, 350 commits retrieved) specifically to make the
commit-cadence / "active" claim verifiable rather than asserted — the standard the
scan applied to `omrikais/sm`, whose shallow clone left cadence unverifiable.

Two claim classes are separated deliberately:

- **Source-verified (clone-derivable at the pinned HEAD):** code paths, delivery
  model, command set, `LICENSE` presence, test-file count, CI config, and — after
  deepening — commit cadence and author spread.
- **Web-observed (not derivable from a clone), recorded 2026-09-05:** GitHub star
  count and issue/PR volume. These are point-in-time observations, not verified
  facts about the code.

## Verified candidate

### vercel-labs/skills (`npx skills`) — HEAD `435076e` (2026-08-18)

TypeScript CLI on npm. Canonical-store + per-agent-symlink delivery model.

- **d1 per-project — yes (activate + disable), with a store-shape reservation.**
  Activate: project scope is the default (skills resolve to the canonical
  `.agents/skills/`, `-g` selects global), `--skill <names>` narrows to a subset
  (`src/install.ts:31-32`, `src/add.ts`). Disable/swap: `remove` accepts named
  skills, `--all`, `*`, or an interactive multiselect (`src/remove.ts:166-195`),
  with a guard that refuses `--all` combined with named skills so an agent cannot
  mass-delete by accident (`src/remove.ts:79-90`). **Reservation:** the "central
  store" is a *distribution* model — skills are pulled *from* a source repo /
  registry into each project's canonical dir (package-manager shape), not the "one
  local store, symlink a per-project view" model of `skills-mgr`. It satisfies the
  activate/disable *mechanics* of d1; it does **not** natively match d1's
  single-central-store *framing* (one store as single source of truth, each project
  a view onto it). This is a spike gate, not a settled pass.
- **d2 Claude Code OOTB — yes.** `claude-code` is a native entry
  (`src/agents.ts:152-159`, `.claude/skills` + `~/.claude/skills`); universal
  agents resolve to the canonical dir (`src/installer.ts:98`).
- **d3 extensibility — data-driven, but no Copilot file-gen.** The `agents` record
  holds 20+ entries (`src/agents.ts:79+`), including `claude-code`,
  `github-copilot`, `gemini-cli`, `antigravity-cli`; adding a skills-directory
  agent is a data entry. **But** `github-copilot` maps to a skills *directory*
  (`skillsDir: '.agents/skills'`, global `~/.copilot/skills`,
  `src/agents.ts:350-357`), **not** the file-based `.instructions.md` shape real
  Copilot / Copilot CLI consume — so, like every other candidate, the file-based
  Copilot target is nominal here and remains extension work. Upstream advertises
  75+ agents; only the 20+ in the `agents` record are source-confirmed.
- **d4 safe delivery — strong.** Canonical copy under `.agents/skills/` symlinked
  per agent; removal is **ref-counted** so uninstalling from one agent does not
  break another (`src/remove.ts:281-298`, issues #287/#1718); lock-tracked,
  ENOENT-tolerant scans, atomic, interactive-path confirmation before delete.
  Delivery within a project is live (symlink) — no refresh step. **But** the
  central-store→project step is a distribution *pull*: editing the one central
  source repo requires re-`add`/`sync` into each consuming project, i.e. the same
  copy-staleness class the scan penalized `skills-mgr` for — the live-edit benefit
  holds only *within* a project, not across the store boundary.
- **d5 health — the strongest in the survey.**
  - Source-verified: `LICENSE` present (MIT); 58 test files; CI
    (`.github/workflows/ci.yml`); after deepening, **active multi-author cadence** —
    30 commits in 2026-07, 17 in 2026-08 (to HEAD 2026-08-18); top authors Andrew
    Qu (39), Jonathan Hefner (11), plus a `vercel-labs publish` bot and ~10 further
    contributors in the last 100 commits — bus-factor clearly >1.
  - Web-observed (2026-09-05): ~30.4k★, hundreds of open issues/PRs. If accurate,
    this is by far the most-starred tool in the survey (next is a GUI at 4270★), so
    it warrants the explicit source rather than being folded into "source-verified".

- Delivery shape: canonical dir + **symlink** into native agent dirs.
- Copilot `.instructions.md`: **no** (`src/agents.ts:350-357`).

## Net position

On the drivers, this tool leads decisively on **d5** and clears the
**activate/disable mechanics of d1**, **d2**, and **d4** with native symlink
delivery. Its two honest limits: (a) the "central store" is a distribution/registry
model, so it does not match d1's literal single-store framing — on that framing
`skills-mgr` fits better; and (b) it does not serve the file-based Copilot target.
Because d5 is the lowest-priority driver, its LEAD status in ADR 002 is a
driver-priority inversion that the spike must weigh openly: the health case is
strong and now verified, but d1's store-shape gate is unresolved.
