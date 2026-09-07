---
name: format-markdown
description: >
  Improves readability of markdown documents by considering formatting rules.
  Use after creating or modifying a markdown file (*.md, *.mdc).
---
# Format Markdown Document

## Linter is the source of truth

This project uses [markdownlint](https://github.com/DavidAnson/markdownlint)
to enforce formatting. After writing or modifying any `.md` or `.mdc` file,
run the linter and fix all errors before considering the file done:

```bash
markdownlint <file>
```

If the command is not found, markdownlint is not installed. Inform the user
and ask them to install it with:

```bash
npm install --global markdownlint-cli
```

If the command is still not found after installation, Node is likely managed
by NVM, which is not sourced in the agent shell. Prefix the invocation:

```bash
source ~/.nvm/nvm.sh && nvm use node &>/dev/null && markdownlint <file>
```

Project-specific rule configuration lives in `.markdownlint.json` at the
repository root.

## Changes to `.markdownlint.json` must be reported

Whenever you add, modify, or remove a rule in `.markdownlint.json`, you MUST
include a dedicated paragraph in your task summary that lists every change.
For each changed rule, state:

- the rule ID (e.g. `MD013`)
- what the previous value was (or that the rule was absent)
- what the new value is (or that the rule was removed)
- why the change was necessary

This gives the user the information needed to judge whether the change is
acceptable before the commit is reviewed.

Example summary paragraph:

> **`.markdownlint.json` changes**: Added `MD013: { code_blocks: false }` (was
> absent — default enabled). Reason: fenced code blocks in ordered list items
> regularly exceed 80 characters; suppressing the limit only for code blocks
> keeps prose line-length enforcement intact.

## Long headings must be shortened

When MD013 fires on a heading, reword the heading to fit within the line
length limit. Do NOT add a `"headings": false` exemption to
`.markdownlint.json`. A shorter heading with the same meaning is always
preferred over suppressing the rule.

## Semantic rule the linter cannot check

**NEVER** use bold text (`**text**`) as a substitute for a heading. If content
looks like a section title, use proper heading syntax (`#`, `##`, `###`, …).
