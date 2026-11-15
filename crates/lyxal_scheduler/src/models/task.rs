//! Tâches déclarées par les modules (`fn::scheduler_task_*`).

use lyxal_surreal::SurrealValue;
use std::collections::BTreeMap;

use super::enums::{Executor, TaskScope, TaskState};
use super::shared::RetryPolicy;
use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId, SchedulerValue};

/// Paramètres de `fn::scheduler_task_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct TaskListParams {
    /// Module propriétaire (`lyxal_<module>`).
    pub module: Option<String>,
    /// État.
    pub state: Option<TaskState>,
    /// Taille de la page (500 au plus).
    pub limit: Option<i64>,
    /// Position du premier élément.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_task_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TaskGetParams {
    /// Nom de la tâche (`<module>.<action>`).
    pub task: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_task_set_state` (session système seulement).
#[derive(Debug, Clone, SurrealValue)]
pub struct TaskSetStateParams {
    /// Nom de la tâche (`<module>.<action>`).
    pub task: String,
    /// Nouvel état.
    pub state: TaskState,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Tâche déclarée par un module (`scheduler_task`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Task {
    /// Identifiant (`scheduler_task:⟨module.action⟩`).
    pub id: SchedulerRecordId,
    /// Module propriétaire.
    pub module: String,
    /// Description par langue.
    pub description: BTreeMap<String, String>,
    /// Exécuteur.
    pub executor: Executor,
    /// Cible : handler, fonction ou type d'événement.
    pub target: String,
    /// Permission `lyxal_auth` exigée pour planifier la tâche.
    pub permission: Option<String>,
    /// Schéma des arguments (moteur de validation du Core).
    pub args_schema: Option<SchedulerValue>,
    /// File d'exécution.
    pub queue: SchedulerRecordId,
    /// Priorité par défaut (0 : la plus haute).
    pub priority: i64,
    /// Politique de tentatives.
    pub retry: RetryPolicy,
    /// Délai maximal d'une tentative.
    pub timeout: SchedulerDuration,
    /// Unicité des exécutions différées.
    pub unique_for: Option<SchedulerDuration>,
    /// Portée.
    pub scope: TaskScope,
    /// État.
    pub state: TaskState,
    /// Déclaration.
    pub created_at: SchedulerDatetime,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
}
