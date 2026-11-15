//! Planifications (`fn::scheduler_schedule_*`).

use lyxal_surreal::SurrealValue;

use super::enums::{Catchup, Overlap, RunOrigin, RunState, ScheduleState};
use super::shared::{RunError, ScheduleSpec};
use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId, SchedulerValue};

/// Paramètres de `fn::scheduler_schedule_create` (à contrôler d'abord par
/// `SchedulerService::schedule_create`).
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleCreateParams {
    /// Nom (slug), unique dans sa portée.
    pub name: String,
    /// Tâche (`<module>.<action>`).
    pub task: String,
    /// Règles de dates.
    pub spec: ScheduleSpec,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Arguments de chaque exécution (objet conforme au schéma de la tâche).
    pub args: Option<SchedulerValue>,
    /// Calendriers d'exceptions de la même portée (10 au plus).
    pub calendars: Option<Vec<SchedulerRecordId>>,
    /// Chevauchement.
    pub overlap: Option<Overlap>,
    /// Rattrapage.
    pub catchup: Option<Catchup>,
    /// Fenêtre de rattrapage.
    pub catchup_window: Option<SchedulerDuration>,
    /// Exécutions restantes.
    pub remaining: Option<i64>,
    /// Pause quand une exécution finit en `dead`.
    pub pause_on_failure: Option<bool>,
    /// Créée en pause.
    pub paused: Option<bool>,
    /// Motif de la pause.
    pub paused_reason: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

impl ScheduleCreateParams {
    /// Planification minimale : nom, tâche et règles de dates.
    pub fn new(name: impl Into<String>, task: impl Into<String>, spec: ScheduleSpec) -> Self {
        Self {
            name: name.into(),
            task: task.into(),
            spec,
            tenant: None,
            args: None,
            calendars: None,
            overlap: None,
            catchup: None,
            catchup_window: None,
            remaining: None,
            pause_on_failure: None,
            paused: None,
            paused_reason: None,
            language: None,
        }
    }
}

/// Paramètres de `fn::scheduler_schedule_update` : un champ absent est conservé (à contrôler
/// d'abord par `SchedulerService::schedule_update`).
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleUpdateParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Arguments.
    pub args: Option<SchedulerValue>,
    /// Règles de dates.
    pub spec: Option<ScheduleSpec>,
    /// Calendriers.
    pub calendars: Option<Vec<SchedulerRecordId>>,
    /// Chevauchement.
    pub overlap: Option<Overlap>,
    /// Rattrapage.
    pub catchup: Option<Catchup>,
    /// Fenêtre de rattrapage.
    pub catchup_window: Option<SchedulerDuration>,
    /// Exécutions restantes.
    pub remaining: Option<i64>,
    /// Pause sur échec.
    pub pause_on_failure: Option<bool>,
    /// Champs à effacer (`catchup_window`, `remaining`, `calendars`).
    pub clear: Option<Vec<String>>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

impl ScheduleUpdateParams {
    /// Modification vide de la planification `schedule`.
    pub fn new(schedule: SchedulerRecordId) -> Self {
        Self {
            schedule,
            args: None,
            spec: None,
            calendars: None,
            overlap: None,
            catchup: None,
            catchup_window: None,
            remaining: None,
            pause_on_failure: None,
            clear: None,
            language: None,
        }
    }
}

/// Paramètres de `fn::scheduler_spec_validate`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SpecValidateParams {
    /// Organisation dont la lecture est exigée (`None` : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Règles de dates à contrôler.
    pub spec: ScheduleSpec,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::scheduler_spec_validate` : règles normalisées.
#[derive(Debug, Clone, SurrealValue)]
pub struct SpecValidateResult {
    /// Règles de dates normalisées (valeurs par défaut appliquées).
    pub spec: ScheduleSpec,
}

/// Paramètres de `fn::scheduler_schedule_get`, `_resume` et `_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleRefParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_schedule_pause`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SchedulePauseParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Motif.
    pub reason: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_schedule_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ScheduleListParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Tâche (`<module>.<action>`).
    pub task: Option<String>,
    /// État.
    pub state: Option<ScheduleState>,
    /// En pause ou non.
    pub paused: Option<bool>,
    /// Taille de la page (500 au plus).
    pub limit: Option<i64>,
    /// Position du premier élément.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_schedule_trigger`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleTriggerParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Chevauchement (défaut : celui de la planification).
    pub overlap: Option<Overlap>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_schedule_backfill`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleBackfillParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Début de la période (inclus), passé.
    pub from: SchedulerDatetime,
    /// Fin de la période (incluse), passée ; un an au plus après `from`.
    pub to: SchedulerDatetime,
    /// Chevauchement (défaut : celui de la planification).
    pub overlap: Option<Overlap>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résumé d'une exécution récente d'une planification.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RunSummary {
    /// Exécution.
    pub id: SchedulerRecordId,
    /// État.
    pub state: RunState,
    /// Origine.
    pub origin: RunOrigin,
    /// Date prévue.
    pub scheduled_for: SchedulerDatetime,
    /// Tentatives commencées.
    pub attempt: i64,
    /// Fin.
    pub finished_at: Option<SchedulerDatetime>,
    /// Dernière erreur.
    pub error: Option<RunError>,
}

/// Planification (`scheduler_schedule`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Schedule {
    /// Identifiant.
    pub id: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Nom (slug).
    pub name: String,
    /// Tâche.
    pub task: SchedulerRecordId,
    /// Arguments.
    pub args: SchedulerValue,
    /// Règles de dates.
    pub spec: ScheduleSpec,
    /// Calendriers d'exceptions.
    pub calendars: Vec<SchedulerRecordId>,
    /// Chevauchement.
    pub overlap: Overlap,
    /// Rattrapage.
    pub catchup: Catchup,
    /// Fenêtre de rattrapage (absente : réglage effectif).
    pub catchup_window: Option<SchedulerDuration>,
    /// Exécutions restantes (absent : illimité).
    pub remaining: Option<i64>,
    /// En pause.
    pub paused: bool,
    /// Motif de la pause.
    pub paused_reason: Option<String>,
    /// Pause sur échec.
    pub pause_on_failure: bool,
    /// État.
    pub state: ScheduleState,
    /// Motif d'invalidité.
    pub invalid_reason: Option<String>,
    /// Prochaine échéance (absente : à calculer).
    pub next_fire_at: Option<SchedulerDatetime>,
    /// Dernière échéance traitée.
    pub last_fire_at: Option<SchedulerDatetime>,
    /// Dernière exécution créée par une échéance.
    pub last_run: Option<SchedulerRecordId>,
    /// État de la dernière exécution.
    pub last_state: Option<RunState>,
    /// Identité qui a créé la planification.
    pub created_by: Option<SchedulerRecordId>,
    /// Création.
    pub created_at: SchedulerDatetime,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
    /// 10 dernières exécutions lisibles (lecture d'une planification seulement).
    #[surreal(default)]
    pub recent_runs: Vec<RunSummary>,
}
