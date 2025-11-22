# Prompt-Driven Development Workflow

This document serves as the user manual for the prompt-driven workflow designed to ensure AI agent rule adherence throughout a development session.

## Overview

The core problem this workflow solves is "AI rule degradation," where the agent forgets foundational rules over time. While the Cursor IDE's "always apply" rules provide a baseline, they are insufficient for long sessions. This workflow counteracts degradation by systematically re-introducing rules at key stages of the development process using a structured prompt library.

## The Workflow Cycle

The workflow is divided into three main phases, each with a corresponding set of prompts.

### 1. Initialization Phase

**Goal**: To create an initial memory bank.
**Prompt**: [`prompts/01-initialization.md`](./prompts/01-initialization.md)

This prompt guides the agent to analyze the project and create an initial memory bank.

### 2. Analysis Phase

**Goal**: To analyze the problem, understand the requirements, and create a plan.
**Prompt**: [`prompts/02-analysis.md`](./prompts/01-analysis.md)

This prompt guides the agent to read the memory bank, understand the current context, and formulate a detailed implementation plan.

### 3. Implementation Phase

**Goal**: To execute the plan, writing code and tests according to project standards.
**Prompt**: [`prompts/03-implementation.md`](./prompts/03-implementation.md)

This prompt instructs the agent to follow strict TDD, create a task list, and explicitly consider all relevant development rules before and during implementation.

### 4. Review Phase

**Goal**: To review the generated code and ensure it meets all quality and rule requirements.
**Prompt**: [`prompts/04-review.md`](./prompts/04-review.md)

This prompt directs the agent to act as a reviewer, checking the completed work against the project's rules and providing feedback for any necessary fixes.

## Usage

1. **Initialize project**: Begin with the Initialization prompt to create the memory bank.
2. **Start a new task**: Run the Analysis prompt to ensure the agent is fully briefed.
3. **Execute the plan**: Use the Implementation prompt to guide the agent through the coding process.
4. **Verify the result**: Use the Review prompt to perform a final check before committing.

By following this cycle, you ensure that the agent's context is regularly refreshed with the project's rules, leading to higher quality and more consistent output.
