//! Référentiels du regroupement technique, administrés par le Data Steward et stockés en base
//! (`ingestion_family_rule`, `ingestion_specification`, `ingestion_substitution_rule`) :
//! familles de produits, spécifications patronnes et règles de substitution certifiées.

use lyxal_surreal::SurrealValue;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use crate::normalization::{CanonicalDimensions, CanonicalWeight};

/// Règle de classification d'une famille technique de produits BTP.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, SurrealValue)]
pub struct FamilyRule {
    /// Code unique de la famille (ex: "CLOISON_PLAQUE_PLATRE", "CARRELAGE_REVETEMENT_SOL")
    pub code: String,
    /// Libellé descriptif
    pub label: String,
    /// Mots-clés de détection dans les libellés commerciaux
    pub keywords: Vec<String>,
    /// Unité de mesure recommandée dans base_unite (ex: "M2", "ML", "PCE")
    pub standard_unit: Option<String>,
}

/// Tolérances dimensionnelles et métrologiques configurables pour une spécification patronne.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, SurrealValue)]
pub struct SpecificationTolerances {
    #[serde(default = "default_dim_tol")]
    #[surreal(default = "default_dim_tol")]
    pub length_tol_mm: f64,
    #[serde(default = "default_dim_tol")]
    #[surreal(default = "default_dim_tol")]
    pub width_tol_mm: f64,
    #[serde(default = "default_height_tol")]
    #[surreal(default = "default_height_tol")]
    pub height_tol_mm: f64,
    #[serde(default = "default_pct_tol")]
    #[surreal(default = "default_pct_tol")]
    pub weight_tol_pct: f64,
}

fn default_dim_tol() -> f64 {
    5.0
}
fn default_height_tol() -> f64 {
    1.0
}
fn default_pct_tol() -> f64 {
    5.0
}

impl Default for SpecificationTolerances {
    fn default() -> Self {
        Self {
            length_tol_mm: 5.0,
            width_tol_mm: 5.0,
            height_tol_mm: 1.0,
            weight_tol_pct: 5.0,
        }
    }
}

/// Spécification technique générique canonique servant de patron de rapprochement.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, SurrealValue)]
pub struct TechnicalSpecification {
    /// Code de famille technique (ex: "CLOISON_PLAQUE_PLATRE", "OSSATURE_RAIL")
    pub family_code: String,
    /// Clé d'identité technique canonique unique
    pub technical_identity_key: String,
    /// Libellé générique de la spécification
    pub generic_title: String,
    /// Cotes dimensionnelles requises en mm
    pub nominal_dimensions: Option<CanonicalDimensions>,
    /// Tolérances configurables
    #[serde(default)]
    #[surreal(default)]
    pub tolerances: Option<SpecificationTolerances>,
    /// Poids nominal en kg
    pub nominal_weight: Option<CanonicalWeight>,
    /// Norme de conformité exigée (ex: "NF EN 520")
    pub standard_norm: Option<String>,
    /// Classement au feu exigé (ex: "A2-S1,D0")
    pub fire_rating: Option<String>,
    /// Critères techniques obligatoires
    pub required_features: HashMap<String, String>,
}

/// Règle de substitution certifiée contextualisée et révocable.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, SurrealValue)]
pub struct ContextualSubstitutionRule {
    /// Identifiant unique de la règle (ex: "RULE-SUBST-PLACO-KNAUF-72-48")
    pub rule_id: String,
    /// Fabricant source
    pub source_manufacturer: String,
    /// Référence source
    pub source_ref: String,
    /// Fabricant cible
    pub target_manufacturer: String,
    /// Référence cible
    pub target_ref: String,
    /// Périmètre strict du système constructif concerné (ex: "SYSTEME_CLOISON_72_48")
    pub system_scope: String,
    /// Organisme officiel de certification (ex: "CSTB", "CERQUAL")
    pub certification_body: String,
    /// Numéro d'agrément officiel (ex: "Avis Technique n° 9/21-1050_V1")
    pub certification_reference: String,
    /// Date d'expiration de la certification au format ISO 8601 (ex: "2028-12-31")
    pub valid_until: String,
    /// Statut de révocation
    pub is_revoked: bool,
    /// Motif explicite de révocation si révoqué
    pub revocation_reason: Option<String>,
}
