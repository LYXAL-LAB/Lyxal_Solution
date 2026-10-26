//! Implémentation du moteur de publication strictement contrôlée vers LYXAL Catalogue V1.1.
//!
//! Exigences de sécurité et d'intégrité :
//! - Manifeste formellement scellé par BLAKE3 et approuvé par un `steward_admin`.
//! - Authentification et autorisation de la session : rôle `catalogue_sync_agent` et scope `catalogue:sync:write`.
//! - Zéro publication directe : seuls les articles qualifiés `VERIFIED` avec preuve commerciale sont éligibles.
//! - Les articles `TO_CONFIRM` et `REJECTED` sont strictement exclus du Master Catalogue.
//! - Reprise idempotente par journalisation détaillée article par article dans `execution_items`.
//! - Aucun accès direct en écriture SQL aux tables du Master : appel exclusif des fonctions publiques autorisées.

use std::collections::HashSet;
use lyxal_event::EventPublisher;
use serde::{Deserialize, Serialize};

use crate::error::{IngestionError, IngestionResult};
use crate::events::ManifestPublishedEvent;
use crate::fingerprint::FingerprintEngine;
use crate::storage::IngestionStore;
use crate::types::{ItemQualification, ManifestStatus, PublicationAction};

/// Session d'un agent de synchronisation de catalogue.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncAgentSession {
    /// Identifiant de l'agent ou de la machine.
    pub agent_id: String,
    /// Rôle système attribué (ex: "catalogue_sync_agent").
    pub role: String,
    /// Scopes de privilèges accordés dans le token JWT.
    pub scopes: Vec<String>,
}

impl SyncAgentSession {
    /// Crée une nouvelle session d'agent.
    pub fn new(agent_id: impl Into<String>, role: impl Into<String>, scopes: Vec<String>) -> Self {
        Self {
            agent_id: agent_id.into(),
            role: role.into(),
            scopes,
        }
    }

    /// Vérifie que la session possède l'identité et les privilèges stricts requis pour la publication.
    pub fn is_authorized(&self) -> bool {
        self.role == "catalogue_sync_agent"
            && self.scopes.iter().any(|s| s == "catalogue:sync:write" || s == "*")
    }
}

/// Rapport d'exécution de la publication d'un manifeste.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct PublicationExecutionReport {
    /// Référence du manifeste traité.
    pub manifest_ref: String,
    /// Nombre total d'articles présents en staging pour le lot.
    pub total_staged: usize,
    /// Nombre d'articles éligibles car qualifiés `VERIFIED`.
    pub eligible_verified: usize,
    /// Nombre d'articles ignorés car en attente de preuve (`TO_CONFIRM`).
    pub skipped_to_confirm: usize,
    /// Nombre d'articles rejetés car non conformes (`REJECTED`).
    pub skipped_rejected: usize,
    /// Nombre d'articles déjà publiés lors d'un run précédent (idempotence).
    pub already_published: usize,
    /// Nombre d'articles nouvellement insérés ou mis à jour dans le Master Catalogue.
    pub newly_published: usize,
    /// Nombre d'articles ayant échoué à l'insertion/mise à jour.
    pub failed: usize,
    /// Indique si la publication intégrale des articles éligibles est achevée.
    pub is_completed: bool,
}

/// Moteur de publication contrôlée pour Lyxal OS.
pub struct ControlledPublisher {
    store: IngestionStore,
    event_publisher: Option<EventPublisher>,
    isolated_test_mode: bool,
}

impl ControlledPublisher {
    /// Crée un nouveau moteur de publication raccordé au store.
    pub fn new(store: IngestionStore) -> Self {
        Self {
            store,
            event_publisher: None,
            isolated_test_mode: true, // Par défaut et impérativement en mode isolé pour Phase 4
        }
    }

    /// Associe un bus d'événements pour tracer la publication du manifeste.
    pub fn with_event_publisher(mut self, publisher: EventPublisher) -> Self {
        self.event_publisher = Some(publisher);
        self
    }

    /// Active ou désactive le mode de production simulée pour éprouver les verrous de sécurité sans Master réel.
    pub fn with_simulated_production_mode(mut self, simulated_prod: bool) -> Self {
        self.isolated_test_mode = !simulated_prod;
        self
    }

    /// Exécute la publication strictement contrôlée d'un manifeste vers le Catalogue V1.1.
    pub async fn publish_manifest(
        &self,
        manifest_ref: &str,
        session: &SyncAgentSession,
    ) -> IngestionResult<PublicationExecutionReport> {
        // 1. Contrôle d'autorisation et d'identité
        if !session.is_authorized() {
            return Err(IngestionError::Unauthorized(format!(
                "Session non autorisée : rôle '{}' ou scope 'catalogue:sync:write' absent",
                session.role
            )));
        }

        // 2. Récupération du manifeste
        let manifest = self
            .store
            .get_manifest(manifest_ref)
            .await?
            .ok_or_else(|| IngestionError::Storage(format!("Manifeste '{manifest_ref}' introuvable")))?;

        // 3. Contrôle de scellement BLAKE3
        if !manifest.is_sealed || manifest.seal_hash.is_empty() {
            return Err(IngestionError::IllegalTransition(
                "Le manifeste doit être préalablement scellé par BLAKE3".to_string(),
            ));
        }

        // 4. Contrôle d'approbation préalable par le steward_admin
        if manifest.statut != ManifestStatus::Approved {
            return Err(IngestionError::IllegalTransition(format!(
                "Publication interdite : le manifeste est en statut '{}' (statut 'APPROVED' requis)",
                manifest.statut.as_str()
            )));
        }

        // 5. Récupération des articles en staging associés au lot
        let staged_items = self
            .store
            .get_staged_items_by_batch(&manifest.batch)
            .await?;

        // 6. Vérification cryptographique de l'intégrité du scellement
        let fingerprints: Vec<String> = staged_items
            .iter()
            .map(|it| it.canonical_fingerprint.clone())
            .collect();
        let expected_seal = FingerprintEngine::compute_manifest_seal(&fingerprints);
        if expected_seal != manifest.seal_hash {
            return Err(IngestionError::FingerprintTampered(
                "L'empreinte de scellement BLAKE3 du manifeste ne correspond pas aux articles du lot".to_string(),
            ));
        }

        // 7. Reprise après exécution partielle : indexation des articles déjà engagés avec succès
        let mut already_committed_refs = HashSet::new();
        for item in &manifest.execution_items {
            if let Some(success) = item.get("success").and_then(|v| v.as_bool()) {
                if success {
                    if let Some(r) = item.get("item_ref").and_then(|v| v.as_str()) {
                        already_committed_refs.insert(r.to_string());
                    }
                }
            }
        }

        let total_staged = staged_items.len();
        let mut eligible_verified = 0;
        let mut skipped_to_confirm = 0;
        let mut skipped_rejected = 0;
        let mut already_published = 0;
        let mut newly_published = 0;
        let mut failed = 0;

        // 8. Boucle de publication contrôlée article par article
        for item in &staged_items {
            match item.qualification {
                ItemQualification::ToConfirm => {
                    // RÈGLE FORMELLE CTO : ZÉRO publication d'article non prouvé commercialement
                    skipped_to_confirm += 1;
                    continue;
                }
                ItemQualification::Rejected => {
                    // RÈGLE FORMELLE CTO : ZÉRO publication d'article rejeté
                    skipped_rejected += 1;
                    continue;
                }
                ItemQualification::Verified => {
                    // VERROU DE SÉCURITÉ INVIOLABLE CTO :
                    // Interdire formellement à toute preuve pilote ou synthétique d'autoriser une publication réelle
                    if !self.isolated_test_mode {
                        let is_eligible = item
                            .commercial_proof
                            .as_ref()
                            .map_or(false, |proof| proof.is_eligible_for_production());

                        if !is_eligible {
                            let proof_ref = item
                                .commercial_proof
                                .as_ref()
                                .map(|p| p.proof_reference.as_str())
                                .unwrap_or("AUCUNE_PREUVE");

                            return Err(IngestionError::Unauthorized(format!(
                                "VERROU SÉCURITÉ PRODUCTION ACTIVÉ : Publication refusée pour l'article '{}' (preuve '{}'). Les preuves pilotes et synthétiques sont strictement interdites pour le Master réel.",
                                item.reference_fabricant, proof_ref
                            )));
                        }
                    }
                    eligible_verified += 1;
                }
            }

            // Vérification d'idempotence : l'article a-t-il déjà été publié ?
            if already_committed_refs.contains(&item.reference_fabricant) {
                already_published += 1;
                continue;
            }

            // Exécution de l'opération via l'API publique de Catalogue V1.1
            let action_str = match item.publication_action {
                PublicationAction::Insert => "fn::catalogue_item_create",
                PublicationAction::Update => "fn::catalogue_item_update",
                PublicationAction::Unchanged | PublicationAction::Deprecate => "none",
            };

            // Payload public standardisé pour les fonctions de catalogue
            let call_payload = serde_json::json!({
                "reference_fabricant": item.reference_fabricant,
                "fabricant": item.fabricant,
                "marque": item.marque,
                "libelle": item.libelle_commercial,
                "gtin": item.code_barre_gtin,
                "type_item": item.type_item,
                "unite": item.unite_reference,
                "conditionnement": item.conditionnement,
                "tenant_id": serde_json::Value::Null
            });

            // Exécution sécurisée en environnement isolé
            let exec_result = self
                .execute_catalogue_api(action_str, &call_payload)
                .await;

            match exec_result {
                Ok(_) => {
                    newly_published += 1;
                    self.store
                        .update_manifest_execution_item(
                            manifest_ref,
                            &item.reference_fabricant,
                            action_str,
                            true,
                            None,
                        )
                        .await?;
                }
                Err(err) => {
                    failed += 1;
                    self.store
                        .update_manifest_execution_item(
                            manifest_ref,
                            &item.reference_fabricant,
                            action_str,
                            false,
                            Some(&err.to_string()),
                        )
                        .await?;
                }
            }
        }

        let is_completed = failed == 0 && (already_published + newly_published) == eligible_verified;

        // 9. Si tous les articles vérifiés ont été publiés sans erreur, sceller la transition finale à COMMITTED via fn::ingestion_manifest_record_exec
        if is_completed {
            self.store
                .record_manifest_exec(
                    manifest_ref,
                    ManifestStatus::Committed,
                    newly_published + already_published,
                    failed,
                )
                .await?;

            // 10. Émission de l'événement de domaine
            if let Some(ref publ) = self.event_publisher {
                let event = ManifestPublishedEvent {
                    manifest_ref: manifest_ref.to_string(),
                    batch_id: manifest.batch.clone(),
                    items_committed: newly_published + already_published,
                    items_failed: failed,
                    publisher_agent: session.agent_id.clone(),
                };
                let _ = publ.publish(&event).await;
            }
        }

        Ok(PublicationExecutionReport {
            manifest_ref: manifest_ref.to_string(),
            total_staged,
            eligible_verified,
            skipped_to_confirm,
            skipped_rejected,
            already_published,
            newly_published,
            failed,
            is_completed,
        })
    }

    /// Exécute l'appel de fonction publique du Catalogue dans l'environnement SurrealDB isolé.
    async fn execute_catalogue_api(
        &self,
        function_name: &str,
        payload: &serde_json::Value,
    ) -> IngestionResult<()> {
        if !self.isolated_test_mode {
            return Err(IngestionError::Unauthorized(
                "Interdiction CTO formelle de publier dans le Master de production !".to_string(),
            ));
        }

        // Simulation/exécution de l'API publique en environnement isolé
        // On effectue un appel typé SurrealDB sans toucher aux tables de prod
        let query = format!("RETURN {{ function_called: '{function_name}', status: 'OK', payload: $p }};");
        let mut res = self
            .store
            .client()
            .query(query)
            .bind(("p", payload.clone()))
            .await
            .map_err(|e| IngestionError::Storage(format!("Échec appel API catalogue {function_name} : {e}")))?;

        let val: Option<serde_json::Value> = res
            .take(0)
            .map_err(|e| IngestionError::Storage(format!("Erreur retour fonction catalogue : {e}")))?;

        if val.is_none() {
            return Err(IngestionError::Storage(format!(
                "La fonction {function_name} a renvoyé un résultat vide"
            )));
        }

        Ok(())
    }
}
