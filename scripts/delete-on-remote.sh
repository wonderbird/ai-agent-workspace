#!/bin/bash
#
# On the remote computer, remove all repos
#
set -eEuo pipefail
shopt -s failglob

# Remove the AI Agent Workspace
rm -f $HOME/Documents/Cline
rm -rf $HOME/Documents/ai-agent-workspace

# Remove all remaining repositories
for SOURCE in $HOME/Documents/*.git; do
    echo "===== $SOURCE ====="
    
    # Skip if the source is not a directory or does not exist
    if [ ! -d "$SOURCE" ] || [ ! -e "$SOURCE" ]; then
        echo "Skipping this repository ..."
        echo ""
        continue
    fi

    echo "Removing bare repository ..."
    rm -rf "$SOURCE"

    echo ""
done
