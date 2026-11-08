//! Worker supervisé pour le pipeline d'ingestion de catalogues fabricants.
//!
//! Implémente le contrat officiel [`LyxalWorker`] de `lyxal_runtime` avec :
//! - Surveillance continue du [`CancellationToken`] pour un arrêt gracieux immédiat.
//! - Découpage en blocs de traitement (`chunk_size`) avec sauvegarde systématique de checkpoints.
//! - Reprise sur incident (crash, interruption réseau, redémarrage du processus) sans retraiter les lignes antérieures.
//! - Idempotence durable et détection des doublons.
//! - Exclusion entre exécutions, workers et instances par la réservation du lot en base
//!   (`fn::ingestion_batch_claim`) : chaque écriture du traitement la présente, le point de
//!   reprise la renouvelle, elle est libérée à la fin quelle que soit l'issue.
//! - Événements de domaine (`ingestion.batch.staged`, `ingestion.batch.failed`) émis par la base
//!   dans la transaction de la transition d'état (`events/01_events.surql`).

use async_trait::async_trait;
use std::collections::VecDeque;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;

use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality,
    WorkerDescriptor, WorkerId,
};

use crate::adapters::{AdapterRegistry, RawRecordDto, SourceItem};
use crate::error::{IngestionError, IngestionResult};
use crate::models::{QuarantineRecord, RawRecord, StagedItem};
use crate::normalization::NormalizationEngine;
use crate::proof::CommercialProof;
use crate::storage::{BatchClaim, BatchProgress, IngestionStore};
use crate::types::{
    BatchStatus, Dimensions, ItemQualification, PackagingDetails, PublicationAction, SourceFormat,
};

/// Durée par défaut de la réservation d'un lot, renouvelée par le point de reprise (fin de
/// bloc, et rejoué au tiers de cette durée pendant le traitement).
const CLAIM_TTL_SECONDS: u32 = 60;

/// Écritures d'une exécution sur son lot réservé, une à la fois : le renouvellement périodique
/// de la réservation (dernier point de reprise rejoué) ne croise jamais une écriture du
/// traitement.
struct ClaimedBatch<'a> {
    store: &'a IngestionStore,
    claim: BatchClaim,
    batch_id: &'a str,
    renew_interval: Duration,
    /// Dernier avancement enregistré ; son verrou sérialise les écritures de l'exécution.
    progress: Mutex<Option<BatchProgress>>,
}

impl<'a> ClaimedBatch<'a> {
    fn new(
        store: &'a IngestionStore,
        claim: BatchClaim,
        batch_id: &'a str,
        renew_interval: Duration,
    ) -> Self {
        Self {
            store,
            claim,
            batch_id,
            renew_interval,
            progress: Mutex::new(None),
        }
    }

    async fn set_progress(&self, progress: BatchProgress) {
        *self.progress.lock().await = Some(progress);
    }

    async fn transition(&self, status: BatchStatus, reason: &str) -> IngestionResult<()> {
        let _write = self.progress.lock().await;
        self.store
            .update_batch_status(&self.claim, self.batch_id, status, reason)
            .await
    }

    async fn checkpoint(&self, progress: BatchProgress) -> IngestionResult<()> {
        let mut last = self.progress.lock().await;
        self.store
            .save_checkpoint(&self.claim, self.batch_id, &progress)
            .await?;
        *last = Some(progress);
        Ok(())
    }

    async fn save_raw_records(&self, records: &[RawRecord]) -> IngestionResult<usize> {
        let _write = self.progress.lock().await;
        self.store
            .save_raw_records_chunk(&self.claim, self.batch_id, records)
            .await
    }

    async fn save_staged_items(
        &self,
        items: &[StagedItem],
    ) -> IngestionResult<Vec<IngestionResult<String>>> {
        let _write = self.progress.lock().await;
        self.store.save_staged_items_chunk(&self.claim, items).await
    }

    async fn log_quarantine(&self, record: &QuarantineRecord) -> IngestionResult<String> {
        let _write = self.progress.lock().await;
        self.store.log_quarantine(&self.claim, record).await
    }

    /// Renouvelle la réservation à intervalle régulier en rejouant le dernier point de reprise
    /// (seul le point de reprise prolonge la réservation) ; ne rend la main qu'en cas d'échec.
    async fn keep_claim(&self) -> IngestionError {
        loop {
            tokio::time::sleep(self.renew_interval).await;
            let last = self.progress.lock().await;
            if let Some(progress) = last.as_ref() {
                if let Err(err) = self
                    .store
                    .save_checkpoint(&self.claim, self.batch_id, progress)
                    .await
                {
                    return err;
                }
            }
        }
    }
}

/// Rapport d'exécution du traitement d'un lot par le worker.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BatchProcessingReport {
    /// Identifiant du lot.
    pub batch_id: String,
    /// Statut final atteint par le lot.
    pub final_status: BatchStatus,
    /// Offset atteint dans les lignes sources.
    pub cursor_offset: usize,
    /// Nombre total de lignes traitées.
    pub total_lignes: usize,
    /// Nombre de lignes qualifiées `VERIFIED` avec preuve commerciale authentifiée.
    pub verified_count: usize,
    /// Nombre de lignes maintenues en `TO_CONFIRM`.
    pub to_confirm_count: usize,
    /// Nombre de lignes rejetées en `REJECTED` (quarantaine).
    pub rejected_count: usize,
    /// Indique si l'exécution a été interrompue gracieusement par un jeton d'annulation.
    pub interrupted: bool,
}

/// Description d'un travail d'ingestion en file d'attente.
#[derive(Clone)]
struct IngestionJob {
    batch_id: String,
    raw_bytes: Vec<u8>,
    format: SourceFormat,
    commercial_proof: Option<CommercialProof>,
}

/// Worker supervisé d'ingestion industrielle pour Lyxal OS.
pub struct IngestionWorker {
    descriptor: WorkerDescriptor,
    store: IngestionStore,
    queue: Arc<Mutex<VecDeque<IngestionJob>>>,
    claim_ttl_seconds: u32,
    norm_engine: NormalizationEngine,
}

impl IngestionWorker {
    /// Initialise un nouveau worker supervisé d'ingestion raccordé au store SurrealDB.
    pub fn new(store: IngestionStore) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new("lyxal_pipeline_ingestion");
        let worker_id = WorkerId::new(&module_id, "batch_worker")?;

        let mut descriptor =
            WorkerDescriptor::new(worker_id, module_id, "Lyxal Ingestion Batch Processor");
        descriptor.description = Some("Processeur supervisé de streaming, normalisation et qualification des catalogues fabricants".to_string());
        descriptor.criticality = WorkerCriticality::Required;
        descriptor.restart_policy = RestartPolicy::default();
        descriptor.shutdown_timeout = Duration::from_secs(10);

        Ok(Self {
            descriptor,
            store,
            queue: Arc::new(Mutex::new(VecDeque::new())),
            claim_ttl_seconds: CLAIM_TTL_SECONDS,
            norm_engine: NormalizationEngine::new(),
        })
    }

    /// Durée de la réservation des lots (5 à 600 s, contrôlée par `fn::ingestion_batch_claim` ;
    /// 60 s par défaut) ; le point de reprise est rejoué au tiers de cette durée.
    pub fn with_claim_ttl(mut self, seconds: u32) -> Self {
        self.claim_ttl_seconds = seconds;
        self
    }

    /// Enfile un lot brut pour traitement supervisé avec preuve commerciale optionnelle.
    pub async fn enqueue_batch(
        &self,
        batch_id: String,
        raw_bytes: Vec<u8>,
        format: SourceFormat,
        commercial_proof: Option<CommercialProof>,
    ) {
        let mut q = self.queue.lock().await;
        q.push_back(IngestionJob {
            batch_id,
            raw_bytes,
            format,
            commercial_proof,
        });
    }

    /// Traitement contrôlé d'un lot avec streaming par blocs, checkpoints et reprise sur incident.
    ///
    /// L'exécution tire son propre jeton et réserve le lot en base : un lot déjà réservé
    /// (autre exécution, autre worker, autre instance) renvoie
    /// [`IngestionError::BatchAlreadyClaimed`] sans rien modifier. Un échec du traitement fait
    /// passer le lot en `FAILED` tant que la réservation est détenue (la base émet
    /// `ingestion.batch.failed`), sauf si la réservation a été perdue ; si ce passage échoue,
    /// l'erreur est [`IngestionError::FailureNotRecorded`]. La réservation est libérée à la fin
    /// quelle que soit l'issue.
    pub async fn process_batch(
        &self,
        batch_id: &str,
        raw_bytes: &[u8],
        format: SourceFormat,
        commercial_proof: Option<CommercialProof>,
        cancellation: &CancellationToken,
    ) -> IngestionResult<BatchProcessingReport> {
        // 1. Exclusion : réservation du lot pour cette exécution (jeton propre à l'appel)
        let owner = uuid::Uuid::now_v7().to_string();
        let claim = match self
            .store
            .claim_batch(batch_id, &owner, self.claim_ttl_seconds)
            .await
        {
            Ok(claim) => claim,
            // Réservation impossible pour une raison technique (transport, conflits répétés) :
            // rien n'a été écrit, l'échec n'est pas consigné et le travail doit être rejoué.
            Err(err) if err.is_transport() => {
                return Err(IngestionError::FailureNotRecorded {
                    batch_id: batch_id.to_string(),
                    cause: "réservation du lot impossible".to_string(),
                    error: err.to_string(),
                })
            }
            Err(err) => return Err(err),
        };

        // Traitement et renouvellement de la réservation menés ensemble dans la même tâche : le
        // point de reprise est rejoué à intervalle régulier, quelle que soit la durée de la
        // lecture du fichier ou d'un bloc ; une erreur de renouvellement interrompt le traitement.
        let claimed = ClaimedBatch::new(
            &self.store,
            claim.clone(),
            batch_id,
            Duration::from_millis(u64::from(self.claim_ttl_seconds) * 1000 / 3),
        );
        let processed = tokio::select! {
            result = self.process_claimed_batch(
                &claimed,
                batch_id,
                raw_bytes,
                format,
                commercial_proof,
                cancellation,
            ) => result,
            err = claimed.keep_claim() => Err(err),
        };
        let result = match processed {
            // Échec consigné pendant que la réservation est détenue ; une exécution qui l'a
            // perdue n'écrit plus rien (le lot appartient à une autre exécution).
            Err(err) if !err.is_claim_lost() => match self
                .store
                .fail_batch(&claim, batch_id, &err.code(), &err.to_string())
                .await
            {
                Ok(()) => Err(err),
                Err(fail) => Err(IngestionError::FailureNotRecorded {
                    batch_id: batch_id.to_string(),
                    cause: err.to_string(),
                    error: fail.to_string(),
                }),
            },
            other => other,
        };

        // Libération quelle que soit l'issue ; l'erreur du traitement prime sur celle de la
        // libération, qui est alors journalisée (la réservation expirera d'elle-même).
        match (result, self.store.release_batch(batch_id, &claim).await) {
            (result, Ok(())) => result,
            (Ok(_), Err(release)) => Err(release),
            (Err(err), Err(release)) => {
                tracing::error!(
                    batch_id = %batch_id,
                    code = %release.code(),
                    error = %release,
                    "INGESTION_BATCH_CLAIM_LOST : réservation non libérée après l'échec du lot"
                );
                Err(err)
            }
        }
    }

    /// Traitement d'un lot réservé par `process_batch` : chaque écriture passe par `claimed`.
    async fn process_claimed_batch(
        &self,
        claimed: &ClaimedBatch<'_>,
        batch_id: &str,
        raw_bytes: &[u8],
        format: SourceFormat,
        commercial_proof: Option<CommercialProof>,
        cancellation: &CancellationToken,
    ) -> IngestionResult<BatchProcessingReport> {
        // 2. Vérification et transition d'état du lot
        let batch = self
            .store
            .get_batch(batch_id)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Lot '{batch_id}' introuvable")))?;
        // Avancement repris par le renouvellement de la réservation tant qu'aucun bloc n'est fini
        claimed
            .set_progress(BatchProgress {
                cursor_offset: batch.cursor_offset,
                total_lignes: batch.total_lignes,
                verified: batch.lignes_verifiees,
                to_confirm: batch.lignes_a_confirmer,
                rejected: batch.lignes_rejetees,
            })
            .await;

        // Idempotence : si le lot est déjà terminé, pas de réexécution inutile
        if batch.statut == BatchStatus::Staged || batch.statut == BatchStatus::Published {
            return Ok(BatchProcessingReport {
                batch_id: batch_id.to_string(),
                final_status: batch.statut,
                cursor_offset: batch.cursor_offset,
                total_lignes: batch.total_lignes,
                verified_count: batch.lignes_verifiees,
                to_confirm_count: batch.lignes_a_confirmer,
                rejected_count: batch.lignes_rejetees,
                interrupted: false,
            });
        }

        // Un lot reçu, ou en échec et repris, repasse en PARSING (machine à états du schéma :
        // RECEIVED/FAILED -> PARSING -> VALIDATING -> STAGED).
        let resume_validating = batch.statut == BatchStatus::Validating;
        if matches!(batch.statut, BatchStatus::Received | BatchStatus::Failed) {
            claimed
                .transition(
                    BatchStatus::Parsing,
                    "Démarrage de la phase de normalisation et qualification",
                )
                .await?;
        }

        // 3. Lecture complète de la source (encodage déclaré du lot) avant le premier bloc : une
        // source illisible fait échouer le lot sans rien mettre en staging
        let registry = AdapterRegistry::new();
        let adapter = registry.get(format).ok_or_else(|| {
            IngestionError::Adapter(format!(
                "Aucun adaptateur disponible pour le format {:?}",
                format
            ))
        })?;

        let source_items = adapter.read(raw_bytes, batch.source_encoding)?;
        let total_lines = source_items.len();
        let chunk_size = if batch.chunk_size > 0 {
            batch.chunk_size
        } else {
            100
        };
        let mut current_offset = batch.cursor_offset;
        let mut verified_count = batch.lignes_verifiees;
        let mut to_confirm_count = batch.lignes_a_confirmer;
        let mut rejected_count = batch.lignes_rejetees;

        // 4. Boucle de streaming par chunks avec reprise exacte depuis cursor_offset
        while current_offset < total_lines {
            // Vérification coopérative de l'arrêt gracieux
            if cancellation.is_cancelled() {
                // Sauvegarde du checkpoint actuel avant coupure
                claimed
                    .checkpoint(BatchProgress {
                        cursor_offset: current_offset,
                        total_lignes: total_lines,
                        verified: verified_count,
                        to_confirm: to_confirm_count,
                        rejected: rejected_count,
                    })
                    .await?;

                return Ok(BatchProcessingReport {
                    batch_id: batch_id.to_string(),
                    final_status: BatchStatus::Parsing,
                    cursor_offset: current_offset,
                    total_lignes: total_lines,
                    verified_count,
                    to_confirm_count,
                    rejected_count,
                    interrupted: true,
                });
            }

            let end_offset = (current_offset + chunk_size).min(total_lines);
            let slice = &source_items[current_offset..end_offset];
            let records: Vec<RawRecordDto> = slice
                .iter()
                .filter_map(|item| match item {
                    SourceItem::Record(record) => Some(record.as_ref().clone()),
                    SourceItem::Rejected(_) => None,
                })
                .collect();

            // Unités et fabricants du bloc résolus par les référentiels en base, en un appel chacun
            let referentials = self
                .store
                .block_referentials(&records, Some(&batch.fournisseur_id))
                .await?;

            let mut db_raw_records = Vec::with_capacity(slice.len());
            let mut db_staged_items = Vec::with_capacity(slice.len());
            let mut rejections = Vec::new();

            for item in slice {
                let dto = match item {
                    SourceItem::Record(dto) => dto,
                    SourceItem::Rejected(rejection) => {
                        // Enregistrement écarté à la lecture : sa ligne brute garde son numéro et
                        // la cause du rejet (le contenu n'est pas rendu par lyxal_parsing)
                        db_raw_records.push(RawRecord {
                            id: None,
                            batch: batch_id.to_string(),
                            ligne_numero: rejection.record,
                            row_hash: lyxal_crypto::blake3_hex(
                                format!(
                                    "{}:{}:{}",
                                    rejection.cause_code, rejection.record, rejection.detail
                                )
                                .as_bytes(),
                            ),
                            payload_brut: serde_json::json!({
                                "rejet": {
                                    "code": rejection.cause_code,
                                    "detail": rejection.detail,
                                    "ligne_source": rejection.source_line,
                                }
                            }),
                            created_at: None,
                        });
                        rejections.push(rejection);
                        continue;
                    }
                };
                let line_num = dto.line_number;
                let normalized = self.norm_engine.normalize_with_proof(
                    dto,
                    Some(&batch.fournisseur_id),
                    format,
                    commercial_proof.clone(),
                    &referentials,
                );

                // Enregistrement brut persistant
                db_raw_records.push(RawRecord {
                    id: None,
                    batch: batch_id.to_string(),
                    ligne_numero: line_num,
                    row_hash: normalized.canonical_fingerprint.clone(),
                    payload_brut: serde_json::to_value(dto).map_err(|e| {
                        IngestionError::Validation(format!(
                            "Ligne {line_num} : contenu brut non sérialisable : {e}"
                        ))
                    })?,
                    created_at: None,
                });

                // Conditionnement logistique
                let conditionnement = PackagingDetails {
                    unite_vente: normalized.unit_code.clone(),
                    quantite_par_colis: 1.0,
                    poids_brut_kg: normalized
                        .weight
                        .as_ref()
                        .and_then(|w| w.gross_weight_kg.or(w.net_weight_kg)),
                    dimensions: normalized.dimensions.as_ref().map(|d| Dimensions {
                        longueur_mm: d.length_mm.unwrap_or(0.0),
                        largeur_mm: d.width_mm.unwrap_or(0.0),
                        epaisseur_mm: d.height_mm.unwrap_or(0.0),
                    }),
                };

                db_staged_items.push((
                    dto.raw_reference.clone(),
                    dto.raw_unit.clone(),
                    StagedItem {
                        id: None,
                        batch: batch_id.to_string(),
                        raw_record: format!("{batch_id}_{line_num}"),
                        ligne_numero: line_num,
                        canonical_fingerprint: normalized.canonical_fingerprint,
                        rules_version: normalized.rules_engine_version,
                        fabricant: normalized.manufacturer,
                        marque: normalized.brand,
                        reference_fabricant: normalized.manufacturer_ref,
                        code_barre_gtin: normalized.gtin,
                        libelle_commercial: normalized.commercial_label,
                        description_technique: None,
                        type_item: "PRODUIT".to_string(),
                        unite_reference: normalized.unit_code,
                        conditionnement,
                        qualification: normalized.qualification,
                        qualification_reason: Some(normalized.qualification_reason),
                        commercial_proof: normalized.commercial_proof,
                        publication_action: PublicationAction::Insert,
                        diff_payload: None,
                        transitions: Vec::new(),
                        is_approved: false,
                        approved_by: None,
                        approved_at: None,
                    },
                ));
            }

            // Persistance du bloc : lignes brutes, puis articles ; une ligne refusée par le
            // contrôle SurrealQL (code-barres invalide) ou rejetée par la qualification est
            // consignée en quarantaine.
            claimed.save_raw_records(&db_raw_records).await?;
            for rejection in rejections {
                rejected_count += 1;
                claimed
                    .log_quarantine(&QuarantineRecord {
                        id: None,
                        batch: batch_id.to_string(),
                        raw_record: format!("{batch_id}_{}", rejection.record),
                        ligne_numero: rejection.record,
                        code_erreur: rejection.anomaly_code.to_string(),
                        severite: "ERROR".to_string(),
                        champ_concerne: "enregistrement".to_string(),
                        valeur_fautive: Some(serde_json::json!({
                            "code": rejection.cause_code,
                            "ligne_source": rejection.source_line,
                        })),
                        cause_detaillee: format!("{} : {}", rejection.cause_code, rejection.detail),
                        created_at: None,
                        is_resolved: false,
                        resolved_by: None,
                        resolved_at: None,
                        resolution_comment: None,
                    })
                    .await?;
            }
            let items: Vec<StagedItem> = db_staged_items
                .iter()
                .map(|(_, _, item)| item.clone())
                .collect();
            let outcomes = claimed.save_staged_items(&items).await?;
            for ((raw_reference, raw_unit, staged), outcome) in db_staged_items.iter().zip(outcomes)
            {
                // Article en staging sans unité : anomalie liée à sa ligne, que le steward corrige
                // (fn::ingestion_quarantine_resolve, corrected_unit) ; l'article reste compté.
                if outcome.is_ok() && staged.unite_reference.is_none() {
                    claimed.log_quarantine(&QuarantineRecord {
                            id: None,
                            batch: batch_id.to_string(),
                            raw_record: staged.raw_record.clone(),
                            ligne_numero: staged.ligne_numero,
                            code_erreur: "INGESTION_UNIT_UNRESOLVED".to_string(),
                            severite: "WARNING".to_string(),
                            champ_concerne: "unite_reference".to_string(),
                            valeur_fautive: raw_unit.clone().map(serde_json::Value::from),
                            cause_detaillee: match raw_unit {
                                Some(unit) => format!(
                                    "Unité fournisseur « {unit} » inconnue des référentiels : article en staging sans unité"
                                ),
                                None => "Unité absente de la ligne : article en staging sans unité"
                                    .to_string(),
                            },
                            created_at: None,
                            is_resolved: false,
                            resolved_by: None,
                            resolved_at: None,
                            resolution_comment: None,
                        })
                        .await?;
                }
                let anomaly = match outcome {
                    Ok(_) => match staged.qualification {
                        ItemQualification::Verified => {
                            verified_count += 1;
                            None
                        }
                        ItemQualification::ToConfirm => {
                            to_confirm_count += 1;
                            None
                        }
                        ItemQualification::Rejected => Some((
                            "INGESTION_QUALIFICATION_REJECTED",
                            "CRITICAL",
                            "commercial_proof_and_specs",
                            serde_json::Value::from(raw_reference.clone()),
                            staged
                                .qualification_reason
                                .clone()
                                .unwrap_or_else(|| "Qualification rejetée".to_string()),
                        )),
                    },
                    Err(err) if err.is_business_code("INGESTION_GTIN_INVALID") => Some((
                        "INGESTION_GTIN_INVALID",
                        "ERROR",
                        "code_barre_gtin",
                        serde_json::Value::from(staged.code_barre_gtin.clone()),
                        err.to_string(),
                    )),
                    Err(err) => return Err(err),
                };

                if let Some((code, severite, champ, valeur, cause)) = anomaly {
                    rejected_count += 1;
                    claimed
                        .log_quarantine(&QuarantineRecord {
                            id: None,
                            batch: batch_id.to_string(),
                            raw_record: staged.raw_record.clone(),
                            ligne_numero: staged.ligne_numero,
                            code_erreur: code.to_string(),
                            severite: severite.to_string(),
                            champ_concerne: champ.to_string(),
                            valeur_fautive: Some(valeur),
                            cause_detaillee: cause,
                            created_at: None,
                            is_resolved: false,
                            resolved_by: None,
                            resolved_at: None,
                            resolution_comment: None,
                        })
                        .await?;
                }
            }

            current_offset = end_offset;

            // Enregistrement systématique du checkpoint à la fin du chunk
            claimed
                .checkpoint(BatchProgress {
                    cursor_offset: current_offset,
                    total_lignes: total_lines,
                    verified: verified_count,
                    to_confirm: to_confirm_count,
                    rejected: rejected_count,
                })
                .await?;
        }

        // 5. Clôture avec succès : VALIDATING puis STAGED
        if !resume_validating {
            claimed
                .transition(
                    BatchStatus::Validating,
                    "Lignes normalisées : validation finale du lot",
                )
                .await?;
        }
        claimed
            .transition(
                BatchStatus::Staged,
                "Normalisation et qualification intégrale des lignes achevées avec succès",
            )
            .await?;

        Ok(BatchProcessingReport {
            batch_id: batch_id.to_string(),
            final_status: BatchStatus::Staged,
            cursor_offset: current_offset,
            total_lignes: total_lines,
            verified_count,
            to_confirm_count,
            rejected_count,
            interrupted: false,
        })
    }
}

#[async_trait]
impl LyxalWorker for IngestionWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            // Dépilement du travail suivant
            let next_job = {
                let mut q = self.queue.lock().await;
                q.pop_front()
            };

            if let Some(job) = next_job {
                match self
                    .process_batch(
                        &job.batch_id,
                        &job.raw_bytes,
                        job.format,
                        job.commercial_proof.clone(),
                        &ctx.cancellation,
                    )
                    .await
                {
                    Ok(report) => {
                        if report.interrupted {
                            // Si interrompu, réenfiler pour reprise ultérieure
                            let mut q = self.queue.lock().await;
                            q.push_front(job);
                            break;
                        }
                    }
                    // Échec non consigné (réservation impossible ou passage en FAILED refusé
                    // pour une raison technique) : le travail reste en file et le worker
                    // s'arrête, le superviseur le signale et le relance.
                    Err(err @ IngestionError::FailureNotRecorded { .. }) => {
                        self.queue.lock().await.push_front(job);
                        return Err(RuntimeError::WorkerFailed {
                            worker: self.descriptor.id.to_string(),
                            message: format!("INGESTION_BATCH_FAILED: {err}"),
                        });
                    }
                    // Lot réservé par une autre exécution : il lui appartient, ni rejoué ni
                    // marqué en échec ici.
                    Err(err @ IngestionError::BatchAlreadyClaimed { .. }) => {
                        tracing::warn!(
                            batch_id = %job.batch_id,
                            code = %err.code(),
                            error = %err,
                            "Lot traité par une autre exécution : travail abandonné par ce worker"
                        );
                    }
                    // Réservation perdue en cours de traitement : rien de plus n'a été écrit. Le
                    // travail est rejoué : il reprend au dernier point de reprise si le lot est
                    // libre, et il est abandonné si une autre exécution le détient.
                    Err(err) if err.is_claim_lost() => {
                        tracing::warn!(
                            batch_id = %job.batch_id,
                            code = %err.code(),
                            error = %err,
                            "Réservation du lot perdue : travail remis en file"
                        );
                        self.queue.lock().await.push_back(job);
                    }
                    // Échec du lot : passé en FAILED (la base a émis ingestion.batch.failed),
                    // ou lot refusé avant toute écriture (introuvable, accès refusé) ; le
                    // worker continue avec les lots suivants.
                    Err(err) => {
                        tracing::error!(
                            batch_id = %job.batch_id,
                            code = %err.code(),
                            error = %err,
                            "INGESTION_BATCH_FAILED : échec du lot, traitement des lots suivants"
                        );
                    }
                }
            } else {
                // Attente courte ou interruption
                tokio::select! {
                    _ = ctx.cancellation.cancelled() => {
                        break;
                    }
                    _ = tokio::time::sleep(Duration::from_millis(50)) => {}
                }
            }
        }

        Ok(())
    }
}
