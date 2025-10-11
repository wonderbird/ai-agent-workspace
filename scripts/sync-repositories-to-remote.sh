#!/bin/bash
# Bring bare clones of local repositories to a remote computer.
#
# Prerequisites
#
# An SSH key for passwordless login to the remote computer is either
# loaded into the SSH agent or stored without password protection in the
# ~/.ssh directory.
#
# Usage
#
# ./create-remote-repository.sh HOST_IP_ADDRESS
#
# Parameters
#
#   HOST_IP_ADDRESS  The IP address of the remote host to which the repositories
#                    are synced.
#
# Example
#
#   pushd ~/source/ai-agent-workspace/scripts && ./sync-repositories-to-remote.sh "$IPV4_ADDRESS"; popd
#
set -eEufo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PARENT_DIR=$(dirname "$SCRIPT_DIR")

# Get remote host IP from command line
if [ -z "$1" ]; then
    echo "Usage: $0 HOST_IP_ADDRESS"
    exit 1
fi

REMOTE_HOST="$1"
REMOTE_HOST_NAME="agent"
REMOTE_USER=galadriel
REMOTE_TARGET="/home/galadriel/Documents"

# Ensure the remote target directory exists
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_TARGET"

# TODO: The list of repository should be configuration shared among the scripts dele-repos-from-remote.sh and sync-repos-to-remote.sh
# List of repositories to be cloned
REPOSITORIES=(
    "$PARENT_DIR"
)

# Clone all repositories to the remote
for REPOSITORY_PATH in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPOSITORY_PATH")

    echo "===== $REPOSITORY_NAME ====="

    echo "Creating temporary bare repository ..."
    TEMP_BARE_REPO=$(mktemp -d)/$REPOSITORY_NAME.git
    git clone --bare "$REPOSITORY_PATH" "$TEMP_BARE_REPO" >/dev/null 2>&1

    echo "Copying bare repository to remote ..."
    rsync -az --delete --delete-during "$TEMP_BARE_REPO" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_TARGET"

    echo "Cleaning up temporary bare repository ..."
    rm -rf "$TEMP_BARE_REPO"

    echo ""
done

echo "===== Cloning working directories on remote ====="
echo "Copying clone-on-remote.sh script to remote ..."
rsync -az --delete --delete-during "$SCRIPT_DIR/clone-on-remote.sh" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_TARGET"

echo "Running clone-on-remote.sh script on remote ..."
echo ""
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_TARGET && ./clone-on-remote.sh"

echo "===== Configuring remote $REMOTE_HOST_NAME ====="
for REPO in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPO")

    echo "Configuring remote for $REPOSITORY_NAME ..."

    echo "  Checking if remote already exists ..."
    if git -C "$REPO" remote get-url "$REMOTE_HOST_NAME" &>/dev/null; then
        echo "  Removing remote ..."
        git -C "$REPO" remote remove "$REMOTE_HOST_NAME"
    fi

    echo "  Configuring new remote ..."
    git -C "$REPO" remote add "$REMOTE_HOST_NAME" "ssh://$REMOTE_USER@$REMOTE_HOST:$REMOTE_TARGET/$REPOSITORY_NAME.git"
done
