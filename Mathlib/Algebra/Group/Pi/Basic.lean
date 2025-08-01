/-
Copyright (c) 2020 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot, Eric Wieser
-/
import Mathlib.Algebra.Group.Defs
import Mathlib.Algebra.Notation.Pi
import Mathlib.Data.Sum.Basic
import Mathlib.Logic.Unique
import Mathlib.Tactic.Spread

/-!
# Instances and theorems on pi types

This file provides instances for the typeclass defined in `Algebra.Group.Defs`. More sophisticated
instances are defined in `Algebra.Group.Pi.Lemmas` files elsewhere.

## Porting note

This file relied on the `pi_instance` tactic, which was not available at the time of porting. The
comment `--pi_instance` is inserted before all fields which were previously derived by
`pi_instance`. See this Zulip discussion:
[https://leanprover.zulipchat.com/#narrow/stream/287929-mathlib4/topic/not.20porting.20pi_instance]
-/

-- We enforce to only import `Algebra.Group.Defs` and basic logic
assert_not_exists Set.range MonoidHom MonoidWithZero DenselyOrdered

universe u v₁ v₂ v₃

variable {I : Type u}

-- The indexing type
variable {α β γ : Type*}

-- The families of types already equipped with instances
variable {f : I → Type v₁} {g : I → Type v₂} {h : I → Type v₃}
variable (x y : ∀ i, f i) (i : I)

namespace Pi

@[to_additive]
instance semigroup [∀ i, Semigroup (f i)] : Semigroup (∀ i, f i) where
  mul_assoc := by intros; ext; exact mul_assoc _ _ _

@[to_additive]
instance commSemigroup [∀ i, CommSemigroup (f i)] : CommSemigroup (∀ i, f i) where
  mul_comm := by intros; ext; exact mul_comm _ _

@[to_additive]
instance mulOneClass [∀ i, MulOneClass (f i)] : MulOneClass (∀ i, f i) where
  one_mul := by intros; ext; exact one_mul _
  mul_one := by intros; ext; exact mul_one _

@[to_additive]
instance invOneClass [∀ i, InvOneClass (f i)] : InvOneClass (∀ i, f i) where
  inv_one := by ext; exact inv_one

@[to_additive]
instance monoid [∀ i, Monoid (f i)] : Monoid (∀ i, f i) where
  __ := semigroup
  __ := mulOneClass
  npow := fun n x i => x i ^ n
  npow_zero := by intros; ext; exact Monoid.npow_zero _
  npow_succ := by intros; ext; exact Monoid.npow_succ _ _

@[to_additive]
instance commMonoid [∀ i, CommMonoid (f i)] : CommMonoid (∀ i, f i) :=
  { monoid, commSemigroup with }

@[to_additive Pi.subNegMonoid]
instance divInvMonoid [∀ i, DivInvMonoid (f i)] : DivInvMonoid (∀ i, f i) where
  zpow := fun z x i => x i ^ z
  div_eq_mul_inv := by intros; ext; exact div_eq_mul_inv _ _
  zpow_zero' := by intros; ext; exact DivInvMonoid.zpow_zero' _
  zpow_succ' := by intros; ext; exact DivInvMonoid.zpow_succ' _ _
  zpow_neg' := by intros; ext; exact DivInvMonoid.zpow_neg' _ _

@[to_additive]
instance divInvOneMonoid [∀ i, DivInvOneMonoid (f i)] : DivInvOneMonoid (∀ i, f i) where
  inv_one := by ext; exact inv_one

@[to_additive]
instance involutiveInv [∀ i, InvolutiveInv (f i)] : InvolutiveInv (∀ i, f i) where
  inv_inv := by intros; ext; exact inv_inv _

@[to_additive]
instance divisionMonoid [∀ i, DivisionMonoid (f i)] : DivisionMonoid (∀ i, f i) where
  __ := divInvMonoid
  __ := involutiveInv
  mul_inv_rev := by intros; ext; exact mul_inv_rev _ _
  inv_eq_of_mul := by intros _ _ h; ext; exact DivisionMonoid.inv_eq_of_mul _ _ (congrFun h _)

@[to_additive instSubtractionCommMonoid]
instance divisionCommMonoid [∀ i, DivisionCommMonoid (f i)] : DivisionCommMonoid (∀ i, f i) :=
  { divisionMonoid, commSemigroup with }

@[to_additive]
instance group [∀ i, Group (f i)] : Group (∀ i, f i) where
  inv_mul_cancel := by intros; ext; exact inv_mul_cancel _

@[to_additive]
instance commGroup [∀ i, CommGroup (f i)] : CommGroup (∀ i, f i) := { group, commMonoid with }

@[to_additive] instance instIsLeftCancelMul [∀ i, Mul (f i)] [∀ i, IsLeftCancelMul (f i)] :
    IsLeftCancelMul (∀ i, f i) where
  mul_left_cancel  _ _ _ h := funext fun _ ↦ mul_left_cancel (congr_fun h _)

@[to_additive] instance instIsRightCancelMul [∀ i, Mul (f i)] [∀ i, IsRightCancelMul (f i)] :
    IsRightCancelMul (∀ i, f i) where
  mul_right_cancel  _ _ _ h := funext fun _ ↦ mul_right_cancel (congr_fun h _)

@[to_additive] instance instIsCancelMul [∀ i, Mul (f i)] [∀ i, IsCancelMul (f i)] :
    IsCancelMul (∀ i, f i) where

@[to_additive]
instance leftCancelSemigroup [∀ i, LeftCancelSemigroup (f i)] : LeftCancelSemigroup (∀ i, f i) :=
  { semigroup with mul_left_cancel := fun _ _ _ => mul_left_cancel }

@[to_additive]
instance rightCancelSemigroup [∀ i, RightCancelSemigroup (f i)] : RightCancelSemigroup (∀ i, f i) :=
  { semigroup with mul_right_cancel := fun _ _ _ => mul_right_cancel }

@[to_additive]
instance leftCancelMonoid [∀ i, LeftCancelMonoid (f i)] : LeftCancelMonoid (∀ i, f i) :=
  { leftCancelSemigroup, monoid with }

@[to_additive]
instance rightCancelMonoid [∀ i, RightCancelMonoid (f i)] : RightCancelMonoid (∀ i, f i) :=
  { rightCancelSemigroup, monoid with }

@[to_additive]
instance cancelMonoid [∀ i, CancelMonoid (f i)] : CancelMonoid (∀ i, f i) :=
  { leftCancelMonoid, rightCancelMonoid with }

@[to_additive]
instance cancelCommMonoid [∀ i, CancelCommMonoid (f i)] : CancelCommMonoid (∀ i, f i) :=
  { leftCancelMonoid, commMonoid with }

section
variable {ι : Type*} {M N O : ι → Type*}
variable [DecidableEq ι]
variable [∀ i, One (M i)] [∀ i, One (N i)] [∀ i, One (O i)]

/-- The function supported at `i`, with value `x` there, and `1` elsewhere. -/
@[to_additive "The function supported at `i`, with value `x` there, and `0` elsewhere."]
def mulSingle (i : ι) (x : M i) : ∀ j, M j :=
  Function.update 1 i x

@[to_additive (attr := simp)]
theorem mulSingle_eq_same (i : ι) (x : M i) : mulSingle i x i = x :=
  Function.update_self i x _

@[to_additive (attr := simp)]
theorem mulSingle_eq_of_ne {i i' : ι} (h : i' ≠ i) (x : M i) : mulSingle i x i' = 1 :=
  Function.update_of_ne h x _

/-- Abbreviation for `mulSingle_eq_of_ne h.symm`, for ease of use by `simp`. -/
@[to_additive (attr := simp)
  "Abbreviation for `single_eq_of_ne h.symm`, for ease of use by `simp`."]
theorem mulSingle_eq_of_ne' {i i' : ι} (h : i ≠ i') (x : M i) : mulSingle i x i' = 1 :=
  mulSingle_eq_of_ne h.symm x

@[to_additive (attr := simp)]
theorem mulSingle_one (i : ι) : mulSingle i (1 : M i) = 1 :=
  Function.update_eq_self _ _

@[to_additive (attr := simp)]
theorem mulSingle_eq_one_iff {i : ι} {x : M i} : mulSingle i x = 1 ↔ x = 1 := by
  refine ⟨fun h => ?_, fun h => h.symm ▸ mulSingle_one i⟩
  rw [← mulSingle_eq_same i x, h, one_apply]

@[to_additive]
theorem mulSingle_ne_one_iff {i : ι} {x : M i} : mulSingle i x ≠ 1 ↔ x ≠ 1 :=
  mulSingle_eq_one_iff.ne

@[to_additive]
theorem apply_mulSingle (f' : ∀ i, M i → N i) (hf' : ∀ i, f' i 1 = 1) (i : ι) (x : M i) (j : ι) :
    f' j (mulSingle i x j) = mulSingle i (f' i x) j := by
  simpa only [Pi.one_apply, hf', mulSingle] using Function.apply_update f' 1 i x j

@[to_additive apply_single₂]
theorem apply_mulSingle₂ (f' : ∀ i, M i → N i → O i) (hf' : ∀ i, f' i 1 1 = 1) (i : ι)
    (x : M i) (y : N i) (j : ι) :
    f' j (mulSingle i x j) (mulSingle i y j) = mulSingle i (f' i x y) j := by
  by_cases h : j = i
  · subst h
    simp only [mulSingle_eq_same]
  · simp only [mulSingle_eq_of_ne h, hf']

@[to_additive]
theorem mulSingle_op (op : ∀ i, M i → N i) (h : ∀ i, op i 1 = 1) (i : ι) (x : M i) :
    mulSingle i (op i x) = fun j => op j (mulSingle i x j) :=
  Eq.symm <| funext <| apply_mulSingle op h i x

@[to_additive]
theorem mulSingle_op₂ (op : ∀ i, M i → N i → O i) (h : ∀ i, op i 1 1 = 1) (i : ι) (x₁ : M i)
    (x₂ : N i) :
    mulSingle i (op i x₁ x₂) = fun j => op j (mulSingle i x₁ j) (mulSingle i x₂ j) :=
  Eq.symm <| funext <| apply_mulSingle₂ op h i x₁ x₂

@[to_additive]
theorem mulSingle_injective (i : ι) : Function.Injective (mulSingle i : M i → ∀ i, M i) :=
  Function.update_injective _ i

@[to_additive (attr := simp)]
theorem mulSingle_inj (i : ι) {x y : M i} : mulSingle i x = mulSingle i y ↔ x = y :=
  (Pi.mulSingle_injective _).eq_iff

variable {M : Type*} [One M]

-- Porting note: added `(_ : ι → M)`
/-- On non-dependent functions, `Pi.mulSingle` can be expressed as an `ite` -/
@[to_additive "On non-dependent functions, `Pi.single` can be expressed as an `ite`"]
lemma mulSingle_apply (i : ι) (x : M) (i' : ι) :
    (mulSingle i x : ι → M) i' = if i' = i then x else 1 :=
  Function.update_apply _ i x i'

-- Porting note: added `(_ : ι → M)`
/-- On non-dependent functions, `Pi.mulSingle` is symmetric in the two indices. -/
@[to_additive "On non-dependent functions, `Pi.single` is symmetric in the two indices."]
lemma mulSingle_comm (i : ι) (x : M) (i' : ι) :
    (mulSingle i x : ι → M) i' = (mulSingle i' x : ι → M) i := by
  simp [mulSingle_apply, eq_comm]

end

/-- The mapping into a product type built from maps into each component. -/
@[simp]
protected def prod (f' : ∀ i, f i) (g' : ∀ i, g i) (i : I) : f i × g i :=
  (f' i, g' i)

-- Porting note: simp now unfolds the lhs, so we are not marking these as simp.
-- @[simp]
theorem prod_fst_snd : Pi.prod (Prod.fst : α × β → α) (Prod.snd : α × β → β) = id :=
  rfl

-- Porting note: simp now unfolds the lhs, so we are not marking these as simp.
-- @[simp]
theorem prod_snd_fst : Pi.prod (Prod.snd : α × β → β) (Prod.fst : α × β → α) = Prod.swap :=
  rfl

end Pi

namespace Function

section Extend

@[to_additive]
theorem extend_one [One γ] (f : α → β) : Function.extend f (1 : α → γ) (1 : β → γ) = 1 :=
  funext fun _ => by apply ite_self

@[to_additive]
theorem extend_mul [Mul γ] (f : α → β) (g₁ g₂ : α → γ) (e₁ e₂ : β → γ) :
    Function.extend f (g₁ * g₂) (e₁ * e₂) = Function.extend f g₁ e₁ * Function.extend f g₂ e₂ := by
  classical
  funext x
  simp [Function.extend_def, apply_dite₂]

@[to_additive]
theorem extend_inv [Inv γ] (f : α → β) (g : α → γ) (e : β → γ) :
    Function.extend f g⁻¹ e⁻¹ = (Function.extend f g e)⁻¹ := by
  classical
  funext x
  simp [Function.extend_def, apply_dite Inv.inv]

@[to_additive]
theorem extend_div [Div γ] (f : α → β) (g₁ g₂ : α → γ) (e₁ e₂ : β → γ) :
    Function.extend f (g₁ / g₂) (e₁ / e₂) = Function.extend f g₁ e₁ / Function.extend f g₂ e₂ := by
  classical
  funext x
  simp [Function.extend_def, apply_dite₂]

end Extend

lemma comp_eq_const_iff (b : β) (f : α → β) {g : β → γ} (hg : Injective g) :
    g ∘ f = Function.const _ (g b) ↔ f = Function.const _ b :=
  hg.comp_left.eq_iff' rfl

@[to_additive]
lemma comp_eq_one_iff [One β] [One γ] (f : α → β) {g : β → γ} (hg : Injective g) (hg0 : g 1 = 1) :
    g ∘ f = 1 ↔ f = 1 := by
  simpa [hg0, const_one] using comp_eq_const_iff 1 f hg

@[to_additive]
lemma comp_ne_one_iff [One β] [One γ] (f : α → β) {g : β → γ} (hg : Injective g) (hg0 : g 1 = 1) :
    g ∘ f ≠ 1 ↔ f ≠ 1 :=
  (comp_eq_one_iff f hg hg0).ne

end Function

/-- If the one function is surjective, the codomain is trivial. -/
@[to_additive "If the zero function is surjective, the codomain is trivial."]
def uniqueOfSurjectiveOne (α : Type*) {β : Type*} [One β] (h : Function.Surjective (1 : α → β)) :
    Unique β :=
  h.uniqueOfSurjectiveConst α (1 : β)

@[to_additive]
theorem Subsingleton.pi_mulSingle_eq {α : Type*} [DecidableEq I] [Subsingleton I] [One α]
    (i : I) (x : α) : Pi.mulSingle i x = fun _ => x :=
  funext fun j => by rw [Subsingleton.elim j i, Pi.mulSingle_eq_same]

namespace Sum

variable (a a' : α → γ) (b b' : β → γ)

@[to_additive (attr := simp)]
theorem elim_one_one [One γ] : Sum.elim (1 : α → γ) (1 : β → γ) = 1 :=
  Sum.elim_const_const 1

@[to_additive (attr := simp)]
theorem elim_mulSingle_one [DecidableEq α] [DecidableEq β] [One γ] (i : α) (c : γ) :
    Sum.elim (Pi.mulSingle i c) (1 : β → γ) = Pi.mulSingle (Sum.inl i) c := by
  simp only [Pi.mulSingle, Sum.elim_update_left, elim_one_one]

@[to_additive (attr := simp)]
theorem elim_one_mulSingle [DecidableEq α] [DecidableEq β] [One γ] (i : β) (c : γ) :
    Sum.elim (1 : α → γ) (Pi.mulSingle i c) = Pi.mulSingle (Sum.inr i) c := by
  simp only [Pi.mulSingle, Sum.elim_update_right, elim_one_one]

@[to_additive]
theorem elim_inv_inv [Inv γ] : Sum.elim a⁻¹ b⁻¹ = (Sum.elim a b)⁻¹ :=
  (Sum.comp_elim Inv.inv a b).symm

@[to_additive]
theorem elim_mul_mul [Mul γ] : Sum.elim (a * a') (b * b') = Sum.elim a b * Sum.elim a' b' := by
  ext x
  cases x <;> rfl

@[to_additive]
theorem elim_div_div [Div γ] : Sum.elim (a / a') (b / b') = Sum.elim a b / Sum.elim a' b' := by
  ext x
  cases x <;> rfl

end Sum
