# Consensus planning

Read this at step 2 of the task loop, before recommending a depth.

## Choosing the depth

**A design note is enough** when the change is bounded, reversible and well
understood: one agent explores, sends a short note — the approach, what it will
touch, how it will be tested, anything surprising it found — and waits for
approval before editing. Most tasks are this.

**The consensus round earns its cost** when a mistake would be expensive or
quiet: changes to control flow, deletions of a guard or a check, anything with
a wide blast radius, anything that could fail silently or leave a green build
over broken behaviour, or work that several later tasks will build on.

If the environment provides a consensus-planning skill — `ralplan` in
oh-my-claudecode is one — prefer it over running the procedure by hand, and
follow the procedure below where it leaves gaps.

## The procedure

1. **Planner.** One agent writes the plan to a file. Two parts of it do the
   most work and are worth requiring explicitly: the **non-goals**, and the
   **options considered with the reason each was rejected** — without them the
   reviewers argue about scope and settled questions reopen later. Also require
   acceptance criteria that can be checked by command. For high-risk work add a
   pre-mortem — concrete ways this plan could fail — and a test that would
   catch each one.
2. **Architect.** A second agent reviews the delivered plan for soundness: is
   the design right, what is the strongest argument against it, what tension
   does it leave unresolved, which claims are wrong.
3. **Critic.** A third agent reviews the same plan independently, after the
   architect has finished. It must not see the architect's review — two
   independent readings find more than one influenced reading, and the overlap
   between them is the strongest signal you will get.
4. **Synthesis.** Only the planner combines the two reviews, revising the plan
   and recording how each item was resolved or why it was rejected.
5. **Repeat** until the critic approves or the findings are purely local. Two
   rounds are usually enough; if a third adds nothing new, stop.
6. **Approval.** Present the plan and the open decisions to the user. Nothing
   is implemented before they approve.

## Rules that make it work

- **The reviewed artefact does not change during review.** With one agent
  active at a time this is automatic: the planner is idle while a reviewer
  reads. If the planner thinks of something meanwhile, it sends the thought to
  you and you fold it into the revision round.
- **Reviewers verify rather than opine.** Require file and line evidence for
  claims about the code, and empirical checks for claims about behaviour, run
  in a scratch workspace and never against the project's own tree.
- **Keep the planner available during implementation.** When the executor finds
  something the plan contradicts, it stops and reports; the planner amends the
  plan and re-freezes it. A plan that silently diverges from the code is worse
  than no plan.

## Handing the plan to an executor

After a consensus round the plan goes to a separate executor, not back to the
planner. Give it the plan's path and tell it: follow the plan, do not redesign,
and stop and report if reality contradicts it. Repeat the definition of done
from the task loop, and name the things it must never do, such as merging or
closing issues.
