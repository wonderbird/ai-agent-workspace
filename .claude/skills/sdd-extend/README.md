# sdd-extend — Spec Driven Development Extension Workflow

A Claude Code skill that extends an existing Spec Driven Development specification
with newly discovered requirements, without overwriting any existing artifacts.

> **Beta** — This workflow mirrors the design of `sdd-workflow` and is
> intended to be used after at least one full `sdd-workflow` session has
> been completed.

## When to use this skill

Use `sdd-extend` when additional requirements are discovered after the initial
specification has been written and a plan already exists. The skill adds the new
requirements to the spec and updates the plan and tasks to cover the gaps — it never
calls `speckit.specify` or `speckit.plan`, which would overwrite the existing artifacts.

Use `sdd-workflow` instead when starting a brand-new feature from scratch.

## Design: subagent architecture

Each speckit command and each review step is executed in a dedicated subagent. This
keeps the main (orchestrator) agent's context lean, so the entire extension workflow
can run in a single chat session without hitting the context token limit.

## Phases

| Phase | What happens |
| --- | --- |
| 1 — Extend Specification | Scope Q&A for new requirements, speckit.clarify |
| 2 — Update Plan and Tasks | speckit.analyze, plan/task gap fixes |
| 3 — Implementation and Review | speckit.implement, code review, fix findings |
| 4 — Acceptance Test | Guided step-by-step test execution for new criteria |

The skill pauses naturally wherever user input is needed (Q&A, command output).
A task list is created at the start so the agent stays on track across all phases.

## Installation

Copy the `sdd-extend/` directory to one of the following locations:

| Scope | Path |
| --- | --- |
| Personal (all projects) | `~/.claude/skills/sdd-extend/` |
| Project only | `.claude/skills/sdd-extend/` |

## Usage

```text
/sdd-extend <additional requirements> <@existing-spec-reference> [<@patterns-reference>]
```

### Arguments

- `<additional requirements>` — 1–2 sentences describing what new requirements were
  discovered and why they are needed
- `<@existing-spec-reference>` — path to the existing spec directory or file
- `<@patterns-reference>` — *(optional)* path to an existing component whose
  structure and conventions the additions should follow

### Example

```text
/sdd-extend Add support for offline mode and background sync @specs/005-data-sync/ @roles/android_studio/
```

## Requirements

This skill invokes the following [speckit](https://github.com/github/spec-kit)
commands, which must be available as skills in the project:

- `speckit.clarify`
- `speckit.analyze`
- `speckit.implement`
