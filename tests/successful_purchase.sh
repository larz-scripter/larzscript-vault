#!/bin/sh
# Seed a save with enough balance, then a real pay()-guarded purchase
# should succeed and the income rate should increase. Greps for the
# specific assertions rather than diffing the whole status block, since
# the exact cent balance can drift by the base passive rate depending on
# real elapsed wall-clock time between the seed/buy/status calls (all
# well under a second normally, but not worth a flaky exact-cent diff).
tmphome="$1"
LARZVAULT="${LARZVAULT:-larzscript larzvault.lz}"
LARZVAULT_SEED="${LARZVAULT_SEED:-larzscript tests/seed_balance.lz}"
HOME="$tmphome" $LARZVAULT_SEED 2000 > /dev/null
HOME="$tmphome" $LARZVAULT buy solar | grep -o '^Bought Solar Panel'
HOME="$tmphome" $LARZVAULT status | grep -E '^Income:|Solar Panel.*yes'
