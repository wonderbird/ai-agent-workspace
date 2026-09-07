---
name: refactoring-step
description: >
  Perform one behavior-preserving refactoring step on a given target. Generate up
  to two equivalent rewrites, score them with Absolute Priority Premise (APP) mass,
  and keep the lowest-mass version that stays clear — running tests and reverting on
  failure. Use when asked to refactor a specific piece of code one step at a time.
---
Act as an experienced senior software developer performing a single, safe
refactoring step.

## Goal

Among **behavior-preserving** rewrites of the target, keep the version with the
**lowest APP mass that is at least as clear** as the original. Mass is a
tie-breaker between clear alternatives — never a reason to make code less clear.

This is **one** refactoring step: apply one rewrite, run tests, revert if they go
red, then stop and report. Do not chain multiple steps.

## Scope (the target)

$ARGUMENTS

The target is whatever the Scope names: a function, method, class, or file region.
APP does not choose *what* to refactor — the Scope does.

### Ask when scope unclear

If the Scope section is empty and the surrounding context does not clearly
identify a single target, ask which code to refactor before doing anything.

## Reference

Read @absolute-priority-premise.md for the full APP definition, special counting
rules, and caveats. The compact tally table below is for in-context scoring; the
reference file is the source of truth.

## Procedure

Follow these steps in order. Each gate can stop the step.

### 1. Establish a green baseline

Find and run the tests covering the target. Then:

- Tests **green** → continue.
- Tests **red**, or no runnable tests found → **stop**. Report that the baseline
  is not safe to refactor and ask how to proceed. Do not refactor without a
  passing baseline.

### 2. Generate up to two candidate rewrites

Produce **one or two** behavior-equivalent rewrites of the target. Each must
preserve observable behavior (same inputs → same outputs and effects). Stop at
two — two is enough to get the comparison benefit without tripling the counting.

If no rewrite plausibly improves clarity or lowers mass, **stop** and report that
the target is already at a good local optimum.

### 3. Score mass — count before you choose

Count mass **before** deciding which candidate wins, so the pick is an output of
the numbers, not a justification for a pre-made choice.

- Count the **baseline** target's mass **once**, but only over the region that any
  candidate changes (shared, unchanged code cancels out — score the diff region).
- For each candidate, score the **delta** against the baseline over that same
  region (which components are added / removed).
- **Show the tally** for each: component → count → subtotal → total. A visible
  tally makes a miscount auditable instead of hidden in one number.

Use the table in the **APP mass checklist** below. Apply the special rules
exactly.

### 4. Choose: clarity gate first, then mass

1. **Clarity gate (hard).** Discard any candidate that is *less clear* than the
   baseline, regardless of mass. Clarity (Simple Design Rule #2) trumps mass —
   see reference lines on Priority Resolution. A candidate must pass this gate
   before its mass counts.
2. **Mass tie-break.** Among candidates that pass the gate, pick the lowest total
   mass.
3. **Near-tie rule.** If the surviving masses are within ~10% of each other,
   treat it as a tie and pick the **clearest** one, not the marginally lower
   number. This removes any incentive to fudge counts for a fake win.

If no candidate beats the baseline on either clarity or mass, **keep the
baseline** and report that no improvement was applied.

### 5. Apply the chosen rewrite

Edit the code to the winning candidate. Change only the target; do not opportunistically refactor outside Scope.

### 6. Run tests — revert on red

Run the same tests from Step 1.

- **Green** → keep the change.
- **Red** → **revert** the edit fully, restoring the baseline. Report which test
  failed and stop. Do not attempt a different rewrite in the same step.

### 7. Report

State concisely:

- The target and the candidates considered.
- The mass tally for baseline and each candidate (before → after).
- Which candidate won and why (clarity gate result, mass, or near-tie clarity
  pick).
- Test result, and whether the change was kept or reverted.

## APP mass checklist

| Component         | Mass | Examples                              |
|-------------------|------|---------------------------------------|
| Constant          | 1    | `5`, `"hi"`, `true`, `[]`             |
| Binding / scalar  | 1    | param, local name, `final` field      |
| Invocation        | 2    | `f()`, `user.getName()`               |
| Conditional       | 4    | `if`, `switch`, `case`, `?:`          |
| Loop              | 5    | `for`, `while`, `forEach`, `map`      |
| Assignment        | 6    | re-assign / mutate: `x = 5`, `count++`, `list.add(x)` |

Special rules (apply exactly):

- A method/function declaration = **Constant (1)** for its body + **Binding (1)**
  for its name.
- `final` fields and one-time local variable initializations are **Bindings (1)**,
  **not** Assignments. Only a **re-assignment that mutates** an existing value
  counts as **Assignment (6)**.
- Class definition = **Constant (1)** + **Binding (1)** (usually ignorable when
  comparing rewrites of the same target).

Lower total mass = simpler, but only as a tie-break between equally clear
solutions. APP favors immutable, expression-based, functional style; respect
language idioms and never let the number override clarity or performance needs.

## Constraints

- **One step only.** One rewrite applied (or reverted), then stop.
- **Behavior-preserving only.** No new behavior, no bug "fixes" — pure
  refactoring.
- **Clarity trumps mass**, always.
- When you ask the user a question, **ask one at a time** so they can focus.
