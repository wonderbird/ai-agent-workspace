---
name: format-docs
description: >
  Apply document style rules to markdown files such as meeting minutes,
  confluence pages, and project documentation. Replaces em dashes with
  commas, colons, or semicolons; removes horizontal rule separators between
  sections; flattens participant tables to inline comma-separated lists.
  Use after creating or modifying a documentation file, or when the user
  asks to format, restyle, or clean up a document.
---

# Format Document Style

Apply every rule below to the file the user specifies. Read the file, apply
all rules in one pass, then write the corrected file. Do not change prose
wording, grammar, or content. Only change characters and structure as
described.

## Rule 1: No em dashes

Replace every em dash (`—`) with the punctuation that fits its grammatical
position:

| Position | Replace `—` with | Example |
|----------|------------------|---------|
| After a heading label (D1, R1, etc.) | colon (`:`) | `### D1: Title` |
| Appositive or parenthetical aside | comma (`,`) | `Team 21, AX expert` |
| Between two independent clauses | semicolon (`;`) | `error table; no change needed` |
| Introducing a list or explanation | colon (`:`) | `Basis: the spec document` |

When unsure, prefer a comma.

## Rule 2: No horizontal rules between sections

Remove all `---` lines that separate sections. Section headings (`##`, `###`)
provide sufficient visual separation. Do not remove `---` that serves as
YAML frontmatter delimiters.

## Rule 3: Participants as inline list

If a document contains a participant or attendee table, replace it with a
single inline list on the `**Participants:**` line.

Before:

```markdown
**Participants:**

| Name | Team / Role |
|---|---|
| Alice | Team Alpha, engineer |
| Bob | Team Beta |
```

After:

```markdown
**Participants:** Alice, Bob
```

Keep only names. Drop team and role annotations from the participant line.
Team and role context belongs in the document body where relevant.

## Rule 4: Arrows only in technical notation

Arrows (`→`) are allowed in technical notation: field mappings, menu
navigation paths, rename operations in tables. Do not use arrows as prose
punctuation. If an arrow appears in running prose, replace it with "to" or
rephrase.

## Rule 5: Compound-word hyphens are fine

Do not remove hyphens in compound words (e.g. Mock-Service, UK-orders,
single-item). These are correct.

## Verification

After applying all rules, scan the result for any remaining `—` characters.
If found, apply Rule 1 again. Report what changed.
