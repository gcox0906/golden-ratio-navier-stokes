#!/usr/bin/env bash
# Run from an extracted verification bundle; REPO is a separate checkout.
set -euo pipefail
bundle=$(cd -- "$(dirname -- "$0")" && pwd)
repo=${1:?Usage: verify_golden_integration.sh /path/to/separate/checkout}
cd "$repo"
test "$(git rev-parse HEAD)" = f9e8bc5b38b6e212696e8a30e3e91517af887bbd
test "$(cat lean-toolchain)" = leanprover/lean4:v4.34.0-rc2
branch=$(git branch --show-current)
case "$branch" in main|master|'') echo 'Use a separate named verification branch.' >&2; exit 1;; esac
# The bundle contains only golden integration changes and audit modules.
cp "$bundle"/changes/NavierStokes/*.lean NavierStokes/
cp "$bundle"/changes/GoldenIntegrationAudit.lean GoldenIntegrationAudit.lean
cp "$bundle"/changes/GoldenAxiomAudit.lean GoldenAxiomAudit.lean
mkdir -p "$bundle/logs-reproduced"
lake exe cache get >"$bundle/logs-reproduced/mathlib-cache.log" 2>&1
test "$(git -C .lake/packages/mathlib rev-parse HEAD)" = 85e3a25e006c35636f0e53b0e9296caca2685bc0
lake --wfail build NavierStokes >"$bundle/logs-reproduced/full-build.log" 2>&1
lake env lean -DwarningAsError=true GoldenIntegrationAudit.lean >"$bundle/logs-reproduced/integration-audit.log" 2>&1
lake env lean -DwarningAsError=true GoldenAxiomAudit.lean >"$bundle/logs-reproduced/stage4-audit.log" 2>&1
echo 'Build and axiom/dependency audit passed.'
