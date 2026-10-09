---
name: kata-from-github-issue
description: Use when a new coding exercise - a kata - shall be crafted from a GitHub issue.
---
Please act as a software engineer skilled in quality assurance, requirements
engineering and technical writing.

Your goal is to create a feature specification from an existing issue in
GitHub.

The feature specification shall serve as exercise description for a coding
exercise. Target audience are developers new to the project. The goal of the
exercise is to learn agentic coding in a very large codebase.

## Workflow

1. If the user supplied the issue link when invoking this skill, use it.
   Otherwise, ask the user for the issue link.
2. Get the issue description and all comments from GitHub, for example with
   `gh issue view <number> -R <owner>/<repo> --comments`.
3. Find the pull request that fixed the issue, its merge commit and the
   parent of the merge commit. Read the diff and the review comments.
   If no merged fix exists, use the current default branch as starting point
   and omit the reference solution.
4. Check every observable detail you intend to use in the acceptance
   criteria against the code at the starting commit, e.g. exit codes, log
   messages, endpoints, configuration keys and existing behavior. Do not
   rely on memory: wrong details make the kata unsolvable.
5. Ask the user up to five questions, one by one. Ask only about points the
   issue, the code and the defaults below do not settle, e.g. unclear scope,
   non-goals or conflicting statements in the issue discussion.
6. Ask the user for the name of the kata owner for the license attribution.
   Suggest the output of `git config user.name` as default. This question
   does not count toward the five questions of step 5.
7. Write the specification to `README.md` in the repository root, using the
   structure below. If `README.md` already exists, ask the user before
   replacing it.
8. If `LICENSE` does not exist in the repository root, download the
   CC BY-SA 4.0 legal code unchanged:
   `curl -fsSL https://creativecommons.org/licenses/by-sa/4.0/legalcode.txt -o LICENSE`.
9. If you can build the project, build the reference solution and run the
   acceptance criteria against it. Fix every criterion that fails.
   If you cannot build it, tell the user which criteria are not validated.
10. Report the starting commit, the reference solution and the validation
    status to the user.

## Defaults

Apply these defaults unless the user asks for something else.

- **Starting point:** the parent of the merge commit of the fix. The kata
  then runs on the real codebase without the fix, and the upstream fix
  serves as reference solution.
- **No hints:** describe required behavior only. Never name files,
  functions, packages or code locations, and never reveal the approach of
  the fix. Finding the relevant code is part of the exercise.
- **Functional scope only:** do not prescribe a development process or
  agentic coding workflow.
- **Acceptance criteria follow project conventions:** observable details
  such as exit codes and log message style mirror how the project already
  handles comparable cases. Require automated tests for the new behavior.

## Specification Structure

Use these sections in this order:

1. Title: `# Kata: <capability>`, followed by a link to the issue.
2. `## Purpose of This Kata`: audience and learning goal.
3. `## Starting Point`: commit hash and subject, clone and branch commands,
   required toolchain version.
4. `## Background`: domain concepts a newcomer needs, and the incident or
   motivation from the issue.
5. `## Problem Statement`
6. `## Goal`
7. `## Non-Goals`: behavior that must stay unchanged, with the reason.
8. `## User Stories`
9. `## Functional Requirements`: numbered `### FR-<n>: <title>`.
10. `## Acceptance Criteria`: numbered `### AC-<n>: <title>`, written as
    Given/When/Then with concrete inputs and observable outcomes.
11. `## Definition of Done`
12. `## Reference Solution`: link to the fixing pull request and its merge
    commit, with the advice to compare only after finishing the kata.
    Omit this section if no merged fix exists.
13. `## License`: see below.

## License Section

New katas are licensed under CC BY-SA 4.0. The `## License` section
contains:

- The statement that the kata is licensed under the
  [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/)
  (CC BY-SA 4.0), with a link to `LICENSE` for the full legal code.
- An attribution line for people who share or adapt the kata:
  `"<kata title>" by <owner>, <repository URL>, licensed under CC BY-SA 4.0.`
  Derive the repository URL from `git remote get-url origin`, converted to
  an `https://` URL without the `.git` suffix. If there is no remote, ask
  the user for the URL.
- One note per excerpt copied from the upstream project, e.g. code, rule
  files or configuration snippets. The note names the upstream project, its
  license and its copyright holder, because these excerpts stay under the
  upstream license. Check the upstream license in the upstream repository.
  Do not name file paths in the note, because the kata gives no hints.
