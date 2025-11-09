# Current Project

## Clarify Project to Focus on

You MUST ask the user which project to focus on. The candidates are the folders in this directory.

To simplify choosing for the user, present all project names as a numbered list. Then ask the user for their chosen number.

Read ONLY files inside the other projects, if the user explicitly asks you to do so.

## Project Specific Rules

Once the user has selected the project to focus on, you MUST check for project-specific rules. To do this, you MUST attempt to list the contents of the **hidden** subdirectories `./.clinerules` and `./.cursor/rules`. If these directories exist and contain files, you MUST read all contained files and linked files. These files describe custom rules for the project that you MUST consider.

If the rules contain contradications or ambiguities, you MUST inform the user and ask whether you should help clarifying the contradictions or ambiguities.