# update-memory-bank

A Claude Code skill that creates or updates the memory bank for the current feature
branch at the end of a session.

## When to use

The virtual machine may be destroyed at any time. This skill keeps the memory bank
perpetually current so a fresh agent can always resume without loss of context.

Claude will auto-invoke this skill after completing significant milestones or
making key decisions. You can also invoke it manually at any time, and should
always do so before ending a session.

## Installation

Copy the `update-memory-bank/` directory to one of the following locations:

| Scope | Path |
| --- | --- |
| Personal (all projects) | `~/.claude/skills/update-memory-bank/` |
| Project only | `.claude/skills/update-memory-bank/` |

## Usage

```text
/update-memory-bank
```

No arguments needed — the skill derives all content from the current session
context. Only outdated or missing files are updated; accurate files are skipped.

## Requirements

The project must have a memory bank rule file at:

```text
.cursor/rules/general/500-cline-memory-bank.mdc
```

This file defines the required memory bank structure and file conventions.
