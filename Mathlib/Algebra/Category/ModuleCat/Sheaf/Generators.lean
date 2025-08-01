/-
Copyright (c) 2024 Joël Riou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joël Riou
-/

import Mathlib.Algebra.Category.ModuleCat.Sheaf.Free
import Mathlib.Algebra.Category.ModuleCat.Sheaf.PushforwardContinuous
import Mathlib.CategoryTheory.Sites.CoversTop

/-!
# Generating sections of sheaves of modules

In this file, given a sheaf of modules `M` over a sheaf of rings `R`, we introduce
the structure `M.GeneratingSections` which consists of a family of (global)
sections `s : I → M.sections` which generate `M`.

We also introduce the structure `M.LocalGeneratorsData` which contains the data
of a covering `X i` of the terminal object and the data of a
`(M.over (X i)).GeneratingSections` for all `i`. This is used in order to
define sheaves of modules of finite type.

## References

* https://stacks.math.columbia.edu/tag/01B4

-/

universe u v' u'

open CategoryTheory Limits

variable {C : Type u'} [Category.{v'} C] {J : GrothendieckTopology C} {R : Sheaf J RingCat.{u}}
  [HasWeakSheafify J AddCommGrp.{u}] [J.WEqualsLocallyBijective AddCommGrp.{u}]
  [J.HasSheafCompose (forget₂ RingCat.{u} AddCommGrp.{u})]

namespace SheafOfModules

variable (M N P : SheafOfModules.{u} R)

/-- The type of sections which generate a sheaf of modules. -/
structure GeneratingSections where
  /-- the index type for the sections -/
  I : Type u
  /-- a family of sections which generate the sheaf of modules -/
  s : I → M.sections
  epi : Epi (M.freeHomEquiv.symm s) := by infer_instance

namespace GeneratingSections

attribute [instance] epi

variable {M N P}

/-- The epimorphism `free σ.I ⟶ M` given by `σ : M.GeneratingSections`. -/
noncomputable abbrev π (σ : M.GeneratingSections) : free σ.I ⟶ M := M.freeHomEquiv.symm σ.s

/-- If `M ⟶ N` is an epimorphism and that `M` is generated by some sections,
then `N` is generated by the images of these sections. -/
@[simps]
def ofEpi (σ : M.GeneratingSections) (p : M ⟶ N) [Epi p] :
    N.GeneratingSections where
  I := σ.I
  s i := sectionsMap p (σ.s i)
  epi := by
    rw [← freeHomEquiv_symm_comp]
    apply epi_comp

lemma opEpi_id (σ : M.GeneratingSections) :
    σ.ofEpi (𝟙 M) = σ := rfl

lemma opEpi_comp (σ : M.GeneratingSections) (p : M ⟶ N) (q : N ⟶ P) [Epi p] [Epi q] :
    σ.ofEpi (p ≫ q) = (σ.ofEpi p).ofEpi q := rfl

/-- Two isomorphic sheaves of modules have equivalent families of generating sections. -/
def equivOfIso (e : M ≅ N) :
    M.GeneratingSections ≃ N.GeneratingSections where
  toFun σ := σ.ofEpi e.hom
  invFun σ := σ.ofEpi e.inv
  left_inv σ := by
    dsimp
    simp only [← opEpi_comp, e.hom_inv_id, opEpi_id]
  right_inv σ := by
    dsimp
    simp only [← opEpi_comp, e.inv_hom_id, opEpi_id]

end GeneratingSections

variable [∀ (X : C), HasWeakSheafify (J.over X) AddCommGrp.{u}]
  [∀ (X : C), (J.over X).WEqualsLocallyBijective AddCommGrp.{u}]
  [∀ (X : C), (J.over X).HasSheafCompose (forget₂ RingCat AddCommGrp.{u})]

/-- The data of generating sections of the restriction of a sheaf of modules
over a covering of the terminal object. -/
structure LocalGeneratorsData where
  /-- the index type of the covering -/
  I : Type u'
  /-- a family of objects which cover the terminal object -/
  X : I → C
  coversTop : J.CoversTop X
  /-- the data of sections of `M` over `X i` which generate `M.over (X i)` -/
  generators (i : I) : (M.over (X i)).GeneratingSections

/-- A sheaf of modules is of finite type if locally, it is generated by finitely
many sections. -/
class IsFiniteType : Prop where
  exists_localGeneratorsData :
    ∃ (σ : M.LocalGeneratorsData), ∀ (i : σ.I), Finite (σ.generators i).I

section

variable [h : M.IsFiniteType]

/-- A choice of local generators when `M` is a sheaf of modules of finite type. -/
noncomputable def localGeneratorsDataOfIsFiniteType : M.LocalGeneratorsData :=
  h.exists_localGeneratorsData.choose

instance (i : M.localGeneratorsDataOfIsFiniteType.I) :
    Finite (M.localGeneratorsDataOfIsFiniteType.generators i).I :=
  h.exists_localGeneratorsData.choose_spec i

end

end SheafOfModules
