#!/usr/bin/env bash
set -euo pipefail
cd /workspace/comparator
{
  lean-4.34.0-rc2-linux/bin/lean --version
  lean-4.34.0-rc2-linux/bin/lake --version
  git -C repo rev-parse HEAD
  git -C repo/.lake/packages/Comparator rev-parse HEAD
  git -C repo/.lake/packages/lean4export rev-parse HEAD
  git -C landrun rev-parse HEAD
  git -c safe.directory=/workspace/comparator/nanoda -C nanoda rev-parse HEAD
  runuser -u verifier -- /workspace/comparator/userhome/.cargo/bin/rustc --version
  bin/landrun --help
} >logs/versions.txt 2>&1
git config --system --add safe.directory /workspace/comparator/repo
chown -R verifier:verifier repo/.lake
chmod -R a+rX repo lean-4.34.0-rc2-linux bin
runuser -u verifier -- bin/deny-unix python3 /workspace/comparator/check_sandbox.py >logs/sandbox-tests.log 2>&1
touch ready
bash /workspace/comparator/run_comparator.sh
