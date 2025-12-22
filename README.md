# AI Agent Workspace

This project provides rules for coding agents similar to the Cline Rules (1).

## Usage

### Setup agent rules

The ai agent workspace folder should be next to your project folder(s). For example, if your projects are in `~/dev/project-a` and `~/dev/project-b`, clone this repository to `~/dev/ai-agent-workspace`.

Next, link the folder `ai-agent-workspace/.cursor/rules` into the rules directory of your project.

If you use Cursor, then you would run

```shell
cd ~/dev/project-a
mkdir -p .cursor/rules
cd .cursor/rules
ln -s ../../../ai-agent-workspace/.cursor/rules general
```

Depending on how you like to code, you can link other files in as well, e.g. the clean-code rules:

```shell
cd .cursor/rules
ln -s ../../../ai-agent-workspace/rules-banks/clean-code clean-code
```

### Setup AGENTS.md as a kind of root prompt

At the begin of every coding session the ai agent first reads the file `AGENTS.md` in the project directory (2). We will use this file to inform the agent about the applicable rules.

Initialize that file using the following commands:

```shell
cd ~/dev/project-a/

cat > AGENTS.md << EOF
# AGENTS.md

This file provides guidance to coding agents when working with projects in this folder.

## How to follow your custom instructions

Whenever the user says "follow your custom instructions", then you must read .cursor/rules/general/500-cline-memory-bank.mdc. Then read the memory bank and identify the immediate next action. Afterwards, identify the applicable rules and read them. Finally, confirm readiness as described in .cursor/rules/general/900-confirm-readiness.mdc.
EOF
```

### Prompt driven development workflow

At the moment I am building up the prompts and documentation for a structured and repeatable agentic workflow.

The current status is documented in [Agentic Development Workflow](./docs/agentic-development-workflow/)

## Adding custom projectspecific rules

For project specific rules, I recommend the following prefix scheme:

```text
A10-desired-effect.mdc
A20-other-desired-effect.mdc
B10-one-more-desired-effect.mdc
```

An alphanumeric schema allows to specify an order in which rules are read. This might have a positive influence on a consistent understanding by the LLM.

The first character allows to group rules together by category.

Using a step size of 10 in the remaining two digits allows to insert more rules later.

## Isolating the AI agent from your computer

If grant AI agents permissions to execute arbitrary commands, then you should isolate it from the programs and data you rely on (4).

I prefer using a dedicated virtual machine either on my computer or hosted in the cloud for this purpose (5).

As an alternative, you can run the project in a DevContainer. The [configuration](./.devcontainer/devcontainer.json) supports both Visual Studio Code and the Cursor IDE.

For running the DevContainer in Cursor, install the Anysphere DevContainer Plugin and ensure that the configuration `"remoteUser": "vscode"` is present.

To verify that the LLM is running in a DevContainer you can use the following prompt:

```text
Verify your sandbox: report user and current directory. You should be user 'vscode' inside '/workspaces/'.
```

## Acknowledgements

The command [generate-cursor-rules.md](.cursor/commands/generate-cursor-rules.md) has been adopted from the following Udemy course:

T. Phillips, “Cursor AI Beginner to Pro: Build Production Web Apps with AI,” Udemy. Accessed: Dec. 06, 2025. [Online]. Available: [https://www.udemy.com/course/learn-cursor-ai/](https://www.udemy.com/course/learn-cursor-ai/)

## References

(1) Cline Bot, Inc., “Cline rules,” Cline. Accessed: Jun. 09, 2025. [Online]. Available: [https://docs.cline.bot/features/cline-rules](https://docs.cline.bot/features/cline-rules)

(2) Open AI, "AGENTS.md". Accessed: Oct. 09, 2025. [Online]. Available: [https://agents.md/](https://agents.md/)

(3) Anysphere, “Cursor Documentation: Core / Rules,” Cursor Documentation. Accessed: Nov. 09, 2025. [Online]. Available: [https://cursor.com/docs/context/rules](https://cursor.com/docs/context/rules)

(4) Section "Safe YOLO mode" in Anthropic, “Claude Code: Best practices for agentic coding.” Accessed: Nov. 22, 2025. [Online]. Available: [https://www.anthropic.com/engineering/claude-code-best-practices](https://www.anthropic.com/engineering/claude-code-best-practices)

(5) S. Boos, "wonderbird/ai-agent-workspace". (Nov. 22, 2025). Shell. Accessed: Nov. 22, 2025. [Online]. Available: [https://github.com/wonderbird/ai-agent-workspace](https://github.com/wonderbird/ai-agent-workspace)
