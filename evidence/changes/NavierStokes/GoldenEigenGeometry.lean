import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic

/-!
Golden version of the 2D auxiliary covering eigendata, independent of the
full Navier–Stokes PDE. Verified with Lean 4.34.0-rc2 on 2026-10-08.
This standalone module does not establish the full PDE substitution.
-/
noncomputable section
namespace GoldenEigenGeometry

abbrev Plane := ℝ × ℝ

def b : ℝ := (Real.sqrt 5 - 1) / 2
def smallEigenvalue : ℝ := (7 - Real.sqrt 5) / 2
def largeEigenvalue : ℝ := (7 + Real.sqrt 5) / 2

def radial : Plane := (1, -b)
def temporal : Plane := (b, 1)
def cover (z : Plane) : Plane := (3 * z.1 + z.2, z.1 + 4 * z.2)

theorem sqrt_five_sq : (Real.sqrt 5) ^ 2 = (5 : ℝ) :=
  Real.sq_sqrt (by norm_num)

theorem b_quadratic : b ^ 2 + b = 1 := by
  unfold b
  nlinarith [sqrt_five_sq]

theorem b_pos : 0 < b := by
  have hs : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg _
  unfold b
  nlinarith [sqrt_five_sq]

theorem b_lt_one : b < 1 := by
  have hs : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg _
  unfold b
  nlinarith [sqrt_five_sq]

theorem eigenvalue_product : smallEigenvalue * largeEigenvalue = 11 := by
  unfold smallEigenvalue largeEigenvalue
  nlinarith [sqrt_five_sq]

theorem smallEigenvalue_gt_two : 2 < smallEigenvalue := by
  have hs : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg _
  unfold smallEigenvalue
  nlinarith [sqrt_five_sq]

theorem largeEigenvalue_gt_one : 1 < largeEigenvalue := by
  have hs : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg _
  unfold largeEigenvalue
  nlinarith [sqrt_five_sq]

theorem cover_radial :
    cover radial = (smallEigenvalue * radial.1, smallEigenvalue * radial.2) := by
  apply Prod.ext
  · simp [cover, radial, b, smallEigenvalue]
    ring
  · dsimp [cover, radial, smallEigenvalue, b]
    nlinarith [sqrt_five_sq]

theorem cover_temporal :
    cover temporal = (largeEigenvalue * temporal.1, largeEigenvalue * temporal.2) := by
  apply Prod.ext
  · dsimp [cover, temporal, largeEigenvalue, b]
    nlinarith [sqrt_five_sq]
  · dsimp [cover, temporal, largeEigenvalue, b]
    ring

theorem eigenvectors_orthogonal : radial.1 * temporal.1 + radial.2 * temporal.2 = 0 := by
  simp [radial, temporal]

theorem eigenbasis_determinant_pos : 0 < radial.1 * temporal.2 - radial.2 * temporal.1 := by
  simp [radial, temporal]
  nlinarith [sq_nonneg b]

/-- The same coarse 6-L∞-norm operator estimate as in the original matrix. -/
theorem cover_norm_infty_bound (x : Plane) :
    max |(cover x).1| |(cover x).2| ≤
      6 * max |x.1| |x.2| := by
  have hx : |x.1| ≤ max |x.1| |x.2| := le_max_left _ _
  have hy : |x.2| ≤ max |x.1| |x.2| := le_max_right _ _
  have hmax : 0 ≤ max |x.1| |x.2| := (abs_nonneg x.1).trans hx
  simp only [cover]
  apply max_le
  · calc
      |3 * x.1 + x.2| ≤ |3 * x.1| + |x.2| := abs_add_le _ _
      _ ≤ 6 * max |x.1| |x.2| := by rw [abs_mul]; norm_num; linarith
  · calc
      |x.1 + 4 * x.2| ≤ |x.1| + |4 * x.2| := abs_add_le _ _
      _ ≤ 6 * max |x.1| |x.2| := by rw [abs_mul]; norm_num; linarith

/-- New: the golden covering has sharp L-infinity operator norm at most 5. -/
theorem cover_norm_infty_sharp (x : Plane) :
    max |(cover x).1| |(cover x).2| ≤
      5 * max |x.1| |x.2| := by
  have hx : |x.1| ≤ max |x.1| |x.2| := le_max_left _ _
  have hy : |x.2| ≤ max |x.1| |x.2| := le_max_right _ _
  have hmax : 0 ≤ max |x.1| |x.2| := (abs_nonneg x.1).trans hx
  simp only [cover]
  apply max_le
  · calc
      |3 * x.1 + x.2| ≤ |3 * x.1| + |x.2| := abs_add_le _ _
      _ ≤ 5 * max |x.1| |x.2| := by rw [abs_mul]; norm_num; linarith
  · calc
      |x.1 + 4 * x.2| ≤ |x.1| + |4 * x.2| := abs_add_le _ _
      _ ≤ 5 * max |x.1| |x.2| := by rw [abs_mul]; norm_num; linarith

end GoldenEigenGeometry
