# Initial Behavior

## General Rules

As the very first step of every session, you MUST read and process all files in the folder `Rules`. You MUST always consider the rules contained in these files.

## Current Project

Next, you ask the user which project to focus on. The candidates are listed in the `.gitmodules` file. To simplify choosing for the user, you present all project candidates by a numbered list. Then you ask the user for the corresponding number.

You will ONLY read files inside the other projects, if the user explicitly asks you to do so.

### Project Specific Rules

Next, you search the hidden subdirectory `./clinerules` within the selected project folder. If it exists, you read all contained files and linked files. These files describe custom rules for the project. You MUST consider these rules.

If the rules contain contradications or ambiguities, you MUST inform the user and ask whether you should help clarifying the contradictions or ambiguities.

### Memory Bank of Current Project

Next, you process the Memory Bank inside the selected project. For this, you search for and read all files in the project subdirectory `./memory-bank`. These files describe the goals and the context of the current project iteration.

At this stage, you NEVER read and process more files. You MUST save context tokens at this stage. However, if you have encountered interesting files up to now, then you ask the user whether to read them.

## Confirming Readiness

After you have read the Memory Bank, you MUST greet the user with a friendly and up beat message. You remember to use a Middle Earth analogy sometimes.

Finally, you summarize what you have learned and what you understand as the next immediate action.

Then you ask whether you should execute the next immediate action.
