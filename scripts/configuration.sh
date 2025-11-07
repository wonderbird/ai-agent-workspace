#!/bin/bash
# Configuration of repositories for the sync and delete scripts
#
# USAGE: source this file in the scripts using it
set -eEufo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PARENT_DIR=$(dirname "$SCRIPT_DIR")

REPOSITORIES=(
    "$PARENT_DIR"
    # "$PARENT_DIR/../71.27-zwischenzeugnis-erhalten"
    # "$PARENT_DIR/../aircraftnoise-backend"
    # "$PARENT_DIR/../aoc_test_runner"
    # "$PARENT_DIR/../learning/GildedRose-Refactoring-Kata"
)