use lyxal_runtime::event::id::RuntimeEventId;
use lyxal_runtime::event::kind::RuntimeEventKind;
use lyxal_runtime::event::payload::*;
use lyxal_runtime::health::snapshot::HealthTransition;
use lyxal_runtime::health::status::{GlobalHealthStatus, HealthStatus};
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::migration::id::MigrationId;
use lyxal_runtime::package::types::{InstallationPhase, ModuleInstallationOutcome};
use lyxal_runtime::reconciler::report::ConvergenceStatus;
use lyxal_runtime::types::{ModuleId, ModuleState};
use lyxal_runtime::worker::id::WorkerId;
use lyxal_runtime::worker::state::WorkerExitReason;
use lyxal_runtime::RuntimeEvent;
use semver::Version;
use std::collections::HashSet;

#[test]
fn test_event_id_uniqueness() {
    let mut set = HashSet::new();
    for _ in 0..2000 {
        let id = RuntimeEventId::generate();
        assert!(set.insert(id.as_str().to_string()));
    }
    assert_eq!(set.len(), 2000);
}

#[test]
fn test_event_kind_mapping() {
    let kinds = [
        (RuntimeEventKind::Module, "module"),
        (RuntimeEventKind::Lifecycle, "lifecycle"),
        (RuntimeEventKind::Installation, "installation"),
        (RuntimeEventKind::Migration, "migration"),
        (RuntimeEventKind::Health, "health"),
        (RuntimeEventKind::Reconciliation, "reconciliation"),
        (RuntimeEventKind::Worker, "worker"),
        (RuntimeEventKind::Runtime, "runtime"),
    ];

    for (kind, expected_str) in kinds {
        assert_eq!(kind.as_str(), expected_str);
        assert_eq!(kind.to_string(), expected_str);

        // Serde roundtrip
        let json = serde_json::to_string(&kind).unwrap();
        assert_eq!(json, format!("\"{}\"", expected_str));
        let deserialized: RuntimeEventKind = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized, kind);
    }
}

#[test]
fn test_event_serialization_roundtrip() {
    let node_id = NodeId::new("node-test");
    let mod_id = ModuleId::new("lyxal-booking");
    let worker_id = WorkerId::new(&mod_id, "calendar-sync").unwrap();
    let mig_id = MigrationId::new("001_create_tables").unwrap();

    let payloads = vec![
        RuntimeEventPayload::Module(ModuleEvent::Registered {
            version: "1.0.0".to_string(),
            description: Some("Booking module".to_string()),
        }),
        RuntimeEventPayload::Lifecycle(LifecycleEvent::StateChanged {
            from: ModuleState::Installed,
            to: ModuleState::Starting,
        }),
        RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
        RuntimeEventPayload::Installation(InstallationEvent::Started {
            version: Version::parse("1.2.0").unwrap(),
        }),
        RuntimeEventPayload::Installation(InstallationEvent::PhaseChanged {
            phase: InstallationPhase::Migration,
        }),
        RuntimeEventPayload::Installation(InstallationEvent::Completed {
            version: Version::parse("1.2.0").unwrap(),
            outcome: ModuleInstallationOutcome::Installed,
        }),
        RuntimeEventPayload::Migration(MigrationEvent::Applying {
            migration_id: mig_id.clone(),
        }),
        RuntimeEventPayload::Migration(MigrationEvent::Applied {
            migration_id: mig_id.clone(),
            duration_ms: 45,
        }),
        RuntimeEventPayload::Health(HealthEvent::Transition(HealthTransition {
            module_id: mod_id.clone(),
            from: HealthStatus::Healthy,
            to: HealthStatus::Unhealthy,
            timestamp: "2026-09-01T12:00:00Z".to_string(),
        })),
        RuntimeEventPayload::Health(HealthEvent::SnapshotCompleted {
            global_status: GlobalHealthStatus::Healthy,
            duration_ms: 12,
        }),
        RuntimeEventPayload::Reconciliation(ReconciliationEvent::PassStarted { pass: 1 }),
        RuntimeEventPayload::Reconciliation(ReconciliationEvent::PassCompleted {
            pass: 1,
            convergence: ConvergenceStatus::Converged,
            duration_ms: 100,
        }),
        RuntimeEventPayload::Worker(WorkerEvent::Starting {
            worker_id: worker_id.clone(),
        }),
        RuntimeEventPayload::Worker(WorkerEvent::Stopped {
            worker_id: worker_id.clone(),
            reason: WorkerExitReason::Completed,
        }),
        RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
    ];

    for (seq, payload) in payloads.into_iter().enumerate() {
        let event = RuntimeEvent {
            id: RuntimeEventId::generate(),
            sequence: (seq + 1) as u64,
            node_id: node_id.clone(),
            timestamp_ms: 1700000000000 + (seq as u64),
            kind: match &payload {
                RuntimeEventPayload::Module(_) => RuntimeEventKind::Module,
                RuntimeEventPayload::Lifecycle(_) => RuntimeEventKind::Lifecycle,
                RuntimeEventPayload::Installation(_) => RuntimeEventKind::Installation,
                RuntimeEventPayload::Migration(_) => RuntimeEventKind::Migration,
                RuntimeEventPayload::Health(_) => RuntimeEventKind::Health,
                RuntimeEventPayload::Reconciliation(_) => RuntimeEventKind::Reconciliation,
                RuntimeEventPayload::Worker(_) => RuntimeEventKind::Worker,
                RuntimeEventPayload::Runtime(_) => RuntimeEventKind::Runtime,
            },
            module_id: Some(mod_id.clone()),
            correlation_id: Some("corr-123".to_string()),
            causation_id: None,
            payload,
        };

        let json = serde_json::to_string(&event).unwrap();
        let deserialized: RuntimeEvent = serde_json::from_str(&json).unwrap();
        assert_eq!(event, deserialized);
    }
}

#[test]
fn test_event_payload_versioning_and_structure() {
    let mod_id = ModuleId::new("lyxal-notification");
    let worker_id = WorkerId::new(&mod_id, "dispatch").unwrap();
    let payload = RuntimeEventPayload::Worker(WorkerEvent::Started {
        worker_id: worker_id.clone(),
    });

    let json_val = serde_json::to_value(&payload).unwrap();
    assert_eq!(json_val["type"], "worker");
    assert_eq!(json_val["data"]["event"], "started");
    assert_eq!(json_val["data"]["worker_id"], "lyxal-notification:dispatch");
}
