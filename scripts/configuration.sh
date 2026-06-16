#!/bin/bash
# Configuration of repositories for the sync and delete scripts
#
# USAGE: source this file in the scripts using it
set -eEufo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REMOTE_USER=galadriel
PARENT_DIR=$(dirname "$SCRIPT_DIR")

REPOSITORIES=(
    #"$PARENT_DIR"
    # "$PARENT_DIR/../hello-world"
)
