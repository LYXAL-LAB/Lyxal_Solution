//! Exécutions (`fn::scheduler_run_*` des personnes et des modules).

use lyxal_surreal::SurrealValue;

use super::enums::{RunOrigin, RunState};
use super::shared::RunError;
use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId, SchedulerValue};

/// Paramètres de `fn::scheduler_run_enqueue` : `run_at` ou `delay`, pas les deux.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunEnqueueParams {
    /// Tâche (`<module>.<action>`).
    pub task: String,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Arguments (objet conforme au schéma de la tâche).
    pub args: Option<SchedulerValue>,
    /// Date d'exécution, future.
    pub run_at: Option<SchedulerDatetime>,
    /// Délai avant l'exécution (1 s à 366 jours).
    pub delay: Option<SchedulerDuration>,
    /// Priorité (0 à 9 ; défaut : celle de la tâche).
    pub priority: Option<i64>,
    /// Clé d'unicité (défaut : empreinte des arguments pour une tâche `unique_for`).
    pub unique_key: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

impl RunEnqueueParams {
    /// Exécution immédiate de la tâche `task`, sans argument.
    pub fn new(task: impl Into<String>) -> Self {
        Self {
            task: task.into(),
            tenant: None,
            args: None,
            run_at: None,
            delay: None,
            priority: None,
            unique_key: None,
            language: None,
        }
    }
}

/// Paramètres de `fn::scheduler_run_get` et `fn::scheduler_run_retry`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunRefParams {
    /// Exécution.
    pub run: SchedulerRecordId,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_run_ref` : forme texte SurrealQL complète d'un identifiant
/// d'exécution (`scheduler_run:clé` ou `scheduler_run:[planification, date]`).
#[derive(Debug, Clone, SurrealValue)]
pub struct RunRefTextParams {
    /// Identifiant SurrealQL complet, en texte.
    pub run: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_run_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RunListParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Planification.
    pub schedule: Option<SchedulerRecordId>,
    /// Tâche (`<module>.<action>`).
    pub task: Option<String>,
    /// État.
    pub state: Option<RunState>,
    /// Date prévue minimale.
    pub since: Option<SchedulerDatetime>,
    /// Taille de la page (500 au plus).
    pub limit: Option<i64>,
    /// Position du premier élément.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_run_cancel`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunCancelParams {
    /// Exécution.
    pub run: SchedulerRecordId,
    /// Motif.
    pub reason: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Exécution (`scheduler_run`), sans le jeton de bail.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Run {
    /// Identifiant (`scheduler_run:[planification, date]` pour une échéance).
    pub id: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Planification d'origine.
    pub schedule: Option<SchedulerRecordId>,
    /// Tâche.
    pub task: SchedulerRecordId,
    /// Arguments.
    pub args: SchedulerValue,
    /// File.
    pub queue: SchedulerRecordId,
    /// Priorité.
    pub priority: i64,
    /// Origine.
    pub origin: RunOrigin,
    /// Date prévue (identité de l'échéance).
    pub scheduled_for: SchedulerDatetime,
    /// Date à partir de laquelle la tentative suivante peut être réservée.
    pub available_at: SchedulerDatetime,
    /// État.
    pub state: RunState,
    /// Tentatives commencées.
    pub attempt: i64,
    /// Tentatives permises.
    pub max_attempts: i64,
    /// Clé d'unicité.
    pub unique_key: Option<String>,
    /// Nœud qui détient le bail.
    pub lease_node: Option<String>,
    /// Échéance du bail.
    pub locked_until: Option<SchedulerDatetime>,
    /// Annulation demandée pendant l'exécution.
    pub cancel_requested: bool,
    /// Motif de l'annulation.
    pub cancel_reason: Option<String>,
    /// Début de la dernière tentative.
    pub started_at: Option<SchedulerDatetime>,
    /// Fin.
    pub finished_at: Option<SchedulerDatetime>,
    /// Durée de la dernière tentative, en millisecondes.
    pub duration_ms: Option<i64>,
    /// Résultat court.
    pub result: Option<SchedulerValue>,
    /// Dernière erreur.
    pub error: Option<RunError>,
    /// Identité à l'origine de l'exécution.
    pub created_by: Option<SchedulerRecordId>,
    /// Création.
    pub created_at: SchedulerDatetime,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
    /// Exécution existante rendue par l'unicité (`fn::scheduler_run_enqueue` seulement).
    pub duplicate: Option<bool>,
    /// Exécution relancée (relance seulement : `origin` vaut `retry`).
    pub retry_of: Option<SchedulerRecordId>,
}
