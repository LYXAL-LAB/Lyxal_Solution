//! Fonctions du moteur : échéances dues, échéances traitées, prochaine échéance, rejeu de
//! période (`fn::scheduler_due_list`, `_schedule_fire`, `_schedule_next_set`, `_backfill_fire`).
//! Celles qui écrivent portent la garde de génération du bail du planificateur (`node`,
//! `generation` : Y2) et sont refusées (`SCHEDULER_LEADER_FENCED`) si ce nœud ne le tient plus.

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
    /// Création de la planification (ancre des intervalles sans `start_at`, U3).
    pub created_at: SchedulerDatetime,
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

/// Échéance remise au moteur SurrealQL : date prévue (identité de l'exécution) et date de
/// disponibilité, décalée par le décalage aléatoire (U5), jamais avant la date prévue.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct FireTime {
    /// Date prévue.
    pub at: SchedulerDatetime,
    /// Date à partir de laquelle l'exécution peut être réservée (`at` + décalage).
    pub available_at: SchedulerDatetime,
}

impl FireTime {
    /// Échéance sans décalage.
    pub fn at(at: SchedulerDatetime) -> Self {
        Self {
            available_at: at,
            at,
        }
    }
}

/// Paramètres de `fn::scheduler_schedule_fire`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleFireParams {
    /// Nœud qui détient le bail du planificateur (garde de génération).
    pub node: String,
    /// Génération du bail du planificateur détenu par ce nœud.
    pub generation: i64,
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Échéances passées calculées par `crate::spec` (1000 au plus).
    pub fire_times: Vec<FireTime>,
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
    /// Échéances ignorées parce que la limite d'exécutions en attente de la portée est atteinte
    /// (`max_pending_runs`, A4).
    pub limited: i64,
    /// Planification mise à jour.
    pub schedule: Schedule,
}

/// Paramètres de `fn::scheduler_schedule_next_set` : `next_fire_at` ou `invalid_reason`, un
/// seul des deux.
#[derive(Debug, Clone, SurrealValue)]
pub struct ScheduleNextSetParams {
    /// Nœud qui détient le bail du planificateur (garde de génération).
    pub node: String,
    /// Génération du bail du planificateur détenu par ce nœud.
    pub generation: i64,
    /// Planification.
    pub schedule: SchedulerRecordId,
    /// Prochaine échéance calculée.
    pub next_fire_at: Option<SchedulerDatetime>,
    /// Motif d'invalidité (expression ou fuseau refusés, écart de moins d'une minute U1,
    /// `no_future_fire`).
    pub invalid_reason: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_backfill_fire`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BackfillFireParams {
    /// Nœud qui détient le bail du planificateur (garde de génération, vérifiée à chaque lot).
    pub node: String,
    /// Génération du bail du planificateur détenu par ce nœud.
    pub generation: i64,
    /// Rejeu.
    pub backfill: SchedulerRecordId,
    /// Échéances de la période calculées par `crate::spec` (1000 au plus).
    pub fire_times: Vec<FireTime>,
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
    /// Échéances ignorées parce que la limite d'exécutions en attente de la portée est atteinte
    /// (`max_pending_runs`, A4).
    pub limited: i64,
    /// Rejeu mis à jour.
    pub backfill: Backfill,
}
