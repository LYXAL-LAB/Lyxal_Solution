//! Worker supervisé pour le pipeline d'ingestion de catalogues fabricants.
//!
//! Implémente le contrat officiel [`LyxalWorker`] de `lyxal_runtime` avec :
//! - Surveillance continue du [`CancellationToken`] pour un arrêt gracieux immédiat.
//! - Découpage en blocs de traitement (`chunk_size`) avec sauvegarde systématique de checkpoints.
//! - Reprise sur incident (crash, interruption réseau, redémarrage du processus) sans retraiter les lignes antérieures.
//! - Idempotence durable et détection des doublons.
//! - Publication des événements de domaine via [`lyxal_event`].

use std::collections::VecDeque;
use std::sync::Arc;
use std::time::Duration;
use async_trait::async_trait;
use tokio::sync::Mutex;

use lyxal_event::EventPublisher;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality,
    WorkerDescriptor, WorkerId,
};

use crate::adapters::AdapterRegistry;
use crate::error::{IngestionError, IngestionResult};
use crate::events::{BatchFailedEvent, BatchStagedEvent};
use crate::models::{QuarantineRecord, RawRecord, StagedItem};
use crate::normalization::NormalizationEngine;
use crate::proof::CommercialProof;
use crate::storage::IngestionStore;
use crate::types::{
    BatchStatus, Dimensions, ItemQualification, PackagingDetails, PublicationAction, SourceFormat,
    StateTransitionRecord,
};

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
    publisher: Option<EventPublisher>,
    active_batch_lock: Arc<Mutex<Option<String>>>,
    norm_engine: NormalizationEngine,
}

impl IngestionWorker {
    /// Initialise un nouveau worker supervisé d'ingestion raccordé au store SurrealDB.
    pub fn new(store: IngestionStore) -> Self {
        let module_id = ModuleId::new("lyxal_pipeline_ingestion");
        let worker_id = WorkerId::new(&module_id, "batch_worker")
            .unwrap_or_else(|_| panic!("Identifiant de worker 'batch_worker' invalide"));

        let mut descriptor = WorkerDescriptor::new(worker_id, module_id, "Lyxal Ingestion Batch Processor");
        descriptor.description = Some("Processeur supervisé de streaming, normalisation et qualification des catalogues fabricants".to_string());
        descriptor.criticality = WorkerCriticality::Required;
        descriptor.restart_policy = RestartPolicy::default();
        descriptor.shutdown_timeout = Duration::from_secs(10);

        Self {
            descriptor,
            store,
            queue: Arc::new(Mutex::new(VecDeque::new())),
            publisher: None,
            active_batch_lock: Arc::new(Mutex::new(None)),
            norm_engine: NormalizationEngine::new(),
        }
    }

    /// Associe un bus d'événements pour la publication des transitions de domaine.
    pub fn with_publisher(mut self, publisher: EventPublisher) -> Self {
        self.publisher = Some(publisher);
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
    pub async fn process_batch(
        &self,
        batch_id: &str,
        raw_bytes: &[u8],
        format: SourceFormat,
        commercial_proof: Option<CommercialProof>,
        cancellation: &CancellationToken,
    ) -> IngestionResult<BatchProcessingReport> {
        // 1. Anti-concurrence : acquisition du verrou logique sur le lot actif
        let mut lock = self.active_batch_lock.lock().await;
        if let Some(ref current) = *lock {
            if current != batch_id {
                return Err(IngestionError::Storage(format!(
                    "Un autre lot '{current}' est déjà en cours de traitement par ce worker"
                )));
            }
        }
        *lock = Some(batch_id.to_string());
        drop(lock);

        // 2. Vérification et transition d'état du lot
        let batch = self
            .store
            .get_batch(batch_id)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Lot '{batch_id}' introuvable")))?;

        // Idempotence : si le lot est déjà terminé, pas de réexécution inutile
        if batch.statut == BatchStatus::Staged || batch.statut == BatchStatus::Published {
            let mut lock = self.active_batch_lock.lock().await;
            *lock = None;
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

        // Si le lot était reçu, le faire passer en PARSING
        if batch.statut == BatchStatus::Received {
            self.store
                .update_batch_status(
                    batch_id,
                    BatchStatus::Parsing,
                    "ingestion_worker",
                    Some("Démarrage de la phase de normalisation et qualification"),
                )
                .await?;
        }

        // 3. Parsing complet du flux source via le registre officiel des adaptateurs
        let content = std::str::from_utf8(raw_bytes)
            .map_err(|e| IngestionError::Adapter(format!("Flux d'ingestion non encodé en UTF-8 : {e}")))?;

        let registry = AdapterRegistry::new();
        let adapter = registry.get(format).ok_or_else(|| {
            IngestionError::Adapter(format!("Aucun adaptateur disponible pour le format {:?}", format))
        })?;

        let raw_records = adapter.parse_content(content)?;
        let total_lines = raw_records.len();
        let chunk_size = if batch.chunk_size > 0 { batch.chunk_size } else { 100 };
        let mut current_offset = batch.cursor_offset;
        let mut verified_count = batch.lignes_verifiees;
        let mut to_confirm_count = batch.lignes_a_confirmer;
        let mut rejected_count = batch.lignes_rejetees;

        // 4. Boucle de streaming par chunks avec reprise exacte depuis cursor_offset
        while current_offset < total_lines {
            // Vérification coopérative de l'arrêt gracieux
            if cancellation.is_cancelled() {
                // Sauvegarde du checkpoint actuel avant coupure
                self.store
                    .save_checkpoint(
                        batch_id,
                        current_offset,
                        total_lines,
                        verified_count,
                        to_confirm_count,
                        rejected_count,
                    )
                    .await?;

                let mut lock = self.active_batch_lock.lock().await;
                *lock = None;

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
            let slice = &raw_records[current_offset..end_offset];

            let mut db_raw_records = Vec::with_capacity(slice.len());
            let mut db_staged_items = Vec::with_capacity(slice.len());
            let mut db_quarantine_records = Vec::new();

            for (idx, dto) in slice.iter().enumerate() {
                let line_num = current_offset + idx + 1;
                let normalized = self.norm_engine.normalize_with_proof(
                    dto,
                    Some(&batch.fournisseur_id),
                    format,
                    commercial_proof.clone(),
                );

                // Enregistrement brut persistant
                let raw_rec = RawRecord {
                    id: None,
                    batch: batch_id.to_string(),
                    ligne_numero: line_num,
                    row_hash: normalized.canonical_fingerprint.clone(),
                    payload_brut: serde_json::to_value(dto).unwrap_or_default(),
                    created_at: Some("2026-10-25T11:00:00Z".to_string()),
                };
                let raw_record_id = format!("{batch_id}_{line_num}");

                // Décompte de la qualification
                match normalized.qualification {
                    ItemQualification::Verified => verified_count += 1,
                    ItemQualification::ToConfirm => to_confirm_count += 1,
                    ItemQualification::Rejected => {
                        rejected_count += 1;
                        db_quarantine_records.push(QuarantineRecord {
                            id: None,
                            batch: batch_id.to_string(),
                            raw_record: raw_record_id.clone(),
                            code_erreur: "REJECTED_QUALIFICATION".to_string(),
                            severite: "CRITIQUE".to_string(),
                            champ_concerne: "commercial_proof_and_specs".to_string(),
                            valeur_fautive: Some(serde_json::to_value(&dto.raw_reference).unwrap_or_default()),
                            cause_detaillee: normalized.qualification_reason.clone(),
                            created_at: Some("2026-10-25T11:00:00Z".to_string()),
                            is_resolved: false,
                            resolved_by: None,
                            resolved_at: None,
                            resolution_comment: None,
                        });
                    }
                }

                // Conditionnement logistique
                let conditionnement = PackagingDetails {
                    unite_vente: normalized.unit_code.clone().unwrap_or_else(|| "PCE".to_string()),
                    quantite_par_colis: 1.0,
                    poids_brut_kg: normalized.weight.as_ref().and_then(|w| w.gross_weight_kg.or(w.net_weight_kg)),
                    dimensions: normalized.dimensions.as_ref().map(|d| Dimensions {
                        longueur_mm: d.length_mm.unwrap_or(0.0),
                        largeur_mm: d.width_mm.unwrap_or(0.0),
                        epaisseur_mm: d.height_mm.unwrap_or(0.0),
                    }),
                };

                // Article en staging
                let staged = StagedItem {
                    id: None,
                    batch: batch_id.to_string(),
                    raw_record: raw_record_id,
                    ligne_numero: line_num,
                    canonical_fingerprint: normalized.canonical_fingerprint,
                    rules_version: "2026-10-V1.1".to_string(),
                    fabricant: normalized.manufacturer,
                    marque: normalized.brand,
                    reference_fabricant: normalized.manufacturer_ref,
                    code_barre_gtin: normalized.gtin,
                    libelle_commercial: normalized.commercial_label,
                    description_technique: None,
                    type_item: "MATERIEL_BTP".to_string(),
                    unite_reference: normalized.unit_code.unwrap_or_else(|| "PCE".to_string()),
                    conditionnement,
                    qualification: normalized.qualification,
                    qualification_reason: Some(normalized.qualification_reason.clone()),
                    commercial_proof: normalized.commercial_proof,
                    publication_action: PublicationAction::Insert,
                    diff_payload: None,
                    transitions: vec![StateTransitionRecord {
                        from_statut: "RAW".to_string(),
                        to_statut: normalized.qualification.as_str().to_string(),
                        transition_at: "2026-10-25T11:00:00Z".to_string(),
                        transition_by: "ingestion_worker".to_string(),
                        reason: normalized.qualification_reason,
                    }],
                    is_approved: false,
                    approved_by: None,
                    approved_at: None,
                };

                db_raw_records.push(raw_rec);
                db_staged_items.push(staged);
            }

            // Persistance atomique par blocs
            self.store.save_raw_records_chunk(&db_raw_records).await?;
            self.store.save_staged_items_chunk(&db_staged_items).await?;
            if !db_quarantine_records.is_empty() {
                self.store.save_quarantine_records_chunk(&db_quarantine_records).await?;
            }

            current_offset = end_offset;

            // Enregistrement systématique du checkpoint à la fin du chunk
            self.store
                .save_checkpoint(
                    batch_id,
                    current_offset,
                    total_lines,
                    verified_count,
                    to_confirm_count,
                    rejected_count,
                )
                .await?;
        }

        // 5. Clôture avec succès : passage à l'état STAGED
        self.store
            .update_batch_status(
                batch_id,
                BatchStatus::Staged,
                "ingestion_worker",
                Some("Normalisation et qualification intégrale des lignes achevées avec succès"),
            )
            .await?;

        // 6. Émission de l'événement de domaine
        if let Some(ref publ) = self.publisher {
            let event = BatchStagedEvent {
                batch_id: batch_id.to_string(),
                source_type: format.as_str().to_string(),
                total_lignes: total_lines,
                verified_count,
                to_confirm_count,
                rejected_count,
            };
            let _ = publ.publish(&event).await;
        }

        // Libération du verrou actif
        let mut lock = self.active_batch_lock.lock().await;
        *lock = None;

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
                    Err(err) => {
                        // En cas d'erreur fatale, marquer le lot FAILED
                        let _ = self
                            .store
                            .update_batch_status(
                                &job.batch_id,
                                BatchStatus::Failed,
                                "ingestion_worker",
                                Some(&err.to_string()),
                            )
                            .await;

                        if let Some(ref publ) = self.publisher {
                            let event = BatchFailedEvent {
                                batch_id: job.batch_id.clone(),
                                error_code: "INGESTION_BATCH_FAILED".to_string(),
                                message: err.to_string(),
                            };
                            let _ = publ.publish(&event).await;
                        }

                        return Err(RuntimeError::Internal {
                            code: "INGESTION_BATCH_FAILED",
                            message: format!("Échec fatal du traitement du lot {}: {err}", job.batch_id),
                        });
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
