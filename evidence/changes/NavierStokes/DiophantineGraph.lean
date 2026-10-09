import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

/-!
Golden matrix Fourier non-resonance and quantitative small-divisor estimates.
Standalone candidate to migrate into the original DiophantineGraph.lean.
Verified with Lean 4.34.0-rc2 on 2026-10-08. Integration into the full
Navier–Stokes construction remains unproved.
-/

noncomputable section
namespace NavierStokes.DiophantineGraph

def quadraticForm (p q : ℤ) : ℝ := (p : ℝ) + Real.sqrt 5 * (q : ℝ)

def integerNorm (p q : ℤ) : ℤ := p ^ 2 - 5 * q ^ 2

theorem sqrt_five_square : (Real.sqrt 5) ^ 2 = (5 : ℝ) :=
  Real.sq_sqrt (by norm_num)

theorem sqrt_five_le_three : Real.sqrt 5 ≤ (3 : ℝ) := by
  nlinarith [sqrt_five_square, Real.sqrt_nonneg (5 : ℝ)]

theorem quadraticForm_ne_zero (p q : ℤ) (hpq : p ≠ 0 ∨ q ≠ 0) :
    quadraticForm p q ≠ 0 := by
  by_cases hq : q = 0
  · have hp : p ≠ 0 := hpq.resolve_right (not_not.mpr hq)
    simpa [quadraticForm, hq] using hp
  · have hi : Irrational (Real.sqrt 5) :=
      (show Nat.Prime 5 by decide).irrational_sqrt
    have hne := hi.ne_rational (-p) q
    intro hz
    apply hne
    have hq' : (q : ℝ) ≠ 0 := by exact_mod_cast hq
    apply (eq_div_iff hq').mpr
    dsimp [quadraticForm] at hz
    push_cast
    nlinarith

theorem conjugate_product (p q : ℤ) :
    quadraticForm p q * quadraticForm p (-q) = (integerNorm p q : ℝ) := by
  simp only [quadraticForm, integerNorm, Int.cast_neg, Int.cast_sub,
    Int.cast_pow, Int.cast_mul, Int.cast_ofNat]
  nlinarith [congrArg (fun x : ℝ => x * (q : ℝ) ^ 2) sqrt_five_square]

theorem integerNorm_ne_zero (p q : ℤ) (hpq : p ≠ 0 ∨ q ≠ 0) :
    integerNorm p q ≠ 0 := by
  have hconj : p ≠ 0 ∨ -q ≠ 0 := by
    rcases hpq with hp | hq
    · exact Or.inl hp
    · exact Or.inr (neg_ne_zero.mpr hq)
  have hprod := mul_ne_zero (quadraticForm_ne_zero p q hpq)
    (quadraticForm_ne_zero p (-q) hconj)
  intro hz
  apply hprod
  rw [conjugate_product, hz, Int.cast_zero]

/-! The correct golden symbols use (2m+n, -n), not the old silver symbols. -/
def radialSymbol (m n : ℤ) : ℝ := quadraticForm (2 * m + n) (-n) / 2
def timeSymbol (m n : ℤ) : ℝ := quadraticForm (2 * n - m) m / 2

def radialConjugate (m n : ℤ) : ℝ := quadraticForm (2 * m + n) n / 2
def timeConjugate (m n : ℤ) : ℝ := quadraticForm (2 * n - m) (-m) / 2

def goldenNorm (m n : ℤ) : ℤ := m ^ 2 + m * n - n ^ 2

theorem radialSymbol_formula (m n : ℤ) :
    radialSymbol m n = (m : ℝ) + ((1 - Real.sqrt 5) / 2) * (n : ℝ) := by
  simp [radialSymbol, quadraticForm]
  ring

theorem timeSymbol_formula (m n : ℤ) :
    timeSymbol m n = ((Real.sqrt 5 - 1) / 2) * (m : ℝ) + (n : ℝ) := by
  simp [timeSymbol, quadraticForm]
  ring

theorem radialConjugate_formula (m n : ℤ) :
    radialConjugate m n = (m : ℝ) + ((1 + Real.sqrt 5) / 2) * (n : ℝ) := by
  simp [radialConjugate, quadraticForm]
  ring

theorem timeConjugate_formula (m n : ℤ) :
    timeConjugate m n = (n : ℝ) - ((1 + Real.sqrt 5) / 2) * (m : ℝ) := by
  simp [timeConjugate, quadraticForm]
  ring

theorem radial_product_formula (m n : ℤ) :
    radialSymbol m n * radialConjugate m n = (goldenNorm m n : ℝ) := by
  rw [radialSymbol_formula, radialConjugate_formula]
  simp [goldenNorm]
  nlinarith [congrArg (fun x : ℝ => x * (n : ℝ) ^ 2) sqrt_five_square]

theorem time_product_formula (m n : ℤ) :
    timeSymbol m n * timeConjugate m n =
      ((n ^ 2 - n * m - m ^ 2 : ℤ) : ℝ) := by
  rw [timeSymbol_formula, timeConjugate_formula]
  push_cast
  nlinarith [congrArg (fun x : ℝ => x * (m : ℝ) ^ 2) sqrt_five_square]

theorem goldenNorm_ne_zero (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    goldenNorm m n ≠ 0 := by
  have hpq : 2 * m + n ≠ 0 ∨ -n ≠ 0 := by
    by_cases hn : n = 0
    · left
      have hm : m ≠ 0 := hmn.resolve_right (not_not.mpr hn)
      omega
    · exact Or.inr (neg_ne_zero.mpr hn)
  have hpq' : 2 * m + n ≠ 0 ∨ n ≠ 0 := by
    rcases hpq with hp | hn
    · exact Or.inl hp
    · exact Or.inr (neg_ne_zero.mp hn)
  have hr : radialSymbol m n ≠ 0 :=
    div_ne_zero (quadraticForm_ne_zero _ _ hpq) (by norm_num)
  have hc : radialConjugate m n ≠ 0 :=
    div_ne_zero (quadraticForm_ne_zero _ _ hpq') (by norm_num)
  intro hz
  have hprod := radial_product_formula m n
  rw [hz, Int.cast_zero] at hprod
  exact (mul_ne_zero hr hc) hprod

theorem radial_product_lower (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    1 ≤ |radialSymbol m n| * |radialConjugate m n| := by
  have hi : (1 : ℤ) ≤ |goldenNorm m n| :=
    Int.add_one_le_iff.mpr (abs_pos.mpr (goldenNorm_ne_zero m n hmn))
  have hr : (1 : ℝ) ≤ |(goldenNorm m n : ℝ)| := by exact_mod_cast hi
  rw [← radial_product_formula, abs_mul] at hr
  exact hr

theorem time_product_lower (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    1 ≤ |timeSymbol m n| * |timeConjugate m n| := by
  have hnorm : n ^ 2 - n * m - m ^ 2 = -(goldenNorm m n) := by
    unfold goldenNorm
    ring
  have hi : (1 : ℤ) ≤ |n ^ 2 - n * m - m ^ 2| := by
    rw [hnorm, abs_neg]
    exact Int.add_one_le_iff.mpr (abs_pos.mpr (goldenNorm_ne_zero m n hmn))
  have hr : (1 : ℝ) ≤ |((n ^ 2 - n * m - m ^ 2 : ℤ) : ℝ)| := by exact_mod_cast hi
  rw [← time_product_formula, abs_mul] at hr
  exact hr

def frequencyL1 (m n : ℤ) : ℝ := |(m : ℝ)| + |(n : ℝ)|
def frequencyLength (m n : ℤ) : ℝ := Real.sqrt ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)

theorem frequencyL1_nonneg (m n : ℤ) : 0 ≤ frequencyL1 m n := by
  unfold frequencyL1
  positivity

theorem frequencyLength_nonneg (m n : ℤ) : 0 ≤ frequencyLength m n :=
  Real.sqrt_nonneg _

theorem radialConjugate_upper (m n : ℤ) :
    |radialConjugate m n| ≤ 3 * frequencyL1 m n := by
  rw [radialConjugate_formula]
  have hb : 0 ≤ (1 + Real.sqrt 5) / 2 ∧ (1 + Real.sqrt 5) / 2 ≤ 3 := by
    constructor <;> nlinarith [sqrt_five_le_three, Real.sqrt_nonneg (5 : ℝ)]
  calc
    |(m : ℝ) + ((1 + Real.sqrt 5) / 2) * (n : ℝ)| ≤
        |(m : ℝ)| + |((1 + Real.sqrt 5) / 2) * (n : ℝ)| := abs_add_le _ _
    _ = |(m : ℝ)| + ((1 + Real.sqrt 5) / 2) * |(n : ℝ)| := by
      rw [abs_mul, abs_of_nonneg hb.1]
    _ ≤ 3 * frequencyL1 m n := by
      unfold frequencyL1
      nlinarith [mul_le_mul_of_nonneg_right hb.2 (abs_nonneg (n : ℝ)),
        abs_nonneg (m : ℝ)]

theorem timeConjugate_upper (m n : ℤ) :
    |timeConjugate m n| ≤ 3 * frequencyL1 m n := by
  rw [timeConjugate_formula]
  have hb : 0 ≤ (1 + Real.sqrt 5) / 2 ∧ (1 + Real.sqrt 5) / 2 ≤ 3 := by
    constructor <;> nlinarith [sqrt_five_le_three, Real.sqrt_nonneg (5 : ℝ)]
  calc
    |(n : ℝ) - ((1 + Real.sqrt 5) / 2) * (m : ℝ)| ≤
        |(n : ℝ)| + |((1 + Real.sqrt 5) / 2) * (m : ℝ)| := abs_sub _ _
    _ = |(n : ℝ)| + ((1 + Real.sqrt 5) / 2) * |(m : ℝ)| := by
      rw [abs_mul, abs_of_nonneg hb.1]
    _ ≤ 3 * frequencyL1 m n := by
      unfold frequencyL1
      nlinarith [mul_le_mul_of_nonneg_right hb.2 (abs_nonneg (m : ℝ)),
        abs_nonneg (n : ℝ)]

theorem frequencyL1_le_twice_length (m n : ℤ) :
    frequencyL1 m n ≤ 2 * frequencyLength m n := by
  have hs : frequencyLength m n ^ 2 = (m : ℝ) ^ 2 + (n : ℝ) ^ 2 :=
    Real.sq_sqrt (by positivity)
  have hm : |(m : ℝ)| ≤ frequencyLength m n := by
    apply (sq_le_sq₀ (abs_nonneg _) (frequencyLength_nonneg m n)).mp
    rw [sq_abs, hs]
    nlinarith [sq_nonneg (n : ℝ)]
  have hn : |(n : ℝ)| ≤ frequencyLength m n := by
    apply (sq_le_sq₀ (abs_nonneg _) (frequencyLength_nonneg m n)).mp
    rw [sq_abs, hs]
    nlinarith [sq_nonneg (m : ℝ)]
  unfold frequencyL1
  linarith

theorem lower_of_conjugate_bound {a b D : ℝ} (hprod : 1 ≤ |a| * |b|)
    (hD : 0 < D) (hb : |b| ≤ D) : 1 / D ≤ |a| := by
  apply (div_le_iff₀ hD).mpr
  exact hprod.trans (mul_le_mul_of_nonneg_left hb (abs_nonneg a))

/-- Preserve the original 1/3 L1 Fourier bound in the golden chart. -/
theorem radial_diophantine_l1 (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    (1 / 3 : ℝ) / (1 + frequencyL1 m n) ≤ |radialSymbol m n| := by
  rw [div_div]
  apply lower_of_conjugate_bound (radial_product_lower m n hmn)
  · have := frequencyL1_nonneg m n
    positivity
  · have := radialConjugate_upper m n
    linarith

/-- The analogous original 1/3 L1 temporal bound. -/
theorem time_diophantine_l1 (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    (1 / 3 : ℝ) / (1 + frequencyL1 m n) ≤ |timeSymbol m n| := by
  rw [div_div]
  apply lower_of_conjugate_bound (time_product_lower m n hmn)
  · have := frequencyL1_nonneg m n
    positivity
  · have := timeConjugate_upper m n
    linarith

/-- Keep original 1/6 Euclidean interface constant: safe for J_phi. -/
theorem radial_diophantine (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    (1 / 6 : ℝ) / (1 + frequencyLength m n) ≤ |radialSymbol m n| := by
  rw [div_div]
  apply lower_of_conjugate_bound (radial_product_lower m n hmn)
  · have := frequencyLength_nonneg m n
    positivity
  · have := radialConjugate_upper m n
    have := frequencyL1_le_twice_length m n
    linarith

theorem time_diophantine (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    (1 / 6 : ℝ) / (1 + frequencyLength m n) ≤ |timeSymbol m n| := by
  rw [div_div]
  apply lower_of_conjugate_bound (time_product_lower m n hmn)
  · have := frequencyLength_nonneg m n
    positivity
  · have := timeConjugate_upper m n
    have := frequencyL1_le_twice_length m n
    linarith


/-- The nonzero golden directions admit a reciprocal multiplier bound with
    the same constant 6 as the original silver-ratio implementation. -/
theorem radialSymbol_ne_zero (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    radialSymbol m n ≠ 0 := by
  intro hz
  have h := radial_product_lower m n hmn
  norm_num [hz] at h

theorem timeSymbol_ne_zero (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    timeSymbol m n ≠ 0 := by
  intro hz
  have h := time_product_lower m n hmn
  norm_num [hz] at h

theorem radial_reciprocal_bound (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    |1 / radialSymbol m n| ≤ 6 * (1 + frequencyLength m n) := by
  rw [abs_div, abs_one]
  apply (div_le_iff₀ (abs_pos.mpr (radialSymbol_ne_zero m n hmn))).mpr
  have hb : |radialConjugate m n| ≤ 6 * (1 + frequencyLength m n) := by
    have := radialConjugate_upper m n
    have := frequencyL1_le_twice_length m n
    linarith
  calc
    1 ≤ |radialSymbol m n| * |radialConjugate m n| := radial_product_lower m n hmn
    _ ≤ |radialSymbol m n| * (6 * (1 + frequencyLength m n)) :=
      mul_le_mul_of_nonneg_left hb (abs_nonneg _)
    _ = _ := by ring

theorem time_reciprocal_bound (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) :
    |1 / timeSymbol m n| ≤ 6 * (1 + frequencyLength m n) := by
  rw [abs_div, abs_one]
  apply (div_le_iff₀ (abs_pos.mpr (timeSymbol_ne_zero m n hmn))).mpr
  have hb : |timeConjugate m n| ≤ 6 * (1 + frequencyLength m n) := by
    have := timeConjugate_upper m n
    have := frequencyL1_le_twice_length m n
    linarith
  calc
    1 ≤ |timeSymbol m n| * |timeConjugate m n| := time_product_lower m n hmn
    _ ≤ |timeSymbol m n| * (6 * (1 + frequencyLength m n)) :=
      mul_le_mul_of_nonneg_left hb (abs_nonneg _)
    _ = _ := by ring

theorem radial_inverse_power_bound (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) (p : ℕ) :
    |1 / radialSymbol m n| ^ p ≤ (6 * (1 + frequencyLength m n)) ^ p := by
  exact pow_le_pow_left₀ (abs_nonneg _) (radial_reciprocal_bound m n hmn) p

theorem time_inverse_power_bound (m n : ℤ) (hmn : m ≠ 0 ∨ n ≠ 0) (p : ℕ) :
    |1 / timeSymbol m n| ^ p ≤ (6 * (1 + frequencyLength m n)) ^ p := by
  exact pow_le_pow_left₀ (abs_nonneg _) (time_reciprocal_bound m n hmn) p

/-- Both original Euclidean Fourier bounds, exported with the old interface shape. -/
theorem graph_directions_diophantine (k : ℤ × ℤ) (hk : k ≠ 0) :
    (1 / 6 : ℝ) / (1 + frequencyLength k.1 k.2) ≤
        |(k.1 : ℝ) + ((1 - Real.sqrt 5) / 2) * (k.2 : ℝ)| ∧
      (1 / 6 : ℝ) / (1 + frequencyLength k.1 k.2) ≤
        |((Real.sqrt 5 - 1) / 2) * (k.1 : ℝ) + (k.2 : ℝ)| := by
  have hmn : k.1 ≠ 0 ∨ k.2 ≠ 0 := by
    by_cases hm : k.1 = 0
    · right
      intro hn
      exact hk (Prod.ext hm hn)
    · exact Or.inl hm
  constructor
  · simpa only [radialSymbol_formula] using radial_diophantine k.1 k.2 hmn
  · simpa only [timeSymbol_formula] using time_diophantine k.1 k.2 hmn

/-- The golden integer matrix acts on integer Fourier frequencies. -/
def coveringFrequency (k : ℤ × ℤ) : ℤ × ℤ :=
  (3 * k.1 + k.2, k.1 + 4 * k.2)

theorem coveringFrequency_injective : Function.Injective coveringFrequency := by
  intro k l hkl
  have h₁ := congrArg Prod.fst hkl
  have h₂ := congrArg Prod.snd hkl
  simp only [coveringFrequency] at h₁ h₂
  apply Prod.ext <;> linarith

theorem coveringFrequency_ne_zero (k : ℤ × ℤ) (hk : k ≠ 0) :
    coveringFrequency k ≠ 0 := by
  intro hz
  apply hk
  apply coveringFrequency_injective
  simpa [coveringFrequency] using hz

/-- Scaling identities required by the two directional Fourier inverses. -/
theorem radial_symbol_covering (k : ℤ × ℤ) :
    radialSymbol (coveringFrequency k).1 (coveringFrequency k).2 =
      ((7 - Real.sqrt 5) / 2) * radialSymbol k.1 k.2 := by
  simp only [coveringFrequency, radialSymbol_formula, Int.cast_add,
    Int.cast_mul, Int.cast_ofNat]
  nlinarith [congrArg (fun x : ℝ => x * (k.2 : ℝ)) sqrt_five_square]

theorem time_symbol_covering (k : ℤ × ℤ) :
    timeSymbol (coveringFrequency k).1 (coveringFrequency k).2 =
      ((7 + Real.sqrt 5) / 2) * timeSymbol k.1 k.2 := by
  simp only [coveringFrequency, timeSymbol_formula, Int.cast_add,
    Int.cast_mul, Int.cast_ofNat]
  nlinarith [congrArg (fun x : ℝ => x * (k.1 : ℝ)) sqrt_five_square]

/-- Both eigenvalues of the golden cover expand. -/
theorem covering_eigenvalues_gt_one :
    1 < (7 - Real.sqrt 5) / 2 ∧ 1 < (7 + Real.sqrt 5) / 2 := by
  have hs : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg _
  have hs2 : Real.sqrt 5 ^ 2 = (5 : ℝ) := sqrt_five_square
  constructor <;> nlinarith

end NavierStokes.DiophantineGraph
