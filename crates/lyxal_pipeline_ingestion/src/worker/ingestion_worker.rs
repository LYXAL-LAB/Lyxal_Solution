//! Worker supervisé pour le pipeline d'ingestion de catalogues fabricants.
//!
//! Implémente le contrat officiel [`LyxalWorker`] de `lyxal_runtime` avec :
//! - Surveillance continue du [`CancellationToken`] pour un arrêt gracieux immédiat.
//! - Découpage en blocs de traitement (`chunk_size`) avec sauvegarde systématique de checkpoints.
//! - Reprise sur incident (crash, interruption réseau, redémarrage du processus) sans retraiter les lignes antérieures.
//! - Idempotence durable et détection des doublons.
//! - Publication des événements de domaine via [`lyxal_event`].

use async_trait::async_trait;
use std::collections::VecDeque;
use std::sync::Arc;
use std::time::Duration;
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
};

/// Version des règles de normalisation enregistrée avec chaque article.
const RULES_VERSION: &str = "2026-10-V1.1";

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
            publisher: None,
            active_batch_lock: Arc::new(Mutex::new(None)),
            norm_engine: NormalizationEngine::new(),
        })
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

        // Le verrou est libéré quelle que soit l'issue (succès, interruption ou erreur) :
        // une erreur ne doit jamais bloquer les lots suivants.
        let result = self
            .process_locked_batch(batch_id, raw_bytes, format, commercial_proof, cancellation)
            .await;
        *self.active_batch_lock.lock().await = None;
        result
    }

    /// Traitement d'un lot dont le verrou logique est déjà pris par `process_batch`.
    async fn process_locked_batch(
        &self,
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
            self.store
                .update_batch_status(
                    batch_id,
                    BatchStatus::Parsing,
                    "Démarrage de la phase de normalisation et qualification",
                )
                .await?;
        }

        // 3. Parsing complet du flux source via le registre officiel des adaptateurs
        let content = std::str::from_utf8(raw_bytes).map_err(|e| {
            IngestionError::Adapter(format!("Flux d'ingestion non encodé en UTF-8 : {e}"))
        })?;

        let registry = AdapterRegistry::new();
        let adapter = registry.get(format).ok_or_else(|| {
            IngestionError::Adapter(format!(
                "Aucun adaptateur disponible pour le format {:?}",
                format
            ))
        })?;

        let raw_records = adapter.parse_content(content)?;
        let total_lines = raw_records.len();
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

            for (idx, dto) in slice.iter().enumerate() {
                let line_num = current_offset + idx + 1;
                let normalized = self.norm_engine.normalize_with_proof(
                    dto,
                    Some(&batch.fournisseur_id),
                    format,
                    commercial_proof.clone(),
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
                    unite_vente: normalized
                        .unit_code
                        .clone()
                        .unwrap_or_else(|| "PCE".to_string()),
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
                    StagedItem {
                        id: None,
                        batch: batch_id.to_string(),
                        raw_record: format!("{batch_id}_{line_num}"),
                        ligne_numero: line_num,
                        canonical_fingerprint: normalized.canonical_fingerprint,
                        rules_version: RULES_VERSION.to_string(),
                        fabricant: normalized.manufacturer,
                        marque: normalized.brand,
                        reference_fabricant: normalized.manufacturer_ref,
                        code_barre_gtin: normalized.gtin,
                        libelle_commercial: normalized.commercial_label,
                        description_technique: None,
                        type_item: "PRODUIT".to_string(),
                        unite_reference: normalized.unit_code.unwrap_or_else(|| "PCE".to_string()),
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
            self.store
                .save_raw_records_chunk(batch_id, &db_raw_records)
                .await?;
            let items: Vec<StagedItem> = db_staged_items
                .iter()
                .map(|(_, item)| item.clone())
                .collect();
            let outcomes = self.store.save_staged_items_chunk(&items).await?;
            for ((raw_reference, staged), outcome) in db_staged_items.iter().zip(outcomes) {
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
                    self.store
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

        // 5. Clôture avec succès : VALIDATING puis STAGED
        if !resume_validating {
            self.store
                .update_batch_status(
                    batch_id,
                    BatchStatus::Validating,
                    "Lignes normalisées : validation finale du lot",
                )
                .await?;
        }
        self.store
            .update_batch_status(
                batch_id,
                BatchStatus::Staged,
                "Normalisation et qualification intégrale des lignes achevées avec succès",
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
            publ.publish(&event).await.map_err(|e| {
                IngestionError::Storage(format!(
                    "Événement ingestion.batch.staged non publié pour le lot {batch_id} : {e}"
                ))
            })?;
        }

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
                        // Le lot passe en FAILED et l'échec est publié ; le worker continue avec
                        // les lots suivants. Si l'une de ces deux étapes échoue, l'échec ne peut
                        // plus être consigné : le worker s'arrête et le superviseur le signale.
                        let mut causes = Vec::new();
                        if let Err(e) = self
                            .store
                            .update_batch_status(
                                &job.batch_id,
                                BatchStatus::Failed,
                                &err.to_string(),
                            )
                            .await
                        {
                            causes.push(format!("passage du lot en FAILED impossible : {e}"));
                        }

                        if let Some(ref publ) = self.publisher {
                            let event = BatchFailedEvent {
                                batch_id: job.batch_id.clone(),
                                error_code: err.code(),
                                message: err.to_string(),
                            };
                            if let Err(e) = publ.publish(&event).await {
                                causes.push(format!("événement d'échec non publié : {e}"));
                            }
                        }

                        if !causes.is_empty() {
                            return Err(RuntimeError::WorkerFailed {
                                worker: self.descriptor.id.to_string(),
                                message: format!(
                                    "INGESTION_BATCH_FAILED: échec du lot {} ({err}) non consigné : {}",
                                    job.batch_id,
                                    causes.join(" ; ")
                                ),
                            });
                        }
                        tracing::error!(
                            batch_id = %job.batch_id,
                            code = %err.code(),
                            error = %err,
                            "INGESTION_BATCH_FAILED : lot passé en FAILED, traitement des lots suivants"
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
