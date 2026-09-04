# Open-Source LLM Agent Skill Managers & TUI Tools: Architectural Brief

## 1. Executive Summary

This document provides a comparative analysis of open-source CLI and Textual User Interface (TUI) tools designed to manage, toggle, and deploy LLM coding agent skills globally across multiple projects.

### Core Requirement & Problem Statement
* **Objective:** Centralize prompt rules, MCP configs, and skill definitions in a single repository and select/deselect skills globally for coding agents (e.g., OpenCode, Claude Code, Cloud Code, Cursor).
* **Architecture Challenge:** Agents load rules from different target directories (`~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.cursor/rules/`, etc.) with varying frontmatter/schema requirements.

---

## 2. Solution Comparison Matrix

The table below summarizes the evaluated open-source solutions sorted by GitHub stars (descending order):

| Tool / Repository | Stars | Commits | Latest Commit | First Commit | Primary Interface | Link Strategy | Multi-Agent Compatibility |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **[`lexler/skill-factory`](https://github.com/lexler/skill-factory)** | **231** | 427 | Sep 2026 | Jan 2026 | Bash / Interactive TUI (`./skills toggle`) | Symlinks (`ln -s`) | Claude Code native; configurable for OpenCode/Cursor |
| **[`mode-io/skill-manager`](https://github.com/mode-io/skill-manager)** | **117** | 48 | Aug 2026 | Nov 2025 | Rust / TS Interactive CLI (`skm`) | Symlinks & Frontmatter Rewriting | OpenCode, Claude Code, Cursor, Codex CLI |
| **[`24KaratAu/openhub`](https://github.com/24KaratAu/openhub)** | **22** | 9 | Aug 2026 | Feb 2026 | Full Python / Textual TUI (`openhub`) | Direct Export / Sync | OpenCode, Claude Code, Cursor, Windsurf |
| **[`lijianru/skills-manager`](https://github.com/lijianru/skills-manager)** | **18** | 10 | Mar 2026 | Feb 2026 | Node.js Interactive Prompts (`skm`) | Deep Copying (IDE safety) | OpenCode, Cursor, Windsurf, Claude Code |
| **[`VictorTomaili/skill-cli`](https://github.com/VictorTomaili/skill-cli)** | **4** | 41 | Aug 2026 | Jul 2026 | Pure TUI (`skill`) | Central Store + Bootstrapping | OpenCode, Claude Code, Gemini CLI, Cursor |

---

## 3. Tool Architecture & Technical Evaluation

### A. `lexler/skill-factory`
* **Architecture:** Skill generation framework + runtime manager with built-in shell lifecycle management.
* **TUI Mechanism:** Uses `./skills toggle` to launch a terminal picker for enabling/disabling skills.
* **Global Delivery:** Symlinks enabled skills into global directories (e.g., `~/.claude/skills/`). Modifications in the source repository immediately apply without re-syncing.
* **Architectural Note:** Implements a two-tiered loading model (~100 token starter prompt, dynamic full body expansion on invocation) to optimize token budgets.

### B. `mode-io/skill-manager` (`skm`)
* **Architecture:** Cross-agent skill router built in Rust/TypeScript.
* **TUI Mechanism:** Interactive CLI selector with search and target filter flags.
* **Global Delivery:** Maintains a canonical local store. Distributes skills across agent targets and handles frontmatter translations (e.g., translating Claude Code SKILL.md specs to Cursor system prompts or OpenCode definitions).
* **Architectural Note:** Best choice if team members use heterogeneous IDEs / agent tools.

### C. `24KaratAu/openhub`
* **Architecture:** SQLite + Python Textual TUI application (`openhub`).
* **TUI Mechanism:** Full keyboard-driven interface with instant search, tags, visual status, and quality ratings.
* **Global Delivery:** Universal skill export (`E` key) supporting the Universal Open Agent Skills Standard (`SKILL.md`). Directly targets `~/.config/opencode/` and `~/.agents/skills/`.
* **Architectural Note:** High UI polish, ideal if skill browsing and visual cataloging are required alongside toggle capabilities.

### D. `lijianru/skills-manager` (`skm`)
* **Architecture:** Node.js package manager pattern for agent skills.
* **TUI Mechanism:** Step-by-step interactive terminal prompts (`Inquirer` pattern).
* **Global Delivery:** Copies files directly rather than using symlinks to ensure 100% platform compatibility across OS boundaries (e.g., Windows without admin symlink privileges).
* **Architectural Note:** Supports selective sub-folder extraction from monorepos.

### E. `VictorTomaili/skill-cli`
* **Architecture:** Store-and-forward isolation harness.
* **TUI Mechanism:** Terminal menu interface using curses/raw terminal controls.
* **Global Delivery:** Stores all master skills in `~/.skill-cli/store/`. Manages active profiles without cluttering agent global paths with inactive files.

---

## 4. Zero-Dependency Alternative: Shell / `fzf` Architecture

If bringing in an external manager dependency is undesirable, a lightweight POSIX-compliant solution using `fzf` provides an instant TUI:

```bash
#!/usr/bin/env bash
# Minimalist Global Skill Toggle Script

SKILLS_STORE="$HOME/.config/agent-skills-repo"
OPENCODE_GLOBAL="$HOME/.config/opencode/skills"
CLAUDE_GLOBAL="$HOME/.claude/skills"

mkdir -p "$SKILLS_STORE" "$OPENCODE_GLOBAL" "$CLAUDE_GLOBAL"

# Interactive Multi-Select TUI with Live Preview
SELECTED=$(find "$SKILLS_STORE" -type f \( -name "*.md" -o -name "*.json" \) | \
  fzf -m --preview 'cat {}' --prompt="Toggle Global Skills [Tab to Select] > ")

if [ -n "$SELECTED" ]; then
    # Unlink existing managed symlinks
    find "$OPENCODE_GLOBAL" "$CLAUDE_GLOBAL" -type l -delete
    
    # Symlink selected skills to global agent directories
    echo "$SELECTED" | while read -r filepath; do
        filename=$(basename "$filepath")
        ln -sf "$filepath" "$OPENCODE_GLOBAL/$filename"
        ln -sf "$filepath" "$CLAUDE_GLOBAL/$filename"
        echo "Enabled globally: $filename"
    done
fi
```

---

## 5. Summary Recommendation for Architecture Review

1. **For Anthropic / Claude Code / OpenCode standard alignment:** Select **`lexler/skill-factory`**. It is the most actively maintained with high community traction.
2. **For Multi-Agent Heterogeneity (OpenCode + Cursor + Claude + Codex):** Select **`mode-io/skill-manager`** due to its format conversion capabilities.
3. **For Rich Terminal Experience:** Select **`24KaratAu/openhub`** for its full Textual TUI dashboard.
4. **For Zero Extra Dependencies:** Implement the **`fzf` symlink shell harness**.
