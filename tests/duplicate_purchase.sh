#!/bin/sh
# Buying an already-owned upgrade twice must be rejected the second time.
tmphome="$1"
LARZVAULT="${LARZVAULT:-larzscript larzvault.lz}"
LARZVAULT_SEED="${LARZVAULT_SEED:-larzscript tests/seed_balance.lz}"
HOME="$tmphome" $LARZVAULT_SEED 2000 > /dev/null
HOME="$tmphome" $LARZVAULT buy solar | grep -o '^Bought Solar Panel'
HOME="$tmphome" $LARZVAULT buy solar
echo "exit=$?"
