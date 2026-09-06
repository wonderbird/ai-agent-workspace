# How to manage skills in this project

Skills for coding agents (Claude Code, OpenCode, and other harnesses that read
`.agents/skills`) are managed with two tools:

- **[omrikais/skill-manager](https://github.com/omrikais/skill-manager) (`sm`)** —
  the manager: installs, links, enables, and disables skills locally and globally.
- **[vercel-labs/skills](https://github.com/vercel-labs/skills) (`npx skills`)** —
  used only to *discover* skills.

The rationale is recorded in
[ADR 002: Centralizing Skills Across Coding Agents](https://github.com/wonderbird/ai-agent-workspace/blob/main/docs/architecture-decisions/002-skill-manager-tool-selection.md)
of the `ai-agent-workspace` repository.

## Prerequisites

- `sm` installed and on your `PATH`.
- `npx` available (for discovery only).

## Everyday workflow

```shell
# 1. Discover a skill (opens a search window; or pass a name)
npx skills find
npx skills find "deploy-to-vercel"

# 2. Install it with sm (source is cloned into ~/.skill-manager/sources/)
sm install <owner>/<repo> "deploy-to-vercel"

# 3. Link it into this project and/or globally via the TUI
sm

# 4. Record the project's skill set, then commit the manifest
rm -f .skills.json && sm init --from-current
git add .skills.json && git commit -m "ai: configure project skills (skill-manager sm)"
```

## What is committed

- **`.skills.json`** — yes. It is the project's skill manifest and the single source
  of truth for which skills this project uses.
- **`.claude/` and `.agents/`** — no. They hold links derived from the manifest and
  are rebuilt on demand.

## Restore after cloning

```shell
sm install
```

This rebuilds the links for every skill in `.skills.json`, into both
`.claude/skills` and `.agents/skills`.

## Things to know

- `sm install` **only adds** — it never deletes. To disable or swap a skill, use the
  `sm` TUI (it removes the skill from the local dirs).
- `sm install` also links the manifest's **global** skills, which is usually what you
  want.
- Skill repositories are distinguished **by repo name only, not owner** — keep repo
  names unique across your sources.
- `npx skills` can install skills too, but its restore is incomplete (it re-links
  only `.agents/`, not `.claude/`, and cannot restore global skills). Prefer `sm` for
  install/restore; use `npx skills find` for discovery. If you do use the `npx skills`
  restore, the `ai-agent-workspace` repo ships
  `scripts/restore-claude-skills-links.sh` to recreate the `.claude/skills` links.
