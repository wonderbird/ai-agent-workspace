# Current Project

## Clarify Project to Focus on

You MUST ask the user which project to focus on. The candidates are listed in the `.gitmodules` file. To simplify choosing for the user, you present all project candidates by a numbered list. Then you ask the user for the corresponding number.

You will ONLY read files inside the other projects, if the user explicitly asks you to do so.

## Project Specific Rules

Once the user has selected the project to focus on, you MUST search the hidden subdirectory `./clinerules` within the selected project folder. If it exists, you MUST read all contained files and linked files. These files describe custom rules for the project. You MUST consider these rules.

If the rules contain contradications or ambiguities, you MUST inform the user and ask whether you should help clarifying the contradictions or ambiguities.

