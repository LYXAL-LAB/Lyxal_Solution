//! Contrats publics des fonctions SurrealQL `fn::infra_*` : paramètres (`XxxParams`) et
//! résultats. Les identifiants transmis sont des textes `table:clé` (règle `record` de
//! `lyxal_core`) ; ceux qui sont rendus sont des `RecordId`.

mod account;
mod change;
mod record;
mod settings;
mod types;
mod worker;
mod zone;

pub use account::{
    AccountCreateParams, AccountDeleted, AccountListParams, AccountListResult, AccountRefParams,
    AccountResult, AccountState, AccountTest, AccountUpdateParams, DiscoveredZone,
    ScalewaySettings,
};
pub use change::{
    ChangeEntry, ChangeListParams, ChangeListResult, ChangeState, ChangeVerifyParams,
    ChangeVerifyResult,
};
pub use record::{
    ConflictAction, ConflictResolveParams, DeclaredItem, DeclaredRecord, ObservedValue,
    RecordConflict, RecordError, RecordListParams, RecordListResult, RecordRefParams,
    RecordResolution, RecordResult, RecordStatus, RecordsDeclareParams, RecordsDeclareResult,
    RecordsReleaseParams, RecordsReleaseResult, RecordsStatusParams, RecordsStatusResult,
    RecordsSubjectsParams, RecordsSubjectsResult,
};
pub use settings::{SettingsGetParams, SettingsResult, SettingsUpdateParams};
pub use types::{
    ChangeAction, InfraDatetime, InfraRecordId, InfraUuid, RecordMode, RecordState, RecordType,
};
pub use worker::{
    AccountDue, AccountDueList, AccountTestOutcome, AccountTestResultParams, ApplyBeginParams,
    ApplyBegun, ApplyOutcome, ApplyResult, ApplyResultParams, ClaimedAccount, HealthParams,
    HealthResult, HealthStatus, ObservedRecord, PassOutcome, PlanReason, PlanStates,
    ProviderZoneStatus, PurgeResult, RecordOutcome, SentChange, VerifyItem, VerifyList,
    VerifyOutcome, VerifyResultParams, WorkerBatchParams, ZoneClaim, ZoneClaimParams,
    ZoneClaimRefParams, ZoneDue, ZoneDueList, ZoneObserveParams, ZoneObserved, ZonePlanResult,
    ZoneReleaseParams, ZoneReleased, ZoneRenewParams, ZoneRenewed,
};
pub use zone::{
    LastPlan, PlannedChange, PlannedConflict, ZoneAttachParams, ZoneCounts, ZoneDetachParams,
    ZoneDetachResult, ZoneError, ZoneListParams, ZoneListResult, ZoneMode, ZonePlanApproveParams,
    ZoneReconcileRequested, ZoneRecordRow, ZoneRecordsParams, ZoneRecordsResult, ZoneRefParams,
    ZoneResult, ZoneState, ZoneUpdateParams,
};
