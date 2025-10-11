#!/bin/bash
#
# On the remote computer, remove all repos
#
set -eEuo pipefail
shopt -s failglob

echo "===== Removing Cline Bot Workspace ====="

echo "Removing Cline Bot workspace ..."
rm -rf "$HOME/Documents/Cline"

echo ""

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
