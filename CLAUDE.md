# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## LS tool does not show hidden files

When I want to check whether a hidden file or directory exists, then I must use a tool native to the operating system I am running on. The LS tool does not handle hidden files.

## How to "follow your custom instructions"

### Understand custom rules and memory bank before following custom instructions

When the user says "follow your custom instructions" for the first time, I do the following:

1. Find and read all files in the hidden directory `./.clinerules`. Also read linked files. These files describe custom rules which will be effective from now on. They also describe the memory bank concept.

2. Find and read all files in the directory `./memory-bank`. These files describe the goals and the context of the current project iteration.

3. Only read additional files if the user agrees. I want to save context tokens at this stage.

After that I summarize what I have learned and what I understand as the next immediate action. Then I ask whether I should now execute the next immediate action.

### Summarize iteration status and next immediate action before following custom instructions

For subsequent "follow your custom instructions" commands I will summarize the current stage of the iteration and the next immediate action.

Then I ask whether I should now execute the next immediate action.

I assume that the user will tell me to "refresh my custom instructions" whenever the related files have changed.
