#!/bin/bash
# Configuration of repositories for the sync and delete scripts
#
# USAGE: source this file in the scripts using it
set -eEufo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PARENT_DIR=$(dirname "$SCRIPT_DIR")

REPOSITORIES=(
    #"$PARENT_DIR"
    # "$PARENT_DIR/../72.21-home-dmz-vlan"
    # "$PARENT_DIR/../aircraftnoise-backend"
    # "$PARENT_DIR/../ansible-all-my-things"
    # "$PARENT_DIR/../aoc_test_runner"
    # "$PARENT_DIR/../birthday-briefing"
    # "$PARENT_DIR/../learning/flashycardycourse"
    # "$PARENT_DIR/../learning/GildedRose-Refactoring-Kata"
    # "$PARENT_DIR/../learning/oop2026-ki-agenten"
    #"$PARENT_DIR/../multi-timer"
    # "$PARENT_DIR/../save-energy"
)
