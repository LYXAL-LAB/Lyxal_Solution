//! Publication contrôlée d'un manifeste approuvé vers le catalogue maître.
//!
//! * Session dédiée : le client de l'hôte est cloné (nouvelle session SurrealDB sur la même
//!   connexion) puis authentifié par un jeton de service `catalogue_sync_agent` court ; la
//!   session système de l'hôte n'est jamais modifiée.
//! * Seuls les articles `VERIFIED`, dont la preuve commerciale est éligible à la production,
//!   sont publiés ; `TO_CONFIRM` et `REJECTED` sont exclus.
//! * Le sceau BLAKE3 du manifeste est recalculé sur les articles du lot avant toute écriture.
//! * Chaque article est journalisé dans le manifeste (`fn::ingestion_manifest_execution_item_update`) ;
//!   une reprise saute les articles déjà publiés.
//! * Issue : `COMMITTED` si tous les articles éligibles sont publiés, sinon `FAILED` (le Data
//!   Steward corrige puis réapprouve). Une erreur de transport remonte telle quelle : la
//!   publication sera rejouée.

use lyxal_event::EventPublisher;
use lyxal_surreal::{LyxalSurrealError, SurrealValue};
use std::collections::HashSet;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use super::catalogue::{catalogue_master_id, CatalogueSyncClient};
use super::token::{CatalogueTokenIssuer, CATALOGUE_SYNC_SUBJECT};
use crate::error::{IngestionError, IngestionResult};
use crate::events::ManifestPublishedEvent;
use crate::fingerprint::FingerprintEngine;
use crate::models::StagedItem;
use crate::storage::IngestionStore;
use crate::types::{ItemQualification, ManifestStatus, PublicationAction};

/// Rapport d'exécution de la publication d'un manifeste.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct PublicationExecutionReport {
    /// Référence du manifeste traité.
    pub manifest_ref: String,
    /// Nombre total d'articles du lot en staging.
    pub total_staged: usize,
    /// Articles qualifiés `VERIFIED`.
    pub eligible_verified: usize,
    /// Articles exclus car en attente de preuve (`TO_CONFIRM`).
    pub skipped_to_confirm: usize,
    /// Articles exclus car rejetés (`REJECTED`).
    pub skipped_rejected: usize,
    /// Articles déjà publiés lors d'une exécution précédente (ou sans changement).
    pub already_published: usize,
    /// Articles créés ou mis à jour dans le catalogue par cette exécution.
    pub newly_published: usize,
    /// Articles refusés (preuve non éligible, refus du catalogue).
    pub failed: usize,
    /// Statut final du manifeste.
    pub final_status: ManifestStatus,
}

impl PublicationExecutionReport {
    /// Indique si tous les articles éligibles sont publiés.
    pub fn is_completed(&self) -> bool {
        self.final_status == ManifestStatus::Committed
    }
}

/// Moteur de publication des manifestes approuvés.
pub struct ControlledPublisher {
    client: Surreal<Any>,
    issuer: Arc<dyn CatalogueTokenIssuer>,
    event_publisher: Option<EventPublisher>,
}

impl ControlledPublisher {
    /// `client` : client de l'hôte (session système), cloné pour chaque publication ;
    /// `issuer` : émetteur des jetons de service `catalogue_sync_agent`.
    pub fn new(client: Surreal<Any>, issuer: Arc<dyn CatalogueTokenIssuer>) -> Self {
        Self {
            client,
            issuer,
            event_publisher: None,
        }
    }

    /// Publie `ingestion.manifest.published` après un manifeste exécuté.
    pub fn with_event_publisher(mut self, publisher: EventPublisher) -> Self {
        self.event_publisher = Some(publisher);
        self
    }

    /// Publie un manifeste approuvé (ou repris en cours d'exécution) vers le catalogue.
    pub async fn publish_manifest(
        &self,
        manifest_ref: &str,
    ) -> IngestionResult<PublicationExecutionReport> {
        // 1. Session dédiée de l'agent de synchronisation
        let token = self.issuer.issue()?;
        let session = self.client.clone();
        session
            .authenticate(token.expose_secret().to_string())
            .await
            .map_err(|e| IngestionError::Surreal(LyxalSurrealError::Database(e)))?;
        let store = IngestionStore::new(session.clone());
        let catalogue = CatalogueSyncClient::new(session);

        // 2. Manifeste : approuvé, ou en cours d'exécution (reprise) ; un manifeste exécuté
        // n'est pas republié
        let manifest = store.get_manifest(manifest_ref).await?.ok_or_else(|| {
            IngestionError::Storage(format!("Manifeste '{manifest_ref}' introuvable"))
        })?;
        let staged_items = store.get_staged_items_by_batch(&manifest.batch).await?;
        if manifest.statut == ManifestStatus::Committed {
            return Ok(report(
                manifest_ref,
                &staged_items,
                manifest.items_committed,
                0,
                0,
                ManifestStatus::Committed,
            ));
        }
        if !matches!(
            manifest.statut,
            ManifestStatus::Approved | ManifestStatus::Executing
        ) {
            return Err(IngestionError::IllegalTransition(format!(
                "Publication du manifeste {manifest_ref} impossible à l'état {}",
                manifest.statut.as_str()
            )));
        }

        // 3. Intégrité : le sceau recalculé sur les articles du lot doit être celui approuvé
        let fingerprints: Vec<String> = staged_items
            .iter()
            .map(|it| it.canonical_fingerprint.clone())
            .collect();
        if FingerprintEngine::compute_manifest_seal(&fingerprints) != manifest.seal_hash {
            return Err(IngestionError::FingerprintTampered(format!(
                "Le sceau du manifeste {manifest_ref} ne correspond plus aux articles du lot {}",
                manifest.batch
            )));
        }

        // 4. Reprise : articles déjà publiés avec succès
        let already_committed: HashSet<String> = manifest
            .execution_items
            .iter()
            .filter(|e| e.get("success").and_then(|v| v.as_bool()) == Some(true))
            .filter_map(|e| {
                e.get("item_ref")
                    .and_then(|v| v.as_str())
                    .map(str::to_string)
            })
            .collect();

        // 5. Publication article par article
        let mut already_published = 0;
        let mut newly_published = 0;
        let mut failed = 0;
        for item in staged_items
            .iter()
            .filter(|i| i.qualification == ItemQualification::Verified)
        {
            let item_ref = catalogue_master_id(&item.fabricant, &item.reference_fabricant);
            if already_committed.contains(&item_ref)
                || item.publication_action == PublicationAction::Unchanged
            {
                already_published += 1;
                continue;
            }
            let refusal = match refusal_before_call(item) {
                Some(reason) => Some(reason),
                None => match catalogue.publish(item, item.publication_action).await {
                    Ok(()) => None,
                    Err(LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(err))) => {
                        Some(format!("{} : {}", err.code, err.message))
                    }
                    Err(e) => return Err(IngestionError::Surreal(e)),
                },
            };
            store
                .update_manifest_execution_item(
                    manifest_ref,
                    &item_ref,
                    item.publication_action,
                    refusal.is_none(),
                    refusal.as_deref(),
                )
                .await?;
            match refusal {
                None => newly_published += 1,
                Some(_) => failed += 1,
            }
        }

        // 6. Issue du manifeste
        let final_status = if failed == 0 {
            ManifestStatus::Committed
        } else {
            ManifestStatus::Failed
        };
        store
            .record_manifest_exec(
                manifest_ref,
                final_status,
                already_published + newly_published,
                failed,
            )
            .await?;
        if final_status == ManifestStatus::Committed {
            if let Some(ref publ) = self.event_publisher {
                let event = ManifestPublishedEvent {
                    manifest_ref: manifest_ref.to_string(),
                    batch_id: manifest.batch.clone(),
                    items_committed: already_published + newly_published,
                    items_failed: failed,
                    publisher_agent: CATALOGUE_SYNC_SUBJECT.to_string(),
                };
                publ.publish(&event).await.map_err(|e| {
                    IngestionError::Storage(format!(
                        "Événement ingestion.manifest.published non publié pour {manifest_ref} : {e}"
                    ))
                })?;
            }
        }

        Ok(report(
            manifest_ref,
            &staged_items,
            already_published,
            newly_published,
            failed,
            final_status,
        ))
    }
}

/// Motif de refus d'un article avant tout appel au catalogue.
fn refusal_before_call(item: &StagedItem) -> Option<String> {
    let eligible = item
        .commercial_proof
        .as_ref()
        .is_some_and(|proof| proof.is_eligible_for_production());
    if !eligible {
        return Some(
            "INGESTION_PROOF_INVALID : preuve commerciale absente, pilote ou synthétique, non éligible à la publication".to_string(),
        );
    }
    if item.publication_action == PublicationAction::Deprecate {
        return Some(
            "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION : le retrait d'un article du catalogue n'est pas pris en charge par la publication".to_string(),
        );
    }
    None
}

fn report(
    manifest_ref: &str,
    staged_items: &[StagedItem],
    already_published: usize,
    newly_published: usize,
    failed: usize,
    final_status: ManifestStatus,
) -> PublicationExecutionReport {
    let count = |q: ItemQualification| staged_items.iter().filter(|i| i.qualification == q).count();
    PublicationExecutionReport {
        manifest_ref: manifest_ref.to_string(),
        total_staged: staged_items.len(),
        eligible_verified: count(ItemQualification::Verified),
        skipped_to_confirm: count(ItemQualification::ToConfirm),
        skipped_rejected: count(ItemQualification::Rejected),
        already_published,
        newly_published,
        failed,
        final_status,
    }
}
