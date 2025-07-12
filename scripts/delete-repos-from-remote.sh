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
# ./delete-repos-from-remote.sh HOST_IP_ADDRESS
#
# Parameters
#
#   HOST_IP_ADDRESS  The IP address of the remote host on which the repositories
#                    should be deleted.
#
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Get remote host IP from command line
if [ -z "$1" ]; then
    echo "Usage: $0 HOST_IP_ADDRESS"
    exit 1
fi

REMOTE_HOST="$1"
REMOTE_HOST_NAME="lorien"
REMOTE_USER=galadriel
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
echo "===== Removing remote entries in local repositories ====="
for REPO in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPO")

    echo "$REPOSITORY_NAME"

    echo "  Removing remote entry ..."
    if [ -d "$REPO" ]; then
        git -C "$REPO" remote remove "$REMOTE_HOST_NAME"
    else
        echo "  Repository does not exist. Skipping ..."
    fi

    echo ""
done

echo "===== Removing repositories from remote ====="
echo "Copying delete-on-remote.sh script to remote ..."
rsync -az --delete --delete-during "$SCRIPT_DIR/delete-on-remote.sh" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_TARGET"

echo "Running delete-on-remote.sh script on remote ..."
echo ""
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_TARGET && ./delete-on-remote.sh"

echo "===== Cleaning up on remote ====="
echo "Removing shell scripts ..."
ssh "$REMOTE_USER@$REMOTE_HOST" "rm -vf $REMOTE_TARGET/clone-on-remote.sh $REMOTE_TARGET/delete-on-remote.sh"
