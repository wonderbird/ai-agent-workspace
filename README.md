# AI Agent Workspace

This project provides rules for coding agents similar to the Cline Rules (1).

## Usage

Clone this project next to your project folders. For example, if your projects are in `~/dev/project-a` and `~/dev/project-b`, clone this repository to `~/dev/ai-agent-workspace`.

If you use Cursor, then link the `.cursor/rules` folder as a subfolder of the `.cursor/rules` for your project. In the `~/dev/project-a` you would run:

```shell
# Assumption: You have created the `.cursor/rules` folder already
cd ~/dev/project-a/.cursor/rules
ln -s ../../../ai-agent-workspace/.cursor/rules general
```

Then instruct your coding agent to read the rules by creating the file `AGENTS.md` in the parent directory (`~/dev/AGENTS.md`) with the following content:

```markdown
# AGENTS.md

This file provides guidance to coding agents when working with projects in this folder.

## Read the Rules

BEFORE ANY REPLY, you MUST read the file `ai-agent-workspace/Rules/010-first-processing-steps.md` and follow ALL contained instructions.
```

Finally, start your coding agent and say:

```text
follow your custom instructions
```

For more usage instructions, read (1).

## DevContainer Setup

You can isolate the AI agent from your computer by running the project in a DevContainer. The [configuration](./.devcontainer/devcontainer.json) supports both Visual Studio Code and the Cursor IDE.

For running the DevContainer in Cursor, install the Anysphere DevContainer Plugin and ensure that the configuration `"remoteUser": "vscode"` is present.

To verify that the LLM is running in a DevContainer you can use the following prompt:

```text
Verify your sandbox: report user and current directory. You should be user 'vscode' inside '/workspaces/'.
```

## References

(1) Cline Bot, Inc., “Cline rules,” Cline. Accessed: Jun. 09, 2025. [Online]. Available: [https://docs.cline.bot/features/cline-rules](https://docs.cline.bot/features/cline-rules)

(2) Open AI, "AGENTS.md". Accessed: Oct. 09, 2025. [Online]. Available: [https://agents.md/](https://agents.md/)