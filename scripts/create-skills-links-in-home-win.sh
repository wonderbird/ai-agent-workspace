#!/bin/bash
#
# Make skills available everywhere.
#
# Create junctions from $(HOME)/.claude/skills to the .claude/skills
# in this repository.
#
# Prerequisites:
#
# - Script must be run on Windows
# - Script must be run in GitBash, cygpath must be available
#
set -eEufo pipefail
shopt -s failglob

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "===== Creating junctions for skills ====="

mkdir -p "$HOME/.claude/skills"

while read -r SOURCE; do

    TARGET="$HOME/.claude/skills/$(basename "$SOURCE")"
    WIN_TARGET="$(cygpath -w "$TARGET")"
    WIN_SOURCE="$(cygpath -w "$SOURCE")"
    
    if [ -d "$TARGET" ]; then
        echo "Skipping existing skill: $(basename "$SOURCE")"
        continue
    fi

    echo "Linking $(basename "$SOURCE")"
    cmd //c mklink //j "$WIN_TARGET" "$WIN_SOURCE" || {
        echo "Failed to create junction for $(basename "$SOURCE")"
        exit 1
    }

done < <(find "$BASE_DIR/.claude/skills" -mindepth 1 -maxdepth 1 -type d)
