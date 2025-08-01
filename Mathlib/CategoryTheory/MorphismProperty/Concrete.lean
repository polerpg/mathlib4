/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang
-/
import Mathlib.CategoryTheory.ConcreteCategory.Basic
import Mathlib.CategoryTheory.MorphismProperty.Composition
import Mathlib.CategoryTheory.MorphismProperty.Factorization

/-!
# Morphism properties defined in concrete categories

In this file, we define the class of morphisms `MorphismProperty.injective`,
`MorphismProperty.surjective`, `MorphismProperty.bijective` in concrete
categories, and show that it is stable under composition and respect isomorphisms.

We introduce type-classes `HasSurjectiveInjectiveFactorization` and
`HasFunctorialSurjectiveInjectiveFactorization` expressing that in a concrete category `C`,
all morphisms can be factored (resp. factored functorially) as a surjective map
followed by an injective map.

-/

universe v u

namespace CategoryTheory

variable (C : Type u) [Category.{v} C] {FC : C → C → Type*} {CC : C → Type*}
variable [∀ X Y, FunLike (FC X Y) (CC X) (CC Y)] [ConcreteCategory C FC]

namespace MorphismProperty

open Function

/-- Injectivity (in a concrete category) as a `MorphismProperty` -/
protected def injective : MorphismProperty C := fun _ _ f => Injective f

/-- Surjectiveness (in a concrete category) as a `MorphismProperty` -/
protected def surjective : MorphismProperty C := fun _ _ f => Surjective f

/-- Bijectiveness (in a concrete category) as a `MorphismProperty` -/
protected def bijective : MorphismProperty C := fun _ _ f => Bijective f

theorem bijective_eq_sup :
    MorphismProperty.bijective C = MorphismProperty.injective C ⊓ MorphismProperty.surjective C :=
  rfl

instance : (MorphismProperty.injective C).IsMultiplicative where
  id_mem X := by
    delta MorphismProperty.injective
    convert injective_id
    aesop
  comp_mem f g hf hg := by
    delta MorphismProperty.injective
    rw [hom_comp]
    exact hg.comp hf

instance : (MorphismProperty.surjective C).IsMultiplicative where
  id_mem X := by
    delta MorphismProperty.surjective
    convert surjective_id
    aesop
  comp_mem f g hf hg := by
    delta MorphismProperty.surjective
    rw [hom_comp]
    exact hg.comp hf

instance : (MorphismProperty.bijective C).IsMultiplicative where
  id_mem X := by
    delta MorphismProperty.bijective
    convert bijective_id
    aesop
  comp_mem f g hf hg := by
    delta MorphismProperty.bijective
    rw [hom_comp]
    exact hg.comp hf

instance injective_respectsIso : (MorphismProperty.injective C).RespectsIso :=
  respectsIso_of_isStableUnderComposition
    (fun _ _ f (_ : IsIso f) => ((forget C).mapIso (asIso f)).toEquiv.injective)

instance surjective_respectsIso : (MorphismProperty.surjective C).RespectsIso :=
  respectsIso_of_isStableUnderComposition
    (fun _ _ f (_ : IsIso f) => ((forget C).mapIso (asIso f)).toEquiv.surjective)

instance bijective_respectsIso : (MorphismProperty.bijective C).RespectsIso :=
  respectsIso_of_isStableUnderComposition
    (fun _ _ f (_ : IsIso f) => ((forget C).mapIso (asIso f)).toEquiv.bijective)

end MorphismProperty

namespace ConcreteCategory

/-- The property that any morphism in a concrete category can be factored as a surjective
map followed by an injective map. -/
abbrev HasSurjectiveInjectiveFactorization :=
    (MorphismProperty.surjective C).HasFactorization (MorphismProperty.injective C)

/-- The property that any morphism in a concrete category can be functorially
factored as a surjective map followed by an injective map. -/
abbrev HasFunctorialSurjectiveInjectiveFactorization :=
  (MorphismProperty.surjective C).HasFunctorialFactorization (MorphismProperty.injective C)

/-- The structure containing the data of a functorial factorization of morphisms as
a surjective map followed by an injective map in a concrete category. -/
abbrev FunctorialSurjectiveInjectiveFactorizationData :=
  (MorphismProperty.surjective C).FunctorialFactorizationData (MorphismProperty.injective C)

end ConcreteCategory

open ConcreteCategory

attribute [local instance] Types.instFunLike Types.instConcreteCategory in
/-- In the category of types, any map can be functorially factored as a surjective
map followed by an injective map. -/
def functorialSurjectiveInjectiveFactorizationData :
    FunctorialSurjectiveInjectiveFactorizationData (Type u) where
  Z :=
    { obj := fun f => Subtype (Set.range f.hom)
      map := fun φ y => ⟨φ.right y.1, by
        obtain ⟨_, x, rfl⟩ := y
        exact ⟨φ.left x, congr_fun φ.w x⟩ ⟩ }
  i :=
    { app := fun f x => ⟨f.hom x, ⟨x, rfl⟩⟩
      naturality := fun f g φ => by
        ext x
        exact congr_fun φ.w x }
  p :=
    { app := fun _ y => y.1
      naturality := by intros; rfl; }
  fac := rfl
  hi := by
    rintro f ⟨_, x, rfl⟩
    exact ⟨x, rfl⟩
  hp f x₁ x₂ h := by
    rw [Subtype.ext_iff]
    exact h

attribute [local instance] Types.instFunLike Types.instConcreteCategory in
instance : HasFunctorialSurjectiveInjectiveFactorization (Type u) where
  nonempty_functorialFactorizationData :=
    ⟨functorialSurjectiveInjectiveFactorizationData⟩

end CategoryTheory
