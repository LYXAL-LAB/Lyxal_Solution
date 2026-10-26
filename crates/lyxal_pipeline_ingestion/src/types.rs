use serde::{Deserialize, Serialize};

/// Formats de sources supportés par le moteur d'ingestion.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
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
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
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
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
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
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
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
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
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

fn default_unite_vente() -> String {
    "PCE".to_string()
}

fn default_quantite() -> f64 {
    1.0
}

/// Dimensions physiques normalisées d'un conditionnement.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct Dimensions {
    #[serde(default)]
    pub longueur_mm: f64,
    #[serde(default)]
    pub largeur_mm: f64,
    #[serde(default)]
    pub epaisseur_mm: f64,
}

/// Conditionnement logistique et commercial.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct PackagingDetails {
    #[serde(default = "default_unite_vente")]
    pub unite_vente: String,
    #[serde(default = "default_quantite")]
    pub quantite_par_colis: f64,
    #[serde(default)]
    pub poids_brut_kg: Option<f64>,
    #[serde(default)]
    pub dimensions: Option<Dimensions>,
}

/// Journal d'audit d'une transition d'état.
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct StateTransitionRecord {
    #[serde(default, alias = "from_status", alias = "from")]
    pub from_statut: String,
    #[serde(default, alias = "to_status", alias = "to")]
    pub to_statut: String,
    #[serde(default, alias = "at", alias = "timestamp")]
    pub transition_at: String,
    #[serde(default, alias = "by", alias = "actor")]
    pub transition_by: String,
    #[serde(default, alias = "comment")]
    pub reason: String,
}
