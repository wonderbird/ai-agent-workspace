---
name: code-review
description: >
  Check code quality according to best practices and standards.
  Use when code review, pull request review or advice is needed.
argument-hint: >
  Scope, e.g. commit range, a set of files, code snippet reference, etc.
---
Check for an appropriate skill to perform a diligent code review.

If no specific skill is available, then ask the user whether you should analyze
the current project and act as an expert in the technologies used before you
start with the review.

## Scope

$ARGUMENTS

## Handle unknown scope

If the "Scope" section is empty, ask me what to review before proceeding.

## Priority of findings

The priority of findings is as follows:

1. Risk to security, privacy, data integrity, intellectual property
2. Risk of malfunction, errors, instability
3. Impact on maintainability and extensibility
4. Others

## Expected output

Save the review findings in `/CODE-REVIEW-FINDINGS.md` in the following format:

```
# Code Review Findings

## F001: [Short description of the finding]

### Description

[Detailed explanation of the finding]

### Impact

[Explanation of the potential impact of the finding]

### Recommendation

[Actionable recommendation for improvement (may be a list)]
```
