//! Store SurrealDB du pipeline d'ingestion.
//!
//! Chaque opération appelle une fonction publique `fn::ingestion_*` par
//! [`LyxalSurrealCall::call_fn`] : validation des entrées, écritures, transitions d'état et
//! contrôles d'identité vivent dans le SurrealQL du module ; le Rust ne construit aucune requête.
//! Une erreur métier (`fn::error_result`) remonte avec son code dans
//! [`IngestionError::Surreal`].

use lyxal_surreal::{Datetime, LyxalSurrealCall, LyxalSurrealError, SurrealValue};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::adapters::RawRecordDto;
use crate::error::{IngestionError, IngestionResult};
use crate::normalization::{BlockReferentials, ResolvedManufacturer};

/// Taille maximale d'un appel de résolution (`fn::ingestion_resolve_units` / `_manufacturers`).
const RESOLVE_CHUNK: usize = 500;
use crate::models::{IngestionBatch, PublicationManifest, QuarantineRecord, RawRecord, StagedItem};
use crate::rules::{ContextualSubstitutionRule, TechnicalSpecification};
use crate::types::{
    BatchStatus, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat,
};

/// Taille des pages lues pour charger tous les articles ou anomalies d'un lot.
const PAGE_SIZE: i64 = 1000;

/// Identifiant court d'un enregistrement (`table:clé` ou `clé`).
fn key<'a>(id: &'a str, table: &str) -> &'a str {
    id.strip_prefix(table)
        .and_then(|rest| rest.strip_prefix(':'))
        .unwrap_or(id)
}

/// Indique si l'erreur est l'erreur métier `code`.
fn is_business(err: &LyxalSurrealError, code: &str) -> bool {
    matches!(err, LyxalSurrealError::Call(call) if call.is_business_code(code))
}

// =============================================================================
// PARAMÈTRES PUBLICS
// =============================================================================

/// Nouveau lot d'ingestion (`fn::ingestion_batch_create`), créé à l'état `RECEIVED`.
#[derive(Debug, Clone, SurrealValue)]
pub struct NewBatch {
    /// Identifiant choisi par l'appelant ; généré (UUID v7) si absent.
    pub id: Option<String>,
    pub source_type: SourceFormat,
    pub source_format_version: String,
    pub fournisseur_id: String,
    pub nom_fichier: String,
    /// Empreinte BLAKE3 (64 caractères hexadécimaux) du fichier : clé d'idempotence.
    pub file_hash_blake3: String,
    pub taille_octets: i64,
    pub chunk_size: i64,
    pub provenance_details: serde_json::Value,
}

/// Manifeste brouillon ou scellé (`fn::ingestion_manifest_save`).
#[derive(Debug, Clone, SurrealValue)]
pub struct ManifestDraft {
    pub manifest_ref: String,
    pub batch_id: String,
    pub manifest_version: i64,
    /// Sceau BLAKE3 des empreintes canoniques des articles du lot.
    pub seal_hash: String,
    /// `Draft` ou `Sealed` ; approbation et exécution ont leurs propres fonctions.
    pub statut: ManifestStatus,
    pub nb_articles_insert: i64,
    pub nb_articles_update: i64,
}

// =============================================================================
// PARAMÈTRES INTERNES
// =============================================================================

#[derive(SurrealValue)]
struct IdParams {
    id: String,
}

#[derive(SurrealValue)]
struct BatchCheckpointParams {
    id: String,
    cursor_offset: i64,
    total_lignes: i64,
    lignes_verifiees: i64,
    lignes_a_confirmer: i64,
    lignes_rejetees: i64,
}

#[derive(SurrealValue)]
struct BatchTransitionParams {
    id: String,
    nouveau_statut: BatchStatus,
    reason: String,
    error_code: Option<String>,
}

#[derive(SurrealValue)]
struct RawRecordParams {
    ligne_numero: i64,
    row_hash: String,
    payload_brut: serde_json::Value,
}

#[derive(SurrealValue)]
struct RawRecordsSaveParams {
    batch_id: String,
    records: Vec<RawRecordParams>,
}

#[derive(SurrealValue)]
struct StagedItemParams {
    ligne_numero: i64,
    canonical_fingerprint: String,
    fabricant: String,
    marque: Option<String>,
    reference_fabricant: String,
    code_barre_gtin: Option<String>,
    libelle_commercial: String,
    description_technique: Option<String>,
    type_item: String,
    unite_reference: Option<String>,
    conditionnement: PackagingDetails,
    qualification: ItemQualification,
    qualification_reason: Option<String>,
    commercial_proof: Option<crate::proof::CommercialProof>,
    publication_action: PublicationAction,
    diff_payload: Option<serde_json::Value>,
}

impl From<&StagedItem> for StagedItemParams {
    fn from(item: &StagedItem) -> Self {
        Self {
            ligne_numero: item.ligne_numero as i64,
            canonical_fingerprint: item.canonical_fingerprint.clone(),
            fabricant: item.fabricant.clone(),
            marque: item.marque.clone(),
            reference_fabricant: item.reference_fabricant.clone(),
            code_barre_gtin: item.code_barre_gtin.clone(),
            libelle_commercial: item.libelle_commercial.clone(),
            description_technique: item.description_technique.clone(),
            type_item: item.type_item.clone(),
            unite_reference: item.unite_reference.clone(),
            conditionnement: item.conditionnement.clone(),
            qualification: item.qualification,
            qualification_reason: item.qualification_reason.clone(),
            commercial_proof: item.commercial_proof.clone(),
            publication_action: item.publication_action,
            diff_payload: item.diff_payload.clone(),
        }
    }
}

#[derive(SurrealValue)]
struct StagedSaveParams {
    batch_id: String,
    rules_version: String,
    items: Vec<StagedItemParams>,
}

/// Résultat d'un article de `fn::ingestion_staged_save`.
#[derive(SurrealValue)]
struct StagedSaveOutcome {
    ok: bool,
    id: Option<String>,
    error: Option<lyxal_error::LyxalError>,
}

#[derive(SurrealValue)]
struct QuarantineLogParams {
    batch_id: String,
    ligne_numero: i64,
    code_erreur: String,
    severite: String,
    champ_concerne: String,
    valeur_fautive: Option<serde_json::Value>,
    cause_detaillee: String,
}

#[derive(SurrealValue)]
struct ManifestRefParams {
    manifest_ref: String,
}

#[derive(SurrealValue)]
struct ManifestApproveParams {
    manifest_ref: String,
    justification: String,
}

#[derive(SurrealValue)]
struct ManifestRecordExecParams {
    manifest_ref: String,
    statut: ManifestStatus,
    items_committed: i64,
    items_failed: i64,
}

#[derive(SurrealValue)]
struct ManifestExecutionItemParams {
    manifest_ref: String,
    item_ref: String,
    action: PublicationAction,
    success: bool,
    error: Option<String>,
}

#[derive(SurrealValue)]
struct ResolveUnitsParams {
    raw_units: Vec<String>,
}

#[derive(SurrealValue)]
struct ResolveManufacturersParams {
    raw_names: Vec<String>,
}

#[derive(SurrealValue)]
struct FamilyRuleAddParams {
    code: String,
    label: String,
    keywords: Vec<String>,
    standard_unit: Option<String>,
}

#[derive(SurrealValue)]
struct SpecAddParams {
    technical_identity_key: String,
    family_code: String,
    generic_title: String,
    nominal_dimensions: Option<crate::normalization::dimensions::CanonicalDimensions>,
    tolerances: Option<crate::rules::SpecificationTolerances>,
    nominal_weight: Option<f64>,
    standard_norm: Option<String>,
    fire_rating: Option<String>,
    required_features: std::collections::HashMap<String, String>,
}

#[derive(SurrealValue)]
struct SubstitutionRuleAddParams {
    rule_id: String,
    source_mfg: String,
    source_ref: String,
    target_mfg: String,
    target_ref: String,
    system_scope: String,
    certification_body: String,
    certification_ref: String,
    valid_until: Datetime,
    is_revoked: bool,
    revocation_reason: Option<String>,
}

#[derive(SurrealValue)]
struct DashboardMetricsParams {
    batch_id: Option<String>,
}

// =============================================================================
// RÉSULTATS
// =============================================================================

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct DashboardMetricsResult {
    pub batches: BatchesMetrics,
    pub items: ItemsMetrics,
    pub quarantine: QuarantineMetrics,
    pub manifests: ManifestsMetrics,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct BatchesMetrics {
    pub total: i64,
    pub active: i64,
    pub staged: i64,
    pub published: i64,
    pub failed: i64,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct ItemsMetrics {
    pub total: i64,
    pub verified: i64,
    pub to_confirm: i64,
    pub rejected: i64,
    pub approved: i64,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct QuarantineMetrics {
    pub total: i64,
    pub critical: i64,
    pub pending: i64,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct ManifestsMetrics {
    pub total: i64,
    pub sealed: i64,
    pub approved: i64,
    pub committed: i64,
}

/// Filtre de `fn::ingestion_staged_list`.
#[derive(Default, Debug, Clone, SurrealValue)]
pub struct StagedListFilter {
    pub batch_id: Option<String>,
    pub qualification: Option<ItemQualification>,
    pub fabricant: Option<String>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Debug, Clone, SurrealValue)]
pub struct StagedListResult {
    pub items: Vec<StagedItem>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

/// Paramètres de `fn::ingestion_staged_requalify` (identité lue dans la session).
#[derive(Debug, Clone, SurrealValue)]
pub struct StagedRequalifyParams {
    pub item_id: String,
    pub new_qualification: ItemQualification,
    pub justification: String,
    pub proof: Option<crate::proof::CommercialProof>,
    pub language: Option<String>,
}

/// Filtre de `fn::ingestion_quarantine_list`.
#[derive(Default, Debug, Clone, SurrealValue)]
pub struct QuarantineListFilter {
    pub batch_id: Option<String>,
    pub severite: Option<String>,
    pub is_resolved: Option<bool>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Debug, Clone, SurrealValue)]
pub struct QuarantineListResult {
    pub records: Vec<QuarantineRecord>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

/// Corrections appliquées à l'article lié lors d'une résolution de quarantaine.
#[derive(Default, Debug, Clone, SurrealValue)]
pub struct QuarantineCorrections {
    pub corrected_gtin: Option<String>,
    pub corrected_unit: Option<String>,
}

/// Paramètres de `fn::ingestion_quarantine_resolve` (identité lue dans la session).
#[derive(Debug, Clone, SurrealValue)]
pub struct QuarantineResolveParams {
    pub quarantine_id: String,
    pub comment: String,
    pub staged_item_id: Option<String>,
    pub corrections: Option<QuarantineCorrections>,
    pub language: Option<String>,
}

/// Filtre de `fn::ingestion_manifest_list`.
#[derive(Default, Debug, Clone, SurrealValue)]
pub struct ManifestListFilter {
    pub batch_id: Option<String>,
    pub statut: Option<ManifestStatus>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Debug, Clone, SurrealValue)]
pub struct ManifestListResult {
    pub manifests: Vec<PublicationManifest>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Debug, Clone, SurrealValue)]
pub struct ManifestDetailResult {
    pub manifest: PublicationManifest,
    pub batch: Option<IngestionBatch>,
    pub is_sealed: bool,
    pub seal_hash: String,
    pub execution_count: i64,
    pub transition_count: i64,
}

// =============================================================================
// STORE
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
    /// Initialise le store avec une instance `Surreal<Any>` existante.
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db: Arc::new(db) }
    }

    /// Client SurrealDB sous-jacent.
    pub fn client(&self) -> &Surreal<Any> {
        &self.db
    }

    // --- Lots ---------------------------------------------------------------

    /// Crée un lot à l'état `RECEIVED` ; un fichier déjà reçu renvoie `INGESTION_BATCH_DUPLICATE`.
    pub async fn create_batch(&self, batch: &NewBatch) -> IngestionResult<String> {
        Ok(self
            .call_fn("ingestion_batch_create", batch.clone())
            .await?)
    }

    /// Lit un lot ; `None` s'il n'existe pas.
    pub async fn get_batch(&self, batch_id: &str) -> IngestionResult<Option<IngestionBatch>> {
        let params = IdParams {
            id: key(batch_id, "ingestion_batch").to_string(),
        };
        match self.call_fn("ingestion_batch_get", params).await {
            Ok(batch) => Ok(Some(batch)),
            Err(e) if is_business(&e, "INGESTION_BATCH_NOT_FOUND") => Ok(None),
            Err(e) => Err(e.into()),
        }
    }

    /// Enregistre un point de reprise du lot.
    pub async fn save_checkpoint(
        &self,
        batch_id: &str,
        cursor_offset: usize,
        total_lignes: usize,
        verified: usize,
        to_confirm: usize,
        rejected: usize,
    ) -> IngestionResult<()> {
        let params = BatchCheckpointParams {
            id: key(batch_id, "ingestion_batch").to_string(),
            cursor_offset: cursor_offset as i64,
            total_lignes: total_lignes as i64,
            lignes_verifiees: verified as i64,
            lignes_a_confirmer: to_confirm as i64,
            lignes_rejetees: rejected as i64,
        };
        let _: bool = self.call_fn("ingestion_batch_checkpoint", params).await?;
        Ok(())
    }

    /// Dernier offset enregistré d'un lot.
    pub async fn load_checkpoint(&self, batch_id: &str) -> IngestionResult<usize> {
        let batch = self
            .get_batch(batch_id)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Lot '{batch_id}' introuvable")))?;
        Ok(batch.cursor_offset)
    }

    /// Fait passer un lot dans un nouvel état, hors échec (voir [`Self::fail_batch`]) ; la
    /// transition est journalisée par SurrealQL au nom de l'identité de la session, et le passage
    /// à `STAGED` émet `ingestion.batch.staged` dans la même transaction.
    pub async fn update_batch_status(
        &self,
        batch_id: &str,
        new_status: BatchStatus,
        reason: &str,
    ) -> IngestionResult<()> {
        self.transition_batch(batch_id, new_status, reason, None)
            .await
    }

    /// Fait passer un lot en `FAILED` avec le code de l'échec ; la base émet
    /// `ingestion.batch.failed` dans la même transaction.
    pub async fn fail_batch(
        &self,
        batch_id: &str,
        error_code: &str,
        reason: &str,
    ) -> IngestionResult<()> {
        self.transition_batch(batch_id, BatchStatus::Failed, reason, Some(error_code))
            .await
    }

    async fn transition_batch(
        &self,
        batch_id: &str,
        new_status: BatchStatus,
        reason: &str,
        error_code: Option<&str>,
    ) -> IngestionResult<()> {
        let params = BatchTransitionParams {
            id: key(batch_id, "ingestion_batch").to_string(),
            nouveau_statut: new_status,
            reason: reason.to_string(),
            error_code: error_code.map(str::to_string),
        };
        let _: bool = self.call_fn("ingestion_batch_transition", params).await?;
        Ok(())
    }

    // --- Lignes brutes et staging -----------------------------------------

    /// Enregistre un bloc de lignes brutes ; une ligne déjà présente est conservée.
    /// Renvoie le nombre de lignes créées.
    pub async fn save_raw_records_chunk(
        &self,
        batch_id: &str,
        records: &[RawRecord],
    ) -> IngestionResult<usize> {
        let params = RawRecordsSaveParams {
            batch_id: key(batch_id, "ingestion_batch").to_string(),
            records: records
                .iter()
                .map(|r| RawRecordParams {
                    ligne_numero: r.ligne_numero as i64,
                    row_hash: r.row_hash.clone(),
                    payload_brut: r.payload_brut.clone(),
                })
                .collect(),
        };
        let created: i64 = self.call_fn("ingestion_raw_records_save", params).await?;
        Ok(created as usize)
    }

    /// Enregistre un article en staging ; un code-barres invalide renvoie
    /// `INGESTION_GTIN_INVALID` (clé GS1 contrôlée par `lyxal_core`).
    pub async fn save_staged_item(&self, item: &StagedItem) -> IngestionResult<String> {
        self.save_staged_items_chunk(std::slice::from_ref(item))
            .await?
            .pop()
            .unwrap_or_else(|| {
                Err(IngestionError::Storage(
                    "fn::ingestion_staged_save : aucun résultat".to_string(),
                ))
            })
    }

    /// Enregistre en une requête un bloc d'articles d'un même lot ; renvoie, dans l'ordre,
    /// l'identifiant de chaque article ou son erreur métier (code-barres invalide, champ
    /// manquant), que le worker consigne en quarantaine.
    pub async fn save_staged_items_chunk(
        &self,
        items: &[StagedItem],
    ) -> IngestionResult<Vec<IngestionResult<String>>> {
        let Some(first) = items.first() else {
            return Ok(Vec::new());
        };
        if let Some(other) = items
            .iter()
            .find(|i| i.batch != first.batch || i.rules_version != first.rules_version)
        {
            return Err(IngestionError::Validation(format!(
                "Un bloc d'articles appartient à un seul lot et une seule version de règles (ligne {})",
                other.ligne_numero
            )));
        }
        let params = StagedSaveParams {
            batch_id: key(&first.batch, "ingestion_batch").to_string(),
            rules_version: first.rules_version.clone(),
            items: items.iter().map(StagedItemParams::from).collect(),
        };
        let outcomes: Vec<StagedSaveOutcome> =
            self.call_fn("ingestion_staged_save", params).await?;
        if outcomes.len() != items.len() {
            return Err(IngestionError::Storage(format!(
                "fn::ingestion_staged_save : {} résultats pour {} articles",
                outcomes.len(),
                items.len()
            )));
        }
        Ok(outcomes
            .into_iter()
            .map(|outcome| match (outcome.ok, outcome.id, outcome.error) {
                (true, Some(id), _) => Ok(id),
                (false, _, Some(error)) => Err(IngestionError::from(LyxalSurrealError::Call(
                    lyxal_error::LyxalCallError::Business(error),
                ))),
                _ => Err(IngestionError::from(LyxalSurrealError::Call(
                    lyxal_error::LyxalCallError::InvalidContract {
                        function: "fn::ingestion_staged_save",
                    },
                ))),
            })
            .collect())
    }

    /// Tous les articles en staging d'un lot, par pages.
    pub async fn get_staged_items_by_batch(
        &self,
        batch_id: &str,
    ) -> IngestionResult<Vec<StagedItem>> {
        let mut items = Vec::new();
        loop {
            let page = self
                .list_staged_items(StagedListFilter {
                    batch_id: Some(key(batch_id, "ingestion_batch").to_string()),
                    limit: Some(PAGE_SIZE),
                    start: Some(items.len() as i64),
                    ..Default::default()
                })
                .await?;
            let received = page.items.len();
            items.extend(page.items);
            if received == 0 || items.len() as i64 >= page.total {
                return Ok(items);
            }
        }
    }

    // --- Quarantaine --------------------------------------------------------

    /// Consigne une anomalie en quarantaine.
    pub async fn log_quarantine(&self, record: &QuarantineRecord) -> IngestionResult<String> {
        let params = QuarantineLogParams {
            batch_id: key(&record.batch, "ingestion_batch").to_string(),
            ligne_numero: record.ligne_numero as i64,
            code_erreur: record.code_erreur.clone(),
            severite: record.severite.clone(),
            champ_concerne: record.champ_concerne.clone(),
            valeur_fautive: record.valeur_fautive.clone(),
            cause_detaillee: record.cause_detaillee.clone(),
        };
        Ok(self.call_fn("ingestion_quarantine_log", params).await?)
    }

    /// Toutes les anomalies d'un lot, par pages.
    pub async fn get_quarantine_by_batch(
        &self,
        batch_id: &str,
    ) -> IngestionResult<Vec<QuarantineRecord>> {
        let mut records = Vec::new();
        loop {
            let page = self
                .list_quarantine_records(QuarantineListFilter {
                    batch_id: Some(key(batch_id, "ingestion_batch").to_string()),
                    limit: Some(PAGE_SIZE),
                    start: Some(records.len() as i64),
                    ..Default::default()
                })
                .await?;
            let received = page.records.len();
            records.extend(page.records);
            if received == 0 || records.len() as i64 >= page.total {
                return Ok(records);
            }
        }
    }

    // --- Manifestes ---------------------------------------------------------

    /// Enregistre un manifeste brouillon ou scellé (modifiable tant qu'il n'est pas approuvé).
    pub async fn save_manifest(&self, manifest: &ManifestDraft) -> IngestionResult<String> {
        let mut params = manifest.clone();
        params.batch_id = key(&manifest.batch_id, "ingestion_batch").to_string();
        Ok(self.call_fn("ingestion_manifest_save", params).await?)
    }

    /// Lit un manifeste ; `None` s'il n'existe pas.
    pub async fn get_manifest(
        &self,
        manifest_ref: &str,
    ) -> IngestionResult<Option<PublicationManifest>> {
        match self.get_manifest_detail(manifest_ref).await {
            Ok(detail) => Ok(Some(detail.manifest)),
            Err(IngestionError::Surreal(e)) if is_business(&e, "INGESTION_MANIFEST_NOT_FOUND") => {
                Ok(None)
            }
            Err(e) => Err(e),
        }
    }

    /// Approuve un manifeste scellé ; l'approbateur est l'identité de la session
    /// (`steward_admin`, ou `system` pour une session de l'hôte).
    pub async fn approve_manifest(
        &self,
        manifest_ref: &str,
        justification: &str,
    ) -> IngestionResult<()> {
        let params = ManifestApproveParams {
            manifest_ref: manifest_ref.to_string(),
            justification: justification.to_string(),
        };
        let _: bool = self.call_fn("ingestion_manifest_approve", params).await?;
        Ok(())
    }

    /// Consigne l'issue (`Committed` ou `Failed`) de l'exécution d'un manifeste approuvé.
    pub async fn record_manifest_exec(
        &self,
        manifest_ref: &str,
        statut: ManifestStatus,
        items_committed: usize,
        items_failed: usize,
    ) -> IngestionResult<()> {
        let params = ManifestRecordExecParams {
            manifest_ref: manifest_ref.to_string(),
            statut,
            items_committed: items_committed as i64,
            items_failed: items_failed as i64,
        };
        let _: bool = self
            .call_fn("ingestion_manifest_record_exec", params)
            .await?;
        Ok(())
    }

    /// Journalise l'exécution d'un article d'un manifeste en cours de publication.
    pub async fn update_manifest_execution_item(
        &self,
        manifest_ref: &str,
        item_ref: &str,
        action: PublicationAction,
        success: bool,
        error: Option<&str>,
    ) -> IngestionResult<()> {
        let params = ManifestExecutionItemParams {
            manifest_ref: manifest_ref.to_string(),
            item_ref: item_ref.to_string(),
            action,
            success,
            error: error.map(str::to_string),
        };
        let _: bool = self
            .call_fn("ingestion_manifest_execution_item_update", params)
            .await?;
        Ok(())
    }

    // --- Référentiels -------------------------------------------------------

    /// Résout un bloc d'unités fournisseurs (500 au plus) : alias de l'ingestion, puis
    /// référentiel de `lyxal_base`. Seules les unités utilisables figurent dans le résultat,
    /// indexé par l'unité brute sans espaces périphériques.
    pub async fn resolve_units(
        &self,
        raw_units: &[String],
    ) -> IngestionResult<std::collections::HashMap<String, String>> {
        let params = ResolveUnitsParams {
            raw_units: raw_units.to_vec(),
        };
        Ok(self.call_fn("ingestion_resolve_units", params).await?)
    }

    /// Résout un bloc de fabricants ou de marques (500 au plus) par leurs alias ; un nom
    /// inconnu est renvoyé normalisé avec `resolved = false`.
    pub async fn resolve_manufacturers(
        &self,
        raw_names: &[String],
    ) -> IngestionResult<std::collections::HashMap<String, ResolvedManufacturer>> {
        let params = ResolveManufacturersParams {
            raw_names: raw_names.to_vec(),
        };
        Ok(self
            .call_fn("ingestion_resolve_manufacturers", params)
            .await?)
    }

    /// Résolutions d'un bloc de lignes : unités et fabricants ou marques distincts, résolus par
    /// appels de 500 valeurs au plus (deux appels pour un bloc ordinaire).
    pub async fn block_referentials(
        &self,
        records: &[RawRecordDto],
        default_manufacturer: Option<&str>,
    ) -> IngestionResult<BlockReferentials> {
        let raw = BlockReferentials::raw_values(records, default_manufacturer);
        let mut referentials = BlockReferentials::default();
        for chunk in raw.units.chunks(RESOLVE_CHUNK) {
            referentials.units.extend(self.resolve_units(chunk).await?);
        }
        for chunk in raw.manufacturers.chunks(RESOLVE_CHUNK) {
            referentials
                .manufacturers
                .extend(self.resolve_manufacturers(chunk).await?);
        }
        Ok(referentials)
    }

    /// Ajoute ou met à jour une famille de produits.
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
            standard_unit: standard_unit.map(str::to_string),
        };
        Ok(self.call_fn("ingestion_rule_family_add", params).await?)
    }

    /// Ajoute ou met à jour une spécification patronne.
    pub async fn add_specification(
        &self,
        spec: &TechnicalSpecification,
    ) -> IngestionResult<String> {
        let params = SpecAddParams {
            technical_identity_key: spec.technical_identity_key.clone(),
            family_code: spec.family_code.clone(),
            generic_title: spec.generic_title.clone(),
            nominal_dimensions: spec.nominal_dimensions.clone(),
            tolerances: spec.tolerances.clone(),
            nominal_weight: spec.nominal_weight.as_ref().and_then(|w| w.net_weight_kg),
            standard_norm: spec.standard_norm.clone(),
            fire_rating: spec.fire_rating.clone(),
            required_features: spec.required_features.clone(),
        };
        Ok(self.call_fn("ingestion_rule_spec_add", params).await?)
    }

    /// Ajoute ou met à jour une règle de substitution certifiée.
    pub async fn add_substitution_rule(
        &self,
        rule: &ContextualSubstitutionRule,
    ) -> IngestionResult<String> {
        let valid_until = rule.valid_until.parse::<Datetime>().map_err(|e| {
            IngestionError::Validation(format!(
                "Règle {} : date de validité '{}' invalide : {e}",
                rule.rule_id, rule.valid_until
            ))
        })?;
        let params = SubstitutionRuleAddParams {
            rule_id: rule.rule_id.clone(),
            source_mfg: rule.source_manufacturer.clone(),
            source_ref: rule.source_ref.clone(),
            target_mfg: rule.target_manufacturer.clone(),
            target_ref: rule.target_ref.clone(),
            system_scope: rule.system_scope.clone(),
            certification_body: rule.certification_body.clone(),
            certification_ref: rule.certification_reference.clone(),
            valid_until,
            is_revoked: rule.is_revoked,
            revocation_reason: rule.revocation_reason.clone(),
        };
        Ok(self
            .call_fn("ingestion_rule_substitution_add", params)
            .await?)
    }

    // --- Console Data Steward ---------------------------------------------

    /// Indicateurs du pipeline, pour un lot ou pour l'ensemble.
    pub async fn get_dashboard_metrics(
        &self,
        batch_id: Option<&str>,
    ) -> IngestionResult<DashboardMetricsResult> {
        let params = DashboardMetricsParams {
            batch_id: batch_id.map(|b| key(b, "ingestion_batch").to_string()),
        };
        Ok(self.call_fn("ingestion_dashboard_metrics", params).await?)
    }

    /// Liste paginée et filtrée des articles en staging.
    pub async fn list_staged_items(
        &self,
        filter: StagedListFilter,
    ) -> IngestionResult<StagedListResult> {
        Ok(self.call_fn("ingestion_staged_list", filter).await?)
    }

    /// Requalifie un article (steward_admin de la session).
    pub async fn requalify_staged_item(
        &self,
        params: StagedRequalifyParams,
    ) -> IngestionResult<bool> {
        Ok(self.call_fn("ingestion_staged_requalify", params).await?)
    }

    /// Liste paginée et filtrée des anomalies en quarantaine.
    pub async fn list_quarantine_records(
        &self,
        filter: QuarantineListFilter,
    ) -> IngestionResult<QuarantineListResult> {
        Ok(self.call_fn("ingestion_quarantine_list", filter).await?)
    }

    /// Résout une anomalie en quarantaine (steward_admin de la session).
    pub async fn resolve_quarantine_record(
        &self,
        params: QuarantineResolveParams,
    ) -> IngestionResult<bool> {
        Ok(self.call_fn("ingestion_quarantine_resolve", params).await?)
    }

    /// Liste paginée et filtrée des manifestes.
    pub async fn list_manifests(
        &self,
        filter: ManifestListFilter,
    ) -> IngestionResult<ManifestListResult> {
        Ok(self.call_fn("ingestion_manifest_list", filter).await?)
    }

    /// Détail d'un manifeste et de son lot.
    pub async fn get_manifest_detail(
        &self,
        manifest_ref: &str,
    ) -> IngestionResult<ManifestDetailResult> {
        let params = ManifestRefParams {
            manifest_ref: manifest_ref.to_string(),
        };
        Ok(self
            .call_fn("ingestion_manifest_get_detail", params)
            .await?)
    }
}
