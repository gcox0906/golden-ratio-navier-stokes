#!/usr/bin/env bash
set -uo pipefail
cd /workspace/comparator/repo
checker_path=/workspace/comparator/bin:/workspace/comparator/lean-4.34.0-rc2-linux/bin:/workspace/comparator/repo/.lake/packages/lean4export/.lake/build/bin:/workspace/comparator/repo/.lake/packages/Comparator/.lake/build/bin:/usr/local/bin:/usr/bin:/bin
runuser -u verifier -- env PATH="$checker_path" LEAN_NUM_THREADS=4 /workspace/comparator/bin/deny-unix /usr/bin/time -v lake env comparator ComparatorChallenges/NavierStokes.json >../logs/comparator.log 2>&1
code=$?
echo "$code" >../comparator-exit-code
sha256sum ComparatorChallenges/NavierStokes.lean ComparatorChallenges/NavierStokes.json NavierStokes/ComparatorDefinitions.lean >../logs/challenge-sha256-after.txt
cmp ../logs/challenge-sha256-before.txt ../logs/challenge-sha256-after.txt
echo "$?" >../challenge-unchanged-exit-code
echo completed >../finished
exit "$code"
