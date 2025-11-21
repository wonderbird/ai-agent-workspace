# Active Context: Formalizing the Prompt-Driven Workflow

## Current Work Focus

**Session Goal**: To formalize the prompt-driven workflow by creating a user manual and a structured prompt library in the `docs/` directory. The focus is on establishing the foundational documentation that will support the next iteration of refining and expanding the prompts.

## Recent Changes

### Completed in This Session
1.  **Workflow Formalized**: Created the initial user manual and placeholder prompt library in `docs/prompt-workflow/`.
2.  **ADR Revised**: Updated the project ADR to reflect that the prompt-driven workflow is the true solution to rule degradation.
3.  **Documentation Strategy Aligned**: Placed the new, stable documentation in the `docs/` directory, adhering to the project's documentation rules.

### Key Insights Discovered
- A formal documentation structure for the workflow is essential for its long-term maintenance and usability.
- Placing stable documentation in `docs/` and working memory in `memory-bank/` creates a clear and effective separation of concerns.

## Next Steps

### Immediate Actions (This Session)
1.  **Update Memory Bank**: Align the memory bank's goals with the new focus on formalizing the workflow.
2.  **Refine Prompt Library**: Begin the process of replacing the placeholder prompts with detailed, effective content.

### Short-term Goals (1-2 weeks)
1.  Complete the first draft of all prompts in the prompt library.
2.  Expand the user manual with more detailed examples and best practices.
3.  Begin exploring opportunities to automate the prompt workflow.

## Active Decisions and Considerations

### Decision 1: Documentation-First Approach
- **Approach**: Establish the structure and documentation for the workflow before diving deep into refining the prompt content.
- **Priority**: Ensure the project has a solid, maintainable foundation for the new workflow.
- **Status**: Complete.

## Important Patterns and Preferences

### Stefan's Preferences
- **Rapid Implementation**: Prefers solutions that can be implemented in under two weeks.
- **Minimal Disruption**: Solutions must not block or interrupt the development workflow.
- **Low Maintenance**: Prefers a "set it and forget it" approach with minimal need for ongoing tuning.

## Learnings and Project Insights

### Process Learnings
- **ADR Value**: Using ADRs provides structure and clarity for critical decisions, ensuring they are well-documented and transparent.
- **Limitations of `always_apply`**: The `always_apply` feature in Cursor is not a complete solution for long-term rule adherence; it must be supplemented with active rule re-enforcement.
