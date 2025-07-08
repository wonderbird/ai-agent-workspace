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
# ./create-remote-repository.sh
#
#
#
set -eEufo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

REMOTE_HOST_NAME="lorien"
REMOTE_USER=galadriel
REMOTE_HOST=$(tart ip "$REMOTE_HOST_NAME")
REMOTE_TARGET="/home/galadriel/Documents"

# List of repositories to be cloned
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

# Clone all repositories to the remote
for REPO in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPO")

    echo "===== $REPOSITORY_NAME ====="

    echo "Creating temporary bare repository ..."
    TEMP_BARE_REPO=$(mktemp -d)/$REPOSITORY_NAME.git
    git clone --bare "$REPO" "$TEMP_BARE_REPO" > /dev/null 2>&1

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
echo ""

echo "===== Configuring remote $REMOTE_HOST_NAME ====="
for REPO in "${REPOSITORIES[@]}"; do
    REPOSITORY_NAME=$(basename "$REPO")
    cd "$REPO"
    git remote add "$REMOTE_HOST_NAME" "ssh://$REMOTE_USER@$REMOTE_HOST:$REMOTE_TARGET/$REPOSITORY_NAME.git"
done
