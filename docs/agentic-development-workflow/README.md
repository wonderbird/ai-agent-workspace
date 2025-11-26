# Agentic Development Workflow

## 1. Initialization

**Goal**: To create an initial memory bank.
**Prompt**: [`prompts/01-initialization.md`](./prompts/01-initialization.md)

This prompt guides the agent to analyze the project and create an initial memory bank.

## 2. Analysis

**Goal**: To analyze the goal of the next iteration.
**Prompt**: [`prompts/02-analysis.md`](./prompts/02-analysis.md)

This prompt guides the agent to understand the current context, and formulate a detailed implementation plan.

## 3. Document Architectural Decisions

**Goal**: To make informed decisions with large impact
**Prompt**: [`prompts/03-architecture-decisions.md`](./prompts/03-architecture-decisions.md)

This prompt guides the agent to research architectural decisions, evaluate options and propose a well informed decision.

## 4. Implementation

**Goal**: To execute the plan, writing code and tests according to project standards.
**Prompt**: [`prompts/04-implementation.md`](./prompts/04-implementation.md)

This prompt instructs the agent to follow strict TDD, create a task list, and explicitly consider all relevant development rules before and during implementation.

## 5. Review

**Goal**: To review the generated code and ensure it meets all quality and rule requirements.
**Prompt**: [`prompts/05-review.md`](./prompts/05-review.md)

This prompt directs the agent to act as a reviewer, checking the completed work against the project's rules and providing feedback for any necessary fixes.
