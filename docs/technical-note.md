Short technical note · October 8, 2026 · prepared for review

# A verified golden-ratio auxiliary covering for the Navier–Stokes construction

An alternative two-dimensional auxiliary torus covering has been integrated into OpenAI’s existing Navier–Stokes formalization. The final whole-space and periodic forced-fluid challenge statements are unchanged. Their dependent proofs were accepted by Comparator, Lean’s kernel, and nanoda.

## Attribution and scope

The original construction, PDE argument and upstream formalization are due to OpenAI: [NavierStokesAndEuler](https://github.com/openai/NavierStokesAndEuler) and [Finite time blowup for Navier–Stokes](https://cdn.openai.com/pdf/32d9f210-8b73-45e0-91bc-82a30aef8a9a/navier-stokes.pdf), Section 6. This contribution changes the auxiliary covering and repairs its dependent proofs. It introduces no new PDE statement or black-hole theorem. The upstream credit to the Formal Conjectures authors for the adapted challenge statement is retained; Lean, Mathlib, Comparator, lean4export and nanoda are credited for verification infrastructure.

## The replacement

```text
Original:       J₀ = [[3,1],[1,5]],  det J₀ = 14.
Replacement:    Jφ = [[3,1],[1,4]],  det Jφ = 11.
b = (√5−1)/2,   b²+b = 1.
vr = (1,−b),    vt = (b,1).
Λ = (7−√5)/2,   T = (7+√5)/2,   ΛT = 11.
```

The patch updates covering maps and degrees, lattice quotients, common-cover coordinates, directional Fourier inverse estimates and chart-scale constants. At depth d the covering degree becomes 11ᵈ rather than 14ᵈ. This changes a combinatorial count; no runtime benchmark or stronger PDE conclusion is claimed.

| Quantity | Original | Golden replacement |
| --- | --- | --- |
| Determinant | 14 | 11 |
| ρ = log Λ / log T | 0.5624713724 | 0.5672834950 |
| Quadratic field | ℚ(√2) | ℚ(√5) |

The original ρ already exceeds 1/2. The added `ChartScales.rho_gt_half` lemma therefore does not cross a previously unavailable threshold. No wider h range, optimality among all matrices, or new physical significance of φ is claimed.

## What was verified

The complete NavierStokes library built with warnings treated as errors: 820 source modules including the root. An axiom inventory covers 2469 theorem declarations, including generated declarations, in the 20 changed or added construction modules. A separate Stage 4 audit covers 59 named theorems and one finite instance.

```text
Final independent-checker targets:
NavierStokes.Comparator.navier_stokes_breakdown_R3
NavierStokes.Comparator.navier_stokes_breakdown_periodic
```

Comparator ran with the original challenge and `enable_nanoda=true`, exited zero, and recorded all three success messages:

```text
nanoda kernel accepts the solution
Lean default kernel accepts the solution
Your solution is okay!
```

The challenge definitions were unchanged. Only `propext`, `Quot.sound` and `Classical.choice` were permitted; `sorryAx` is excluded. The intentional reference-challenge placeholders are separate from the accepted solution proofs. Dependency traversal confirms that both final proofs reach the changed covering and spectral constants. The independent check covers their dependent proof terms, rather than replaying every unused declaration in the library.

The checker ran under an unprivileged Linux account with Landrun. An inherited seccomp wrapper replaced the documented systemd wrapper. The recorded filesystem and AF_UNIX denial tests are disclosed in the evidence. These records establish proof acceptance and the tested properties; they are not a general adversarial-sandbox certification.

## Patch and reproduction

```text
Upstream base: f9e8bc5b38b6e212696e8a30e3e91517af887bbd
Lean: leanprover/lean4:v4.34.0-rc2
Mathlib: 85e3a25e006c35636f0e53b0e9296caca2685bc0
Comparator: 19e111e2141cf333c7daff0f64c5f24acc91dd2e
```

[The complete patch](../evidence/golden-covering.patch) contains 17 modified and three added construction modules. It applies to a pristine copy of the pinned base and reproduces the verified source text; exact verified file snapshots are supplied separately because patch application may normalize line endings. The audit modules are also included. Follow [the reproduction instructions](../evidence/REPRODUCE.txt) in a separate checkout and named branch.

The package includes [the complete Comparator log](../evidence/checker-logs/comparator.log), [the independent-checker report](../evidence/comparator-status.txt), [the library-build report](../evidence/integration-status.txt), [module hashes](../evidence/modules-verified.tsv), [the theorem/axiom inventory](../evidence/theorems-verified.tsv), all relevant scripts, original license attribution, and integrity hashes. These logs record the earlier successful verification; packaging did not rerun the Lean kernels.

This is a reproducible alternative auxiliary construction. Research novelty beyond that substitution has not been established. The verification work used a separate checkout and branch. This repository publishes the note and evidence; the upstream repository remains unchanged. The [short upstream-discussion draft](../evidence/upstream-discussion.txt) is ready for review.

An [editable LaTeX version](../evidence/technical-note.tex) and the [original HTML note](../evidence/technical-note.html) are included. No compiled PDF is supplied.
