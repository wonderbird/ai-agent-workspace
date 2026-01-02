# Cursor Commands

## create-memory-bank - Create Memory Bank for Existing Project

**Goal**: Create the initial memory bank.
**Prompt**: [create-memory-bank-from-existing-project.md](/.cursor/commands/create-memory-bank-from-existing-project.md)

In **ask mode**, the LLM will analyze the project and ask questions until it can create the initial memory bank.

Switch to **plan or agent mode** to acutally write the memory bank.

Focus on writing the memory bank. Architectural decisions should become tasks in the memory bank.

### define-next-increment - Identify Goal of next Iteration

**Goal**: To analyze the goal of the next iteration.
**Prompt**: [define-next-increment.md](/.cursor/commands/define-next-increment.md)
**Prerequisite**: `follow your custom instructions`
**Mode**: agent mode

This prompt guides the agent to understand the current context, and formulate a detailed implementation plan.

## create-adr - Document Architectural Decisions

**Goal**: To make informed decisions with large impact
**Prompt**: [create-adr.md](/.cursor/commands/create-adr.md)
**Prerequisite**: The current chat contains a discussion about an architecturally relevant decision.

This prompt guides the agent to research architectural decisions, evaluate options and propose a well informed decision.

## update-docs-from-memory-bank.md - Permanently Document Learnings

**Goal**: Transfer Insights from Memory Bank to Better Places
**Prompt**: [update-docs-from-memory-bank.md](/.cursor/commands/update-docs-from-memory-bank.md)
**Prerequisite**: `follow your custom instructions`

The goal is to identify important insights in the volatile memory bank. These insights shall be moved to appropriate places in the permanent documentation.

## Prompts not converted to commands yet

>[!NOTE]
>
> I have learned how to create Cursor commands. As a consequence I am converting the prompts to cursor commands stored in [.cursor/commands](/.cursor/commands).

### Implementation

**Goal**: To execute the plan, writing code and tests according to project standards.
**Prompt**: [`prompts/implementation.md`](./prompts/implementation.md)

This prompt instructs the agent to follow strict TDD, create a task list, and explicitly consider all relevant development rules before and during implementation.

### Review

**Goal**: To review the generated code and ensure it meets all quality and rule requirements.
**Prompt**: [`prompts/review.md`](./prompts/review.md)

This prompt directs the agent to act as a reviewer, checking the completed work against the project's rules and providing feedback for any necessary fixes.
