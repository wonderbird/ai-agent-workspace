# Memory Bank of Current Project

## Select Memory Bank

The entry `./memory-bank` inside the selected project represents the memory bank associated with the current iteration.

If that entry does not exist, but a folder `./memory-bank-branches` exists, then it contains different memory banks, each associated with a different product increment. In this situation, you MUST ask the user on which increment they want to work. After the user has selected an increment, create a symbolic link `./memory-bank` pointing to the corresponding folder in `./memory-bank-branches`.

If neither a `./memory-bank` folder nor a `./memory-bank-branches` folder exists, then the next immediate action is to create a memory bank for the current iteration.

## Process the Memory Bank

If the `./memory-bank` entry exists for the selected project or after the corresponding symbolic link has been created, you MUST process the memory bank inside the selected project. For this, you search for and read all files in the project subdirectory or symbolic link `./memory-bank`. These files describe the goals and the context of the current project iteration.

At this stage, you NEVER read and process more files. You MUST save context tokens at this stage. However, if you have encountered interesting files up to now, then you ask the user whether to read them.

