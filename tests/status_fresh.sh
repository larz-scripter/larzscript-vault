#!/bin/sh
# Fresh game: starting balance, base income rate, no upgrades owned.
# Filters the "While away" line - real elapsed wall-clock time between
# game creation and this first status call is normally sub-cent (0
# earned), but isn't guaranteed deterministic on a slow CI runner, so it
# is filtered rather than risking a flaky diff.
set -e
tmphome="$1"
LARZVAULT="${LARZVAULT:-larzscript larzvault.lz}"
HOME="$tmphome" $LARZVAULT status | grep -v '^While away'
