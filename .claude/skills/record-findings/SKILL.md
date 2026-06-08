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
   in_progress.

2. If the issue associated with the findings is still open or in progress,
   then block it by the beads gate unless it is an epic. If the issue is an
   epic, then make the beads gate a child of the epic.

3. If not already done earlier, then read the skill most appropriate for
   developing code or for consulting on technical questions in the current
   project, so that you have a solid understanding of the technical context.

4. Ask me for my first finding.

5. Give your point of view as a technical expert, and ask me any follow-up
   questions you may have to clarify the finding.

6. Ask me whether to record the finding in the beads gate as a child task.

7. If I say yes, create a child task in the beads gate to record the finding.

8. Repeat steps 4-7 for each finding I share with you.
