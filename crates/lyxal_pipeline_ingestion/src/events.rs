//! Événements de domaine pour le pipeline d'ingestion Lyxal OS.
//!
//! Conformes au contrat standard `lyxal_event::Event`.

use lyxal_event::Event;
use serde::{Deserialize, Serialize};

/// Événement émis lorsqu'un lot de données a été intégralement normalisé et qualifié en staging.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct BatchStagedEvent {
    /// Identifiant du lot.
    pub batch_id: String,
    /// Format ou type de la source (FAB-DIS, CSV, XML, JSON).
    pub source_type: String,
    /// Nombre total de lignes traitées.
    pub total_lignes: usize,
    /// Nombre de lignes qualifiées VERIFIED avec preuve commerciale.
    pub verified_count: usize,
    /// Nombre de lignes maintenues en TO_CONFIRM.
    pub to_confirm_count: usize,
    /// Nombre de lignes rejetées REJECTED (en quarantaine).
    pub rejected_count: usize,
}

impl Event for BatchStagedEvent {
    const EVENT_TYPE: &'static str = "ingestion.batch.staged";
}

/// Événement émis lorsqu'un lot rencontre un échec fatal irréversible.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct BatchFailedEvent {
    /// Identifiant du lot.
    pub batch_id: String,
    /// Code d'erreur interne ou master data.
    pub error_code: String,
    /// Motif détaillé de l'échec.
    pub message: String,
}

impl Event for BatchFailedEvent {
    const EVENT_TYPE: &'static str = "ingestion.batch.failed";
}

/// Événement émis lorsqu'un manifeste scellé et approuvé est publié dans le Catalogue.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ManifestPublishedEvent {
    /// Référence unique du manifeste.
    pub manifest_ref: String,
    /// Identifiant du lot d'origine.
    pub batch_id: String,
    /// Nombre d'articles créés ou mis à jour avec succès.
    pub items_committed: usize,
    /// Nombre d'articles ayant échoué lors de la publication.
    pub items_failed: usize,
    /// Identité de l'agent ayant exécuté la synchronisation (ex: "catalogue_sync_agent").
    pub publisher_agent: String,
}

impl Event for ManifestPublishedEvent {
    const EVENT_TYPE: &'static str = "ingestion.manifest.published";
}
