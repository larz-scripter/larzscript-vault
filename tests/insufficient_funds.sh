#!/bin/sh
# A fresh game has $5.00; Solar Panel costs $10.00 - require() must
# refuse the purchase and the CLI must exit non-zero.
tmphome="$1"
LARZVAULT="${LARZVAULT:-larzscript larzvault.lz}"
HOME="$tmphome" $LARZVAULT buy solar
echo "exit=$?"
