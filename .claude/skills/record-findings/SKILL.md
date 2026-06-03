---
name: record-findings
description: >
  Use when you want to keep track of important insights and issues that arise
  during the development process.
argument-hint: >
  Description or reference of the feature
---
## Goal

The goal of this skill is to help me record findings related to a feature in a
structured way, so that I can keep track of important insights and issues that
arise during the development process.

## Feature description

$ARGUMENTS

## How to clarify unclear feature descriptions

If the section "Feature description" is empty or unclear, ask me questions, one
by one, until you understand the feature description.

## Process for recording findings

1. Find the existing "Review PR and collect findings" user story that is already
   a child of the parent feature. It was instantiated via the `pr-review-cycle`
   molecule when the feature transitioned to `in_progress`. If it does not exist,
   stop and remind me to instantiate the molecule first per the Beads Workflow
   rule in CLAUDE.md.

2. Read the skill most appropriate for developing code or for consulting on
   technical questions, so that you have a solid understanding of the technical
   context.

3. Ask me for my first finding.

4. Give your point of view as a technical expert, and ask me any follow-up
   questions you may have to clarify the finding.

5. Ask me whether to record the finding as a child task of the user story.

6. If I say yes, create a child task under the user story and wire it to block
   the merge task: `bd dep add <merge-task-id> <finding-task-id>`

7. Repeat steps 3-6 for each finding I share with you.