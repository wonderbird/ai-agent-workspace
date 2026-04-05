# sdd-workflow — Spec Driven Development Workflow

A Claude Code skill that runs the full Spec Driven Development workflow from
specification to acceptance test in a single session.

> **Beta** — This workflow is in a beta testing phase. A first proof of
> concept has been performed successfully using Claude Sonnet 4.6 with
> medium thinking effort.

## Design: subagent architecture

Each speckit command and each review step is executed in a dedicated subagent. This
keeps the main (orchestrator) agent's context lean, so the entire development
workflow — from spec definition through acceptance test — can run in a single chat
session without hitting the context token limit.

## Phases

| Phase | What happens |
| --- | --- |
| 1 — Define Specification | Scope Q&A, speckit.specify, speckit.clarify |
| 2 — Create Plan and Tasks | speckit.plan, speckit.tasks, speckit.analyze |
| 3 — Implementation and Review | speckit.implement, code review, fix findings |
| 4 — Acceptance Test | Guided step-by-step test execution |

The skill pauses naturally wherever user input is needed (Q&A, command output).
A task list is created at the start so the agent stays on track across all phases.

## Installation

Copy the `sdd-workflow/` directory to one of the following locations:

| Scope | Path |
| --- | --- |
| Personal (all projects) | `~/.claude/skills/sdd-workflow/` |
| Project only | `.claude/skills/sdd-workflow/` |

## Usage

```text
/sdd-workflow <feature description> <@context-reference> [<@patterns-reference>]
```

### Arguments

- `<feature description>` — 1–2 sentences on what is being built and why
- `<@context-reference>` — path to existing spec or code to read before starting
- `<@patterns-reference>` — *(optional)* path to an existing component whose
  structure and conventions the new feature should follow

### Example

```text
/sdd-workflow Install the Flutter SDK as a new Ansible role for Chrome/web development @specs/003-android-studio-role/ @roles/android_studio/
```

## Requirements

This skill invokes the following [speckit](https://github.com/github/spec-kit)
commands, which must be available as skills in the project:

- `speckit.specify`
- `speckit.clarify`
- `speckit.plan`
- `speckit.tasks`
- `speckit.analyze`
- `speckit.implement`
