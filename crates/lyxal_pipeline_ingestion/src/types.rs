use lyxal_surreal::SurrealValue;
use serde::{Deserialize, Serialize};

/// Formats de sources supportés par le moteur d'ingestion.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize, SurrealValue)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[surreal(untagged, rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SourceFormat {
    FabDis,
    Csv,
    Xml,
    Json,
}

impl SourceFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::FabDis => "FAB_DIS",
            Self::Csv => "CSV",
            Self::Xml => "XML",
            Self::Json => "JSON",
        }
    }
}

/// États de cycle de vie d'un lot d'ingestion (`ingestion_batch`).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[surreal(untagged, rename_all = "SCREAMING_SNAKE_CASE")]
pub enum BatchStatus {
    Received,
    Parsing,
    Validating,
    Staged,
    Published,
    Failed,
}

impl BatchStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Received => "RECEIVED",
            Self::Parsing => "PARSING",
            Self::Validating => "VALIDATING",
            Self::Staged => "STAGED",
            Self::Published => "PUBLISHED",
            Self::Failed => "FAILED",
        }
    }
}

/// Triptyque officiel de qualification commerciale et technique d'un article en staging.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[surreal(untagged, rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ItemQualification {
    /// 100% conforme techniquement ET provenance commerciale avérée (GTIN GS1 Modulo 10 vérifié, unité reconnue, conditionnement complet).
    Verified,
    /// Données plausibles mais preuve insuffisante ou information manquante (requiert arbitrage du Data Steward).
    ToConfirm,
    /// Invalide, incohérent ou corrompu (orienté automatiquement vers la zone de quarantaine).
    Rejected,
}

impl ItemQualification {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Verified => "VERIFIED",
            Self::ToConfirm => "TO_CONFIRM",
            Self::Rejected => "REJECTED",
        }
    }
}

/// Action de publication prévue pour un article normalisé.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[surreal(untagged, rename_all = "SCREAMING_SNAKE_CASE")]
pub enum PublicationAction {
    Insert,
    Update,
    Unchanged,
    Deprecate,
}

impl PublicationAction {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Insert => "INSERT",
            Self::Update => "UPDATE",
            Self::Unchanged => "UNCHANGED",
            Self::Deprecate => "DEPRECATE",
        }
    }
}

/// États du manifeste de publication scellé (`ingestion_publication_manifest`).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[surreal(untagged, rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ManifestStatus {
    Draft,
    Sealed,
    Approved,
    Executing,
    Committed,
    Failed,
}

impl ManifestStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Draft => "DRAFT",
            Self::Sealed => "SEALED",
            Self::Approved => "APPROVED",
            Self::Executing => "EXECUTING",
            Self::Committed => "COMMITTED",
            Self::Failed => "FAILED",
        }
    }
}

fn default_quantite() -> f64 {
    1.0
}

/// Dimensions physiques normalisées d'un conditionnement.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize, SurrealValue)]
pub struct Dimensions {
    #[serde(default)]
    #[surreal(default)]
    pub longueur_mm: f64,
    #[serde(default)]
    #[surreal(default)]
    pub largeur_mm: f64,
    #[serde(default)]
    #[surreal(default)]
    pub epaisseur_mm: f64,
}

/// Conditionnement logistique et commercial.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize, SurrealValue)]
pub struct PackagingDetails {
    /// Unité de vente du référentiel ; absente tant que l'unité fournisseur n'est pas résolue.
    #[serde(default)]
    #[surreal(default)]
    pub unite_vente: Option<String>,
    #[serde(default = "default_quantite")]
    #[surreal(default = "default_quantite")]
    pub quantite_par_colis: f64,
    #[serde(default)]
    #[surreal(default)]
    pub poids_brut_kg: Option<f64>,
    #[serde(default)]
    #[surreal(default)]
    pub dimensions: Option<Dimensions>,
}

/// Transition d'état journalisée par les fonctions SurrealQL (lot, article, manifeste) :
/// état d'origine (absent à la création), état atteint, identité de la session, motif et
/// horodatage. Lecture seule : le Rust ne construit jamais une transition.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
pub struct StateTransitionRecord {
    #[serde(default)]
    pub from_state: Option<String>,
    pub to_state: String,
    #[serde(default)]
    pub triggered_by: Option<String>,
    pub reason: String,
    pub transitioned_at: lyxal_surreal::Datetime,
    /// Référence de la preuve commerciale d'une requalification en `VERIFIED`.
    #[serde(default)]
    pub proof_reference: Option<String>,
}
