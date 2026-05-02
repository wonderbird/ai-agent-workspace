#!/bin/bash
#
# Make skills available everywhere.
#
# Create symlinks from $(HOME)/.claude/skills to the .claude/skills
# in this repository.
#
# Prerequisites:
#
# - Script must be run on Linux
#
set -eEufo pipefail
shopt -s failglob

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "===== Creating symlinks for skills ====="

mkdir -p "$HOME/.claude/skills"

while read -r SOURCE; do

    TARGET="$HOME/.claude/skills/$(basename "$SOURCE")"

    if [ -d "$TARGET" ]; then
        echo "Skipping existing skill: $(basename "$SOURCE")"
        continue
    fi

    ln -s "$SOURCE" "$TARGET" || {
        echo "Failed to create symlink for $(basename "$SOURCE")"
        exit 1
    }

done < <(find "$BASE_DIR/.claude/skills" -mindepth 1 -maxdepth 1 -type d)
