#!/bin/bash
#
# On the remote computer, clone all bare repositories into the working directory
#
set -eEuo pipefail
shopt -s failglob

echo "===== Setting up Cline Bot Workspace ====="
echo "Creating Cline Bot workspace ..."
mkdir "$HOME/Documents/Cline"
echo ""

# Clone the remaining repositories into the AI Agent Workspace
for SOURCE in $HOME/Documents/*.git; do
    echo "===== $(basename $SOURCE .git) ====="

    # Skip if the source is not a directory or does not exist
    if [ ! -d "$SOURCE" ] || [ ! -e "$SOURCE" ]; then
        echo "Skipping this repository ..."
        echo ""
        continue
    fi

    TARGET="$HOME/Documents/Cline/$(basename "$SOURCE" .git)"
    if [ -d "$TARGET" ]; then
        echo "Removing existing folder ..."
        rm -rf "$TARGET"
    fi

    echo "Cloning bare repository ..."
    git clone "$SOURCE" "$TARGET" >/dev/null 2>&1

    echo ""

done
