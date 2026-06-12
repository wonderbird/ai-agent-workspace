---
name: sdd-workflow
description: >
  Spec Driven Development Workflow. Covers spec definition, clarification,
  planning, task breakdown, implementation, code review, and acceptance test
  in sequence. Pass a feature description and context reference as arguments.
argument-hint: <feature description> <@context-reference> [<@patterns-reference>]
disable-model-invocation: true
---

You are running the Spec Driven Development workflow for the context defined
below.

Throughout this session, apply these conventions:

- **Ask one question at a time** so I can focus on each individually.
- **A / B / C / Custom** — whenever you present options, list them in this format
  with a brief rationale per option.
- **Never run .specify/scripts directly** — Never run the scripts in the
  .specify/scripts directory directly. These scripts will be invoked by
  speckit-specify, speckit-plan, speckit-tasks, and speckit-implement in
  subagents at the appropriate phases.

Before doing any work, create an internal task list (not beads) covering all
phases. Mark each task as in progress when you start it and complete when it is
done.

---

### Constraints

- Follow rules and principles from @AGENTS.md and constitution
- KISS: Smallest possible increment from main to working feature

---

### Context

$ARGUMENTS

### How to Handle Unknown Context

If the context is unclear, ask me for context before proceeding.

---

### Phase 1 - Create Beads Feature Request

Search beads for an epic or feature that could be a parent for this work. It is
ok if you find none.

Create corresponding feature in beads. If parent candidate exists, wire the new
feature to the parent.

Claim the new feature and move it to in_progress.

### Phase 2 — Define Specification

Ensure you are on the main branch and have the latest code. The speckit-specify
command will create a feature branch, do not create one manually.

Ask me questions to clarify scope, technical approach, and acceptance
criteria. If a decision requires domain knowledge you are not confident
about, consult an expert subagent first and present its findings as part of
the options. Stop asking when you have enough to write a focused, small spec.
Avoid big upfront design.

Invoke speckit-specify in a subagent. Pass it a concise solution description that
captures everything learned: feature name, platform constraints, dependencies,
installation or implementation approach, acceptance criterion, patterns to follow
from the patterns reference in the context (if provided), and the primary use case.
Present any immediate clarification questions raised by the spec draft.

Invoke speckit-clarify in a subagent. For each finding, follow this resolution order:

1. **Resolve from context** — check whether the existing codebase, spec, or prior
   conversation already answers it. If yes, resolve it directly.
2. **Consult an expert subagent** — if the finding is technical and context
   does not resolve it, craft a focused expert persona prompt and consult it
   in a subagent. Instruct the subagent to explicitly state whether its
   answer is conclusive, inconclusive, missing information, or ambiguous.
3. **Escalate to user** — if the finding remains unresolved after steps 1
   and 2, add it to a list of open questions and present them to me.

Once all findings are resolved, invoke a subagent to write the answers back
into the spec.

---

### Phase 3 — Create Plan and Tasks

Invoke speckit-plan in a subagent. Derive the solution approach from the session
context.

Invoke speckit-tasks in a subagent.

Invoke speckit-analyze in a subagent. For each finding, follow this resolution order:

1. **Resolve from context** — check whether the existing codebase, spec, plan, or
   tasks already answer it. If yes, resolve it directly.
2. **Consult an expert subagent** — if the finding is technical and context
   does not resolve it, craft a focused expert persona prompt and consult it
   in a subagent. Instruct the subagent to explicitly state whether its
   answer is conclusive, inconclusive, missing information, or ambiguous.
3. **Escalate to user** — if the finding remains unresolved after steps 1
   and 2, add it to a list of open questions and present them to me.

Once all findings are resolved, invoke a subagent to write the answers back
into the relevant artifacts.

---

### Phase 4 — Implementation and Review

Invoke the "sdd-ralhp" skill in a subagent.

---

### Phase 5 — Acceptance Test

Read the acceptance criteria from the spec. Walk me through each criterion one step
at a time: briefly explain which acceptance criterion you are testing and what the
command does, then give me the exact command to run. Wait for me to paste the result,
evaluate it against the criterion, and confirm pass or fail before moving to the
next.

When all criteria pass, declare the acceptance test complete.
