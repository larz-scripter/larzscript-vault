#!/bin/sh
# Corrupting the save's signature (simulating a tampered/corrupted file)
# must be caught on load, refused, and exit non-zero - the save is never
# silently accepted.
tmphome="$1"
LARZVAULT="${LARZVAULT:-larzscript larzvault.lz}"
HOME="$tmphome" $LARZVAULT status > /dev/null
save="$tmphome/.larzvault/save.json"
# Flip the sig field to a value that can never be valid hex, guaranteeing
# a mismatch regardless of what the real signature happened to be.
sed -i 's/"sig":"[0-9a-f]/"sig":"z/' "$save"
HOME="$tmphome" $LARZVAULT status
echo "exit=$?"
