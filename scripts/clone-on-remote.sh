#!/bin/bash
#
# On the remote computer, clone all bare repositories into the working directory
#
set -eEuo pipefail
shopt -s failglob

# Setup the AI Agent Workspace and configure Cline Bot to use it
echo "===== Setting up AI Agent Workspace ====="
git clone $HOME/Documents/ai-agent-workspace.git $HOME/Documents/ai-agent-workspace > /dev/null 2>&1
ln -s $HOME/Documents/ai-agent-workspace Cline
echo ""

# Clone the remaining repositories into the AI Agent Workspace
for SOURCE in $HOME/Documents/*.git; do
    echo "===== $SOURCE ====="
    
    # Skip if the source is not a directory, does not exist or is ai-agent-workspace.git
    if [ ! -d "$SOURCE" ] || [ ! -e "$SOURCE" ] || [ "$SOURCE" == "$HOME/Documents/ai-agent-workspace.git" ]; then
        echo "Skipping this repository ..."
        echo ""
        continue
    fi

    TARGET="$HOME/Documents/ai-agent-workspace/$(basename "$SOURCE" .git)"
    if [ -d "$TARGET" ]; then
        echo "Removing existing folder ..."
        rm -rf "$TARGET"
    fi

    echo "Cloning bare repository ..."
    git clone "$SOURCE" "$TARGET" > /dev/null 2>&1

    echo ""

done
