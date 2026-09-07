---
name: review-single-rule
description: >
  Review and fix a single agent-facing context file for consistency, clarity, and
  token efficiency.
---

# Goal

Review and fix a single agent-facing context file.

# Quality criteria

The file must be:
- Token-efficient, unambiguous, complete
- Internally consistent

# Finding types

- `redundancy` — repeated content within or across files
- `ambiguity` — multiple valid interpretations
- `inconsistency` — internal contradiction
- `token-waste` — verbose phrasing, filler
- `requires-invention` — fix would require inventing content; flag only,
  never auto-fix

**Hard constraint: do not invent rules. Do not change intended meaning.
Auto-fix all types except `requires-invention`.**

# Execution

## Step 1 — Review

1. Read file and all files it directly links to
2. Review against quality criteria
3. Return structured findings:

```
FILE: <path>
FINDING: <section or line ref> | <type> | <description> | <proposed fix>
```

## Step 2 — Fix findings

Apply fixes and write to disk.

`requires-invention` findings: never auto-fixed; forwarded to Step 3.

## Step 3 — Summary

- Files changed
- Fix count by type
- `requires-invention` findings (flagged for human review)
