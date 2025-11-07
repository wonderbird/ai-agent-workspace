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
# Example
#
#   pushd ~/source/ai-agent-workspace/scripts && ./delete-repos-from-remote.sh "$IPV4_ADDRESS"; popd
#
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Read configuration
# shellcheck disable=SC1091
#   (shellcheck is not able to read the file for some reason and the recommended workaround does not work)
. "$SCRIPT_DIR/configuration.sh"

# Get remote host IP from command line
if [ -z "$1" ]; then
    echo "Usage: $0 HOST_IP_ADDRESS"
    exit 1
fi

REMOTE_HOST="$1"
REMOTE_HOST_NAME="agent"
REMOTE_USER=galadriel
REMOTE_TARGET="/home/galadriel/Documents"

# Remove remote entries in local repositories
echo "===== Removing remote entries in local repositories ====="
for REPOSITORY_PATH in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPOSITORY_PATH")

    echo "$REPOSITORY_NAME"

    echo "  Removing remote entry ..."
    if [ -d "$REPOSITORY_PATH" ]; then
        git -C "$REPOSITORY_PATH" remote remove "$REMOTE_HOST_NAME"
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
