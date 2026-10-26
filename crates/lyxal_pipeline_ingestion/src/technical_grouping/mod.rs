//! Module de regroupement technique et de préparation au rapprochement des catalogues.
//!
//! Expose les 4 niveaux stricts de rapprochement :
//! 1. `Family` (Famille)
//! 2. `Specification` (Spécification technique)
//! 3. `FunctionalEquivalence` (Équivalence fonctionnelle)
//! 4. `AuthorizedSubstitution` (Substitution autorisée)

pub mod engine;
pub mod types;

pub use engine::TechnicalGroupingEngine;
pub use types::{
    ContextualSubstitutionRule, FamilyRule, SpecificationTolerances, TechnicalGroupLevel,
    TechnicalGroupingDecision, TechnicalSpecification,
};
