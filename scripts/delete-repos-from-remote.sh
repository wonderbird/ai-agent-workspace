#!/bin/bash
# Delete remote repositories that were created by sync-repositories-to-remote.sh.
#
# This script also removes the remote entries from the local repositories.
#
# Prerequisites
#
# An SSH key for passwordless login to the remote computer is either
# loaded into the SSH agent or stored without password protection in the
# ~/.ssh directory.
#
# Usage
#
# ./delete-repos-from-remote.sh
#
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

REMOTE_HOST_NAME="lorien"
REMOTE_USER=galadriel
REMOTE_HOST=$(tart ip "$REMOTE_HOST_NAME")
REMOTE_TARGET="/home/galadriel/Documents"

# List of repositories to be deleted
REPOSITORIES=(
    "$HOME/source/ai-agent-workspace"
)

# Add git submodules to the list of repositories
while IFS= read -r line; do
    if [[ $line == \[submodule* ]]; then
        REPO_NAME=$(echo "$line" | sed 's/\[submodule "\(.*\)"\]/\1/')
        REPOSITORIES+=("$REPO_NAME")
    fi
done < ".gitmodules"

# Remove remote entries in local repositories
for REPO in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPO")

    echo "===== $REPOSITORY_NAME ====="

    echo "Removing remote entry from local repository ..."
    if [ -d "$REPO" ]; then
        cd "$REPO" || continue
        git remote remove "$REMOTE_HOST_NAME"
    else
        echo "Repository does not exist. Skipping."
    fi

    echo ""
done

echo "===== Removing repositories from remote ====="
echo "Copying delete-on-remote.sh script to remote ..."
rsync -az --delete --delete-during "$SCRIPT_DIR/delete-on-remote.sh" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_TARGET"

echo "Running delete-on-remote.sh script on remote ..."
echo ""
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_TARGET && ./delete-on-remote.sh"
echo ""

echo "===== Deleting scripts from remote ====="
ssh "$REMOTE_USER@$REMOTE_HOST" "rm -f $REMOTE_TARGET/clone-on-remote.sh"
ssh "$REMOTE_USER@$REMOTE_HOST" "rm -f $REMOTE_TARGET/delete-on-remote.sh"
echo ""

echo "===== Deleting remote ai-agent-workspace ====="
ssh "$REMOTE_USER@$REMOTE_HOST" "rm -rf $REMOTE_TARGET/ai-agent-workspace"
