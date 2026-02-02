#!/bin/bash
#
# On the remote computer, remove all repos
#
set -eEuo pipefail
shopt -s failglob

echo "===== Removing Repositories ====="

for BARE_REPO_PATH in "$HOME/Documents/"*.git; do
    WORKSPACE_NAME=$(basename "$BARE_REPO_PATH" .git)
    WORKSPACE_PATH="$HOME/Documents/Cline/$WORKSPACE_NAME"
    
    echo "$WORKSPACE_NAME"
    
    if [ ! -d "$BARE_REPO_PATH" ]; then
        echo "  Skipping (bare repository not found) ..."
        echo ""
        continue
    fi
    
    if [ -d "$WORKSPACE_PATH" ]; then
        echo "  Removing workspace directory ..."
        rm -rf "$WORKSPACE_PATH"
    else
        echo "  Skipping (workspace directory not found) ..."
    fi
    
    echo "  Removing bare repository ..."
    rm -rf "$BARE_REPO_PATH"
   
    echo ""
done

echo ""
