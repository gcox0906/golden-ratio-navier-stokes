import NavierStokes.ComparatorSolution
import NavierStokes.PaperResults
import NavierStokes.TorusCoverDegree
import NavierStokes.GoldenEigenGeometry
import NavierStokes.GoldenDiophantineGraph
import NavierStokes.GoldenCoverLattice
import NavierStokes.CorrectionInitializationNoOptions
import Lean

-- Check the final statements without altering the upstream problem definitions.
#check NavierStokes.Comparator.navier_stokes_breakdown_R3
#check NavierStokes.Comparator.navier_stokes_breakdown_periodic
#check NavierStokesR3.theorem_1_1
#check NavierStokes.PeriodicPaper.periodic_corollary

#print axioms NavierStokes.Comparator.navier_stokes_breakdown_R3
#print axioms NavierStokes.Comparator.navier_stokes_breakdown_periodic
#print axioms NavierStokesR3.theorem_1_1
#print axioms NavierStokesR3.theorem_1_1_with_dissipation
#print axioms NavierStokes.PeriodicPaper.periodic_corollary
#print axioms NavierStokes.ChartScales.rho_gt_half
#print axioms NavierStokes.DiophantineGraph.graph_directions_diophantine
#print axioms NavierStokes.TorusInverse.reciprocal_symbol_bound
#print axioms NavierStokes.TorusCoverLattice.card_sheet
#print axioms NavierStokes.TorusCoverDegree.card_fiber
#print axioms NavierStokes.PhysicalGraphBounds.cover_radialDirection
#print axioms NavierStokes.PhysicalGraphBounds.cover_timeDirection
#print axioms NavierStokes.TemporalMeanUpdate.coverLinear_temporal

-- Confirm that the final proof term actually reaches the changed construction.
-- This is a diagnostic traversal, not an additional axiom or proof assumption.
open Lean in
private partial def goldenDependencies (env : Environment) (todo : List Name)
    (seen : NameSet := {}) : NameSet :=
  match todo with
  | [] => seen
  | name :: rest =>
    if seen.contains name then goldenDependencies env rest seen
    else
      let seen := seen.insert name
      match env.find? name with
      | none => goldenDependencies env rest seen
      | some info =>
        let deps := info.type.getUsedConstants.toList
        let deps := match info.value? (allowOpaque := true) with
          | some value => value.getUsedConstants.toList ++ deps
          | none => deps
        goldenDependencies env (deps ++ rest) seen

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  for root in [``NavierStokes.Comparator.navier_stokes_breakdown_R3,
      ``NavierStokes.Comparator.navier_stokes_breakdown_periodic] do
    let used := goldenDependencies env [root]
    for target in [``NavierStokes.SlotGeometry.cover,
        ``NavierStokes.SlotColoring.coverGrowth,
        ``NavierStokes.ChartScales.Lambda,
        ``NavierStokes.TorusInverse.vector,
        ``NavierStokes.CommonCoverSolve.indexMap] do
      unless used.contains target do
        throwError "Missing golden construction dependency: {root} -> {target}"
      logInfo m!"GOLDEN_DEPENDENCY {root} -> {target}"

-- Exact theorem inventory and assumption check for the changed construction modules.
open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let modules := ["NavierStokes.ActualSignedGeometry", "NavierStokes.ActualSignedNativeBounds",
    "NavierStokes.ChartScales",
    "NavierStokes.CommonCoverClass", "NavierStokes.CommonCoverSolve",
    "NavierStokes.CorrectionInitialization", "NavierStokes.CorrectionInitializationNoOptions",
    "NavierStokes.DiophantineGraph",
    "NavierStokes.PhysicalGraphBounds", "NavierStokes.PrimaryFieldAssembly",
    "NavierStokes.SlotColoring", "NavierStokes.SlotGeometry",
    "NavierStokes.TemporalMeanUpdate", "NavierStokes.TorusAverages",
    "NavierStokes.TorusCoverDegree", "NavierStokes.TorusCoverLattice",
    "NavierStokes.TorusInverse", "NavierStokes.GoldenEigenGeometry",
    "NavierStokes.GoldenDiophantineGraph", "NavierStokes.GoldenCoverLattice"]
  for (name, info) in env.constants.toList do
    if info.isTheorem then
      if let some idx := env.getModuleIdxFor? name then
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modules.contains moduleName.toString then
          let axioms ← collectAxioms name
          for ax in axioms do
            unless [``propext, ``Quot.sound, ``Classical.choice].contains ax do
              throwError "Unpermitted axiom in {name}: {ax}"
          logInfo m!"GOLDEN_THEOREM\t{moduleName}\t{name}\t{axioms}"
