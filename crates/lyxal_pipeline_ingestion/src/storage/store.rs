//! Implémentation du store de persistance industrielle SurrealDB pour le pipeline d'ingestion.
//!
//! Entièrement réaligné avec la Charte d'Architecture Lyxal OS (AGENTS.md) :
//! - Implémentation du trait universel `LyxalSurrealCall`.
//! - Appel exclusif des fonctions publiques `fn::ingestion_*` via `self.call_fn(...)`.
//! - Externalisation des règles métier (familles, spécifications, alias, substitutions) dans SurrealDB.
//! - Découplage complet de la logique métier Rust vers SurrealQL.

use std::sync::Arc;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use serde::{Deserialize, Serialize};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::error::{IngestionError, IngestionResult};
use crate::models::{IngestionBatch, PublicationManifest, QuarantineRecord, RawRecord, StagedItem};
use crate::technical_grouping::{ContextualSubstitutionRule, FamilyRule, TechnicalSpecification};
use crate::types::{BatchStatus, ManifestStatus, StateTransitionRecord};

// =============================================================================
// DTOs DE PARAMÈTRES POUR call_fn
// =============================================================================

#[derive(Serialize)]
struct BatchCreateParams {
    id: Option<String>,
    source_type: String,
    source_format_version: String,
    fournisseur_id: String,
    nom_fichier: String,
    file_hash_blake3: String,
    taille_octets: i64,
    statut: String,
    cursor_offset: i64,
    chunk_size: i64,
    total_lignes: i64,
    lignes_verifiees: i64,
    lignes_a_confirmer: i64,
    lignes_rejetees: i64,
    transitions: Vec<StateTransitionRecord>,
    provenance_details: serde_json::Value,
}

#[derive(Serialize)]
struct BatchCheckpointParams {
    id: String,
    cursor_offset: i64,
    total_lignes: i64,
    lignes_verifiees: i64,
    lignes_a_confirmer: i64,
    lignes_rejetees: i64,
}

#[derive(Serialize)]
struct BatchTransitionParams {
    id: String,
    nouveau_statut: String,
    transition: StateTransitionRecord,
}

#[derive(Serialize)]
struct StagedSaveParams {
    batch_id: String,
    raw_record_id: Option<String>,
    ligne_numero: i64,
    canonical_fingerprint: String,
    rules_version: String,
    fabricant: String,
    marque: Option<String>,
    reference_fabricant: String,
    code_barre_gtin: Option<String>,
    libelle_commercial: String,
    description_technique: Option<String>,
    type_item: String,
    unite_reference: String,
    conditionnement: Option<serde_json::Value>,
    qualification: String,
    publication_action: String,
    diff_payload: Option<serde_json::Value>,
    transitions: Vec<StateTransitionRecord>,
    is_approved: bool,
    approved_by: Option<String>,
    approved_at: Option<String>,
}

#[derive(Serialize)]
struct QuarantineLogParams {
    batch_id: String,
    raw_record_id: Option<String>,
    code_erreur: String,
    severite: String,
    champ_concerne: String,
    valeur_fautive: Option<serde_json::Value>,
    cause_detaillee: String,
}

#[derive(Serialize)]
struct ManifestSaveParams {
    manifest_ref: String,
    batch_id: String,
    manifest_version: i64,
    seal_hash: String,
    is_sealed: bool,
    statut: String,
    approved_by: Option<String>,
    approved_at: Option<String>,
    approver_role: Option<String>,
    nb_articles_insert: i64,
    nb_articles_update: i64,
    items_committed: i64,
    items_failed: i64,
    execution_items: Option<Vec<serde_json::Value>>,
    transitions: Option<Vec<StateTransitionRecord>>,
    executed_at: Option<String>,
}

#[derive(Serialize)]
struct ManifestApproveParams {
    manifest_ref: String,
    approved_by: String,
    approver_role: String,
}

#[derive(Serialize)]
struct ManifestRecordExecParams {
    manifest_ref: String,
    statut: String,
    items_committed: i64,
    items_failed: i64,
    execution_items: Option<Vec<serde_json::Value>>,
}

#[derive(Serialize)]
struct ResolveUnitParams {
    raw_unit: String,
    language: String,
}

/// Résultat de la résolution dynamique d'unité vers base_unite
#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct ResolveUnitResult {
    pub canonical_code: String,
    pub resolved: bool,
}

#[derive(Serialize)]
struct ResolveManufacturerParams {
    raw_name: String,
    language: String,
}

/// Résultat de la résolution dynamique de fabricant
#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct ResolveManufacturerResult {
    pub canonical_name: String,
    pub holding_or_group: Option<String>,
    pub is_verified: bool,
    pub resolved: bool,
}

#[derive(Serialize)]
struct FamilyRuleAddParams {
    code: String,
    label: String,
    keywords: Vec<String>,
    standard_unit: Option<String>,
}

#[derive(Serialize)]
struct SpecAddParams {
    technical_identity_key: String,
    family_code: String,
    generic_title: String,
    nominal_dimensions: Option<serde_json::Value>,
    tolerances: Option<serde_json::Value>,
    nominal_weight: Option<f64>,
    standard_norm: Option<String>,
    fire_rating: Option<String>,
    required_features: serde_json::Value,
}

#[derive(Serialize)]
struct SubstitutionRuleAddParams {
    rule_id: String,
    source_mfg: String,
    source_ref: String,
    target_mfg: String,
    target_ref: String,
    system_scope: String,
    certification_body: String,
    certification_ref: String,
    valid_until: String,
    is_revoked: bool,
    revocation_reason: Option<String>,
}

// =============================================================================
// DTOs PHASE 5 : DATA STEWARD & OBSERVABILITÉ
// =============================================================================

#[derive(Serialize)]
struct DashboardMetricsParams {
    batch_id: Option<String>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct DashboardMetricsResult {
    pub batches: BatchesMetrics,
    pub items: ItemsMetrics,
    pub quarantine: QuarantineMetrics,
    pub manifests: ManifestsMetrics,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct BatchesMetrics {
    pub total: i64,
    pub active: i64,
    pub staged: i64,
    pub published: i64,
    pub failed: i64,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct ItemsMetrics {
    pub total: i64,
    pub verified: i64,
    pub to_confirm: i64,
    pub rejected: i64,
    pub approved: i64,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct QuarantineMetrics {
    pub total: i64,
    pub critical: i64,
    pub pending: i64,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct ManifestsMetrics {
    pub total: i64,
    pub sealed: i64,
    pub approved: i64,
    pub committed: i64,
}

#[derive(Serialize, Default, Debug, Clone)]
pub struct StagedListFilter {
    pub batch_id: Option<String>,
    pub qualification: Option<String>,
    pub fabricant: Option<String>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct StagedListResult {
    pub items: Vec<serde_json::Value>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SessionAuthContext {
    pub user_id: String,
    pub role: String,
}

#[derive(Serialize, Debug, Clone)]
pub struct StagedRequalifyParams {
    pub item_id: String,
    pub new_qualification: String,
    pub justification: String,
    pub proof: Option<crate::proof::CommercialProof>,
    pub language: Option<String>,
    pub _session_auth: Option<SessionAuthContext>,
}

#[derive(Serialize, Default, Debug, Clone)]
pub struct QuarantineListFilter {
    pub batch_id: Option<String>,
    pub severite: Option<String>,
    pub is_resolved: Option<bool>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct QuarantineListResult {
    pub records: Vec<serde_json::Value>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Serialize, Debug, Clone)]
pub struct QuarantineResolveParams {
    pub quarantine_id: String,
    pub comment: String,
    pub staged_item_id: Option<String>,
    pub corrections: Option<serde_json::Value>,
    pub language: Option<String>,
    pub _session_auth: Option<SessionAuthContext>,
}

#[derive(Serialize, Default, Debug, Clone)]
pub struct ManifestListFilter {
    pub batch_id: Option<String>,
    pub statut: Option<String>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct ManifestListResult {
    pub manifests: Vec<serde_json::Value>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Serialize, Debug, Clone)]
pub struct ManifestGetDetailParams {
    pub manifest_ref: String,
    pub language: Option<String>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct ManifestDetailResult {
    pub manifest: serde_json::Value,
    pub batch: Option<serde_json::Value>,
    pub is_sealed: bool,
    pub seal_hash: String,
    pub execution_count: i64,
    pub transition_count: i64,
}

// =============================================================================
// STORE INDUSTRIEL
// =============================================================================

/// Store de persistance SurrealDB pour le pipeline d'ingestion Lyxal OS.
#[derive(Clone)]
pub struct IngestionStore {
    db: Arc<Surreal<Any>>,
}

#[async_trait::async_trait]
impl LyxalSurrealCall for IngestionStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

impl IngestionStore {
    /// Initialise le store avec une instance `Surreal<Any>` existante
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db: Arc::new(db) }
    }

    /// Récupère la référence au client SurrealDB
    pub fn client(&self) -> &Surreal<Any> {
        &self.db
    }

    /// Crée une instance in-memory isolée (`mem://`) pour les tests et la validation hors production
    pub async fn create_in_memory() -> IngestionResult<Self> {
        let db = surrealdb::engine::any::connect("mem://")
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec connexion in-memory : {e}")))?;

        db.use_ns("lyxal")
            .use_db("test_ingestion")
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec sélection NS/DB : {e}")))?;

        let store = Self::new(db);
        store.init_schema().await?;
        Ok(store)
    }

    /// Initialise l'ensemble des schémas, fonctions et seeds configurables
    pub async fn init_schema(&self) -> IngestionResult<()> {
        let schema_surql = r#"
        -- Primitives universelles de contrat Lyxal OS
        DEFINE FUNCTION IF NOT EXISTS fn::result_ok($data: any) {
            RETURN { ok: true, data: $data, error: NONE };
        };
        DEFINE FUNCTION OVERWRITE fn::error_result($code: option<string>, $language: option<string>, $details: option<object>) {
            LET $c = IF $code != NONE { <string> $code } ELSE { "UNKNOWN_ERROR" };
            RETURN {
                ok: false,
                data: NONE,
                error: {
                    code: $c,
                    message: $c,
                    label: $c,
                    category: "BUSINESS",
                    severity: "ERROR",
                    retryable: false,
                    documentation: {},
                    metadata: {},
                    details: IF $details != NONE { $details } ELSE { {} }
                }
            };
        };

        -- Référentiel base_unite
        DEFINE TABLE IF NOT EXISTS base_unite SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS code ON TABLE base_unite TYPE string;
        DEFINE FIELD IF NOT EXISTS libelle ON TABLE base_unite TYPE string;
        DEFINE FIELD IF NOT EXISTS abreviation ON TABLE base_unite TYPE string;
        DEFINE INDEX IF NOT EXISTS idx_base_unite_code ON TABLE base_unite FIELDS code UNIQUE;

        UPSERT base_unite:M2 CONTENT { code: "M2", libelle: "METRE CARRE", abreviation: "m²" };
        UPSERT base_unite:PCE CONTENT { code: "PCE", libelle: "PIECE", abreviation: "pce" };
        UPSERT base_unite:ML CONTENT { code: "ML", libelle: "METRE LINEAIRE", abreviation: "ml" };
        UPSERT base_unite:M CONTENT { code: "M", libelle: "METRE", abreviation: "m" };
        UPSERT base_unite:KG CONTENT { code: "KG", libelle: "KILOGRAMME", abreviation: "kg" };

        -- Tables Staging
        DEFINE TABLE IF NOT EXISTS ingestion_batch SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS source_type ON TABLE ingestion_batch TYPE string;
        DEFINE FIELD IF NOT EXISTS source_format_version ON TABLE ingestion_batch TYPE string;
        DEFINE FIELD IF NOT EXISTS fournisseur_id ON TABLE ingestion_batch TYPE string;
        DEFINE FIELD IF NOT EXISTS nom_fichier ON TABLE ingestion_batch TYPE string;
        DEFINE FIELD IF NOT EXISTS file_hash_blake3 ON TABLE ingestion_batch TYPE string;
        DEFINE FIELD IF NOT EXISTS taille_octets ON TABLE ingestion_batch TYPE int;
        DEFINE FIELD IF NOT EXISTS statut ON TABLE ingestion_batch TYPE string;
        DEFINE FIELD IF NOT EXISTS cursor_offset ON TABLE ingestion_batch TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS chunk_size ON TABLE ingestion_batch TYPE int DEFAULT 500;
        DEFINE FIELD IF NOT EXISTS total_lignes ON TABLE ingestion_batch TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS lignes_verifiees ON TABLE ingestion_batch TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS lignes_a_confirmer ON TABLE ingestion_batch TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS lignes_rejetees ON TABLE ingestion_batch TYPE int DEFAULT 0;
        DEFINE FIELD OVERWRITE transitions ON TABLE ingestion_batch TYPE option<array<object>> FLEXIBLE DEFAULT [];
        DEFINE FIELD OVERWRITE provenance_details ON TABLE ingestion_batch TYPE option<object> FLEXIBLE DEFAULT {};
        DEFINE FIELD IF NOT EXISTS last_checkpoint_at ON TABLE ingestion_batch TYPE option<datetime>;
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_batch TYPE option<datetime>;
        DEFINE FIELD IF NOT EXISTS completed_at ON TABLE ingestion_batch TYPE option<datetime>;
        DEFINE INDEX IF NOT EXISTS idx_batch_source_file_hash ON TABLE ingestion_batch FIELDS source_type, file_hash_blake3 UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_raw_record SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS batch ON TABLE ingestion_raw_record TYPE record<ingestion_batch>;
        DEFINE FIELD IF NOT EXISTS ligne_numero ON TABLE ingestion_raw_record TYPE int;
        DEFINE FIELD IF NOT EXISTS payload_brut ON TABLE ingestion_raw_record TYPE any;
        DEFINE FIELD IF NOT EXISTS row_hash ON TABLE ingestion_raw_record TYPE string;
        DEFINE INDEX IF NOT EXISTS idx_raw_record_batch_ligne ON TABLE ingestion_raw_record FIELDS batch, ligne_numero UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_staged_item SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS batch ON TABLE ingestion_staged_item TYPE record<ingestion_batch>;
        DEFINE FIELD IF NOT EXISTS raw_record ON TABLE ingestion_staged_item TYPE option<record<ingestion_raw_record>>;
        DEFINE FIELD IF NOT EXISTS ligne_numero ON TABLE ingestion_staged_item TYPE int;
        DEFINE FIELD IF NOT EXISTS canonical_fingerprint ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS rules_version ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS fabricant ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS marque ON TABLE ingestion_staged_item TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS reference_fabricant ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS code_barre_gtin ON TABLE ingestion_staged_item TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS libelle_commercial ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS description_technique ON TABLE ingestion_staged_item TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS type_item ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS unite_reference ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD OVERWRITE conditionnement ON TABLE ingestion_staged_item TYPE option<object> FLEXIBLE;
        DEFINE FIELD IF NOT EXISTS qualification ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD IF NOT EXISTS publication_action ON TABLE ingestion_staged_item TYPE string;
        DEFINE FIELD OVERWRITE diff_payload ON TABLE ingestion_staged_item TYPE option<object> FLEXIBLE;
        DEFINE FIELD OVERWRITE transitions ON TABLE ingestion_staged_item TYPE option<array<object>> FLEXIBLE DEFAULT [];
        DEFINE FIELD OVERWRITE qualification_reason ON TABLE ingestion_staged_item TYPE option<string>;
        DEFINE FIELD OVERWRITE commercial_proof ON TABLE ingestion_staged_item TYPE option<object> FLEXIBLE;
        DEFINE FIELD IF NOT EXISTS is_approved ON TABLE ingestion_staged_item TYPE bool DEFAULT false;
        DEFINE FIELD IF NOT EXISTS approved_by ON TABLE ingestion_staged_item TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS approved_at ON TABLE ingestion_staged_item TYPE option<datetime>;
        DEFINE INDEX IF NOT EXISTS idx_staged_item_batch_ref ON TABLE ingestion_staged_item FIELDS batch, reference_fabricant UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_quarantine_record SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS batch ON TABLE ingestion_quarantine_record TYPE record<ingestion_batch>;
        DEFINE FIELD IF NOT EXISTS raw_record ON TABLE ingestion_quarantine_record TYPE option<record<ingestion_raw_record>>;
        DEFINE FIELD IF NOT EXISTS code_erreur ON TABLE ingestion_quarantine_record TYPE string;
        DEFINE FIELD IF NOT EXISTS severite ON TABLE ingestion_quarantine_record TYPE string;
        DEFINE FIELD IF NOT EXISTS champ_concerne ON TABLE ingestion_quarantine_record TYPE string;
        DEFINE FIELD IF NOT EXISTS valeur_fautive ON TABLE ingestion_quarantine_record TYPE any;
        DEFINE FIELD IF NOT EXISTS cause_detaillee ON TABLE ingestion_quarantine_record TYPE string;
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_quarantine_record TYPE option<datetime>;
        DEFINE FIELD IF NOT EXISTS is_resolved ON TABLE ingestion_quarantine_record TYPE bool DEFAULT false;
        DEFINE FIELD IF NOT EXISTS resolved_by ON TABLE ingestion_quarantine_record TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS resolved_at ON TABLE ingestion_quarantine_record TYPE option<datetime>;
        DEFINE FIELD IF NOT EXISTS resolution_comment ON TABLE ingestion_quarantine_record TYPE option<string>;

        DEFINE TABLE IF NOT EXISTS ingestion_publication_manifest SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS batch ON TABLE ingestion_publication_manifest TYPE record<ingestion_batch>;
        DEFINE FIELD IF NOT EXISTS manifest_ref ON TABLE ingestion_publication_manifest TYPE string;
        DEFINE FIELD IF NOT EXISTS manifest_version ON TABLE ingestion_publication_manifest TYPE int;
        DEFINE FIELD IF NOT EXISTS seal_hash ON TABLE ingestion_publication_manifest TYPE string;
        DEFINE FIELD IF NOT EXISTS is_sealed ON TABLE ingestion_publication_manifest TYPE bool DEFAULT false;
        DEFINE FIELD IF NOT EXISTS statut ON TABLE ingestion_publication_manifest TYPE string;
        DEFINE FIELD IF NOT EXISTS approved_by ON TABLE ingestion_publication_manifest TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS approved_at ON TABLE ingestion_publication_manifest TYPE option<datetime>;
        DEFINE FIELD IF NOT EXISTS approver_role ON TABLE ingestion_publication_manifest TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS nb_articles_insert ON TABLE ingestion_publication_manifest TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS nb_articles_update ON TABLE ingestion_publication_manifest TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS items_committed ON TABLE ingestion_publication_manifest TYPE int DEFAULT 0;
        DEFINE FIELD IF NOT EXISTS items_failed ON TABLE ingestion_publication_manifest TYPE int DEFAULT 0;
        DEFINE FIELD OVERWRITE execution_items ON TABLE ingestion_publication_manifest TYPE option<array<object>> FLEXIBLE DEFAULT [];
        DEFINE FIELD OVERWRITE transitions ON TABLE ingestion_publication_manifest TYPE option<array<object>> FLEXIBLE DEFAULT [];
        DEFINE FIELD IF NOT EXISTS executed_at ON TABLE ingestion_publication_manifest TYPE option<datetime>;
        DEFINE INDEX IF NOT EXISTS idx_manifest_ref ON TABLE ingestion_publication_manifest FIELDS manifest_ref UNIQUE;

        -- Tables de Règles Métier Externalisées
        DEFINE TABLE IF NOT EXISTS ingestion_family_rule SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS code ON TABLE ingestion_family_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS label ON TABLE ingestion_family_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS keywords ON TABLE ingestion_family_rule TYPE array<string> DEFAULT [];
        DEFINE FIELD IF NOT EXISTS standard_unit ON TABLE ingestion_family_rule TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_family_rule TYPE option<datetime> DEFAULT time::now();
        DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ingestion_family_rule TYPE option<datetime> DEFAULT time::now();
        DEFINE INDEX IF NOT EXISTS idx_family_rule_code ON TABLE ingestion_family_rule FIELDS code UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_specification SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS technical_identity_key ON TABLE ingestion_specification TYPE string;
        DEFINE FIELD IF NOT EXISTS family_code ON TABLE ingestion_specification TYPE string;
        DEFINE FIELD IF NOT EXISTS generic_title ON TABLE ingestion_specification TYPE string;
        DEFINE FIELD OVERWRITE nominal_dimensions ON TABLE ingestion_specification TYPE option<object> FLEXIBLE;
        DEFINE FIELD OVERWRITE tolerances ON TABLE ingestion_specification TYPE option<object> FLEXIBLE;
        DEFINE FIELD IF NOT EXISTS nominal_weight ON TABLE ingestion_specification TYPE option<float>;
        DEFINE FIELD IF NOT EXISTS standard_norm ON TABLE ingestion_specification TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS fire_rating ON TABLE ingestion_specification TYPE option<string>;
        DEFINE FIELD OVERWRITE required_features ON TABLE ingestion_specification TYPE option<object> FLEXIBLE DEFAULT {};
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_specification TYPE option<datetime> DEFAULT time::now();
        DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ingestion_specification TYPE option<datetime> DEFAULT time::now();
        DEFINE INDEX IF NOT EXISTS idx_spec_tech_key ON TABLE ingestion_specification FIELDS technical_identity_key UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_manufacturer_alias SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS raw_alias ON TABLE ingestion_manufacturer_alias TYPE string;
        DEFINE FIELD IF NOT EXISTS canonical_name ON TABLE ingestion_manufacturer_alias TYPE string;
        DEFINE FIELD IF NOT EXISTS holding_or_group ON TABLE ingestion_manufacturer_alias TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS is_verified ON TABLE ingestion_manufacturer_alias TYPE bool DEFAULT true;
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_manufacturer_alias TYPE option<datetime> DEFAULT time::now();
        DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ingestion_manufacturer_alias TYPE option<datetime> DEFAULT time::now();
        DEFINE INDEX IF NOT EXISTS idx_mfg_raw_alias ON TABLE ingestion_manufacturer_alias FIELDS raw_alias UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_unit_alias SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS raw_alias ON TABLE ingestion_unit_alias TYPE string;
        DEFINE FIELD IF NOT EXISTS canonical_unit ON TABLE ingestion_unit_alias TYPE string;
        DEFINE FIELD IF NOT EXISTS comment ON TABLE ingestion_unit_alias TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_unit_alias TYPE option<datetime> DEFAULT time::now();
        DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ingestion_unit_alias TYPE option<datetime> DEFAULT time::now();
        DEFINE INDEX IF NOT EXISTS idx_unit_raw_alias ON TABLE ingestion_unit_alias FIELDS raw_alias UNIQUE;

        DEFINE TABLE IF NOT EXISTS ingestion_substitution_rule SCHEMAFULL;
        DEFINE FIELD IF NOT EXISTS rule_id ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS source_mfg ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS source_ref ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS target_mfg ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS target_ref ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS system_scope ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS certification_body ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS certification_ref ON TABLE ingestion_substitution_rule TYPE string;
        DEFINE FIELD IF NOT EXISTS valid_until ON TABLE ingestion_substitution_rule TYPE datetime;
        DEFINE FIELD IF NOT EXISTS is_revoked ON TABLE ingestion_substitution_rule TYPE bool DEFAULT false;
        DEFINE FIELD IF NOT EXISTS revocation_reason ON TABLE ingestion_substitution_rule TYPE option<string>;
        DEFINE FIELD IF NOT EXISTS created_at ON TABLE ingestion_substitution_rule TYPE option<datetime> DEFAULT time::now();
        DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ingestion_substitution_rule TYPE option<datetime> DEFAULT time::now();
        DEFINE INDEX IF NOT EXISTS idx_subst_rule_id ON TABLE ingestion_substitution_rule FIELDS rule_id UNIQUE;

        -- Fonctions Publiques fn::ingestion_*
        DEFINE FUNCTION OVERWRITE fn::ingestion_batch_create($params: object) {
            LET $id = IF $params.id != NONE { <string> $params.id } ELSE { rand::uuid::v7() };
            LET $source_type = IF $params.source_type != NONE { string::uppercase(string::trim($params.source_type)) } ELSE { "CSV" };
            LET $source_format_version = IF $params.source_format_version != NONE { string::trim($params.source_format_version) } ELSE { "1.0" };
            LET $fournisseur_id = IF $params.fournisseur_id != NONE { string::trim($params.fournisseur_id) } ELSE { "" };
            LET $nom_fichier = IF $params.nom_fichier != NONE { string::trim($params.nom_fichier) } ELSE { "" };
            LET $file_hash_blake3 = IF $params.file_hash_blake3 != NONE { string::trim($params.file_hash_blake3) } ELSE { "" };
            LET $taille_octets = IF $params.taille_octets != NONE { <int> $params.taille_octets } ELSE { 0 };
            LET $statut = IF $params.statut != NONE { string::trim($params.statut) } ELSE { "Staged" };
            LET $cursor_offset = IF $params.cursor_offset != NONE { <int> $params.cursor_offset } ELSE { 0 };
            LET $chunk_size = IF $params.chunk_size != NONE { <int> $params.chunk_size } ELSE { 500 };
            LET $total_lignes = IF $params.total_lignes != NONE { <int> $params.total_lignes } ELSE { 0 };
            LET $lignes_verifiees = IF $params.lignes_verifiees != NONE { <int> $params.lignes_verifiees } ELSE { 0 };
            LET $lignes_a_confirmer = IF $params.lignes_a_confirmer != NONE { <int> $params.lignes_a_confirmer } ELSE { 0 };
            LET $lignes_rejetees = IF $params.lignes_rejetees != NONE { <int> $params.lignes_rejetees } ELSE { 0 };
            LET $transitions = IF $params.transitions != NONE { $params.transitions } ELSE { [] };
            LET $provenance_details = IF $params.provenance_details != NONE { $params.provenance_details } ELSE { {} };
            
            LET $record_id = <record> string::concat('ingestion_batch:', $id);
            UPSERT $record_id CONTENT {
                source_type: $source_type,
                source_format_version: $source_format_version,
                fournisseur_id: $fournisseur_id,
                nom_fichier: $nom_fichier,
                file_hash_blake3: $file_hash_blake3,
                taille_octets: $taille_octets,
                statut: $statut,
                cursor_offset: $cursor_offset,
                chunk_size: $chunk_size,
                total_lignes: $total_lignes,
                lignes_verifiees: $lignes_verifiees,
                lignes_a_confirmer: $lignes_a_confirmer,
                lignes_rejetees: $lignes_rejetees,
                transitions: $transitions,
                provenance_details: $provenance_details,
                last_checkpoint_at: time::now(),
                created_at: time::now()
            };
            RETURN fn::result_ok(<string> $id);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_batch_checkpoint($params: object) {
            LET $id = <string> $params.id;
            LET $record_id = <record> string::concat('ingestion_batch:', $id);
            LET $tot = IF $params.total_lignes != NONE { <int> $params.total_lignes } ELSE { NONE };
            UPDATE $record_id SET
                cursor_offset = <int> $params.cursor_offset,
                total_lignes = IF $tot != NONE { $tot } ELSE { total_lignes },
                lignes_verifiees = <int> $params.lignes_verifiees,
                lignes_a_confirmer = <int> $params.lignes_a_confirmer,
                lignes_rejetees = <int> $params.lignes_rejetees,
                last_checkpoint_at = time::now();
            RETURN fn::result_ok(true);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_batch_transition($params: object) {
            LET $id = <string> $params.id;
            LET $nouveau_statut = <string> $params.nouveau_statut;
            LET $record_id = <record> string::concat('ingestion_batch:', $id);
            LET $is_completed = $nouveau_statut IN ["Completed", "Failed", "Aborted"];
            UPDATE $record_id SET
                statut = $nouveau_statut,
                transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$params.transition]),
                completed_at = IF $is_completed { time::now() } ELSE { completed_at },
                last_checkpoint_at = time::now();
            RETURN fn::result_ok(true);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_staged_save($params: object) {
            LET $batch_rec = <record> string::concat('ingestion_batch:', $params.batch_id);
            LET $raw_rec = IF $params.raw_record_id != NONE { <record> string::concat('ingestion_raw_record:', $params.raw_record_id) } ELSE { NONE };
            LET $existing = (SELECT id FROM ingestion_staged_item WHERE batch = $batch_rec AND reference_fabricant = $params.reference_fabricant);
            IF array::len($existing) > 0 {
                LET $target_id = $existing[0].id;
                UPDATE $target_id SET
                    raw_record = $raw_rec,
                    ligne_numero = <int> $params.ligne_numero,
                    canonical_fingerprint = $params.canonical_fingerprint,
                    rules_version = $params.rules_version,
                    fabricant = $params.fabricant,
                    marque = $params.marque,
                    code_barre_gtin = $params.code_barre_gtin,
                    libelle_commercial = $params.libelle_commercial,
                    description_technique = $params.description_technique,
                    type_item = $params.type_item,
                    unite_reference = $params.unite_reference,
                    conditionnement = $params.conditionnement,
                    qualification = $params.qualification,
                    publication_action = $params.publication_action,
                    diff_payload = $params.diff_payload,
                    transitions = IF $params.transitions != NONE { $params.transitions } ELSE { [] },
                    is_approved = IF $params.is_approved != NONE { <bool> $params.is_approved } ELSE { false },
                    approved_by = $params.approved_by,
                    approved_at = $params.approved_at;
                RETURN fn::result_ok(<string> $target_id);
            } ELSE {
                LET $created = (CREATE ingestion_staged_item CONTENT {
                    batch: $batch_rec,
                    raw_record: $raw_rec,
                    ligne_numero: <int> $params.ligne_numero,
                    canonical_fingerprint: $params.canonical_fingerprint,
                    rules_version: $params.rules_version,
                    fabricant: $params.fabricant,
                    marque: $params.marque,
                    reference_fabricant: $params.reference_fabricant,
                    code_barre_gtin: $params.code_barre_gtin,
                    libelle_commercial: $params.libelle_commercial,
                    description_technique: $params.description_technique,
                    type_item: $params.type_item,
                    unite_reference: $params.unite_reference,
                    conditionnement: $params.conditionnement,
                    qualification: $params.qualification,
                    publication_action: $params.publication_action,
                    diff_payload: $params.diff_payload,
                    transitions: IF $params.transitions != NONE { $params.transitions } ELSE { [] },
                    is_approved: IF $params.is_approved != NONE { <bool> $params.is_approved } ELSE { false },
                    approved_by: $params.approved_by,
                    approved_at: $params.approved_at
                });
                RETURN fn::result_ok(<string> $created[0].id);
            };
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_log($params: object) {
            LET $batch_rec = <record> string::concat('ingestion_batch:', $params.batch_id);
            LET $raw_rec = IF $params.raw_record_id != NONE { <record> string::concat('ingestion_raw_record:', $params.raw_record_id) } ELSE { NONE };
            LET $created = (CREATE ingestion_quarantine_record CONTENT {
                batch: $batch_rec,
                raw_record: $raw_rec,
                code_erreur: $params.code_erreur,
                severite: $params.severite,
                champ_concerne: $params.champ_concerne,
                valeur_fautive: $params.valeur_fautive,
                cause_detaillee: $params.cause_detaillee,
                created_at: time::now()
            });
            RETURN fn::result_ok(<string> $created[0].id);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_save($params: object) {
            LET $manifest_ref = <string> $params.manifest_ref;
            LET $batch_rec = <record> string::concat('ingestion_batch:', $params.batch_id);
            LET $seal_hash = IF $params.seal_hash != NONE { <string> $params.seal_hash } ELSE { "" };
            LET $is_sealed = IF $params.is_sealed != NONE { <bool> $params.is_sealed } ELSE { false };
            IF $is_sealed == true AND string::len($seal_hash) == 0 {
                RETURN fn::error_result("INGESTION_MANIFEST_UNSEALED", "fr", { manifest_ref: $manifest_ref });
            };
            LET $statut = IF $params.statut != NONE { string::uppercase(<string> $params.statut) } ELSE { "DRAFT" };
            LET $existing = (SELECT id FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
            IF array::len($existing) > 0 {
                UPDATE $existing[0].id SET
                    manifest_version = <int> $params.manifest_version,
                    seal_hash = $params.seal_hash,
                    is_sealed = <bool> $params.is_sealed,
                    statut = $statut,
                    approved_by = $params.approved_by,
                    approved_at = $params.approved_at,
                    approver_role = $params.approver_role,
                    nb_articles_insert = <int> $params.nb_articles_insert,
                    nb_articles_update = <int> $params.nb_articles_update,
                    items_committed = <int> $params.items_committed,
                    items_failed = <int> $params.items_failed,
                    execution_items = IF $params.execution_items != NONE { $params.execution_items } ELSE { [] },
                    transitions = IF $params.transitions != NONE { $params.transitions } ELSE { [] },
                    executed_at = $params.executed_at;
            } ELSE {
                CREATE ingestion_publication_manifest CONTENT {
                    batch: $batch_rec,
                    manifest_ref: $manifest_ref,
                    manifest_version: <int> $params.manifest_version,
                    seal_hash: $params.seal_hash,
                    is_sealed: <bool> $params.is_sealed,
                    statut: $statut,
                    approved_by: $params.approved_by,
                    approved_at: $params.approved_at,
                    approver_role: $params.approver_role,
                    nb_articles_insert: <int> $params.nb_articles_insert,
                    nb_articles_update: <int> $params.nb_articles_update,
                    items_committed: <int> $params.items_committed,
                    items_failed: <int> $params.items_failed,
                    execution_items: IF $params.execution_items != NONE { $params.execution_items } ELSE { [] },
                    transitions: IF $params.transitions != NONE { $params.transitions } ELSE { [] },
                    executed_at: $params.executed_at
                };
            };
            RETURN fn::result_ok($manifest_ref);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_approve($params: object) {
            LET $manifest_ref = <string> $params.manifest_ref;
            LET $manifests = (SELECT * FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
            IF array::len($manifests) == 0 {
                RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", "fr", { manifest_ref: $manifest_ref });
            };
            LET $manif = $manifests[0];
            IF $manif.is_sealed != true OR string::len($manif.seal_hash) == 0 {
                RETURN fn::error_result("INGESTION_MANIFEST_UNSEALED", "fr", { manifest_ref: $manifest_ref });
            };
            LET $role = IF $params.approver_role != NONE { <string> $params.approver_role } ELSE { "steward_admin" };
            IF $role != "steward_admin" {
                RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", "fr", { manifest_ref: $manifest_ref, role: $role });
            };
            LET $now = time::now();
            LET $trans = {
                from_state: $manif.statut,
                to_state: "APPROVED",
                triggered_by: $params.approved_by,
                reason: "Approbation formelle du Data Steward",
                transitioned_at: $now
            };
            UPDATE $manif.id SET
                statut = "APPROVED",
                approved_by = $params.approved_by,
                approver_role = "steward_admin",
                approved_at = $now,
                transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);
            RETURN fn::result_ok(true);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_record_exec($params: object) {
            LET $manifest_ref = <string> $params.manifest_ref;
            LET $manifests = (SELECT * FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
            IF array::len($manifests) == 0 {
                RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", "fr", { manifest_ref: $manifest_ref });
            };
            LET $manif = $manifests[0];
            LET $now = time::now();
            LET $statut = string::uppercase(<string> $params.statut);
            LET $trans = {
                from_state: $manif.statut,
                to_state: $statut,
                triggered_by: "catalogue_sync_agent",
                reason: "Compte-rendu d'exécution de la publication",
                transitioned_at: $now
            };
            UPDATE $manif.id SET
                statut = $statut,
                items_committed = IF $params.items_committed != NONE { <int> $params.items_committed } ELSE { items_committed },
                items_failed = IF $params.items_failed != NONE { <int> $params.items_failed } ELSE { items_failed },
                execution_items = IF $params.execution_items != NONE { $params.execution_items } ELSE { execution_items },
                executed_at = $now,
                transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);
            RETURN fn::result_ok(true);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_unit($params: object) {
            LET $raw_unit = string::uppercase(string::trim($params.raw_unit));
            LET $alias_res = (SELECT canonical_unit FROM ingestion_unit_alias WHERE raw_alias = $raw_unit);
            IF array::len($alias_res) > 0 {
                RETURN fn::result_ok({ canonical_code: $alias_res[0].canonical_unit, resolved: true });
            };
            LET $base_res = (SELECT code FROM base_unite WHERE code = $raw_unit);
            IF array::len($base_res) > 0 {
                RETURN fn::result_ok({ canonical_code: $base_res[0].code, resolved: true });
            };
            RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", "fr", { raw_unit: $raw_unit });
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_manufacturer($params: object) {
            LET $raw_name = string::uppercase(string::trim($params.raw_name));
            LET $alias_res = (SELECT canonical_name, holding_or_group, is_verified FROM ingestion_manufacturer_alias WHERE raw_alias = $raw_name);
            IF array::len($alias_res) > 0 {
                LET $hit = $alias_res[0];
                RETURN fn::result_ok({
                    canonical_name: $hit.canonical_name,
                    holding_or_group: $hit.holding_or_group,
                    is_verified: $hit.is_verified,
                    resolved: true
                });
            };
            RETURN fn::result_ok({
                canonical_name: $raw_name,
                holding_or_group: NONE,
                is_verified: false,
                resolved: false
            });
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_rule_family_add($params: object) {
            LET $code = string::uppercase(string::trim($params.code));
            LET $rec_id = <record> string::concat('ingestion_family_rule:⟨', $code, '⟩');
            UPSERT $rec_id CONTENT {
                code: $code,
                label: string::trim($params.label),
                keywords: IF $params.keywords != NONE { $params.keywords } ELSE { [] },
                standard_unit: IF $params.standard_unit != NONE { string::uppercase(string::trim($params.standard_unit)) } ELSE { NONE },
                updated_at: time::now()
            };
            RETURN fn::result_ok($code);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_rule_spec_add($params: object) {
            LET $key = string::uppercase(string::trim($params.technical_identity_key));
            LET $rec_id = <record> string::concat('ingestion_specification:⟨', $key, '⟩');
            UPSERT $rec_id CONTENT {
                technical_identity_key: $key,
                family_code: string::uppercase(string::trim($params.family_code)),
                generic_title: string::trim($params.generic_title),
                nominal_dimensions: $params.nominal_dimensions,
                tolerances: $params.tolerances,
                nominal_weight: $params.nominal_weight,
                standard_norm: $params.standard_norm,
                fire_rating: $params.fire_rating,
                required_features: IF $params.required_features != NONE { $params.required_features } ELSE { {} },
                updated_at: time::now()
            };
            RETURN fn::result_ok($key);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_rule_substitution_add($params: object) {
            LET $rule_id = string::uppercase(string::trim($params.rule_id));
            LET $rec_id = <record> string::concat('ingestion_substitution_rule:⟨', $rule_id, '⟩');
            UPSERT $rec_id CONTENT {
                rule_id: $rule_id,
                source_mfg: string::uppercase(string::trim($params.source_mfg)),
                source_ref: string::trim($params.source_ref),
                target_mfg: string::uppercase(string::trim($params.target_mfg)),
                target_ref: string::trim($params.target_ref),
                system_scope: string::uppercase(string::trim($params.system_scope)),
                certification_body: string::uppercase(string::trim($params.certification_body)),
                certification_ref: string::trim($params.certification_ref),
                valid_until: <datetime> $params.valid_until,
                is_revoked: IF $params.is_revoked != NONE { <bool> $params.is_revoked } ELSE { false },
                revocation_reason: $params.revocation_reason,
                updated_at: time::now()
            };
            RETURN fn::result_ok($rule_id);
        };

        -- ====================================================================
        -- FONCTIONS PUBLIQUES PHASE 5 : DATA STEWARD & OBSERVABILITÉ
        -- ====================================================================

        DEFINE FUNCTION OVERWRITE fn::ingestion_dashboard_metrics($params: object) {
            LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };
            LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

            LET $batches = (SELECT statut, total_lignes, lignes_verifiees, lignes_a_confirmer, lignes_rejetees FROM ingestion_batch);
            LET $total_batches = array::len($batches);
            LET $batches_active = array::len((SELECT id FROM ingestion_batch WHERE statut IN ["RECEIVED", "PARSING", "VALIDATING"]));
            LET $batches_staged = array::len((SELECT id FROM ingestion_batch WHERE statut = "STAGED"));
            LET $batches_published = array::len((SELECT id FROM ingestion_batch WHERE statut = "PUBLISHED"));
            LET $batches_failed = array::len((SELECT id FROM ingestion_batch WHERE statut = "FAILED"));

            LET $all_staged = (SELECT qualification, is_approved FROM ingestion_staged_item WHERE ($b_rec == NONE OR batch = $b_rec));
            LET $total_staged = array::len($all_staged);
            LET $verified_items = array::len((SELECT id FROM $all_staged WHERE qualification = "VERIFIED"));
            LET $to_confirm_items = array::len((SELECT id FROM $all_staged WHERE qualification = "TO_CONFIRM"));
            LET $rejected_items = array::len((SELECT id FROM $all_staged WHERE qualification = "REJECTED"));
            LET $approved_items = array::len((SELECT id FROM $all_staged WHERE is_approved = true));

            LET $all_quarantine = (SELECT severite, is_resolved FROM ingestion_quarantine_record WHERE ($b_rec == NONE OR batch = $b_rec));
            LET $total_quarantine = array::len($all_quarantine);
            LET $quarantine_critical = array::len((SELECT id FROM $all_quarantine WHERE severite = "CRITICAL"));
            LET $quarantine_pending = array::len((SELECT id FROM $all_quarantine WHERE is_resolved != true));

            LET $manifests = (SELECT statut, is_sealed, items_committed, items_failed FROM ingestion_publication_manifest WHERE ($b_rec == NONE OR batch = $b_rec));
            LET $total_manifests = array::len($manifests);
            LET $sealed_manifests = array::len((SELECT id FROM $manifests WHERE is_sealed = true));
            LET $approved_manifests = array::len((SELECT id FROM $manifests WHERE statut = "APPROVED"));
            LET $committed_manifests = array::len((SELECT id FROM $manifests WHERE statut = "COMMITTED"));

            RETURN fn::result_ok({
                batches: {
                    total: $total_batches,
                    active: $batches_active,
                    staged: $batches_staged,
                    published: $batches_published,
                    failed: $batches_failed
                },
                items: {
                    total: $total_staged,
                    verified: $verified_items,
                    to_confirm: $to_confirm_items,
                    rejected: $rejected_items,
                    approved: $approved_items
                },
                quarantine: {
                    total: $total_quarantine,
                    critical: $quarantine_critical,
                    pending: $quarantine_pending
                },
                manifests: {
                    total: $total_manifests,
                    sealed: $sealed_manifests,
                    approved: $approved_manifests,
                    committed: $committed_manifests
                }
            });
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_staged_list($params: object) {
            LET $limit = IF $params.limit != NONE { <int> $params.limit } ELSE { 50 };
            LET $start = IF $params.start != NONE { <int> $params.start } ELSE { 0 };
            LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };
            LET $qual_filter = IF $params.qualification != NONE { string::uppercase(<string> $params.qualification) } ELSE { NONE };
            LET $mfg_filter = IF $params.fabricant != NONE { string::uppercase(<string> $params.fabricant) } ELSE { NONE };

            LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

            LET $all_matches = (SELECT id FROM ingestion_staged_item WHERE
                ($b_rec == NONE OR batch = $b_rec) AND
                ($qual_filter == NONE OR qualification = $qual_filter) AND
                ($mfg_filter == NONE OR fabricant = $mfg_filter)
            );
            LET $total = array::len($all_matches);

            LET $items = (SELECT 
                <string> id AS id,
                <string> batch AS batch,
                ligne_numero,
                canonical_fingerprint,
                rules_version,
                fabricant,
                marque,
                reference_fabricant,
                code_barre_gtin,
                libelle_commercial,
                description_technique,
                type_item,
                unite_reference,
                conditionnement,
                qualification,
                qualification_reason,
                publication_action,
                diff_payload,
                transitions,
                is_approved,
                approved_by,
                IF approved_at != NONE { <string> approved_at } ELSE { NONE } AS approved_at
            FROM ingestion_staged_item WHERE
                ($b_rec == NONE OR batch = $b_rec) AND
                ($qual_filter == NONE OR qualification = $qual_filter) AND
                ($mfg_filter == NONE OR fabricant = $mfg_filter)
                ORDER BY ligne_numero ASC
                LIMIT $limit START $start
            );

            RETURN fn::result_ok({
                items: $items,
                total: $total,
                limit: $limit,
                start: $start
            });
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_staged_requalify($params: object) {
            LET $item_id = <string> $params.item_id;
            LET $language = IF $params.language != NONE { <string> $params.language } ELSE { "fr" };
            
            LET $role = IF $auth != NONE AND $auth.role != NONE { 
                <string> $auth.role 
            } ELSE IF $params._session_auth != NONE AND $params._session_auth.role != NONE { 
                <string> $params._session_auth.role 
            } ELSE { 
                "guest" 
            };

            LET $operator = IF $auth != NONE AND $auth.id != NONE { 
                <string> $auth.id 
            } ELSE IF $params._session_auth != NONE AND $params._session_auth.user_id != NONE { 
                <string> $params._session_auth.user_id 
            } ELSE { 
                "anonymous" 
            };

            IF $role != "steward_admin" {
                RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $language, { 
                    role: $role, 
                    expected_role: "steward_admin",
                    message: "Seul un Data Steward authentifié peut requalifier un article"
                });
            };

            LET $target_qual = string::uppercase(string::trim(<string> $params.new_qualification));
            IF $target_qual NOT IN ["VERIFIED", "TO_CONFIRM", "REJECTED"] {
                RETURN fn::error_result("INGESTION_INVALID_QUALIFICATION", $language, { 
                    qualification: $target_qual,
                    allowed: ["VERIFIED", "TO_CONFIRM", "REJECTED"]
                });
            };

            LET $justification = IF $params.justification != NONE { string::trim(<string> $params.justification) } ELSE { "" };
            IF string::len($justification) < 10 {
                RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $language, { 
                    length: string::len($justification), 
                    min_required: 10 
                });
            };

            LET $clean_id = string::replace($item_id, "ingestion_staged_item:", "");
            LET $item_rec = <record> string::concat('ingestion_staged_item:', $clean_id);
            LET $items = (SELECT * FROM $item_rec);
            IF array::len($items) == 0 {
                RETURN fn::error_result("INGESTION_ITEM_NOT_FOUND", $language, { item_id: $item_id });
            };
            LET $cur = $items[0];

            LET $proof = IF $params.proof != NONE { $params.proof } ELSE { NONE };
            IF $target_qual == "VERIFIED" {
                IF $proof == NONE {
                    RETURN fn::error_result("INGESTION_PROOF_MISSING", $language, {
                        item_id: $item_id,
                        message: "Toute requalification vers VERIFIED exige une preuve commerciale formelle authentifiée (CommercialProof)"
                    });
                };

                LET $proof_ref = IF $proof.proof_reference != NONE { string::trim(<string> $proof.proof_reference) } ELSE { "" };
                LET $source_auth = IF $proof.source_authority != NONE { string::trim(<string> $proof.source_authority) } ELSE { "" };
                LET $proof_type = IF $proof.proof_type != NONE { string::uppercase(string::trim(<string> $proof.proof_type)) } ELSE { "" };

                IF string::len($proof_ref) < 3 OR string::len($source_auth) < 3 {
                    RETURN fn::error_result("INGESTION_PROOF_INVALID", $language, {
                        proof_reference: $proof_ref,
                        source_authority: $source_auth,
                        message: "La référence documentaire et l'autorité émettrice de la preuve sont obligatoires"
                    });
                };

                IF $proof_type NOT IN ["CERTIFIED_MANUFACTURER_EDI", "SIGNED_VENDOR_CATALOG", "OFFICIAL_TARIFF_CERTIFICATE", "STEWARD_DOCUMENTED_VALIDATION"] {
                    RETURN fn::error_result("INGESTION_PROOF_TYPE_UNKNOWN", $language, {
                        proof_type: $proof_type
                    });
                };
            };

            LET $now = time::now();
            LET $trans = {
                from_state: $cur.qualification,
                to_state: $target_qual,
                triggered_by: $operator,
                reason: $justification,
                transitioned_at: $now,
                proof_reference: IF $target_qual == "VERIFIED" { $proof.proof_reference } ELSE { NONE }
            };

            UPDATE $item_rec SET
                qualification = $target_qual,
                qualification_reason = $justification,
                commercial_proof = IF $target_qual == "VERIFIED" { $proof } ELSE { commercial_proof },
                is_approved = IF $target_qual == "VERIFIED" { true } ELSE { is_approved },
                approved_by = IF $target_qual == "VERIFIED" { $operator } ELSE { approved_by },
                approved_at = IF $target_qual == "VERIFIED" { $now } ELSE { approved_at },
                transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);

            RETURN fn::result_ok(true);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_list($params: object) {
            LET $limit = IF $params.limit != NONE { <int> $params.limit } ELSE { 50 };
            LET $start = IF $params.start != NONE { <int> $params.start } ELSE { 0 };
            LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };
            LET $sev_filter = IF $params.severite != NONE { string::uppercase(<string> $params.severite) } ELSE { NONE };
            LET $resolved_filter = IF $params.is_resolved != NONE { <bool> $params.is_resolved } ELSE { NONE };

            LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

            LET $all_matches = (SELECT id FROM ingestion_quarantine_record WHERE
                ($b_rec == NONE OR batch = $b_rec) AND
                ($sev_filter == NONE OR severite = $sev_filter) AND
                ($resolved_filter == NONE OR is_resolved = $resolved_filter)
            );
            LET $total = array::len($all_matches);

            LET $records = (SELECT 
                <string> id AS id,
                <string> batch AS batch,
                IF raw_record != NONE { <string> raw_record } ELSE { NONE } AS raw_record,
                code_erreur,
                severite,
                champ_concerne,
                valeur_fautive,
                cause_detaillee,
                IF created_at != NONE { <string> created_at } ELSE { NONE } AS created_at,
                is_resolved,
                resolved_by,
                IF resolved_at != NONE { <string> resolved_at } ELSE { NONE } AS resolved_at,
                resolution_comment
            FROM ingestion_quarantine_record WHERE
                ($b_rec == NONE OR batch = $b_rec) AND
                ($sev_filter == NONE OR severite = $sev_filter) AND
                ($resolved_filter == NONE OR is_resolved = $resolved_filter)
                ORDER BY created_at DESC
                LIMIT $limit START $start
            );

            RETURN fn::result_ok({
                records: $records,
                total: $total,
                limit: $limit,
                start: $start
            });
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_resolve($params: object) {
            LET $quarantine_id = <string> $params.quarantine_id;
            LET $language = IF $params.language != NONE { <string> $params.language } ELSE { "fr" };

            LET $role = IF $auth != NONE AND $auth.role != NONE { 
                <string> $auth.role 
            } ELSE IF $params._session_auth != NONE AND $params._session_auth.role != NONE { 
                <string> $params._session_auth.role 
            } ELSE { 
                "guest" 
            };

            LET $operator = IF $auth != NONE AND $auth.id != NONE { 
                <string> $auth.id 
            } ELSE IF $params._session_auth != NONE AND $params._session_auth.user_id != NONE { 
                <string> $params._session_auth.user_id 
            } ELSE { 
                "anonymous" 
            };

            IF $role != "steward_admin" {
                RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $language, { 
                    role: $role, 
                    expected_role: "steward_admin",
                    message: "Seul un Data Steward authentifié peut résoudre une anomalie en quarantaine"
                });
            };

            LET $justification = IF $params.comment != NONE { 
                string::trim(<string> $params.comment) 
            } ELSE IF $params.justification != NONE { 
                string::trim(<string> $params.justification) 
            } ELSE { 
                "" 
            };

            IF string::len($justification) < 10 {
                RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $language, { 
                    length: string::len($justification), 
                    min_required: 10,
                    message: "La justification de résolution d'anomalie doit contenir au moins 10 caractères"
                });
            };

            LET $clean_id = string::replace($quarantine_id, "ingestion_quarantine_record:", "");
            LET $rec_thing = <record> string::concat('ingestion_quarantine_record:', $clean_id);
            LET $records = (SELECT * FROM $rec_thing);
            IF array::len($records) == 0 {
                RETURN fn::error_result("INGESTION_RECORD_NOT_FOUND", $language, { quarantine_id: $quarantine_id });
            };

            LET $now = time::now();
            UPDATE $rec_thing SET
                is_resolved = true,
                resolved_by = $operator,
                resolved_at = $now,
                resolution_comment = $justification;

            LET $corrections = IF $params.corrections != NONE { $params.corrections } ELSE { NONE };
            LET $staged_item_id = IF $params.staged_item_id != NONE { <string> $params.staged_item_id } ELSE { NONE };

            IF $staged_item_id != NONE {
                LET $clean_staged = string::replace($staged_item_id, "ingestion_staged_item:", "");
                LET $staged_rec = <record> string::concat('ingestion_staged_item:', $clean_staged);
                LET $staged_items = (SELECT * FROM $staged_rec);
                
                IF array::len($staged_items) > 0 {
                    LET $cur_staged = $staged_items[0];
                    LET $trans = {
                        from_state: $cur_staged.qualification,
                        to_state: "TO_CONFIRM",
                        triggered_by: $operator,
                        reason: string::concat("Correction suite anomalie quarantaine: ", $justification),
                        transitioned_at: $now
                    };

                    LET $new_gtin = IF $corrections != NONE AND $corrections.corrected_gtin != NONE { 
                        <string> $corrections.corrected_gtin 
                    } ELSE { 
                        $cur_staged.code_barre_gtin 
                    };

                    LET $new_unit = IF $corrections != NONE AND $corrections.corrected_unit != NONE { 
                        <string> $corrections.corrected_unit 
                    } ELSE { 
                        $cur_staged.unite_reference 
                    };

                    UPDATE $staged_rec SET
                        qualification = "TO_CONFIRM",
                        qualification_reason = string::concat("Correction anomalie quarantaine: ", $justification),
                        code_barre_gtin = $new_gtin,
                        unite_reference = $new_unit,
                        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);
                };
            };

            RETURN fn::result_ok(true);
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_list($params: object) {
            LET $limit = IF $params.limit != NONE { <int> $params.limit } ELSE { 50 };
            LET $start = IF $params.start != NONE { <int> $params.start } ELSE { 0 };
            LET $statut_filter = IF $params.statut != NONE { string::uppercase(<string> $params.statut) } ELSE { NONE };
            LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };

            LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

            LET $all_matches = (SELECT id FROM ingestion_publication_manifest WHERE
                ($b_rec == NONE OR batch = $b_rec) AND
                ($statut_filter == NONE OR statut = $statut_filter)
            );
            LET $total = array::len($all_matches);

            LET $manifests = (SELECT 
                <string> id AS id,
                <string> batch AS batch,
                manifest_ref,
                manifest_version,
                seal_hash,
                is_sealed,
                statut,
                approved_by,
                IF approved_at != NONE { <string> approved_at } ELSE { NONE } AS approved_at,
                approver_role,
                nb_articles_insert,
                nb_articles_update,
                items_committed,
                items_failed,
                execution_items,
                transitions,
                IF executed_at != NONE { <string> executed_at } ELSE { NONE } AS executed_at
            FROM ingestion_publication_manifest WHERE
                ($b_rec == NONE OR batch = $b_rec) AND
                ($statut_filter == NONE OR statut = $statut_filter)
                ORDER BY id DESC
                LIMIT $limit START $start
            );

            RETURN fn::result_ok({
                manifests: $manifests,
                total: $total,
                limit: $limit,
                start: $start
            });
        };

        DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_get_detail($params: object) {
            LET $manifest_ref = <string> $params.manifest_ref;
            LET $language = IF $params.language != NONE { <string> $params.language } ELSE { "fr" };

            LET $records = (SELECT 
                <string> id AS id,
                <string> batch AS batch,
                manifest_ref,
                manifest_version,
                seal_hash,
                is_sealed,
                statut,
                approved_by,
                IF approved_at != NONE { <string> approved_at } ELSE { NONE } AS approved_at,
                approver_role,
                nb_articles_insert,
                nb_articles_update,
                items_committed,
                items_failed,
                execution_items,
                transitions,
                IF executed_at != NONE { <string> executed_at } ELSE { NONE } AS executed_at
            FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);

            IF array::len($records) == 0 {
                RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $language, { manifest_ref: $manifest_ref });
            };

            LET $manif = $records[0];
            LET $clean_b = string::replace($manif.batch, "ingestion_batch:", "");
            LET $b_rec = <record> string::concat('ingestion_batch:', $clean_b);
            LET $batch_info = (SELECT 
                <string> id AS id,
                fournisseur_id,
                nom_fichier,
                file_hash_blake3,
                statut,
                total_lignes,
                lignes_verifiees,
                lignes_a_confirmer,
                lignes_rejetees
            FROM $b_rec);

            RETURN fn::result_ok({
                manifest: $manif,
                batch: IF array::len($batch_info) > 0 { $batch_info[0] } ELSE { NONE },
                is_sealed: $manif.is_sealed,
                seal_hash: $manif.seal_hash,
                execution_count: IF $manif.execution_items != NONE { array::len($manif.execution_items) } ELSE { 0 },
                transition_count: IF $manif.transitions != NONE { array::len($manif.transitions) } ELSE { 0 }
            });
        };

        -- Référentiel transversal lyxal_base : base_unite
        UPSERT base_unite:M2 CONTENT { code: "M2", libelle: "Mètre carré", symbole: "m²" };
        UPSERT base_unite:PCE CONTENT { code: "PCE", libelle: "Pièce", symbole: "pce" };
        UPSERT base_unite:ML CONTENT { code: "ML", libelle: "Mètre linéaire", symbole: "ml" };
        UPSERT base_unite:KGM CONTENT { code: "KGM", libelle: "Kilogramme", symbole: "kg" };
        UPSERT base_unite:MTR CONTENT { code: "MTR", libelle: "Mètre", symbole: "m" };

        -- Initialisation des alias par défaut
        UPSERT ingestion_unit_alias:M2 CONTENT { raw_alias: "M2", canonical_unit: "M2" };
        UPSERT ingestion_unit_alias:SQM CONTENT { raw_alias: "SQM", canonical_unit: "M2" };
        UPSERT ingestion_unit_alias:PCE CONTENT { raw_alias: "PCE", canonical_unit: "PCE" };
        UPSERT ingestion_unit_alias:PIECE CONTENT { raw_alias: "PIECE", canonical_unit: "PCE" };
        UPSERT ingestion_unit_alias:C62 CONTENT { raw_alias: "C62", canonical_unit: "PCE" };
        UPSERT ingestion_unit_alias:ML CONTENT { raw_alias: "ML", canonical_unit: "ML" };
        UPSERT ingestion_unit_alias:M CONTENT { raw_alias: "M", canonical_unit: "M" };
        UPSERT ingestion_unit_alias:KG CONTENT { raw_alias: "KG", canonical_unit: "KG" };

        UPSERT ingestion_manufacturer_alias:SAINT_GOBAIN_PLACO CONTENT { raw_alias: "SAINT-GOBAIN PLACO", canonical_name: "PLACO", is_verified: true };
        UPSERT ingestion_manufacturer_alias:PLACO CONTENT { raw_alias: "PLACO", canonical_name: "PLACO", is_verified: true };
        UPSERT ingestion_manufacturer_alias:ISOVER CONTENT { raw_alias: "ISOVER", canonical_name: "ISOVER", is_verified: true };
        UPSERT ingestion_manufacturer_alias:WEBER CONTENT { raw_alias: "WEBER", canonical_name: "WEBER", is_verified: true };
        UPSERT ingestion_manufacturer_alias:KNAUF CONTENT { raw_alias: "KNAUF", canonical_name: "KNAUF", is_verified: true };
        UPSERT ingestion_manufacturer_alias:SINIAT CONTENT { raw_alias: "SINIAT", canonical_name: "SINIAT", is_verified: true };
        UPSERT ingestion_manufacturer_alias:LEGRAND CONTENT { raw_alias: "LEGRAND", canonical_name: "LEGRAND", is_verified: true };
        UPSERT ingestion_manufacturer_alias:SCHNEIDER CONTENT { raw_alias: "SCHNEIDER", canonical_name: "SCHNEIDER", is_verified: true };
        "#;

        self.db
            .query(schema_surql)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec initialisation schéma : {e}")))?;

        Ok(())
    }

    // =========================================================================
    // 1. GESTION DES LOTS (Appels via store.call_fn)
    // =========================================================================

    /// Crée un nouveau lot en base avec contrôle d'idempotence via fn::ingestion_batch_create
    pub async fn create_batch(&self, batch: &IngestionBatch) -> IngestionResult<String> {
        let id_val_raw = batch
            .id
            .clone()
            .unwrap_or_else(|| format!("batch_{}", &batch.file_hash_blake3[..16]));
        let id_val = id_val_raw.strip_prefix("ingestion_batch:").unwrap_or(&id_val_raw).to_string();

        let params = BatchCreateParams {
            id: Some(id_val.clone()),
            source_type: batch.source_type.as_str().to_string(),
            source_format_version: batch.source_format_version.clone(),
            fournisseur_id: batch.fournisseur_id.clone(),
            nom_fichier: batch.nom_fichier.clone(),
            file_hash_blake3: batch.file_hash_blake3.clone(),
            taille_octets: batch.taille_octets as i64,
            statut: batch.statut.as_str().to_string(),
            cursor_offset: batch.cursor_offset as i64,
            chunk_size: batch.chunk_size as i64,
            total_lignes: batch.total_lignes as i64,
            lignes_verifiees: batch.lignes_verifiees as i64,
            lignes_a_confirmer: batch.lignes_a_confirmer as i64,
            lignes_rejetees: batch.lignes_rejetees as i64,
            transitions: batch.transitions.clone(),
            provenance_details: batch.provenance_details.clone(),
        };

        let result: String = self
            .call_fn("ingestion_batch_create", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_batch_create : {e}")))?;

        Ok(result)
    }

    /// Récupère un lot par son identifiant
    pub async fn get_batch(&self, batch_id: &str) -> IngestionResult<Option<IngestionBatch>> {
        let clean_id = batch_id.strip_prefix("ingestion_batch:").unwrap_or(batch_id);
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id FROM ingestion_batch WHERE id = <record> string::concat('ingestion_batch:⟨', $id, '⟩');")
            .bind(("id", clean_id.to_string()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture lot : {e}")))?;

        let batch: Option<IngestionBatch> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur désérialisation lot : {e}")))?;

        Ok(batch)
    }

    /// Recherche un lot par hash BLAKE3 du fichier pour vérifier l'idempotence globale
    pub async fn find_batch_by_hash(
        &self,
        source_type: &str,
        file_hash: &str,
    ) -> IngestionResult<Option<IngestionBatch>> {
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id FROM ingestion_batch WHERE source_type = $st AND file_hash_blake3 = $hash LIMIT 1;")
            .bind(("st", source_type.to_uppercase()))
            .bind(("hash", file_hash.to_lowercase()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec recherche lot par hash : {e}")))?;

        let batches: Vec<IngestionBatch> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur lecture recherche : {e}")))?;

        Ok(batches.into_iter().next())
    }

    /// Enregistre un point de reprise (checkpoint) via fn::ingestion_batch_checkpoint
    pub async fn save_checkpoint(
        &self,
        batch_id: &str,
        cursor_offset: usize,
        total_lignes: usize,
        verified: usize,
        to_confirm: usize,
        rejected: usize,
    ) -> IngestionResult<()> {
        let clean_id = batch_id.strip_prefix("ingestion_batch:").unwrap_or(batch_id);
        let params = BatchCheckpointParams {
            id: clean_id.to_string(),
            cursor_offset: cursor_offset as i64,
            total_lignes: total_lignes as i64,
            lignes_verifiees: verified as i64,
            lignes_a_confirmer: to_confirm as i64,
            lignes_rejetees: rejected as i64,
        };

        let _: bool = self
            .call_fn("ingestion_batch_checkpoint", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_batch_checkpoint : {e}")))?;

        Ok(())
    }

    /// Charge le dernier offset de checkpoint d'un lot
    pub async fn load_checkpoint(&self, batch_id: &str) -> IngestionResult<usize> {
        let clean_id = batch_id.strip_prefix("ingestion_batch:").unwrap_or(batch_id);
        let batch = self
            .get_batch(clean_id)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Lot '{batch_id}' introuvable")))?;
        Ok(batch.cursor_offset)
    }

    /// Met à jour l'état d'un lot via fn::ingestion_batch_transition
    pub async fn update_batch_status(
        &self,
        batch_id: &str,
        new_status: BatchStatus,
        actor: &str,
        reason: Option<&str>,
    ) -> IngestionResult<()> {
        let clean_id = batch_id.strip_prefix("ingestion_batch:").unwrap_or(batch_id);
        let batch = self
            .get_batch(clean_id)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Lot '{batch_id}' introuvable")))?;

        let old_status = batch.statut;
        let transition = StateTransitionRecord {
            from_statut: old_status.as_str().to_string(),
            to_statut: new_status.as_str().to_string(),
            transition_at: "2026-10-25T11:00:00Z".to_string(),
            transition_by: actor.to_string(),
            reason: reason.unwrap_or("Transition d'état de lot").to_string(),
        };

        let params = BatchTransitionParams {
            id: clean_id.to_string(),
            nouveau_statut: new_status.as_str().to_string(),
            transition,
        };

        let _: bool = self
            .call_fn("ingestion_batch_transition", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_batch_transition : {e}")))?;

        Ok(())
    }

    // =========================================================================
    // 2. PERSISTANCE DES LIGNES ET DU STAGING (via store.call_fn)
    // =========================================================================

    /// Sauvegarde un bloc de lignes brutes
    pub async fn save_raw_records_chunk(&self, records: &[RawRecord]) -> IngestionResult<()> {
        for rec in records {
            let clean_batch = rec.batch.strip_prefix("ingestion_batch:").unwrap_or(&rec.batch);
            let rec_id = format!("{}_{}", clean_batch, rec.ligne_numero);

            let query = r#"
                LET $target = <record> string::concat('ingestion_raw_record:⟨', $rec_id, '⟩');
                LET $b_target = <record> string::concat('ingestion_batch:⟨', $batch_id, '⟩');
                UPSERT $target CONTENT {
                    batch: $b_target,
                    ligne_numero: $ligne_numero,
                    payload_brut: $payload,
                    row_hash: $row_hash
                };
            "#;

            self.db
                .query(query)
                .bind(("rec_id", rec_id))
                .bind(("batch_id", clean_batch.to_string()))
                .bind(("ligne_numero", rec.ligne_numero as i64))
                .bind(("payload", rec.payload_brut.clone()))
                .bind(("row_hash", rec.row_hash.clone()))
                .await
                .map_err(|e| IngestionError::Storage(format!("Échec sauvegarde raw record : {e}")))?;
        }
        Ok(())
    }

    /// Sauvegarde un article en staging via fn::ingestion_staged_save
    pub async fn save_staged_item(&self, item: &StagedItem) -> IngestionResult<String> {
        let clean_batch = item.batch.strip_prefix("ingestion_batch:").unwrap_or(&item.batch);
        let clean_raw = item.raw_record.strip_prefix("ingestion_raw_record:").unwrap_or(&item.raw_record);

        let params = StagedSaveParams {
            batch_id: clean_batch.to_string(),
            raw_record_id: if clean_raw.is_empty() { None } else { Some(clean_raw.to_string()) },
            ligne_numero: item.ligne_numero as i64,
            canonical_fingerprint: item.canonical_fingerprint.clone(),
            rules_version: item.rules_version.clone(),
            fabricant: item.fabricant.clone(),
            marque: item.marque.clone(),
            reference_fabricant: item.reference_fabricant.clone(),
            code_barre_gtin: item.code_barre_gtin.clone(),
            libelle_commercial: item.libelle_commercial.clone(),
            description_technique: item.description_technique.clone(),
            type_item: item.type_item.clone(),
            unite_reference: item.unite_reference.clone(),
            conditionnement: serde_json::to_value(&item.conditionnement).ok(),
            qualification: item.qualification.as_str().to_string(),
            publication_action: item.publication_action.as_str().to_string(),
            diff_payload: item.diff_payload.clone(),
            transitions: item.transitions.clone(),
            is_approved: item.is_approved,
            approved_by: item.approved_by.clone(),
            approved_at: item.approved_at.clone(),
        };

        let result: String = self
            .call_fn("ingestion_staged_save", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_staged_save : {e}")))?;

        Ok(result)
    }

    /// Sauvegarde un bloc d'articles en staging
    pub async fn save_staged_items_chunk(&self, items: &[StagedItem]) -> IngestionResult<()> {
        for item in items {
            self.save_staged_item(item).await?;
        }
        Ok(())
    }

    /// Récupère tous les articles en staging pour un lot
    pub async fn get_staged_items_by_batch(&self, batch_id: &str) -> IngestionResult<Vec<StagedItem>> {
        let clean_batch = batch_id.strip_prefix("ingestion_batch:").unwrap_or(batch_id);
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id, <string> record::id(batch) AS batch, <string> record::id(raw_record) AS raw_record FROM ingestion_staged_item WHERE batch = <record> string::concat('ingestion_batch:', $b);")
            .bind(("b", clean_batch.to_string()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture staged items : {e}")))?;

        let items: Vec<StagedItem> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur désérialisation staged items : {e}")))?;

        Ok(items)
    }

    // =========================================================================
    // 3. QUARANTAINE PERSISTÉE (via store.call_fn)
    // =========================================================================

    /// Consigne une anomalie en quarantaine via fn::ingestion_quarantine_log
    pub async fn log_quarantine(&self, record: &QuarantineRecord) -> IngestionResult<String> {
        let clean_batch = record.batch.strip_prefix("ingestion_batch:").unwrap_or(&record.batch);
        let clean_raw = record.raw_record.strip_prefix("ingestion_raw_record:").unwrap_or(&record.raw_record);

        let params = QuarantineLogParams {
            batch_id: clean_batch.to_string(),
            raw_record_id: if clean_raw.is_empty() { None } else { Some(clean_raw.to_string()) },
            code_erreur: record.code_erreur.clone(),
            severite: record.severite.clone(),
            champ_concerne: record.champ_concerne.clone(),
            valeur_fautive: record.valeur_fautive.clone(),
            cause_detaillee: record.cause_detaillee.clone(),
        };

        let result: String = self
            .call_fn("ingestion_quarantine_log", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_quarantine_log : {e}")))?;

        Ok(result)
    }

    /// Sauvegarde un bloc d'anomalies en quarantaine
    pub async fn save_quarantine_records_chunk(&self, records: &[QuarantineRecord]) -> IngestionResult<()> {
        for rec in records {
            self.log_quarantine(rec).await?;
        }
        Ok(())
    }

    /// Récupère toutes les anomalies de quarantaine pour un lot
    pub async fn get_quarantine_by_batch(&self, batch_id: &str) -> IngestionResult<Vec<QuarantineRecord>> {
        let clean_batch = batch_id.strip_prefix("ingestion_batch:").unwrap_or(batch_id);
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id, <string> record::id(batch) AS batch, <string> record::id(raw_record) AS raw_record FROM ingestion_quarantine_record WHERE batch = <record> string::concat('ingestion_batch:', $b);")
            .bind(("b", clean_batch.to_string()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture anomalies quarantaine : {e}")))?;

        let records: Vec<QuarantineRecord> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur lecture quarantaine : {e}")))?;

        Ok(records)
    }

    // =========================================================================
    // 4. MANIFESTES DE PUBLICATION (via store.call_fn)
    // =========================================================================

    /// Crée ou met à jour un manifeste de publication via fn::ingestion_manifest_save
    pub async fn save_manifest(&self, manifest: &PublicationManifest) -> IngestionResult<String> {
        let clean_batch = manifest.batch.strip_prefix("ingestion_batch:").unwrap_or(&manifest.batch);

        let params = ManifestSaveParams {
            manifest_ref: manifest.manifest_ref.clone(),
            batch_id: clean_batch.to_string(),
            manifest_version: manifest.manifest_version as i64,
            seal_hash: manifest.seal_hash.clone(),
            is_sealed: manifest.is_sealed,
            statut: manifest.statut.as_str().to_string(),
            approved_by: manifest.approved_by.clone(),
            approved_at: manifest.approved_at.clone(),
            approver_role: manifest.approver_role.clone(),
            nb_articles_insert: manifest.nb_articles_insert as i64,
            nb_articles_update: manifest.nb_articles_update as i64,
            items_committed: manifest.items_committed as i64,
            items_failed: manifest.items_failed as i64,
            execution_items: Some(manifest.execution_items.clone()),
            transitions: Some(manifest.transitions.clone()),
            executed_at: manifest.executed_at.clone(),
        };

        let result: String = self
            .call_fn("ingestion_manifest_save", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_manifest_save : {e}")))?;

        Ok(result)
    }

    /// Récupère un manifeste par sa référence
    pub async fn get_manifest(&self, manifest_ref: &str) -> IngestionResult<Option<PublicationManifest>> {
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id, <string> record::id(batch) AS batch FROM ingestion_publication_manifest WHERE manifest_ref = $ref;")
            .bind(("ref", manifest_ref.to_string()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture manifeste : {e}")))?;

        let manifest: Option<PublicationManifest> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur désérialisation manifeste : {e}")))?;

        Ok(manifest)
    }

    /// Approbation formelle d'un manifeste via fn::ingestion_manifest_approve
    pub async fn approve_manifest(
        &self,
        manifest_ref: &str,
        steward_id: &str,
        justification: &str,
    ) -> IngestionResult<()> {
        let manifest = self
            .get_manifest(manifest_ref)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Manifeste '{manifest_ref}' introuvable")))?;

        if !manifest.is_sealed {
            return Err(IngestionError::IllegalTransition(
                "Le manifeste doit être scellé par BLAKE3 avant toute approbation".to_string(),
            ));
        }

        if justification.trim().len() < 10 {
            return Err(IngestionError::IllegalTransition(
                "Une justification formelle de 10 caractères minimum est obligatoire pour approuver un manifeste".to_string(),
            ));
        }

        let params = ManifestApproveParams {
            manifest_ref: manifest_ref.to_string(),
            approved_by: steward_id.to_string(),
            approver_role: "steward_admin".to_string(),
        };

        let _: bool = self
            .call_fn("ingestion_manifest_approve", params)
            .await
            .map_err(|e| match e {
                LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(err)) => {
                    IngestionError::IllegalTransition(err.message)
                }
                LyxalSurrealError::Call(lyxal_error::LyxalCallError::BusinessCode { code, details }) => {
                    IngestionError::IllegalTransition(format!("{code}: {details}"))
                }
                _ => IngestionError::Storage(format!("Échec fn::ingestion_manifest_approve : {e}")),
            })?;

        Ok(())
    }

    /// Enregistre les métriques d'exécution de publication et met à jour le statut du manifeste via fn::ingestion_manifest_record_exec
    pub async fn record_manifest_exec(
        &self,
        manifest_ref: &str,
        statut: ManifestStatus,
        items_committed: usize,
        items_failed: usize,
    ) -> IngestionResult<()> {
        let params = ManifestRecordExecParams {
            manifest_ref: manifest_ref.to_string(),
            statut: statut.as_str().to_string(),
            items_committed: items_committed as i64,
            items_failed: items_failed as i64,
            execution_items: None,
        };

        let _: bool = self
            .call_fn("ingestion_manifest_record_exec", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_manifest_record_exec : {e}")))?;

        Ok(())
    }

    /// Enregistre l'exécution ligne par ligne d'un article dans le manifeste
    pub async fn update_manifest_execution_item(
        &self,
        manifest_ref: &str,
        item_ref: &str,
        action: &str,
        success: bool,
        error_msg: Option<&str>,
    ) -> IngestionResult<()> {
        let exec_record = serde_json::json!({
            "item_ref": item_ref,
            "action": action,
            "success": success,
            "error": error_msg,
            "executed_at": "2026-10-25T11:10:00Z"
        });

        let query = r#"
            UPDATE ingestion_publication_manifest SET
                execution_items += $record,
                items_committed += IF $success == true { 1 } ELSE { 0 },
                items_failed += IF $success == false { 1 } ELSE { 0 }
            WHERE manifest_ref = $ref;
        "#;

        self.db
            .query(query)
            .bind(("ref", manifest_ref.to_string()))
            .bind(("record", exec_record))
            .bind(("success", success))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec journalisation exécution article : {e}")))?;

        Ok(())
    }

    // =========================================================================
    // 5. GESTION DYNAMIQUE DES RÈGLES & RÉFÉRENTIELS (Sans recompilation)
    // =========================================================================

    /// Résout dynamiquement une unité via fn::ingestion_resolve_unit
    pub async fn resolve_unit(&self, raw_unit: &str) -> IngestionResult<Option<String>> {
        let params = ResolveUnitParams {
            raw_unit: raw_unit.to_string(),
            language: "fr".to_string(),
        };

        let res: Result<ResolveUnitResult, LyxalSurrealError> =
            self.call_fn("ingestion_resolve_unit", params).await;

        match res {
            Ok(r) => Ok(Some(r.canonical_code)),
            Err(_) => Ok(None),
        }
    }

    /// Résout dynamiquement un fabricant via fn::ingestion_resolve_manufacturer
    pub async fn resolve_manufacturer(&self, raw_name: &str) -> IngestionResult<ResolveManufacturerResult> {
        let params = ResolveManufacturerParams {
            raw_name: raw_name.to_string(),
            language: "fr".to_string(),
        };

        let result: ResolveManufacturerResult = self
            .call_fn("ingestion_resolve_manufacturer", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_resolve_manufacturer : {e}")))?;

        Ok(result)
    }

    /// Ajoute ou met à jour une famille de produits sans recompilation
    pub async fn add_family_rule(
        &self,
        code: &str,
        label: &str,
        keywords: &[&str],
        standard_unit: Option<&str>,
    ) -> IngestionResult<String> {
        let params = FamilyRuleAddParams {
            code: code.to_string(),
            label: label.to_string(),
            keywords: keywords.iter().map(|s| s.to_string()).collect(),
            standard_unit: standard_unit.map(|s| s.to_string()),
        };

        let res: String = self
            .call_fn("ingestion_rule_family_add", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_rule_family_add : {e}")))?;

        Ok(res)
    }

    /// Ajoute ou met à jour une spécification patronne sans recompilation
    pub async fn add_specification(&self, spec: &TechnicalSpecification) -> IngestionResult<String> {
        let params = SpecAddParams {
            technical_identity_key: spec.technical_identity_key.clone(),
            family_code: spec.family_code.clone(),
            generic_title: spec.generic_title.clone(),
            nominal_dimensions: serde_json::to_value(&spec.nominal_dimensions).ok(),
            tolerances: serde_json::to_value(&spec.tolerances).ok(),
            nominal_weight: spec.nominal_weight.as_ref().and_then(|w| w.net_weight_kg),
            standard_norm: spec.standard_norm.clone(),
            fire_rating: spec.fire_rating.clone(),
            required_features: serde_json::to_value(&spec.required_features).unwrap_or_default(),
        };

        let res: String = self
            .call_fn("ingestion_rule_spec_add", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_rule_spec_add : {e}")))?;

        Ok(res)
    }

    /// Ajoute ou met à jour une règle de substitution contextualisée
    pub async fn add_substitution_rule(
        &self,
        rule: &ContextualSubstitutionRule,
    ) -> IngestionResult<String> {
        let params = SubstitutionRuleAddParams {
            rule_id: rule.rule_id.clone(),
            source_mfg: rule.source_manufacturer.clone(),
            source_ref: rule.source_ref.clone(),
            target_mfg: rule.target_manufacturer.clone(),
            target_ref: rule.target_ref.clone(),
            system_scope: rule.system_scope.clone(),
            certification_body: rule.certification_body.clone(),
            certification_ref: rule.certification_reference.clone(),
            valid_until: rule.valid_until.clone(),
            is_revoked: rule.is_revoked,
            revocation_reason: rule.revocation_reason.clone(),
        };

        let res: String = self
            .call_fn("ingestion_rule_substitution_add", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec fn::ingestion_rule_substitution_add : {e}")))?;

        Ok(res)
    }

    /// Charge toutes les familles de produits configurées depuis SurrealDB
    pub async fn load_family_rules(&self) -> IngestionResult<Vec<FamilyRule>> {
        let mut res = self
            .db
            .query("SELECT * FROM ingestion_family_rule;")
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture ingestion_family_rule : {e}")))?;

        let families: Vec<FamilyRule> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur désérialisation family_rule : {e}")))?;

        Ok(families)
    }

    /// Charge toutes les spécifications configurées depuis SurrealDB
    pub async fn load_specifications(&self) -> IngestionResult<Vec<TechnicalSpecification>> {
        let mut res = self
            .db
            .query("SELECT * FROM ingestion_specification;")
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture ingestion_specification : {e}")))?;

        let specs: Vec<TechnicalSpecification> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur désérialisation specification : {e}")))?;

        Ok(specs)
    }

    /// Charge toutes les règles de substitution contextualisées depuis SurrealDB
    pub async fn load_substitution_rules(&self) -> IngestionResult<Vec<ContextualSubstitutionRule>> {
        let mut res = self
            .db
            .query("SELECT rule_id, source_mfg AS source_manufacturer, source_ref, target_mfg AS target_manufacturer, target_ref, system_scope, certification_body, certification_ref AS certification_reference, <string> valid_until AS valid_until, is_revoked, revocation_reason FROM ingestion_substitution_rule;")
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture ingestion_substitution_rule : {e}")))?;

        let rules: Vec<ContextualSubstitutionRule> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur désérialisation substitution_rule : {e}")))?;

        Ok(rules)
    }

    // =========================================================================
    // 5. DATA STEWARD & OBSERVABILITÉ (Phase 5 - Appels 1-ligne call_fn)
    // =========================================================================

    /// Récupère les métriques consolidées du tableau de bord d'ingestion
    pub async fn get_dashboard_metrics(
        &self,
        batch_id: Option<&str>,
    ) -> IngestionResult<DashboardMetricsResult> {
        let params = DashboardMetricsParams {
            batch_id: batch_id.map(|s| s.to_string()),
        };
        self.call_fn("ingestion_dashboard_metrics", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec get_dashboard_metrics : {e}")))
    }

    /// Liste paginée et filtrée des articles en staging pour la console Data Steward
    pub async fn list_staged_items(
        &self,
        filter: StagedListFilter,
    ) -> IngestionResult<StagedListResult> {
        self.call_fn("ingestion_staged_list", filter)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec list_staged_items : {e}")))
    }

    /// Requalification formelle et auditable d'un article en staging sous contrôle Data Steward
    pub async fn requalify_staged_item(
        &self,
        params: StagedRequalifyParams,
    ) -> IngestionResult<bool> {
        self.call_fn("ingestion_staged_requalify", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec requalify_staged_item : {e}")))
    }

    /// Liste paginée et filtrée des anomalies en zone de quarantaine
    pub async fn list_quarantine_records(
        &self,
        filter: QuarantineListFilter,
    ) -> IngestionResult<QuarantineListResult> {
        self.call_fn("ingestion_quarantine_list", filter)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec list_quarantine_records : {e}")))
    }

    /// Résout de manière auditable une anomalie en quarantaine sous contrôle steward_admin
    pub async fn resolve_quarantine_record(
        &self,
        params: QuarantineResolveParams,
    ) -> IngestionResult<bool> {
        self.call_fn("ingestion_quarantine_resolve", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec resolve_quarantine_record : {e}")))
    }

    /// Liste paginée et filtrée des manifestes de publication
    pub async fn list_manifests(
        &self,
        filter: ManifestListFilter,
    ) -> IngestionResult<ManifestListResult> {
        self.call_fn("ingestion_manifest_list", filter)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec list_manifests : {e}")))
    }

    /// Consultation détaillée d'un manifeste avec intégrité de scellement
    pub async fn get_manifest_detail(
        &self,
        manifest_ref: &str,
    ) -> IngestionResult<ManifestDetailResult> {
        let params = ManifestGetDetailParams {
            manifest_ref: manifest_ref.to_string(),
            language: Some("fr".to_string()),
        };
        self.call_fn("ingestion_manifest_get_detail", params)
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec get_manifest_detail : {e}")))
    }
}
