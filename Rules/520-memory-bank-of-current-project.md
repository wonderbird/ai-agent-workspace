# Memory Bank of Current Project

## Select Memory Bank

The entry `./memory-bank` inside the selected project represents the memory bank associated with the current iteration.

If neither the entry `./memory-bank` nor a folder `./memory-bank-branches` exists, then you MUST ask the user whether they would like to explore a product vision in order to create a memory bank. If they confirm, then ask the user for a business analyst persona prompt which tailors your answers to their need.

If that entry does not exist, but a folder `./memory-bank-branches` exists, then it contains different memory banks, each associated with a different product increment. In this situation, you MUST ask the user on which increment they want to work. After the user has selected an increment, you MUST:

1. **Remove existing memory-bank entry**: Delete any existing `./memory-bank` (file, directory, or symlink)
2. **Create fresh symbolic link**: Create `./memory-bank` as a symbolic link pointing to `memory-bank-branches/[selected-increment]`
3. **Verify target**: Confirm the symlink resolves to the intended directory before proceeding

If neither a `./memory-bank` folder nor a `./memory-bank-branches` folder exists, then the next immediate action is to create a memory bank for the current iteration.

## Symlink Safety Check

Before processing the memory bank, you MUST verify that `./memory-bank` correctly points to the intended target directory. If you discover:

- Nested symlinks
- Broken symlinks  
- Incorrect targets

Then you MUST:

1. Report the issue to the user
2. Remove the problematic `./memory-bank` entry
3. Recreate the correct symbolic link to the selected increment

## Process the Memory Bank

If the `./memory-bank` entry exists for the selected project or after the corresponding symbolic link has been created, you MUST process the memory bank inside the selected project. For this, you search for and read all files in the project subdirectory or symbolic link `./memory-bank` in the exact sequence defined in 500-cline-memory-bank.md. These files describe the goals and the context of the current project iteration.

At this stage, you NEVER read and process more files. You MUST save context tokens at this stage. However, if you have encountered interesting files up to now, then you ask the user whether to read them.
