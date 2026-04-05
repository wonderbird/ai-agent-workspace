---
name: sdd-extend
description: >
  Used when new requirements are discovered after a spec already exists.
  Extends the spec, fills gaps in the plan and tasks, implements, and
  validates — without overwriting existing artifacts.
argument-hint: <additional requirements> <@existing-spec-reference> [<@patterns-reference>]
disable-model-invocation: true
---

You are running the Spec Driven Development Extension workflow for: $ARGUMENTS

Throughout this session, apply these conventions:

- **Ask one question at a time** so I can focus on each individually.
- **A / B / C / Custom** — whenever you present options, list them in this format
  with a brief rationale per option.

Before doing any work, create a task list covering all four phases. Mark each task
as in progress when you start it and complete when it is done.

---

### Phase 1 — Extend Specification

Read the existing spec reference in $ARGUMENTS to understand the current state of
the specification. If no spec reference is provided, ask me for one before proceeding.

Ask me questions to clarify the new requirements: scope, technical approach, and
acceptance criteria for the additions. Resolve questions against the existing
spec and codebase before escalating to me. If a decision requires domain
knowledge you are not confident about, consult an expert subagent first and
present its findings as part of the options. Stop asking when you have enough
to describe the additions precisely.

Invoke speckit.clarify in a subagent. Provide it with a concise description of the
additions that captures everything learned: what is new, how it relates to existing
functionality, any changed constraints or dependencies, patterns to follow
from the patterns reference in $ARGUMENTS (if provided), and the new
acceptance criteria. For each finding raised by speckit.clarify, follow this
resolution order:

1. **Resolve from context** — check whether the existing codebase, spec, or prior
   conversation already answers it. If yes, resolve it directly.
2. **Consult an expert subagent** — if the finding is technical and context
   does not resolve it, craft a focused expert persona prompt and consult it
   in a subagent. Instruct the subagent to explicitly state whether its
   answer is conclusive, inconclusive, missing information, or ambiguous.
3. **Escalate to user** — if the finding remains unresolved after steps 1
   and 2, add it to a list of open questions and present them to me.

Once all findings are resolved, invoke a subagent to write the answers back
into the spec, adding the new requirements alongside the existing ones.

---

### Phase 2 — Update Plan and Tasks

Invoke speckit.analyze in a subagent. Provide it with the updated spec so it can
identify gaps introduced by the new requirements in the existing plan, tasks,
and any other derived documents. For each finding, follow this resolution order:

1. **Resolve from context** — check whether the existing codebase, spec, plan, or
   tasks already answer it. If yes, resolve it directly.
2. **Consult an expert subagent** — if the finding is technical and context
   does not resolve it, craft a focused expert persona prompt and consult it
   in a subagent. Instruct the subagent to explicitly state whether its
   answer is conclusive, inconclusive, missing information, or ambiguous.
3. **Escalate to user** — if the finding remains unresolved after steps 1
   and 2, add it to a list of open questions and present them to me.

Once all findings are resolved, invoke a subagent to write the answers back
into the relevant artifacts — extending the plan and tasks to cover the new
requirements without discarding or overwriting existing content.

---

### Phase 3 — Implementation and Review

Invoke speckit.implement in a subagent.

Invoke a subagent with the following prompt:

> Act as a senior developer with deep expertise in the language and technology stack
> used in this implementation.
>
> I wish to merge the changes of the active branch into main.
>
> Perform a diligent code review of the differences. Focus on the following:
>
> - Security risks must be avoided by design or mitigated. If not mitigated, a clear
>   rationale must explain why the risk is acceptable.
> - The code must follow the rules and conventions in the project (check for any
>   rules or style guides in the repository).
> - The code must be easy to maintain and extend.
> - Identify evolving patterns in the codebase and check whether the new code
>   follows them.
> - The code must be idiomatic for the language and technology used.
>
> Sort all findings by severity. Present them in a structured format that can be
> handed directly to a developer agent for fixing.

Hand all findings to a subagent with the following instruction:

> Act as a senior developer with deep expertise in the language and technology stack
> used in this implementation. Fix all findings from the code review, working through
> them in severity order (critical first). For each finding, apply the minimal change
> that resolves it without introducing new issues.

---

### Phase 4 — Acceptance Test

Read the new acceptance criteria added to the spec. Walk me through each new
criterion one step at a time: briefly explain which acceptance criterion you
are testing and what the command does, then give me the exact command to run.
Wait for me to paste the result, evaluate it against the criterion, and
confirm pass or fail before moving to the next.

When all new criteria pass, declare the acceptance test complete.
