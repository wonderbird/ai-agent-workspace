#!/bin/bash
#
# On the remote computer, remove all repos
#
set -eEuo pipefail
shopt -s failglob

# Remove the AI Agent Workspace
echo "===== Removing AI Agent Workspace ====="

echo "Removing Cline Bot workspace symlink ..."
rm -f "$HOME/Documents/Cline"

echo "Removing actual workspace ..."
rm -rf "$HOME/Documents/ai-agent-workspace"

echo ""

# Remove all remaining repositories
echo "===== Removing bare repositories ====="
for SOURCE in "$HOME/Documents/"*.git; do
    basename "$SOURCE"

    # Skip if the source is not a directory or does not exist
    if [ ! -d "$SOURCE" ] || [ ! -e "$SOURCE" ]; then
        echo "Skipping this repository ..."
        echo ""
        continue
    fi

    echo "  Removing bare repository ..."
    rm -rf "$SOURCE"
done

echo ""
