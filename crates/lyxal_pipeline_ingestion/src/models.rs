use crate::types::{
    BatchStatus, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat, StateTransitionRecord,
};
use serde::{Deserialize, Serialize};

/// Modèle Rust pour `ingestion_batch`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IngestionBatch {
    pub id: Option<String>,
    pub source_type: SourceFormat,
    pub source_format_version: String,
    pub fournisseur_id: String,
    pub nom_fichier: String,
    pub file_hash_blake3: String,
    pub taille_octets: usize,
    pub statut: BatchStatus,
    pub cursor_offset: usize,
    pub chunk_size: usize,
    pub total_lignes: usize,
    pub lignes_verifiees: usize,
    pub lignes_a_confirmer: usize,
    pub lignes_rejetees: usize,
    pub transitions: Vec<StateTransitionRecord>,
    pub provenance_details: serde_json::Value,
    pub created_at: Option<String>,
    pub completed_at: Option<String>,
}

/// Modèle Rust pour `ingestion_raw_record`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RawRecord {
    pub id: Option<String>,
    pub batch: String,
    pub ligne_numero: usize,
    pub row_hash: String,
    pub payload_brut: serde_json::Value,
    pub created_at: Option<String>,
}

/// Modèle Rust pour `ingestion_staged_item`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StagedItem {
    pub id: Option<String>,
    pub batch: String,
    pub raw_record: String,
    pub ligne_numero: usize,
    pub canonical_fingerprint: String,
    pub rules_version: String,
    
    // Identité métier fabricant / référence
    pub fabricant: String,
    pub marque: Option<String>,
    pub reference_fabricant: String,
    pub code_barre_gtin: Option<String>,

    // Caractéristiques commerciales & techniques
    pub libelle_commercial: String,
    pub description_technique: Option<String>,
    pub type_item: String,
    pub unite_reference: String,
    pub conditionnement: PackagingDetails,

    // Triptyque de qualification et publication
    pub qualification: ItemQualification,
    #[serde(default)]
    pub qualification_reason: Option<String>,
    #[serde(default)]
    pub commercial_proof: Option<crate::proof::CommercialProof>,
    pub publication_action: PublicationAction,
    pub diff_payload: Option<serde_json::Value>,
    pub transitions: Vec<StateTransitionRecord>,
    
    pub is_approved: bool,
    pub approved_by: Option<String>,
    pub approved_at: Option<String>,
}

/// Modèle Rust pour `ingestion_quarantine_record`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuarantineRecord {
    pub id: Option<String>,
    pub batch: String,
    pub raw_record: String,
    pub code_erreur: String,
    pub severite: String, // "CRITICAL", "ERROR", "WARNING"
    pub champ_concerne: String,
    pub valeur_fautive: Option<serde_json::Value>,
    pub cause_detaillee: String,
    pub created_at: Option<String>,
    #[serde(default)]
    pub is_resolved: bool,
    pub resolved_by: Option<String>,
    pub resolved_at: Option<String>,
    pub resolution_comment: Option<String>,
}

/// Modèle Rust pour `ingestion_publication_manifest`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicationManifest {
    pub id: Option<String>,
    pub batch: String,
    pub manifest_ref: String,
    pub manifest_version: usize,
    pub seal_hash: String,
    pub is_sealed: bool,
    pub statut: ManifestStatus,
    
    pub approved_by: Option<String>,
    pub approved_at: Option<String>,
    pub approver_role: Option<String>,

    pub nb_articles_insert: usize,
    pub nb_articles_update: usize,
    pub items_committed: usize,
    pub items_failed: usize,
    pub execution_items: Vec<serde_json::Value>,
    pub transitions: Vec<StateTransitionRecord>,
    pub executed_at: Option<String>,
}
