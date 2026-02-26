# CLAUDE.md

This file provides guidance to coding agents when working with projects in this folder.

## Rules are stored in .cursor/rules

Rules are stored in the .cursor/rules directory.

Note that .cursor/rules/general is a symbolic link. The rules insided that directory are also applicable.

## How to follow your custom instructions

Whenever the user says "follow your custom instructions", then you must read .cursor/rules/general/500-cline-memory-bank.mdc.

Then read the memory bank and identify the immediate next action.

Afterwards, identify the applicable rules and read them.

Finally, confirm readiness as described in .cursor/rules/general/900-confirm-readiness.mdc.

## LS tool does not show hidden files

When you want to check whether a hidden file or directory exists, then you MUST use a tool native to the operating system you are running on. The LS tool does not handle hidden files.
