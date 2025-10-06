# Documentation Strategy

## Overview

Projects use structured documentation following specialized templates and patterns. This rule defines the general documentation strategy that encompasses multiple specialized approaches.

## Documentation Structure

### `README.md` - Developer Onboarding

- **Purpose**: Minimal document for developers to get started quickly
- **Pattern**: Concise, action-oriented, no documentation duplication
- **Content**: Quick start, prerequisites, basic usage, development commands
- **References**: May include links to detailed documentation in `memory-bank/` and `docs/` when appropriate
- **Lifecycle**: Updated when setup/usage changes, kept minimal
- **Reading**: First file to read for new developers

### `memory-bank/` - Working Memory

- **Purpose**: Milestone-focused working memory for developers and coding agents
- **Pattern**: Follows cline memory bank pattern (see 500-cline-memory-bank.md)
- **Content**: Current iteration context, active decisions, progress tracking
- **Lifecycle**: Updated frequently during development, reviewed at milestone completion
- **Reading**: MUST read ALL files in sequence defined in 500-cline-memory-bank.md

### `docs/` - Architecture Documentation

- **Purpose**: Long-term architecture and interface documentation
- **Pattern**: Follows arc42 architecture documentation template
- **Content**: Stable reference materials, interface specifications, architecture decisions
- **Lifecycle**: Created when stable, updated when architecture changes
- **Reading**: Read as needed for specific context

## Usage Guidelines

- **README.md**: Always present, minimal developer onboarding
- **memory-bank/**: Current milestone context, active development insights, progress tracking
- **docs/**: Stable interface specifications, architecture decisions, long-term references

### Migration Strategy

- Content moves from `memory-bank/` to `docs/` when it becomes stable
- Review at milestone completion to identify content for migration
- Maintain clear separation between working memory and reference documentation

## Integration with Specialized Rules

- **500-cline-memory-bank.md**: Defines memory bank pattern and reading sequence
- **520-memory-bank-of-current-project.md**: Applies memory bank pattern to current projects
- **530-clarify-current-project.md**: Handles project selection and project-specific rules

## References

- [arc42 Architecture Documentation](https://docs.arc42.org/)
- [Cline Memory Bank Pattern](500-cline-memory-bank.md)
