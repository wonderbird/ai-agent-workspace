# Cursor Commands

## define-next-increment - Identify Goal of next Iteration

**Goal**: To analyze the goal of the next iteration.
**Prompt**: [define-next-increment.md](/.claude/commands/define-next-increment.md)
**Prerequisite**: `follow your custom instructions`
**Mode**: agent mode

This prompt guides the agent to understand the current context, and formulate a detailed implementation plan.

## create-adr - Document Architectural Decisions

**Goal**: To make informed decisions with large impact
**Prompt**: [create-adr.md](/.claude/commands/create-adr.md)
**Prerequisite**: The current chat contains a discussion about an architecturally relevant decision.

This prompt guides the agent to research architectural decisions, evaluate options and propose a well informed decision.

## improve-document-iteratively - Improve any document for readability and understandability

**Goal**: Agent improves document for readability and understandability
**Prompt**: [improve-document-iteratively](/.claude/commands/improve-document-iteratively.md)
**Prerequisite**: None.

This prompt guides the agent to iteratively improve the document under review.

## Prompts not converted to commands yet

>[!NOTE]
>
> I have learned how to create Cursor commands. As a consequence I am converting the prompts to cursor commands stored in [.claude/commands](/.claude/commands).

### Implementation

**Goal**: To execute the plan, writing code and tests according to project standards.
**Prompt**: [`prompts/implementation.md`](./prompts/implementation.md)

This prompt instructs the agent to follow strict TDD, create a task list, and explicitly consider all relevant development rules before and during implementation.

### Review

**Goal**: To review the generated code and ensure it meets all quality and rule requirements.
**Prompt**: [`prompts/review.md`](./prompts/review.md)

This prompt directs the agent to act as a reviewer, checking the completed work against the project's rules and providing feedback for any necessary fixes.
