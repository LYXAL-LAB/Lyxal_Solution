use crate::health::snapshot::HealthTransition;
use crate::health::status::GlobalHealthStatus;
use crate::migration::id::MigrationId;
use crate::package::types::{InstallationPhase, ModuleInstallationOutcome};
use crate::reconciler::report::ConvergenceStatus;
use crate::types::{ModuleId, ModuleState};
use crate::worker::id::WorkerId;
use crate::worker::state::WorkerExitReason;
use semver::Version;
use serde::{Deserialize, Serialize};

/// Événements liés à l'enregistrement et à l'identité des modules.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum ModuleEvent {
    Registered {
        version: String,
        description: Option<String>,
    },
}

/// Événements liés au cycle de vie opérationnel d'un module.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum LifecycleEvent {
    StateChanged { from: ModuleState, to: ModuleState },
    StartRequested,
    Started,
    StartFailed { error: String },
    StopRequested,
    Stopped,
    StopFailed { error: String },
}

/// Événements liés au pipeline d'installation et de release d'un package de module.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum InstallationEvent {
    Started {
        version: Version,
    },
    PhaseChanged {
        phase: InstallationPhase,
    },
    Completed {
        version: Version,
        outcome: ModuleInstallationOutcome,
    },
    Failed {
        version: Version,
        phase: InstallationPhase,
        error_code: String,
        message: String,
    },
}

/// Événements liés au moteur de migration de schéma.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum MigrationEvent {
    Planned {
        migration_id: MigrationId,
    },
    Applying {
        migration_id: MigrationId,
    },
    Applied {
        migration_id: MigrationId,
        duration_ms: u64,
    },
    Failed {
        migration_id: MigrationId,
        error_code: String,
        message: String,
    },
    Skipped {
        migration_id: MigrationId,
        reason: String,
    },
    LeaseRecovered {
        migration_id: MigrationId,
        generation: u64,
    },
}

/// Événements liés au moteur de santé du Runtime.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum HealthEvent {
    Transition(HealthTransition),
    SnapshotCompleted {
        global_status: GlobalHealthStatus,
        duration_ms: u64,
    },
}

/// Événements liés à la réconciliation déclarative continue.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum ReconciliationEvent {
    PassStarted {
        pass: u64,
    },
    PlanCreated {
        action_count: usize,
        blocker_count: usize,
    },
    ActionExecuted {
        module_id: ModuleId,
        action: String,
    },
    PassCompleted {
        pass: u64,
        convergence: ConvergenceStatus,
        duration_ms: u64,
    },
    PassFailed {
        pass: u64,
        error_code: String,
        message: String,
    },
}

/// Événements liés au cycle de vie supervisé des workers d'arrière-plan.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum WorkerEvent {
    Starting {
        worker_id: WorkerId,
    },
    Started {
        worker_id: WorkerId,
    },
    Stopping {
        worker_id: WorkerId,
    },
    Stopped {
        worker_id: WorkerId,
        reason: WorkerExitReason,
    },
    Failed {
        worker_id: WorkerId,
        message: String,
    },
    RestartScheduled {
        worker_id: WorkerId,
        attempt: u32,
        delay_ms: u64,
    },
    Restarted {
        worker_id: WorkerId,
        attempt: u32,
    },
    ForcedAbort {
        worker_id: WorkerId,
    },
}

/// Événements liés au système global du Runtime local.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum RuntimeSystemEvent {
    Started,
    ShutdownRequested,
    ShutdownCompleted,
}

/// Enveloppe polymorphique et fortement typée des charges utiles d'événements du Runtime.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "type", content = "data", rename_all = "snake_case")]
pub enum RuntimeEventPayload {
    Module(ModuleEvent),
    Lifecycle(LifecycleEvent),
    Installation(InstallationEvent),
    Migration(MigrationEvent),
    Health(HealthEvent),
    Reconciliation(ReconciliationEvent),
    Worker(WorkerEvent),
    Runtime(RuntimeSystemEvent),
}

impl RuntimeEventPayload {
    /// Retourne le nom de type formel du payload.
    pub fn event_type_name(&self) -> &'static str {
        match self {
            Self::Module(_) => "module",
            Self::Lifecycle(_) => "lifecycle",
            Self::Installation(_) => "installation",
            Self::Migration(_) => "migration",
            Self::Health(_) => "health",
            Self::Reconciliation(_) => "reconciliation",
            Self::Worker(_) => "worker",
            Self::Runtime(_) => "runtime",
        }
    }
}
