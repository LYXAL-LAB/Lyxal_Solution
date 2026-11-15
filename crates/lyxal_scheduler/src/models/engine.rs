//! Fonctions du moteur : échéances dues, échéances traitées, prochaine échéance, rejeu de
//! période (`fn::scheduler_due_list`, `_schedule_fire`, `_schedule_next_set`, `_backfill_fire`).

use lyxal_surreal::SurrealValue;

use super::enums::{BackfillState, Catchup, Overlap, RunState};
use super::schedule::Schedule;
use super::shared::{CalendarRules, ScheduleSpec};
use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId};

/// Paramètres de `fn::scheduler_due_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct DueListParams {
    /// Nombre maximal de planifications et de rejeux (1000 au plus).
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Planification due, avec ce que le calcul des dates en demande.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DueSchedule {
    /// Planification.
    pub id: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Tâche.
    pub task: SchedulerRecordId,
    /// Règles de dates.
    pub spec: ScheduleSpec,
    /// Règles de ses calendriers.
    pub calendars: Vec<CalendarRules>,
    /// Rattrapage.
    pub catchup: Catchup,
    /// Fenêtre de rattrapage effective.
    pub catchup_window: SchedulerDuration,
    /// Prochaine échéance (absente : à calculer).
    pub next_fire_at: Option<SchedulerDatetime>,
    /// Dernière échéance traitée.
    pub last_fire_at: Option<SchedulerDatetime>,
    /// Création (ancre des intervalles sans `start_at`, U3).
    pub created_at: SchedulerDatetime,
}

/// Rejeu de période en attente ou en cours, avec les règles de sa planification.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DueBackfill {
    /// Rejeu.
    pub id: SchedulerRecordId,
    /// Planification rejouée.
    pub schedule: SchedulerRecordId,
    /// Début de la période (inclus).
    pub from: SchedulerDatetime,
    /// Fin de la période (incluse).
    pub to: SchedulerDatetime,
    /// Chevauchement (absent : celui de la planification).
    pub overlap: Option<Overlap>,
    /// État.
    pub state: BackfillState,
    /// Règles de dates de la planification.
    pub spec: ScheduleSpec,
    /// Règles des calendriers de la planification.
    pub calendars: Vec<CalendarRules>,
}

/// Résultat de `fn::scheduler_due_list`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DueList {
    /// Instant de la lecture (horloge de la base).
    pub now: SchedulerDatetime,
    /// Planifications dues.
    pub schedules: Vec<DueSchedule>,
    /// Rejeux en attente ou en cours.
    pub backfills: Vec<DueBackfill>,
}

/// Paramètres de `fn::scheduler_schedule_fire`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleFireParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Échéances passées calculées par `crate::spec` (1000 au plus).
    pub fire_times: Vec<SchedulerDatetime>,
    /// Prochaine échéance (absente : plus aucune, la planification est terminée).
    pub next_fire_at: Option<SchedulerDatetime>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Exécution créée par une échéance ou un rejeu.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct FiredRun {
    /// Exécution (`scheduler_run:[planification, date]`).
    pub id: SchedulerRecordId,
    /// État après le chevauchement.
    pub state: RunState,
    /// Date prévue.
    pub scheduled_for: SchedulerDatetime,
}

/// Résultat de `fn::scheduler_schedule_fire`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct FireResult {
    /// Exécutions créées.
    pub runs: Vec<FiredRun>,
    /// Échéances fournies sans exécution créée (rattrapage, doublon, limite).
    pub ignored: i64,
    /// Planification mise à jour.
    pub schedule: Schedule,
}

/// Paramètres de `fn::scheduler_schedule_next_set` : `next_fire_at` ou `invalid_reason`, un
/// seul des deux.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleNextSetParams {
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Prochaine échéance calculée.
    pub next_fire_at: Option<SchedulerDatetime>,
    /// Motif d'invalidité (expression ou fuseau refusés, `no_future_fire`).
    pub invalid_reason: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_backfill_fire`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BackfillFireParams {
    /// Rejeu.
    pub backfill: SchedulerRecordId,
    /// Échéances de la période calculées par `crate::spec` (1000 au plus).
    pub fire_times: Vec<SchedulerDatetime>,
    /// Dernier lot du rejeu.
    pub done: Option<bool>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Rejeu de période (`scheduler_backfill`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Backfill {
    /// Identifiant.
    pub id: SchedulerRecordId,
    /// Planification rejouée.
    pub schedule: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Début de la période (inclus).
    pub from: SchedulerDatetime,
    /// Fin de la période (incluse).
    pub to: SchedulerDatetime,
    /// Chevauchement (absent : celui de la planification).
    pub overlap: Option<Overlap>,
    /// État.
    pub state: BackfillState,
    /// Exécutions créées.
    pub runs_created: i64,
    /// Identité qui a demandé le rejeu.
    pub requested_by: Option<SchedulerRecordId>,
    /// Demande.
    pub created_at: SchedulerDatetime,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
}

/// Résultat de `fn::scheduler_backfill_fire`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct BackfillFireResult {
    /// Exécutions créées.
    pub runs: Vec<FiredRun>,
    /// Rejeu mis à jour.
    pub backfill: Backfill,
}
