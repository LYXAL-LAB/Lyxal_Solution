//! Contrats des fonctions SurrealQL `fn::scheduler_*` : paramètres (`XxxParams`), dont les
//! champs portent exactement les noms lus dans `$params`, et résultats décodés depuis `data`.
//! Un champ facultatif absent (`None`) prend la valeur par défaut de SurrealQL.

mod audit;
mod calendar;
mod engine;
mod enums;
mod queue;
mod run;
mod schedule;
mod settings;
mod shared;
mod task;
mod types;
mod worker;

pub use audit::{AuditEntry, AuditListParams};
pub use calendar::{
    Calendar, CalendarCreateParams, CalendarListParams, CalendarRefParams, CalendarUpdateParams,
};
pub use engine::{
    Backfill, BackfillFireParams, BackfillFireResult, DueBackfill, DueList, DueListParams,
    DueSchedule, FireResult, FiredRun, ScheduleFireParams, ScheduleNextSetParams,
};
pub use enums::{
    BackfillState, Catchup, Executor, Overlap, RetryStrategy, RuleKind, RuleMode, RunOrigin,
    RunState, ScheduleState, TaskScope, TaskState,
};
pub use queue::{Queue, QueueListParams, QueuePauseParams, QueueResumeParams, Slot};
pub use run::{Run, RunCancelParams, RunEnqueueParams, RunListParams, RunRefParams};
pub use schedule::{
    RunSummary, Schedule, ScheduleBackfillParams, ScheduleCreateParams, ScheduleListParams,
    SchedulePauseParams, ScheduleRefParams, ScheduleTriggerParams, ScheduleUpdateParams,
};
pub use settings::{Settings, SettingsGetParams, SettingsResult, SettingsSetParams, StoredSettings};
pub use shared::{CalendarRule, CalendarRules, Deleted, Page, RetryPolicy, RunError, ScheduleSpec};
pub use task::{Task, TaskGetParams, TaskListParams, TaskSetStateParams};
pub use types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId, SchedulerValue};
pub use worker::{
    ClaimResult, ClaimedRun, Heartbeat, LeaseToken, PruneResult, RescueResult, RescuedRun,
    RunClaimParams, RunCompleteParams, RunFailParams, RunFailure, RunHeartbeatParams,
    RunPruneParams, RunRescueParams,
};
