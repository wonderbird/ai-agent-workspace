# AI Agent Workspace

This project provides rules for coding agents similar to the Cline Rules (1).

## Usage

### CLAUDE.md is the root prompt

At the begin of every coding session the ai agent first reads the file
[CLAUDE.md](./CLAUDE.md) in the project directory (2). It informs the agent
about the applicable rules.

You can copy and adapt the [CLAUDE.md](./CLAUDE.md) in this repository for
your project.

### Link rules, commands and skills into your project

The ai agent workspace folder should be next to your project folder(s).

Rules, commands and skills in [`.claude`](./.claude) are intended to be linked
into your project folder(s) via symbolic links. This allows you to maintain a
single source of truth for your agent rules and reuse them across multiple
projects.

The folder [rules-banks](./rules-banks) contains use case specific rules that
you can link into your project as needed.

### Make skills available system-wide

To symlink all skills from `.claude/skills` into `~/.claude/skills`, run the
appropriate script for your OS:

- **Linux:** `scripts/create-skills-links-in-home.sh`
- **Windows (GitBash):** `scripts/create-skills-links-in-home-win.sh`

## Acknowledgements

The [generate-cursor-rules.md](.claude/commands/generate-cursor-rules.md)
command has been adopted from the following Udemy course:

T. Phillips, “Cursor AI Beginner to Pro: Build Production Web Apps with AI,”
Udemy. Accessed: Dec. 06, 2025. [Online]. Available:
[https://www.udemy.com/course/learn-cursor-ai/](https://www.udemy.com/course/learn-cursor-ai/)

## References

(1) Cline Bot, Inc., “Cline rules,” Cline. Accessed: Jun. 09, 2025. [Online].
    Available: [https://docs.cline.bot/features/cline-rules](https://docs.cline.bot/features/cline-rules)

(2) Open AI, "AGENTS.md". Accessed: Oct. 09, 2025. [Online].
    Available: [https://agents.md/](https://agents.md/)
