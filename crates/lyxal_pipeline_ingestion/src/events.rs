//! Événements de domaine pour le pipeline d'ingestion Lyxal OS.
//!
//! Conformes au contrat standard `lyxal_event::Event`. Tous sont émis par la base
//! (`events/01_events.surql`), dans la transaction de la transition d'état qui les motive ;
//! ces structures sont le contrat typé des consommateurs.

use lyxal_event::Event;
use serde::{Deserialize, Serialize};

/// Émis quand un lot passe à `STAGED` (intégralement normalisé et qualifié en staging).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct BatchStagedEvent {
    /// Lot (`ingestion_batch:<clé>`).
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

/// Émis quand un lot passe à `FAILED`.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct BatchFailedEvent {
    /// Lot (`ingestion_batch:<clé>`).
    pub batch_id: String,
    /// Code d'erreur interne ou master data.
    pub error_code: String,
    /// Motif détaillé de l'échec.
    pub message: String,
}

impl Event for BatchFailedEvent {
    const EVENT_TYPE: &'static str = "ingestion.batch.failed";
}

/// Événement émis par la base (`DEFINE EVENT`, `events/01_events.surql`) quand un manifeste
/// passe à l'état `APPROVED` ; il déclenche la publication vers le catalogue.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ManifestApprovedEvent {
    /// Référence du manifeste approuvé.
    pub manifest_ref: String,
    /// Lot d'origine (`ingestion_batch:<clé>`).
    pub batch_id: String,
    /// Identité de l'approbateur.
    pub approved_by: Option<String>,
    /// Sceau BLAKE3 approuvé.
    pub seal_hash: String,
}

impl Event for ManifestApprovedEvent {
    const EVENT_TYPE: &'static str = "ingestion.manifest.approved";
}

/// Émis quand un manifeste approuvé passe à `COMMITTED` (publié dans le catalogue).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ManifestPublishedEvent {
    /// Référence unique du manifeste.
    pub manifest_ref: String,
    /// Lot d'origine (`ingestion_batch:<clé>`).
    pub batch_id: String,
    /// Nombre d'articles créés ou mis à jour avec succès.
    pub items_committed: usize,
    /// Nombre d'articles ayant échoué lors de la publication.
    pub items_failed: usize,
    /// Auteur de la transition vers `COMMITTED` (identité de la session de publication).
    pub publisher_agent: String,
}

impl Event for ManifestPublishedEvent {
    const EVENT_TYPE: &'static str = "ingestion.manifest.published";
}
