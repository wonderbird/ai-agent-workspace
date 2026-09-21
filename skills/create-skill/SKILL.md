---
name: create-skill
description: >
  Author a new skill in the sboos-skills source repo, deploy it with Skill Manager (sm), verify it,
  and commit it. Use when the user says "create a skill", "make this a skill", "turn these
  instructions into a skill", "add a new skill", wants repeated instructions or a section of
  AGENTS.md persisted as a reusable procedure, or invokes /create-skill.
argument-hint: "[skill-name]"
---

Skills live in a git source repo and are deployed as symlinks by Skill Manager. Author in the
source repo — never edit the deployed copy under `~/.skill-manager/skills/`, which `sm import`
overwrites.

## 1. Author

Path: `~/.skill-manager/sources/sboos-skills/skills/<name>/SKILL.md`

Name the directory after what the skill does, lowercase with hyphens; it becomes the `/<name>`
command. Read a sibling skill first and match its register.

```yaml
---
name: <name>
description: >
  What the skill does, then when to use it — including the literal phrases a user would say
  and the /<name> invocation.
argument-hint: "[work-item-id]"   # optional
---
```

- The opening `---` MUST be the first line, or the whole file is treated as body text.
- `description` is the only field that decides whether the skill ever loads. Lead with the use
  case; `description` plus `when_to_use` is truncated at 1536 characters in the skill listing.
- All other fields are optional. Add `disable-model-invocation: true` for procedures that should
  run only when explicitly invoked.

Body rules:

- Once loaded, the body stays in context across turns — every line is a recurring cost. State what
  to do, not why.
- Write the decisions and the gotchas, not a transcript. Exact commands, field names and paths
  that are tedious to rediscover earn their place; narration does not.
- Encode failure modes you actually hit, with the resolution. That is the part a fresh agent
  cannot re-derive.
- Reference sibling skills by name for adjacent work instead of duplicating their content, and
  name what is out of scope.

## 2. Deploy

```bash
sm import ~/.skill-manager/sources/sboos-skills/skills/<name>
```

`import` deploys to **user** scope for both tools right away. Keep that for general-purpose
skills. For a skill bound to one organization, project or repo, move it to project scope:

```bash
sm remove <name> --cc && sm remove <name> --codex   # no --all flag exists
cd <project> && sm add <name> --project --codex     # scope follows the working directory
```

Then add the entry to the project's `.skills.json` **by hand** — neither `import` nor `add`
updates the manifest, and `sm init --from-current` refuses to overwrite an existing one:

```json
{ "name": "<name>", "tools": ["codex"], "scope": "project" }
```

## 3. Verify before committing

- `sm info <name>` — a rendered description and the expected Active Links prove the frontmatter
  parsed and the symlink resolved. Silence about the description means broken frontmatter.
- Run the skill's own commands once. A skill documenting commands that do not execute is worse
  than no skill.

## 4. Commit

In the source repo, per the `commit` skill: agent-facing files take `ai(skills):`, never `docs:`
or `chore:`. The headline states the capability the agent gains, not the file that changed —
"ai(skills): read azure devops work items via az cli".

History there is linear. When the remote has moved on, `git rebase origin/main` before pushing;
never force-push a branch that is already shared.

Deploying is separate from publishing: `sm import` copies into `~/.skill-manager/skills/`, so the
skill works locally before the commit exists, and other machines only see it after the push plus
a source sync (`sm` TUI → `r` → select source → `I`).
