#!/usr/bin/env bash
#
# Restore links in .claude/skills from existing skills in .agents/skills.
#
# Use this after `npx skills experimental_install` (vercel-labs/skills), which
# currently restores skills only into .agents/skills and does not recreate the
# .claude/skills symlinks. When skills are managed with omrikais/skill-manager
# (`sm install`), this script is not needed — `sm` links into both dirs.
#
# USAGE: ./restore-claude-skills-links.sh
#
set -euo pipefail

canon=".agents/skills"
dest=".claude/skills"
mkdir -p "$dest"

shopt -s nullglob
for d in "$canon"/*/; do
name=$(basename "$d")
[ -f "$d/SKILL.md" ] || continue                 # real skills only
link="$dest/$name"
want="../../$canon/$name"

if [ -L "$link" ]; then
  # already a symlink: keep if it resolves to this canonical skill
  if [ "$(readlink -f "$link")" = "$(readlink -f "$d")" ]; then
    continue
  fi
  rm -f "$link"                                  # wrong/broken link → replace
elif [ -e "$link" ]; then
  echo "skip $name: real directory in $dest, left untouched" >&2
  continue                                       # never clobber real data
fi

ln -s "$want" "$link"
echo "linked $name"
done
