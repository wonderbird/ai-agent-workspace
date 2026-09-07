---
name: sdd-ralph
description: >
    Invoke ralph with spec-kit artifacts from the current feature branch
disable-model-invocation: true
argument-hint: "[optional additional instructions]"
---
1. Run `git branch --show-current` → BRANCH_NAME.
   Set FEATURE_DIR = `specs/BRANCH_NAME/`.

2. Verify required artifacts exist:
   - FEATURE_DIR/tasks.md            — required
   - FEATURE_DIR/plan.md             — required
   - FEATURE_DIR/spec.md             — required
   - .specify/memory/constitution.md — required
   If any missing: stop, tell user which file is absent and which speckit
   command to run first.

3. BEADS SETUP — create one beads issue per incomplete task:
   a. If `.omc/speckit-task-map.json` already exists, load it (resume after
      interruption). Skip creating issues for task IDs already in the map.
   b. Parse FEATURE_DIR/tasks.md. For each line matching `- [ ] T\d+`:
      - Extract task ID (e.g. T001) and title (first line of task text, ≤80 chars).
      - Run:
        bd create \
          --title="T001: <first-line-of-task-description>" \
          --description="speckit:BRANCH_NAME | T001 | <first-line>" \
          --type=task --priority=2
      - Record the returned beads ID.
   c. Write (or merge) `.omc/speckit-task-map.json`:
      {
        "feature_dir": "FEATURE_DIR",
        "branch": "BRANCH_NAME",
        "tasks": [
          {"task_id": "T001", "beads_id": "beads-xxx", "title": "..."},
          ...
        ]
      }

4. Invoke the ralph skill with the substituted prompt below

   ralph: implement the feature defined in:
          - FEATURE_DIR/tasks.md         (task list — READ-ONLY; do NOT
                                          modify checkboxes during work)
          - FEATURE_DIR/plan.md          (technical plan)
          - FEATURE_DIR/spec.md          (Gherkin acceptance criteria)
          - .specify/memory/constitution.md (project constraints)

          TASK TRACKING: use beads exclusively — do NOT edit tasks.md
          checkboxes during implementation.

          Find this feature's issues: `bd search "speckit:BRANCH_NAME"`
          Issue titles follow "T001: <description>" matching tasks.md.
          Workflow per task:
            Start:    bd update <beads-id> --claim
            Finish:   bd close <beads-id>
          Navigate work with `bd ready` and `bd list --status=in_progress`.
          Respect the dependency order in tasks.md
          § "Dependencies & Execution Order".
          Use `bd remember "<insight>"` to record non-obvious discoveries,
          gotchas, or design decisions encountered during implementation.

          Verifier must sign off against each Gherkin scenario before
          completion.
          $ARGUMENTS

5. SYNC — run only after ralph signals completion:
   a. Read `.omc/speckit-task-map.json`.
   b. For each entry: `bd show <beads-id>` → get status field.
   c. Edit FEATURE_DIR/tasks.md:
      - Status closed → change `- [ ] T\d+` to `- [x] T\d+` on that line
      - Status open   → leave `- [ ]` unchanged
   d. Commit:
      git add FEATURE_DIR/tasks.md
      git commit -m "chore: sync tasks.md with beads completion status"
   e. Delete `.omc/speckit-task-map.json`.
