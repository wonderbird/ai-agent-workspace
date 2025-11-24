# Agentic Development Workflow

## 1. Initialization

**Goal**: To create an initial memory bank.
**Prompt**: [`prompts/01-initialization.md`](./prompts/01-initialization.md)

This prompt guides the agent to analyze the project and create an initial memory bank.

## 2. Analysis

**Goal**: To analyze the problem, understand the requirements, and create a plan.
**Prompt**: [`prompts/02-analysis.md`](./prompts/01-analysis.md)

This prompt guides the agent to read the memory bank, understand the current context, and formulate a detailed implementation plan.

## 3. Implementation

**Goal**: To execute the plan, writing code and tests according to project standards.
**Prompt**: [`prompts/03-implementation.md`](./prompts/03-implementation.md)

This prompt instructs the agent to follow strict TDD, create a task list, and explicitly consider all relevant development rules before and during implementation.

## 4. Review

**Goal**: To review the generated code and ensure it meets all quality and rule requirements.
**Prompt**: [`prompts/04-review.md`](./prompts/04-review.md)

This prompt directs the agent to act as a reviewer, checking the completed work against the project's rules and providing feedback for any necessary fixes.
