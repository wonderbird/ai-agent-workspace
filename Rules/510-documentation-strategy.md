# Documentation Strategy

## Overview

Projects use structured documentation following specialized templates and patterns. This rule defines the general documentation strategy that encompasses multiple specialized approaches.

## Documentation Folder Structure

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

## Future Documentation Patterns

### `requirements/` - Business Requirements (Future)

- **Purpose**: Business requirements and stakeholder needs
- **Pattern**: Follows req42 requirements template
- **Content**: Requirements specifications, stakeholder analysis, business rules

## Documentation Guidelines

### When to Use `memory-bank/`

- Current milestone context and decisions
- Active development insights and learnings
- Progress tracking and task management
- Working memory for coding agents

### When to Use `docs/`

- Interface specifications (e.g., API documentation)
- Architecture decisions and patterns
- Long-term technical references
- Stable documentation that won't change frequently

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
- [req42 Requirements Template](https://req42.de/)
- [Cline Memory Bank Pattern](500-cline-memory-bank.md)
