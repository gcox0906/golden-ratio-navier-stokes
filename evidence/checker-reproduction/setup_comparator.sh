#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq git curl zstd python3 ca-certificates build-essential golang-go libseccomp-dev pkg-config strace time libcap2-bin
mkdir -p /workspace/comparator/{logs,bin}
cd /workspace/comparator
useradd --create-home --home-dir /workspace/comparator/userhome --shell /bin/bash verifier
uname -a >logs/kernel.txt
python3 - <<'PY' >logs/landlock-abi.txt
import ctypes
libc=ctypes.CDLL(None,use_errno=True)
abi=libc.syscall(444,0,0,1)
print('Landlock ABI:',abi,'errno:',ctypes.get_errno())
if abi<1: raise SystemExit('Landlock is not supported on this host.')
PY
gcc -O2 deny_unix.c -lseccomp -o bin/deny-unix
gcc -O2 lake_threads.c -o bin/lake
curl -fL --retry 2 https://github.com/leanprover/lean4/releases/download/v4.34.0-rc2/lean-4.34.0-rc2-linux.tar.zst -o lean.tar.zst
echo '3d011041203acacf300d343a39673f7d233743397993797c941346ae9e5df1a8  lean.tar.zst' | sha256sum -c -
tar --use-compress-program=unzstd -xf lean.tar.zst
export PATH=/workspace/comparator/lean-4.34.0-rc2-linux/bin:$PATH
export LEAN_NUM_THREADS=4
export MATHLIB_CACHE_DIR=/workspace/comparator/mathlib-cache
git clone --depth 1 https://github.com/openai/NavierStokesAndEuler.git repo
cd repo
git fetch --depth 1 origin f9e8bc5b38b6e212696e8a30e3e91517af887bbd
git checkout -b codex/golden-comparator-verification f9e8bc5b38b6e212696e8a30e3e91517af887bbd
test "$(cat lean-toolchain)" = leanprover/lean4:v4.34.0-rc2
mkdir -p .lake/packages
git clone --depth 1 --branch v4.34.0-rc2 https://github.com/leanprover-community/mathlib4.git .lake/packages/mathlib
test "$(git -C .lake/packages/mathlib rev-parse HEAD)" = 85e3a25e006c35636f0e53b0e9296caca2685bc0
tar -xzf ../golden-changes.tar.gz
git diff --exit-code HEAD -- ComparatorChallenges/NavierStokes.lean ComparatorChallenges/NavierStokes.json NavierStokes/ComparatorDefinitions.lean NavierStokes/ComparatorSolution.lean lakefile.toml lake-manifest.json lean-toolchain >../logs/unchanged-challenge.log
sha256sum ComparatorChallenges/NavierStokes.lean ComparatorChallenges/NavierStokes.json NavierStokes/ComparatorDefinitions.lean >../logs/challenge-sha256-before.txt
lake exe cache get >../logs/mathlib-cache.log 2>&1
lake build comparator lean4export >../logs/checker-build.log 2>&1
test "$(git -C .lake/packages/Comparator rev-parse HEAD)" = 19e111e2141cf333c7daff0f64c5f24acc91dd2e
test "$(git -C .lake/packages/lean4export rev-parse HEAD)" = cacf989bd75f608700820f6afc595f32e7a99a4d
cd ..
git clone --depth 1 https://github.com/Zouuup/landrun.git landrun
git -C landrun fetch --depth 1 origin 811cfff51ceaf3d9843708aa6d22e9b84ccac8b4
git -C landrun checkout 811cfff51ceaf3d9843708aa6d22e9b84ccac8b4
(cd landrun && GOTOOLCHAIN=go1.24.0 go build -o ../bin/landrun ./cmd/landrun) >logs/landrun-build.log 2>&1
git clone --depth 1 https://github.com/ammkrn/nanoda_lib.git nanoda
git -C nanoda fetch --depth 1 origin 3a2407216ee84a75f9e1aead6803d0578be06ae7
git -C nanoda checkout 3a2407216ee84a75f9e1aead6803d0578be06ae7
curl -fL --retry 2 https://sh.rustup.rs -o rustup-init.sh
runuser -u verifier -- sh /workspace/comparator/rustup-init.sh -y --profile minimal --default-toolchain 1.99.0 >logs/rust-install.log 2>&1
chown -R verifier:verifier nanoda
runuser -u verifier -- bash -c 'cd /workspace/comparator/nanoda && /workspace/comparator/userhome/.cargo/bin/cargo build --release' >logs/nanoda-build.log 2>&1
cp nanoda/target/release/nanoda_bin bin/
{
  lean --version
  lake --version
  git -C repo rev-parse HEAD
  git -C repo/.lake/packages/Comparator rev-parse HEAD
  git -C repo/.lake/packages/lean4export rev-parse HEAD
  git -C landrun rev-parse HEAD
  git -c safe.directory=/workspace/comparator/nanoda -C nanoda rev-parse HEAD
  runuser -u verifier -- /workspace/comparator/userhome/.cargo/bin/rustc --version
  bin/landrun --help
} >logs/versions.txt 2>&1
# The user can write build artifacts, never challenge or solution source files.
chown -R verifier:verifier repo/.lake
chmod -R a+rX repo lean-4.34.0-rc2-linux bin
runuser -u verifier -- bin/deny-unix python3 /workspace/comparator/check_sandbox.py >logs/sandbox-tests.log 2>&1
touch ready
bash /workspace/comparator/run_comparator.sh
