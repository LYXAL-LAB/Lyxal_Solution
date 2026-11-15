//! Accès aux fonctions SurrealQL de `lyxal_scheduler` : un appel typé d'une ligne par fonction
//! publique (`LyxalSurrealCall::call_fn`). Les règles (droits, états, chevauchement, rattrapage)
//! restent dans SurrealQL ; la session SurrealDB du client détermine l'appelant.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    AuditEntry, AuditListParams, Backfill, BackfillFireParams, BackfillFireResult, Calendar, CalendarCreateParams, CalendarListParams, CalendarRefParams, CalendarUpdateParams, ClaimResult, Deleted, DueList, DueListParams, FireResult, Heartbeat, Page, PruneResult, Queue, QueueListParams, QueuePauseParams, QueueResumeParams, RescueResult, Run, RunCancelParams, RunClaimParams, RunCompleteParams, RunEnqueueParams, RunFailParams, RunHeartbeatParams, RunListParams, RunPruneParams, RunRefParams, RunRescueParams, Schedule, ScheduleBackfillParams, ScheduleCreateParams, ScheduleFireParams, ScheduleListParams, ScheduleNextSetParams, SchedulePauseParams, ScheduleRefParams, ScheduleTriggerParams, ScheduleUpdateParams, SettingsGetParams, SettingsResult, SettingsSetParams, Task, TaskGetParams, TaskListParams, TaskSetStateParams,
};

/// Store de `lyxal_scheduler` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct SchedulerStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for SchedulerStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

type Call<T> = Result<T, LyxalSurrealError>;

impl SchedulerStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// `fn::scheduler_settings_get` : réglages enregistrés et effectifs d'une portée.
    pub async fn settings_get(&self, params: SettingsGetParams) -> Call<SettingsResult> {
        self.call_fn("scheduler_settings_get", params).await
    }

    /// `fn::scheduler_settings_set` : réglages d'une portée enregistrés.
    pub async fn settings_set(&self, params: SettingsSetParams) -> Call<SettingsResult> {
        self.call_fn("scheduler_settings_set", params).await
    }

    /// `fn::scheduler_task_list` : tâches déclarées.
    pub async fn task_list(&self, params: TaskListParams) -> Call<Page<Task>> {
        self.call_fn("scheduler_task_list", params).await
    }

    /// `fn::scheduler_task_get` : tâche d'après son nom.
    pub async fn task_get(&self, params: TaskGetParams) -> Call<Task> {
        self.call_fn("scheduler_task_get", params).await
    }

    /// `fn::scheduler_task_set_state` : tâche activée ou désactivée (session système).
    pub async fn task_set_state(&self, params: TaskSetStateParams) -> Call<Task> {
        self.call_fn("scheduler_task_set_state", params).await
    }

    /// `fn::scheduler_queue_list` : files et leurs places occupées.
    pub async fn queue_list(&self, params: QueueListParams) -> Call<Vec<Queue>> {
        self.call_fn("scheduler_queue_list", params).await
    }

    /// `fn::scheduler_queue_pause` : file mise en pause.
    pub async fn queue_pause(&self, params: QueuePauseParams) -> Call<Queue> {
        self.call_fn("scheduler_queue_pause", params).await
    }

    /// `fn::scheduler_queue_resume` : file reprise.
    pub async fn queue_resume(&self, params: QueueResumeParams) -> Call<Queue> {
        self.call_fn("scheduler_queue_resume", params).await
    }

    /// `fn::scheduler_calendar_create` : calendrier créé (règles lisibles par le calcul des dates : `crate::spec::CalendarSet::parse`).
    pub async fn calendar_create(&self, params: CalendarCreateParams) -> Call<Calendar> {
        self.call_fn("scheduler_calendar_create", params).await
    }

    /// `fn::scheduler_calendar_update` : calendrier modifié.
    pub async fn calendar_update(&self, params: CalendarUpdateParams) -> Call<Calendar> {
        self.call_fn("scheduler_calendar_update", params).await
    }

    /// `fn::scheduler_calendar_get` : calendrier et planifications qui l'utilisent.
    pub async fn calendar_get(&self, params: CalendarRefParams) -> Call<Calendar> {
        self.call_fn("scheduler_calendar_get", params).await
    }

    /// `fn::scheduler_calendar_list` : calendriers d'une portée.
    pub async fn calendar_list(&self, params: CalendarListParams) -> Call<Page<Calendar>> {
        self.call_fn("scheduler_calendar_list", params).await
    }

    /// `fn::scheduler_calendar_delete` : calendrier supprimé.
    pub async fn calendar_delete(&self, params: CalendarRefParams) -> Call<Deleted> {
        self.call_fn("scheduler_calendar_delete", params).await
    }

    /// `fn::scheduler_schedule_create` : planification créée, sans contrôle des dates (passer par `SchedulerService::schedule_create`).
    pub async fn schedule_create(&self, params: ScheduleCreateParams) -> Call<Schedule> {
        self.call_fn("scheduler_schedule_create", params).await
    }

    /// `fn::scheduler_schedule_update` : planification modifiée, sans contrôle des dates (passer par `SchedulerService::schedule_update`).
    pub async fn schedule_update(&self, params: ScheduleUpdateParams) -> Call<Schedule> {
        self.call_fn("scheduler_schedule_update", params).await
    }

    /// `fn::scheduler_schedule_get` : planification et ses 10 dernières exécutions.
    pub async fn schedule_get(&self, params: ScheduleRefParams) -> Call<Schedule> {
        self.call_fn("scheduler_schedule_get", params).await
    }

    /// `fn::scheduler_schedule_list` : planifications d'une portée.
    pub async fn schedule_list(&self, params: ScheduleListParams) -> Call<Page<Schedule>> {
        self.call_fn("scheduler_schedule_list", params).await
    }

    /// `fn::scheduler_schedule_pause` : planification mise en pause.
    pub async fn schedule_pause(&self, params: SchedulePauseParams) -> Call<Schedule> {
        self.call_fn("scheduler_schedule_pause", params).await
    }

    /// `fn::scheduler_schedule_resume` : planification reprise.
    pub async fn schedule_resume(&self, params: ScheduleRefParams) -> Call<Schedule> {
        self.call_fn("scheduler_schedule_resume", params).await
    }

    /// `fn::scheduler_schedule_delete` : planification supprimée.
    pub async fn schedule_delete(&self, params: ScheduleRefParams) -> Call<Deleted> {
        self.call_fn("scheduler_schedule_delete", params).await
    }

    /// `fn::scheduler_schedule_trigger` : exécution immédiate d'une planification.
    pub async fn schedule_trigger(&self, params: ScheduleTriggerParams) -> Call<Run> {
        self.call_fn("scheduler_schedule_trigger", params).await
    }

    /// `fn::scheduler_schedule_backfill` : rejeu d'une période passée demandé.
    pub async fn schedule_backfill(&self, params: ScheduleBackfillParams) -> Call<Backfill> {
        self.call_fn("scheduler_schedule_backfill", params).await
    }

    /// `fn::scheduler_run_enqueue` : exécution différée ou immédiate d'une tâche.
    pub async fn run_enqueue(&self, params: RunEnqueueParams) -> Call<Run> {
        self.call_fn("scheduler_run_enqueue", params).await
    }

    /// `fn::scheduler_run_get` : exécution.
    pub async fn run_get(&self, params: RunRefParams) -> Call<Run> {
        self.call_fn("scheduler_run_get", params).await
    }

    /// `fn::scheduler_run_list` : exécutions d'une portée.
    pub async fn run_list(&self, params: RunListParams) -> Call<Page<Run>> {
        self.call_fn("scheduler_run_list", params).await
    }

    /// `fn::scheduler_run_cancel` : exécution annulée, ou annulation demandée.
    pub async fn run_cancel(&self, params: RunCancelParams) -> Call<Run> {
        self.call_fn("scheduler_run_cancel", params).await
    }

    /// `fn::scheduler_run_retry` : nouvelle exécution d'une exécution terminée en échec ou annulée.
    pub async fn run_retry(&self, params: RunRefParams) -> Call<Run> {
        self.call_fn("scheduler_run_retry", params).await
    }

    /// `fn::scheduler_audit_list` : entrées du journal.
    pub async fn audit_list(&self, params: AuditListParams) -> Call<Page<AuditEntry>> {
        self.call_fn("scheduler_audit_list", params).await
    }

    /// `fn::scheduler_due_list` : moteur : planifications dues et rejeux en cours.
    pub async fn due_list(&self, params: DueListParams) -> Call<DueList> {
        self.call_fn("scheduler_due_list", params).await
    }

    /// `fn::scheduler_schedule_fire` : moteur : échéances d'une planification traitées.
    pub async fn schedule_fire(&self, params: ScheduleFireParams) -> Call<FireResult> {
        self.call_fn("scheduler_schedule_fire", params).await
    }

    /// `fn::scheduler_schedule_next_set` : moteur : prochaine échéance écrite, ou planification invalide.
    pub async fn schedule_next_set(&self, params: ScheduleNextSetParams) -> Call<Schedule> {
        self.call_fn("scheduler_schedule_next_set", params).await
    }

    /// `fn::scheduler_backfill_fire` : moteur : exécutions d'un rejeu créées.
    pub async fn backfill_fire(&self, params: BackfillFireParams) -> Call<BackfillFireResult> {
        self.call_fn("scheduler_backfill_fire", params).await
    }

    /// `fn::scheduler_run_claim` : moteur : exécutions réservées sous bail.
    pub async fn run_claim(&self, params: RunClaimParams) -> Call<ClaimResult> {
        self.call_fn("scheduler_run_claim", params).await
    }

    /// `fn::scheduler_run_heartbeat` : moteur : bail prolongé.
    pub async fn run_heartbeat(&self, params: RunHeartbeatParams) -> Call<Heartbeat> {
        self.call_fn("scheduler_run_heartbeat", params).await
    }

    /// `fn::scheduler_run_complete` : moteur : exécution terminée avec succès.
    pub async fn run_complete(&self, params: RunCompleteParams) -> Call<Run> {
        self.call_fn("scheduler_run_complete", params).await
    }

    /// `fn::scheduler_run_fail` : moteur : tentative terminée en échec.
    pub async fn run_fail(&self, params: RunFailParams) -> Call<Run> {
        self.call_fn("scheduler_run_fail", params).await
    }

    /// `fn::scheduler_run_rescue` : moteur : exécutions au bail expiré reprises.
    pub async fn run_rescue(&self, params: RunRescueParams) -> Call<RescueResult> {
        self.call_fn("scheduler_run_rescue", params).await
    }

    /// `fn::scheduler_run_prune` : moteur : exécutions terminées élaguées.
    pub async fn run_prune(&self, params: RunPruneParams) -> Call<PruneResult> {
        self.call_fn("scheduler_run_prune", params).await
    }
}
