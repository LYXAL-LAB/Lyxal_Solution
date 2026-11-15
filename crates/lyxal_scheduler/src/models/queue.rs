//! Files d'exécution (`fn::scheduler_queue_*`).

use lyxal_surreal::SurrealValue;
use std::collections::BTreeMap;

use super::types::{SchedulerDatetime, SchedulerRecordId};

/// Paramètres de `fn::scheduler_queue_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct QueueListParams {
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_queue_pause`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueuePauseParams {
    /// Nom de la file.
    pub queue: String,
    /// Motif.
    pub reason: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_queue_resume`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueResumeParams {
    /// Nom de la file.
    pub queue: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Places occupées par une portée dans une file.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Slot {
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Places occupées.
    pub running: i64,
}

/// File d'exécution (`scheduler_queue`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Queue {
    /// Identifiant (`scheduler_queue:<nom>`).
    pub id: SchedulerRecordId,
    /// Exécutions simultanées de la file.
    pub concurrency: i64,
    /// Places occupées.
    pub running: i64,
    /// En pause.
    pub paused: bool,
    /// Motif de la pause.
    pub paused_reason: Option<String>,
    /// Description par langue.
    pub description: BTreeMap<String, String>,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
    /// Places par organisation lisibles par l'appelant (`fn::scheduler_queue_list` seulement).
    #[surreal(default)]
    pub slots: Vec<Slot>,
}
