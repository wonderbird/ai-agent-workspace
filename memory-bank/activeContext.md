# Active Context: Refining Prompt-Driven Workflow

## Current Work Focus

**Session Goal**: To document and refine the newly developed prompt-driven workflow that counteracts AI rule degradation. The focus is on capturing the lessons learned from the initial validation and optimizing the process for better autonomy and reliability.

## Recent Changes

### Completed in This Session
1.  **Initial Validation**: Completed the initial testing of the Cursor IDE setup.
2.  **Identified Rule Degradation**: Discovered that `always_apply` rules in Cursor are insufficient to prevent rule degradation over a session.
3.  **Developed New Workflow**: Created a prompt-driven workflow to re-introduce and enforce rules at critical stages.

### Key Insights Discovered
- **Rule Degradation Persists**: `always_apply` rules are only loaded at the start of a session, leading to the same degradation pattern observed previously.
- **Prompting is Key**: Explicitly instructing the agent to read and apply rules via a structured prompt sequence is an effective countermeasure.
- **Visual Feedback Works**: The emoji-based system for tracking rule application is a simple and effective way to monitor compliance.

## Next Steps

### Immediate Actions (This Session)
1.  **Document New Workflow**: Update the memory bank to reflect the new prompt-driven development process.
2.  **Refine Prompt Library**: Begin optimizing the prompts used in the workflow for clarity and effectiveness.
3.  **Identify Automation Opportunities**: Explore ways to automate the sequencing of prompts to reduce manual effort.

### Short-term Goals (1-2 weeks)
1.  Fully document the prompt-driven workflow and best practices.
2.  Expand the prompt library to cover a wider range of development tasks.
3.  Implement any identified automation improvements.

## Active Decisions and Considerations

### Decision 1: Workflow Refinement Strategy
- **Approach**: Iteratively improve the prompt library based on real-world usage and feedback.
- **Priority**: Focus on prompts that increase agent autonomy and reduce the need for manual correction.
- **Status**: In progress.

## Important Patterns and Preferences

### Stefan's Preferences
- **Rapid Implementation**: Prefers solutions that can be implemented in under two weeks.
- **Minimal Disruption**: Solutions must not block or interrupt the development workflow.
- **Low Maintenance**: Prefers a "set it and forget it" approach with minimal need for ongoing tuning.

## Learnings and Project Insights

### Process Learnings
- **ADR Value**: Using ADRs provides structure and clarity for critical decisions, ensuring they are well-documented and transparent.
- **Limitations of `always_apply`**: The `always_apply` feature in Cursor is not a complete solution for long-term rule adherence; it must be supplemented with active rule re-enforcement.
