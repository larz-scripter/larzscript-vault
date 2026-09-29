#!/bin/sh
# Runs each tests/*.sh scenario against a fresh temp $HOME and diffs its
# combined output against tests/<name>.expected. Same discipline as every
# other larzscript-* showcase app's tests/run_tests.sh.
#
# Env override: LARZVAULT="larzscript /path/to/larzvault.lz" and
# LARZVAULT_SEED="larzscript /path/to/seed_balance.lz" to test an
# installed copy instead of the repo one (used by CI).
set -e
cd "$(dirname "$0")/.."
LARZVAULT="${LARZVAULT:-larzscript larzvault.lz}"
LARZVAULT_SEED="${LARZVAULT_SEED:-larzscript tests/seed_balance.lz}"
export LARZVAULT
export LARZVAULT_SEED
# Each test overrides $HOME to a fresh temp dir (so the game's own save
# lives there, not the real ~/.larzvault) - but module resolution's
# "~/.larzscript/lib" fallback would then ALSO re-resolve against that
# fake HOME and stop finding the packages installed for the real user.
# Pin LARZSCRIPT_PATH to the real, fixed install location now, before
# any test gets a chance to override HOME.
export LARZSCRIPT_PATH="${LARZSCRIPT_PATH:-$HOME/.larzscript/lib}"

pass=0; fail=0
for t in tests/*.sh; do
  case "$t" in *run_tests.sh) continue ;; esac
  exp="${t%.sh}.expected"
  tmphome="$(mktemp -d)"
  got="$(sh "$t" "$tmphome" 2>&1 | sed "s#$tmphome#HOME_DIR#g" || true)"
  rm -rf "$tmphome"
  if [ "$got" = "$(cat "$exp")" ]; then
    pass=$((pass+1))
  else
    fail=$((fail+1)); echo "FAIL $t"; echo "--- expected ---"; cat "$exp"; echo "--- got ---"; echo "$got"
  fi
done
echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
