---
name: record-findings
description: >
  Use when you want to keep track of important follow-up tasks and findings
  that arise during the software development and review process.
argument-hint: >
  Description or reference of the current scope including beads issue reference
---
## Goal

The goal of this skill is to help me record findings related to a previously
started or completed issue in a structured way, so that I can keep track of
important insights and issues that arise during the software development and
review process.

## Scope

$ARGUMENTS

## How to clarify unclear scope

If the section "Scope" is empty or unclear, ask me questions, one by one, until
you understand the scope and the corresponding beads issue.

## Process for recording findings

1. Create a beads gate to cover these findings, claim it and move it to
   in_progress. Include the following note in the gate description:
   "IMPORTANT: This gate MUST NOT be closed by an AI agent. Only the human
   reviewer may close it, after verifying that each child finding has been
   properly addressed."

2. If the issue associated with the findings is still open or in progress,
   then block it by the beads gate unless it is an epic. If the issue is an
   epic, then make the beads gate a child of the epic.

3. If not already done earlier, then read the skill most appropriate for
   developing code or for consulting on technical questions in the current
   project, so that you have a solid understanding of the technical context.

4. If findings are given by comments in a pull request or by a file, then
   read them all and sort them such that we can easily discuss them one by one.

5. Identify the first finding to discuss. If there are no findings yet, then
   ask me for my first finding.

6. Give your point of view as a technical expert, and ask me any follow-up
   questions you may have to clarify the finding.

7. Ask me whether to record the finding in the beads gate as a child task.

8. If I say yes, create a child task in the beads gate to record the finding.

9. Repeat steps 5-8 for each finding I share with you.

10. After all findings have been recorded, ensure **exactly one** follow-up
   review task exists as a child of the gate. If one already exists (an earlier
   invocation against the same gate left a child whose title starts
   `Human review:`), update it; otherwise create it.

   Do **not** bake a finding list or a walkthrough order into this task. Both
   are derived live at review time. This is deliberate:

   - The list lives authoritatively in the gate's children. A verbatim copy
     would miss findings filed after this task was created and duplicates a
     source of truth. `bd show <gate-id>` lists closed children too, so a live
     query still surfaces findings that were fixed and closed since.
   - The optimal order depends on which files each *fix* touched and how the
     fixes depend on each other — knowable only from the commits, in hindsight.
     Guessing it at filing time bakes in errors.

   Title:
   `Human review: verify fixes for <gate-id> findings; invoke /record-findings <gate-id>`

   Description (a procedure, not a snapshot):
   - "IMPORTANT: This task MUST be executed by the human reviewer, not an AI
     agent, and MUST NOT be closed by an AI agent."
   - "Review procedure — derive everything live; trust no pre-baked list or
     order:"
     1. List the gate's children (open **and** closed) via `bd show <gate-id>`,
        then **exclude any already labeled `human-reviewed`** and this review
        task itself. What remains is the unreviewed set. This is what keeps
        review rounds from overlapping: findings accepted in an earlier round
        carry the label and drop out, while findings filed *during* that
        earlier round are still unlabeled and surface now — so no finding is
        reviewed twice and none is missed.
     2. For each finding in the unreviewed set, locate its fixing commit(s) with
        `git log --no-pager --grep=<finding-id>` (the `commit` skill mandates a
        `Refs: <finding-id>` trailer, so every fix is discoverable). A finding
        with no commit is "not yet fixed" — leave it unlabeled for a later
        round; do not review it now.
     3. From the files actually changed across those commits, group findings by
        file/area and order them dependency-first — computed in hindsight from
        the real diffs, so the reviewer opens each file once. This is the one
        analytically hard step. For a large or tangled finding set, delegate it
        to a high-reasoning, read-only subagent (e.g. an Opus-class model),
        which returns the grouped, ordered plan. Skip the delegation for a
        small set — the main thread orders it fine. (Step 9 that *creates* this
        review task is mechanical and needs no such model; only this review-time
        analysis does.) Step 4 below stays in the main thread regardless — it is
        a turn-by-turn dialogue with the reviewer and cannot be delegated to a
        single-shot subagent.
     4. Walk through each finding in that order, confirming each fix. The moment
        the human accepts **or** rejects a fix, mark that finding reviewed:
        `bd update <finding-id> --add-label human-reviewed`. For a rejected
        fix, also file a new child finding under the gate — it stays unlabeled
        and is reviewed in the next round.

## Gate Lifecycle Rule

**AI agents MUST NOT close a findings gate.** The gate is a human review
checkpoint — it signals that a set of findings has been collected and is
awaiting human sign-off. Only the human reviewer closes it after confirming
each child finding has been addressed. This applies regardless of how many
child tasks have been closed.
