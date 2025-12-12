# Agentic Development Workflow

>[!NOTE]
>
> I have learned how to create Cursor commands. As a consequence I am converting the prompts to cursor commands stored in [.cursor/commands](/.cursor/commands).

## Cursor commands

### create-adr - Document Architectural Decisions

**Goal**: To make informed decisions with large impact
**Prompt**: [`create-adr.md`](/.cursor/commands/create-adr.md)

This prompt guides the agent to research architectural decisions, evaluate options and propose a well informed decision.

## Prompts not converted to commands yet

### Initialization

**Goal**: To create an initial memory bank.
**Prompt**: [`prompts/initialization.md`](./prompts/initialization.md)

This prompt guides the agent to analyze the project and create an initial memory bank.

### Analysis

**Goal**: To analyze the goal of the next iteration.
**Prompt**: [`prompts/analysis.md`](./prompts/analysis.md)

This prompt guides the agent to understand the current context, and formulate a detailed implementation plan.

### Implementation

**Goal**: To execute the plan, writing code and tests according to project standards.
**Prompt**: [`prompts/implementation.md`](./prompts/implementation.md)

This prompt instructs the agent to follow strict TDD, create a task list, and explicitly consider all relevant development rules before and during implementation.

### Review

**Goal**: To review the generated code and ensure it meets all quality and rule requirements.
**Prompt**: [`prompts/review.md`](./prompts/review.md)

This prompt directs the agent to act as a reviewer, checking the completed work against the project's rules and providing feedback for any necessary fixes.
