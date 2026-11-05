//! Implémentation du store de persistance industrielle SurrealDB pour le pipeline d'ingestion.
//!
//! Entièrement réaligné avec la Charte d'Architecture Lyxal OS (AGENTS.md) :
//! - Implémentation du trait universel `LyxalSurrealCall`.
//! - Appel exclusif des fonctions publiques `fn::ingestion_*` via `self.call_fn(...)`.
//! - Externalisation des règles métier (familles, spécifications, alias, substitutions) dans SurrealDB.
//! - Découplage complet de la logique métier Rust vers SurrealQL.

use lyxal_surreal::SurrealValue;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::error::{IngestionError, IngestionResult};
use crate::models::{IngestionBatch, PublicationManifest, QuarantineRecord, RawRecord, StagedItem};
use crate::technical_grouping::{ContextualSubstitutionRule, FamilyRule, TechnicalSpecification};
use crate::types::{BatchStatus, ManifestStatus, StateTransitionRecord};

// =============================================================================
// DTOs DE PARAMÈTRES POUR call_fn
// =============================================================================

#[derive(SurrealValue)]
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
    nouveau_statut: String,
    transition: StateTransitionRecord,
}

#[derive(SurrealValue)]
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
    conditionnement: crate::types::PackagingDetails,
    qualification: String,
    publication_action: String,
    diff_payload: Option<serde_json::Value>,
    transitions: Vec<StateTransitionRecord>,
}

#[derive(SurrealValue)]
struct QuarantineLogParams {
    batch_id: String,
    raw_record_id: Option<String>,
    ligne_numero: i64,
    code_erreur: String,
    severite: String,
    champ_concerne: String,
    valeur_fautive: Option<serde_json::Value>,
    cause_detaillee: String,
}

#[derive(SurrealValue)]
struct ManifestSaveParams {
    manifest_ref: String,
    batch_id: String,
    manifest_version: i64,
    seal_hash: String,
    is_sealed: bool,
    statut: String,
    nb_articles_insert: i64,
    nb_articles_update: i64,
    items_committed: i64,
    items_failed: i64,
    execution_items: Option<Vec<serde_json::Value>>,
    transitions: Option<Vec<StateTransitionRecord>>,
    executed_at: Option<lyxal_surreal::Datetime>,
}

#[derive(SurrealValue)]
struct ManifestApproveParams {
    manifest_ref: String,
    justification: String,
}

#[derive(SurrealValue)]
struct ManifestRecordExecParams {
    manifest_ref: String,
    statut: String,
    items_committed: i64,
    items_failed: i64,
    execution_items: Option<Vec<serde_json::Value>>,
}

#[derive(SurrealValue)]
struct ResolveUnitParams {
    raw_unit: String,
    language: String,
}

/// Résultat de la résolution dynamique d'unité vers base_unite
#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct ResolveUnitResult {
    pub canonical_code: String,
    pub resolved: bool,
}

#[derive(SurrealValue)]
struct ResolveManufacturerParams {
    raw_name: String,
    language: String,
}

/// Résultat de la résolution dynamique de fabricant
#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct ResolveManufacturerResult {
    pub canonical_name: String,
    pub holding_or_group: Option<String>,
    pub is_verified: bool,
    pub resolved: bool,
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
    tolerances: Option<crate::technical_grouping::types::SpecificationTolerances>,
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
    valid_until: String,
    is_revoked: bool,
    revocation_reason: Option<String>,
}

// =============================================================================
// DTOs PHASE 5 : DATA STEWARD & OBSERVABILITÉ
// =============================================================================

#[derive(SurrealValue)]
struct DashboardMetricsParams {
    batch_id: Option<String>,
}

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

#[derive(Serialize, Default, Debug, Clone, SurrealValue)]
pub struct StagedListFilter {
    pub batch_id: Option<String>,
    pub qualification: Option<String>,
    pub fabricant: Option<String>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct StagedListResult {
    pub items: Vec<serde_json::Value>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Serialize, Debug, Clone, SurrealValue)]
pub struct StagedRequalifyParams {
    pub item_id: String,
    pub new_qualification: String,
    pub justification: String,
    pub proof: Option<crate::proof::CommercialProof>,
    pub language: Option<String>,
}

#[derive(Serialize, Default, Debug, Clone, SurrealValue)]
pub struct QuarantineListFilter {
    pub batch_id: Option<String>,
    pub severite: Option<String>,
    pub is_resolved: Option<bool>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct QuarantineListResult {
    pub records: Vec<serde_json::Value>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Serialize, Debug, Clone, SurrealValue)]
pub struct QuarantineResolveParams {
    pub quarantine_id: String,
    pub comment: String,
    pub staged_item_id: Option<String>,
    pub corrections: Option<serde_json::Value>,
    pub language: Option<String>,
}

#[derive(Serialize, Default, Debug, Clone, SurrealValue)]
pub struct ManifestListFilter {
    pub batch_id: Option<String>,
    pub statut: Option<String>,
    pub limit: Option<i64>,
    pub start: Option<i64>,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
pub struct ManifestListResult {
    pub manifests: Vec<serde_json::Value>,
    pub total: i64,
    pub limit: i64,
    pub start: i64,
}

#[derive(Serialize, Debug, Clone, SurrealValue)]
pub struct ManifestGetDetailParams {
    pub manifest_ref: String,
    pub language: Option<String>,
}

#[derive(Deserialize, Serialize, Debug, Clone, SurrealValue)]
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

    // =========================================================================
    // 1. GESTION DES LOTS (Appels via store.call_fn)
    // =========================================================================

    /// Crée un nouveau lot en base avec contrôle d'idempotence via fn::ingestion_batch_create
    pub async fn create_batch(&self, batch: &IngestionBatch) -> IngestionResult<String> {
        let id_val_raw = batch
            .id
            .clone()
            .unwrap_or_else(|| format!("batch_{}", &batch.file_hash_blake3[..16]));
        let id_val = id_val_raw
            .strip_prefix("ingestion_batch:")
            .unwrap_or(&id_val_raw)
            .to_string();

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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_batch_create : {e}"))
            })?;

        Ok(result)
    }

    /// Récupère un lot par son identifiant
    pub async fn get_batch(&self, batch_id: &str) -> IngestionResult<Option<IngestionBatch>> {
        let clean_id = batch_id
            .strip_prefix("ingestion_batch:")
            .unwrap_or(batch_id);
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
        let clean_id = batch_id
            .strip_prefix("ingestion_batch:")
            .unwrap_or(batch_id);
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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_batch_checkpoint : {e}"))
            })?;

        Ok(())
    }

    /// Charge le dernier offset de checkpoint d'un lot
    pub async fn load_checkpoint(&self, batch_id: &str) -> IngestionResult<usize> {
        let clean_id = batch_id
            .strip_prefix("ingestion_batch:")
            .unwrap_or(batch_id);
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
        let clean_id = batch_id
            .strip_prefix("ingestion_batch:")
            .unwrap_or(batch_id);
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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_batch_transition : {e}"))
            })?;

        Ok(())
    }

    // =========================================================================
    // 2. PERSISTANCE DES LIGNES ET DU STAGING (via store.call_fn)
    // =========================================================================

    /// Sauvegarde un bloc de lignes brutes
    pub async fn save_raw_records_chunk(&self, records: &[RawRecord]) -> IngestionResult<()> {
        for rec in records {
            let clean_batch = rec
                .batch
                .strip_prefix("ingestion_batch:")
                .unwrap_or(&rec.batch);
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
                .map_err(|e| {
                    IngestionError::Storage(format!("Échec sauvegarde raw record : {e}"))
                })?;
        }
        Ok(())
    }

    /// Sauvegarde un article en staging via fn::ingestion_staged_save
    pub async fn save_staged_item(&self, item: &StagedItem) -> IngestionResult<String> {
        let clean_batch = item
            .batch
            .strip_prefix("ingestion_batch:")
            .unwrap_or(&item.batch);
        let clean_raw = item
            .raw_record
            .strip_prefix("ingestion_raw_record:")
            .unwrap_or(&item.raw_record);

        let params = StagedSaveParams {
            batch_id: clean_batch.to_string(),
            raw_record_id: if clean_raw.is_empty() {
                None
            } else {
                Some(clean_raw.to_string())
            },
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
            conditionnement: item.conditionnement.clone(),
            qualification: item.qualification.as_str().to_string(),
            publication_action: item.publication_action.as_str().to_string(),
            diff_payload: item.diff_payload.clone(),
            transitions: item.transitions.clone(),
        };

        let result: String = self
            .call_fn("ingestion_staged_save", params)
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_staged_save : {e}"))
            })?;

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
    pub async fn get_staged_items_by_batch(
        &self,
        batch_id: &str,
    ) -> IngestionResult<Vec<StagedItem>> {
        let clean_batch = batch_id
            .strip_prefix("ingestion_batch:")
            .unwrap_or(batch_id);
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id, <string> record::id(batch) AS batch, <string> record::id(raw_record) AS raw_record FROM ingestion_staged_item WHERE batch = <record> string::concat('ingestion_batch:', $b);")
            .bind(("b", clean_batch.to_string()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture staged items : {e}")))?;

        let items: Vec<StagedItem> = res.take(0).map_err(|e| {
            IngestionError::Storage(format!("Erreur désérialisation staged items : {e}"))
        })?;

        Ok(items)
    }

    // =========================================================================
    // 3. QUARANTAINE PERSISTÉE (via store.call_fn)
    // =========================================================================

    /// Consigne une anomalie en quarantaine via fn::ingestion_quarantine_log
    pub async fn log_quarantine(&self, record: &QuarantineRecord) -> IngestionResult<String> {
        let clean_batch = record
            .batch
            .strip_prefix("ingestion_batch:")
            .unwrap_or(&record.batch);
        let clean_raw = record
            .raw_record
            .strip_prefix("ingestion_raw_record:")
            .unwrap_or(&record.raw_record);

        let params = QuarantineLogParams {
            batch_id: clean_batch.to_string(),
            raw_record_id: if clean_raw.is_empty() {
                None
            } else {
                Some(clean_raw.to_string())
            },
            ligne_numero: record.ligne_numero as i64,
            code_erreur: record.code_erreur.clone(),
            severite: record.severite.clone(),
            champ_concerne: record.champ_concerne.clone(),
            valeur_fautive: record.valeur_fautive.clone(),
            cause_detaillee: record.cause_detaillee.clone(),
        };

        let result: String = self
            .call_fn("ingestion_quarantine_log", params)
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_quarantine_log : {e}"))
            })?;

        Ok(result)
    }

    /// Sauvegarde un bloc d'anomalies en quarantaine
    pub async fn save_quarantine_records_chunk(
        &self,
        records: &[QuarantineRecord],
    ) -> IngestionResult<()> {
        for rec in records {
            self.log_quarantine(rec).await?;
        }
        Ok(())
    }

    /// Récupère toutes les anomalies de quarantaine pour un lot
    pub async fn get_quarantine_by_batch(
        &self,
        batch_id: &str,
    ) -> IngestionResult<Vec<QuarantineRecord>> {
        let clean_batch = batch_id
            .strip_prefix("ingestion_batch:")
            .unwrap_or(batch_id);
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
        let clean_batch = manifest
            .batch
            .strip_prefix("ingestion_batch:")
            .unwrap_or(&manifest.batch);

        let params = ManifestSaveParams {
            manifest_ref: manifest.manifest_ref.clone(),
            batch_id: clean_batch.to_string(),
            manifest_version: manifest.manifest_version as i64,
            seal_hash: manifest.seal_hash.clone(),
            is_sealed: manifest.is_sealed,
            statut: manifest.statut.as_str().to_string(),
            nb_articles_insert: manifest.nb_articles_insert as i64,
            nb_articles_update: manifest.nb_articles_update as i64,
            items_committed: manifest.items_committed as i64,
            items_failed: manifest.items_failed as i64,
            execution_items: Some(manifest.execution_items.clone()),
            transitions: Some(manifest.transitions.clone()),
            executed_at: manifest.executed_at,
        };

        let result: String = self
            .call_fn("ingestion_manifest_save", params)
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_manifest_save : {e}"))
            })?;

        Ok(result)
    }

    /// Récupère un manifeste par sa référence
    pub async fn get_manifest(
        &self,
        manifest_ref: &str,
    ) -> IngestionResult<Option<PublicationManifest>> {
        let mut res = self
            .db
            .query("SELECT *, <string> record::id(id) AS id, <string> record::id(batch) AS batch FROM ingestion_publication_manifest WHERE manifest_ref = $ref;")
            .bind(("ref", manifest_ref.to_string()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture manifeste : {e}")))?;

        let manifest: Option<PublicationManifest> = res.take(0).map_err(|e| {
            IngestionError::Storage(format!("Erreur désérialisation manifeste : {e}"))
        })?;

        Ok(manifest)
    }

    /// Approbation d'un manifeste via fn::ingestion_manifest_approve. L'approbateur est
    /// l'identité de la session (steward_admin, ou `system` pour une session de l'hôte).
    pub async fn approve_manifest(
        &self,
        manifest_ref: &str,
        justification: &str,
    ) -> IngestionResult<()> {
        let params = ManifestApproveParams {
            manifest_ref: manifest_ref.to_string(),
            justification: justification.to_string(),
        };

        let _: bool = self
            .call_fn("ingestion_manifest_approve", params)
            .await
            .map_err(|e| match e {
                LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(err)) => {
                    IngestionError::IllegalTransition(err.message)
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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_manifest_record_exec : {e}"))
            })?;

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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec journalisation exécution article : {e}"))
            })?;

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

        // Seule une unité inconnue donne `None` ; toute autre erreur (base, transport) remonte.
        match res {
            Ok(r) => Ok(Some(r.canonical_code)),
            Err(LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(err)))
                if err.code == "INGESTION_UNIT_UNRESOLVED" =>
            {
                Ok(None)
            }
            Err(e) => Err(IngestionError::Storage(format!(
                "Échec fn::ingestion_resolve_unit : {e}"
            ))),
        }
    }

    /// Résout dynamiquement un fabricant via fn::ingestion_resolve_manufacturer
    pub async fn resolve_manufacturer(
        &self,
        raw_name: &str,
    ) -> IngestionResult<ResolveManufacturerResult> {
        let params = ResolveManufacturerParams {
            raw_name: raw_name.to_string(),
            language: "fr".to_string(),
        };

        let result: ResolveManufacturerResult = self
            .call_fn("ingestion_resolve_manufacturer", params)
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_resolve_manufacturer : {e}"))
            })?;

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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_rule_family_add : {e}"))
            })?;

        Ok(res)
    }

    /// Ajoute ou met à jour une spécification patronne sans recompilation
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

        let res: String = self
            .call_fn("ingestion_rule_spec_add", params)
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_rule_spec_add : {e}"))
            })?;

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
            .map_err(|e| {
                IngestionError::Storage(format!("Échec fn::ingestion_rule_substitution_add : {e}"))
            })?;

        Ok(res)
    }

    /// Charge toutes les familles de produits configurées depuis SurrealDB
    pub async fn load_family_rules(&self) -> IngestionResult<Vec<FamilyRule>> {
        let mut res = self
            .db
            .query("SELECT * FROM ingestion_family_rule;")
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec lecture ingestion_family_rule : {e}"))
            })?;

        let families: Vec<FamilyRule> = res.take(0).map_err(|e| {
            IngestionError::Storage(format!("Erreur désérialisation family_rule : {e}"))
        })?;

        Ok(families)
    }

    /// Charge toutes les spécifications configurées depuis SurrealDB
    pub async fn load_specifications(&self) -> IngestionResult<Vec<TechnicalSpecification>> {
        let mut res = self
            .db
            .query("SELECT * FROM ingestion_specification;")
            .await
            .map_err(|e| {
                IngestionError::Storage(format!("Échec lecture ingestion_specification : {e}"))
            })?;

        let specs: Vec<TechnicalSpecification> = res.take(0).map_err(|e| {
            IngestionError::Storage(format!("Erreur désérialisation specification : {e}"))
        })?;

        Ok(specs)
    }

    /// Charge toutes les règles de substitution contextualisées depuis SurrealDB
    pub async fn load_substitution_rules(
        &self,
    ) -> IngestionResult<Vec<ContextualSubstitutionRule>> {
        let mut res = self
            .db
            .query("SELECT rule_id, source_mfg AS source_manufacturer, source_ref, target_mfg AS target_manufacturer, target_ref, system_scope, certification_body, certification_ref AS certification_reference, <string> valid_until AS valid_until, is_revoked, revocation_reason FROM ingestion_substitution_rule;")
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec lecture ingestion_substitution_rule : {e}")))?;

        let rules: Vec<ContextualSubstitutionRule> = res.take(0).map_err(|e| {
            IngestionError::Storage(format!("Erreur désérialisation substitution_rule : {e}"))
        })?;

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
