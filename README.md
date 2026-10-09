# A verified golden-ratio auxiliary covering for the Navier–Stokes construction

This repository publishes a verified alternative auxiliary torus covering for
[OpenAI's NavierStokesAndEuler construction](https://github.com/openai/NavierStokesAndEuler).
It replaces the matrix `[[3,1],[1,5]]` with `[[3,1],[1,4]]` and updates the dependent
Lean proofs. The original whole-space and periodic **forced** Navier–Stokes
challenge statements are unchanged.

The complete library build passed, and both final dependent proofs were accepted
by Comparator, Lean's kernel, and nanoda. This is an auxiliary construction
change, with no new PDE statement, wider parameter-range claim, or black-hole
theorem. The original PDE construction and formalization are credited to the
upstream authors. This publication is not an upstream-endorsed release.

## Read or download

- [Short technical note](docs/technical-note.md)
- [Complete 20-module patch](evidence/golden-covering.patch)
- [Pinned reproduction instructions](evidence/REPRODUCE.txt)
- [Comparator and nanoda verification status](evidence/comparator-status.txt)
- [Full-library build and axiom-audit status](evidence/integration-status.txt)
- [Original checker logs](evidence/checker-logs/)
- [Original integration logs](evidence/integration-logs/)
- [Module inventory](evidence/modules-verified.tsv) and [theorem inventory](evidence/theorems-verified.tsv)
- [Integrity manifest](evidence/SHA256SUMS.json)
- [Release downloads](https://github.com/gcox0906/golden-ratio-navier-stokes/releases)

The evidence directory retains the exact previously prepared review package,
including its historical discussion draft. Statements in that draft about being
unpublished describe its preparation state. This README describes the public release.

## What changes

Let `b = (sqrt(5)-1)/2`, so `b²+b=1`. The replacement has determinant 11,
eigenvalues `(7-sqrt(5))/2` and `(7+sqrt(5))/2`, and eigenvectors `(1,-b)` and `(b,1)`.

| Quantity | Original | Golden replacement |
| --- | --- | --- |
| Matrix | `[[3,1],[1,5]]` | `[[3,1],[1,4]]` |
| Determinant | 14 | 11 |
| Covering degree at depth d | `14^d` | `11^d` |
| Spectral exponent rho | 0.5624713724 | 0.5672834950 |

The patch updates the covering maps, degree proofs, lattice quotients,
common-cover coordinates, directional Fourier inverses, and chart-scale constants.
It contains 17 modified and three added construction modules. Both final
challenge proofs depend on the replacement construction.

The original rho already exceeds 1/2. The new lemma recording that inequality
does not establish a previously unavailable threshold. The lower covering degree
is a combinatorial improvement; no runtime speedup or universal optimality is claimed.

## Verification record

The verification was performed at upstream commit
`f9e8bc5b38b6e212696e8a30e3e91517af887bbd`, using the pinned toolchain:

| Dependency | Pin |
| --- | --- |
| Lean | `leanprover/lean4:v4.34.0-rc2` |
| Mathlib | `85e3a25e006c35636f0e53b0e9296caca2685bc0` |
| Comparator | `19e111e2141cf333c7daff0f64c5f24acc91dd2e` |
| lean4export | `cacf989bd75f608700820f6afc595f32e7a99a4d` |
| nanoda | `3a2407216ee84a75f9e1aead6803d0578be06ae7` |

- Complete NavierStokes library: **820 source modules**, warnings treated as errors.
- Changed construction modules: **2469 theorem declarations** in the axiom inventory,
  including generated declarations.
- Standalone Stage 4 modules: **59 named theorems and one finite instance**.
- Unchanged Comparator challenge, with `enable_nanoda=true`: exit code **0**.
- Both final dependent proofs accepted by **nanoda** and **Lean's default kernel**.
- Permitted axioms: `propext`, `Quot.sound`, and `Classical.choice`; `sorryAx` excluded.

Final checked targets:

```text
NavierStokes.Comparator.navier_stokes_breakdown_R3
NavierStokes.Comparator.navier_stokes_breakdown_periodic
```

The reference challenge intentionally contains placeholders; the accepted
solution proofs satisfy the three-axiom whitelist. The independent checker
replays the targets' dependent proof terms, rather than every unused library declaration.

The original checker ran in a container with an unprivileged verifier and Landrun.
An inherited seccomp wrapper replaced the documented systemd wrapper. Its scripts
and tested filesystem/AF_UNIX denial properties are disclosed in the package.
These records establish proof acceptance and the tested properties, not a general
adversarial-sandbox certification.

These are the recorded earlier successful checks. Publishing the repository
does not constitute another Lean build or independent-kernel run.

## Reproduce

Use a separate checkout and a named branch:

```bash
git clone https://github.com/openai/NavierStokesAndEuler.git golden-check
cd golden-check
git checkout -b golden-auxiliary-covering f9e8bc5b38b6e212696e8a30e3e91517af887bbd
git apply /absolute/path/to/this-publication/evidence/golden-covering.patch
bash /absolute/path/to/this-publication/evidence/verify_golden_integration.sh /absolute/path/to/golden-check
```

Follow [REPRODUCE.txt](evidence/REPRODUCE.txt) for toolchain setup, the independent
checker, and the exact container reproduction scripts. Preserve the original
challenge definitions and configuration. The patch was applied to a pristine
export of the pinned base and matched all 20 verified construction files after
CRLF/LF normalization; exact source snapshots are also supplied.

## Scope and attribution

The mathematical statements being preserved are those specified by the upstream
whole-space and periodic forced-fluid challenge. This repository makes no
stronger unforced Navier–Stokes claim, physical significance claim for phi,
exact Einstein metric claim, or global event-horizon claim. The later exploratory
gravity and cross-domain investigations are outside this verified release.

Original sources:

- [OpenAI, NavierStokesAndEuler](https://github.com/openai/NavierStokesAndEuler)
- [Finite time blowup for Navier–Stokes, Section 6](https://cdn.openai.com/pdf/32d9f210-8b73-45e0-91bc-82a30aef8a9a/navier-stokes.pdf)
- [Attribution details](evidence/ATTRIBUTION.txt)

Upstream source comments and credits are retained. The original Apache-2.0
license is included as [LICENSE](LICENSE). The repository is published by
[`gcox0906`](https://github.com/gcox0906) as a reproducible alternative-construction record.
