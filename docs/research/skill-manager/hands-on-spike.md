# Hands-on spike: managing skills with omrikais/sm and vercel-labs/skills

> **Frozen research** behind
> [ADR 002](../../architecture-decisions/002-skill-manager-tool-selection.md).
> Hands-on observations at spike time (2026-09-06); tool behavior may have changed
> since. Not maintained.

This note records the hands-on spike behind
[ADR 002: Centralizing Skills Across Coding Agents](../../architecture-decisions/002-skill-manager-tool-selection.md).
It is part of the ai-agent-workspace project. Superscript-style markers like `(1)`
point to the [References](#references) section.

## Using omrikais Skill Manager and vercel-labs skills together

Because [vercel-labs/skills](https://github.com/vercel-labs/skills) (1) searches
skills so well, I want to use that tool to *identify* skills:

```shell
npx skills find
npx skills find "skill-name"
```

A skill found this way can then be installed and managed with
[omrikais/skill-manager](https://github.com/omrikais/skill-manager) (2):

> [!WARNING]
> **Repository names must be unique**
>
> To distinguish skill repositories, only the repository name is used, not the
> owner name.

```shell
# A skill found with `npx skills find` can be installed from its git repo —
# here using the "deploy-to-vercel" skill as an example.
sm install vercel-labs/agent-skills "deploy-to-vercel"

# The source then lands in
vi ~/.skill-manager/sources.json

# and the cloned skill(s) in
ls -la ~/.skill-manager/sources/<slug>/
```

Next, link the skill into the project or globally via `sm`.

Afterwards you can rewrite the `.skills.json` file:

```shell
rm -f .skills.json && sm init --from-current
```

> [!IMPORTANT]
> **A `npx skills` skill must later be reinstalled with `sm install`**
>
> If `~/.skill-manager/sources.json` and the `~/.skill-manager/sources/` folder do
> not exist, a foreign skill must first be installed with the `sm install` command
> shown above.

## omrikais Skill Manager (sm)

[omrikais/skill-manager](https://github.com/omrikais/skill-manager) (2)

### Verdict: Skill Manager meets my needs for both local and global skills

Skill Manager matches what I want quite closely. I can manage my own skills with it
and install them locally or globally into the `.claude` and/or the `.agents`
folder. That makes them usable by OpenCode among others — vercel-labs/skills (1)
contains a list of many harnesses that load skills from `.agents/skills`.

Skill packages can be created as a GitHub repository and shared.

The tool lets you create profiles, which can then be used like a project template.

Project manifest files (`.skills.json`) define the skills used in a project. Those
skills can then be installed with `sm install`.

### Usage

> [!WARNING]
> **`sm install` also installs global skills from the manifest**
>
> This is actually very good, because then all the required skills are always
> linked.
>
> If you would rather have all project skills locally, you can simply adjust that in
> the `.skills.json` file.

> [!NOTE]
> **`sm install` does not delete**
>
> `sm install` only *adds* skills from the `.skills.json` manifest (global and
> local).
>
> If only the manifest's skills should be installed, first delete the symlinks in the
> corresponding skill directories:
>
> ```shell
> rm -rv .claude/skills/*; \
> rm -rv .agents/skills/*
> ```

```shell
# Open the Skill Manager TUI
sm

# Here you can install skills globally and/or into the current project.

# The following file holds the machine-wide configuration:
vi ~/.skill-manager/state.json

# After installing the skills, the configuration can be saved as
# .skills.json in the project folder:
sm init --from-current

# To update .skills.json, delete the current file and recreate it.
rm -f .skills.json && sm init --from-current

# This writes the globally and locally available project skills into
# the .skills.json file
vi .skills.json

# It can then be committed to git
git add .skills.json && git commit -m "ai: configure project skills (skill-manager sm)"

# The .agents and .claude folders do not need to be committed to git.
# After cloning they can be restored as follows:
#
# NOTES:
# - sm install also installs the global skills!
# - sm install only adds and does not disable.
sm install
```

## vercel-labs skills

[vercel-labs/skills](https://github.com/vercel-labs/skills) (1)

### Verdict: searching for skills is great, but restoring skills is inadequate

Overall the tool feels good. The community also seems to enjoy using it (3).

Skills can be installed from several sources:

- git repositories
- local folders

Skills can be installed into the local project or globally. Skills installed with
`npx skill add` are stored in a configuration file.

> [!NOTE]
> Only `npx skill add` updates the configuration file.

> [!WARNING]
> **Restoring skills is still incomplete**
>
> Unfortunately skills are so far restored only into the `.agents` folder. The
> symlinks in the other folders are not (yet) created.
>
> The feature for restoring project skills is marked "experimental".
>
> Global skills are not (yet) restored.

### Risks

- Only a single maintainer merges pull requests. Between July and September 2026
  there were no merges.

### Gaps

- Restoring project skills is "experimental" and considers only the `.agents`
  folder. Skills are not added to `.claude`. There are, however, open feature
  requests (issues) and pull requests on the topic.

- Global skills cannot be restored. The globally installed skills are tracked in the
  global lock file but not re-linked. Here too there are feature requests and pull
  requests.

### Usage

The [AGENTS.md](https://github.com/vercel-labs/skills/blob/main/AGENTS.md) contains
more detailed CLI documentation.

Unfortunately the documentation is not sufficient to get comfortable with the tool.
It is therefore best to clone the
[vercel-labs/skills](https://github.com/vercel-labs/skills) repository and let an
LLM advise you.

Skills activated in the project are stored in `./skill-lock.json`.

> [!NOTE]
> **A different file name is used for global skills — `.skill-lock.json`**
>
> Global skills are stored in the `XDG_STATE_HOME` config folder, i.e. under Linux
> in `~/.config/skills/.skill-lock.json`. If that file does not exist, storage
> defaults to `~/.agents/.skill-lock.json`.

```shell
# `npx skills find` without a parameter simply opens a search window.
# It lets you search for skills.
npx skills find

# You need the following command to get the exact provider URL
# when you know the name of the skill
npx skills find "deploy-to-vercel"

# Then install the skill — only the `npx skills add` command writes
# the skill into the local skills-lock.json, or into the
# global ~/.agents/.skills-lock.json file.
#
# The skill's original is placed in .agents/skills/<slug>/.
# In the other folders, e.g. .claude/skills/, a symlink is then
# created. The "Installation Summary" describes this before the
# installation.
npx skills add vercel-labs/agent-skills@deploy-to-vercel

# Afterwards the skill appears in the local skills-lock.json file
vi skills-lock.json

# With the -g (--global) parameter you install skills globally
npx skills add --global vercel-labs/agent-skills@deploy-to-vercel

# Afterwards the skill appears in the global .skill-lock.json file
#
# CAUTION: the file name differs from the local file name!
vi ~/.agents/.skill-lock.json

# Local skills are removed with
npx skills remove "deploy-to-vercel"

# The same for globally installed skills:
npx skills remove --global "deploy-to-vercel"

# The .agents and .claude folders do not need to be committed to git.
# After cloning they can be restored as follows:
#
# NOTE:
# - Skills are restored only into the .agents/skills folder.
npx skills experimental_install
```

To work around the incomplete restore, the
[`scripts/restore-claude-skills-links.sh`](../../../scripts/restore-claude-skills-links.sh)
script recreates the `.claude/skills` links from the skills present in
`.agents/skills` (never clobbering real directories). It is only needed for the
vercel-only restore flow; `sm install` links into both dirs directly.

## References

(1) vercel-labs/skills — <https://github.com/vercel-labs/skills>

(2) omrikais/skill-manager — <https://github.com/omrikais/skill-manager>

(3) Matt Pocock, skills — <https://github.com/mattpocock/skills> (community use of
    vercel-labs/skills).
