use crate::proof::CommercialProof;
use crate::types::{
    BatchStatus, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat, StateTransitionRecord,
};
use lyxal_surreal::SurrealValue;
use serde::{Deserialize, Serialize};

/// Modèle Rust pour `ingestion_batch`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
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
    pub created_at: Option<lyxal_surreal::Datetime>,
    pub completed_at: Option<lyxal_surreal::Datetime>,
}

/// Modèle Rust pour `ingestion_raw_record`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct RawRecord {
    pub id: Option<String>,
    pub batch: String,
    pub ligne_numero: usize,
    pub row_hash: String,
    pub payload_brut: serde_json::Value,
    pub created_at: Option<lyxal_surreal::Datetime>,
}

/// Modèle Rust pour `ingestion_staged_item`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
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
    /// Unité du référentiel ; absente tant que l'unité fournisseur n'est pas résolue
    /// (anomalie `INGESTION_UNIT_UNRESOLVED` en quarantaine, jamais de valeur par défaut).
    #[serde(default)]
    #[surreal(default)]
    pub unite_reference: Option<String>,
    pub conditionnement: PackagingDetails,

    // Triptyque de qualification et publication
    pub qualification: ItemQualification,
    #[serde(default)]
    #[surreal(default)]
    pub qualification_reason: Option<String>,
    #[serde(default)]
    #[surreal(default)]
    pub commercial_proof: Option<crate::proof::CommercialProof>,
    pub publication_action: PublicationAction,
    pub diff_payload: Option<serde_json::Value>,
    pub transitions: Vec<StateTransitionRecord>,

    pub is_approved: bool,
    pub approved_by: Option<String>,
    pub approved_at: Option<lyxal_surreal::Datetime>,
}

/// Modèle Rust pour `ingestion_quarantine_record`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct QuarantineRecord {
    pub id: Option<String>,
    pub batch: String,
    pub raw_record: String,
    /// Numéro de la ligne du fichier source (à partir de 1).
    pub ligne_numero: usize,
    pub code_erreur: String,
    pub severite: String, // "CRITICAL", "ERROR", "WARNING"
    pub champ_concerne: String,
    pub valeur_fautive: Option<serde_json::Value>,
    pub cause_detaillee: String,
    pub created_at: Option<lyxal_surreal::Datetime>,
    #[serde(default)]
    #[surreal(default)]
    pub is_resolved: bool,
    pub resolved_by: Option<String>,
    pub resolved_at: Option<lyxal_surreal::Datetime>,
    pub resolution_comment: Option<String>,
}

/// Modèle Rust pour `ingestion_publication_manifest`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct PublicationManifest {
    pub id: Option<String>,
    pub batch: String,
    pub manifest_ref: String,
    pub manifest_version: usize,
    /// Contenu exact publié, figé au scellement (absent en brouillon).
    #[serde(default)]
    #[surreal(default)]
    pub contenu: Option<Vec<ManifestEntry>>,
    /// Sceau BLAKE3 du contenu, calculé par le serveur au scellement (absent en brouillon).
    pub seal_hash: Option<String>,
    pub is_sealed: bool,
    pub statut: ManifestStatus,

    pub approved_by: Option<String>,
    pub approved_at: Option<lyxal_surreal::Datetime>,
    pub approver_role: Option<String>,

    pub nb_articles_insert: usize,
    pub nb_articles_update: usize,
    pub items_committed: usize,
    pub items_failed: usize,
    pub execution_items: Vec<serde_json::Value>,
    pub transitions: Vec<StateTransitionRecord>,
    pub executed_at: Option<lyxal_surreal::Datetime>,
}

/// Élément du contenu figé d'un manifeste (`fn::ingestion_manifest_content`) : un article
/// `VERIFIED` du lot, tel qu'il est envoyé au catalogue.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct ManifestEntry {
    /// Identifiant maître de l'article (`ING-<empreinte>`), code et `master_id` au catalogue.
    pub item_ref: String,
    pub publication_action: PublicationAction,
    pub commercial_proof: Option<CommercialProof>,
    /// Charge utile de `fn::catalogue_item_create`.
    pub catalogue: CataloguePayload,
}

/// Article commercial maître tel que publié au catalogue (contrat de `lyxal_catalogue`).
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct CataloguePayload {
    pub code: String,
    #[serde(rename = "type")]
    #[surreal(rename = "type")]
    pub type_item: String,
    pub libelle: String,
    /// Code de l'unité de référence (`base_unite`) ; absent si l'unité n'est pas résolue.
    pub unite_reference: Option<String>,
    pub description: Option<String>,
    pub nature_reference: String,
    pub fabricant: String,
    pub marque: Option<String>,
    pub reference_fabricant: String,
    pub code_barre: Option<String>,
    pub conditionnement: CatalogueConditionnement,
    /// `base_unite:<CODE>` en texte.
    pub unite_conditionnement: Option<String>,
    pub master_id: String,
}

/// Conditionnement d'un article publié.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct CatalogueConditionnement {
    pub quantite: f64,
    pub poids_kg: Option<f64>,
    pub dimensions: Option<CatalogueDimensions>,
}

/// Dimensions d'un article publié (mm).
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct CatalogueDimensions {
    pub longueur: f64,
    pub largeur: f64,
    pub epaisseur: f64,
}
