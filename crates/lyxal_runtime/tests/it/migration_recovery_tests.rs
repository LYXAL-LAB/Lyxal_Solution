//! Reprise guidée d'une migration interrompue : liste, décision `retry` ou `abandon` sous bail
//! d'installation, rejeu par le moteur de migration, refus et trace au journal.

use crate::common;
use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::event::bus::{MemoryRuntimeEventBus, RuntimeEventBus};
use lyxal_runtime::event::journal::RuntimeEventJournal;
use lyxal_runtime::event::payload::{MigrationEvent, RuntimeEventPayload};
use lyxal_runtime::event::store::SurrealRuntimeEventJournal;
use lyxal_runtime::lock::{
    AcquireInstallationLeaseResult, AcquireLeaseResult, InstallationLeaseManager,
    InstallationLockKey, MigrationLeaseManager, MigrationLockKey, NodeId,
    SurrealInstallationLeaseManager, SurrealMigrationLeaseManager,
};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::migration::{
    MigrationChecksum, MigrationId, MigrationInterruptedParams, MigrationRecord, MigrationRecovery,
    MigrationResolveAction, MigrationResolveParams, MigrationRunner, MigrationStatus,
};
use lyxal_runtime::package::types::ModuleInstallationOutcome;
use lyxal_runtime::resource::ResourceKind;
use lyxal_runtime::store::{RuntimeStore, SurrealRuntimeStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, LyxalRuntime, RuntimeConfig, RuntimeError};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
use surrealdb::Surreal;

const MODULE: &str = "lyxal-booking";
const MIGRATION: &str = "001_initial";
const SCRIPT: &str = "migrations/001_initial.surql";
const VERSION: &str = "1.0.0";
const SQL: &str = "DEFINE TABLE OVERWRITE recovery_booking SCHEMAFULL;";

struct Module(ModuleDescriptor);

#[async_trait]
impl LyxalModule for Module {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.0
    }
    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

fn manifest() -> ModuleManifest {
    ModuleManifest {
        manifest_version: lyxal_runtime::manifest::CURRENT_MANIFEST_VERSION,
        id: ModuleId::new(MODULE),
        name: MODULE.to_string(),
        version: semver::Version::parse(VERSION).unwrap(),
        description: None,
        runtime: None,
        dependencies: Vec::new(),
        capabilities: Vec::new(),
        resources: Default::default(),
    }
}

fn provider() -> Arc<common::MemoryProvider> {
    Arc::new(common::MemoryProvider::new().add_resource(SCRIPT, ResourceKind::Migration, SQL))
}

fn migration_key() -> MigrationLockKey {
    MigrationLockKey::new(ModuleId::new(MODULE), MigrationId::new(MIGRATION).unwrap())
}

fn record(status: MigrationStatus) -> MigrationRecord {
    MigrationRecord {
        migration_id: MigrationId::new(MIGRATION).unwrap(),
        module_id: ModuleId::new(MODULE),
        module_version: VERSION.to_string(),
        checksum: MigrationChecksum::from_surql(SQL),
        applied_at: 0,
        duration_ms: 0,
        status,
        error: None,
        script: Some(SCRIPT.to_string()),
        node_id: None,
    }
}

async fn run(client: &Surreal<Any>, sql: &str) {
    client.query(sql).await.unwrap().check().unwrap();
}

/// Le nœud `node-a` commence la migration sous son bail, puis s'arrête sans l'enregistrer :
/// elle reste `Applying`. Tant que le bail n'est pas échu, elle est « en cours ».
async fn start_migration(client: &Surreal<Any>) {
    let store = SurrealRuntimeStore::new(client.clone());
    let lease = match SurrealMigrationLeaseManager::new(client.clone())
        .acquire(
            &migration_key(),
            &NodeId::new("node-a"),
            Duration::from_secs(30),
        )
        .await
        .unwrap()
    {
        AcquireLeaseResult::Acquired(lease) => lease,
        other => panic!("bail attendu, obtenu {other:?}"),
    };
    store
        .record_migration(&record(MigrationStatus::Applying), Some(&lease))
        .await
        .unwrap();
}

/// Le bail de migration du nœud arrêté arrive à échéance (heure de la base).
async fn expire_migration_lease(client: &Surreal<Any>) {
    run(
        client,
        "UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1 WHERE kind = 'migration';",
    )
    .await;
}

async fn interrupt(client: &Surreal<Any>) {
    start_migration(client).await;
    expire_migration_lease(client).await;
}

fn recovery(client: &Surreal<Any>, node: &str) -> MigrationRecovery {
    let node = NodeId::new(node);
    MigrationRecovery::new(
        client.clone(),
        node.clone(),
        Arc::new(MemoryRuntimeEventBus::new(node)),
    )
}

fn decision(action: MigrationResolveAction, reason: &str) -> MigrationResolveParams {
    MigrationResolveParams {
        module: MODULE.to_string(),
        migration: MIGRATION.to_string(),
        action,
        reason: reason.to_string(),
        actor: "auth_identity:ops".to_string(),
    }
}

async fn status(client: &Surreal<Any>) -> MigrationStatus {
    SurrealRuntimeStore::new(client.clone())
        .get_migration(
            &ModuleId::new(MODULE),
            &MigrationId::new(MIGRATION).unwrap(),
        )
        .await
        .unwrap()
        .expect("migration enregistrée")
        .status
}

fn runner(client: &Surreal<Any>) -> MigrationRunner {
    let store: Arc<dyn RuntimeStore> = Arc::new(SurrealRuntimeStore::new(client.clone()));
    MigrationRunner::new(store, client.clone()).with_node_id(NodeId::new("node-b"))
}

async fn run_migrations(
    client: &Surreal<Any>,
) -> Result<lyxal_runtime::migration::MigrationRunResult, RuntimeError> {
    let provider = provider();
    let mut manifest = manifest();
    manifest.resources = provider.resources();
    runner(client)
        .run_module(&manifest, provider.as_ref())
        .await
}

#[derive(Debug, SurrealValue)]
struct RawError {
    code: String,
}

#[derive(Debug, SurrealValue)]
struct RawResult {
    ok: bool,
    #[surreal(default)]
    error: Option<RawError>,
}

#[tokio::test]
async fn test_interrupted_migration_is_listed_resolved_and_replayed() {
    let client = common::setup_db("recovery_retry", "recovery_retry").await;
    let ops = recovery(&client, "node-ops");

    // En cours (bail de migration détenu) : ni listée, ni résoluble
    start_migration(&client).await;
    assert!(ops
        .interrupted(MigrationInterruptedParams::default())
        .await
        .unwrap()
        .is_empty());
    match ops
        .resolve(decision(MigrationResolveAction::Retry, "trop tôt"))
        .await
        .unwrap_err()
    {
        RuntimeError::MigrationNotInterrupted { status, .. } => assert_eq!(status, "running"),
        other => panic!("refus attendu, obtenu {other:?}"),
    }

    // Bail échu : la migration est interrompue, et lisible avec son contexte
    expire_migration_lease(&client).await;
    let listed = ops
        .interrupted(MigrationInterruptedParams::default())
        .await
        .unwrap();
    assert_eq!(listed.len(), 1);
    let interrupted = &listed[0];
    assert_eq!(interrupted.module, MODULE);
    assert_eq!(interrupted.migration, MIGRATION);
    assert_eq!(interrupted.version, VERSION);
    assert_eq!(interrupted.script.as_deref(), Some(SCRIPT));
    assert_eq!(interrupted.node.as_deref(), Some("node-a"));
    assert_eq!(interrupted.state, "interrupted");
    assert!(interrupted.started_at.is_some());
    assert!(interrupted.resolution.is_none());

    // Filtre par module ; paramètre inconnu refusé
    assert!(ops
        .interrupted(MigrationInterruptedParams {
            module: Some("lyxal-autre".to_string()),
        })
        .await
        .unwrap()
        .is_empty());
    let mut refused = client
        .query("RETURN fn::runtime_migration_interrupted_list({ inconnu: true });")
        .await
        .unwrap();
    let refused: Option<RawResult> = refused.take(0).unwrap();
    assert_eq!(
        refused.unwrap().error.unwrap().code,
        "RUNTIME_INVALID_PARAMETERS"
    );

    // Sans décision, le moteur refuse de la rejouer
    assert!(matches!(
        run_migrations(&client).await.unwrap_err(),
        RuntimeError::MigrationInterrupted { .. }
    ));

    // Décision retry : marquée à rejouer, plus listée, bail d'installation rendu
    let resolved = ops
        .resolve(decision(
            MigrationResolveAction::Retry,
            "  table absente, script rejouable  ",
        ))
        .await
        .unwrap();
    assert_eq!(resolved.action, "retry");
    assert_eq!(resolved.status, "RetryRequested");
    assert_eq!(resolved.previous_status, "Applying");
    assert_eq!(resolved.version, VERSION);
    assert_eq!(status(&client).await, MigrationStatus::RetryRequested);
    assert!(ops
        .interrupted(MigrationInterruptedParams::default())
        .await
        .unwrap()
        .is_empty());
    let installation_key = InstallationLockKey::new(ModuleId::new(MODULE), VERSION);
    assert!(SurrealInstallationLeaseManager::new(client.clone())
        .inspect(&installation_key)
        .await
        .unwrap()
        .is_none());

    // Une seconde décision n'a plus d'objet
    match ops
        .resolve(decision(MigrationResolveAction::Retry, "encore"))
        .await
        .unwrap_err()
    {
        RuntimeError::MigrationNotInterrupted { status, .. } => {
            assert_eq!(status, "RetryRequested")
        }
        other => panic!("refus attendu, obtenu {other:?}"),
    }

    // Le moteur la rejoue et l'enregistre appliquée
    let result = run_migrations(&client).await.unwrap();
    assert_eq!(result.applied.len(), 1);
    assert_eq!(status(&client).await, MigrationStatus::Applied);
    run(&client, "CREATE recovery_booking:one;").await;

    // Trace au journal : qui, quand, pourquoi, depuis quel nœud
    let journal = SurrealRuntimeEventJournal::new(client.clone());
    let events = journal.by_module(&ModuleId::new(MODULE), 10).await.unwrap();
    assert_eq!(events.len(), 1);
    assert_eq!(events[0].node_id, NodeId::new("node-ops"));
    assert!(events[0].timestamp_ms > 0);
    match &events[0].payload {
        RuntimeEventPayload::Migration(MigrationEvent::Resolved {
            migration_id,
            version,
            action,
            actor,
            reason,
            previous_status,
        }) => {
            assert_eq!(migration_id.as_str(), MIGRATION);
            assert_eq!(version, VERSION);
            assert_eq!(action, "retry");
            assert_eq!(actor, "auth_identity:ops");
            assert_eq!(reason, "table absente, script rejouable");
            assert_eq!(previous_status, "Applying");
        }
        other => panic!("trace attendue, obtenu {other:?}"),
    }
}

#[tokio::test]
async fn test_abandoned_migration_blocks_installation_until_retry() {
    let client = common::setup_db("recovery_abandon", "recovery_abandon").await;
    let bus: Arc<dyn RuntimeEventBus> = Arc::new(MemoryRuntimeEventBus::new(NodeId::new("node-b")));
    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_node_id(NodeId::new("node-b"))
        .with_event_bus(bus)
        .with_client(client.clone())
        .with_store(Arc::new(SurrealRuntimeStore::new(client.clone())))
        .with_installation_lease_manager(Arc::new(SurrealInstallationLeaseManager::new(
            client.clone(),
        )));
    let package = common::package(manifest(), provider())
        .with_module_impl(Arc::new(Module(ModuleDescriptor::new(MODULE, VERSION))));

    interrupt(&client).await;

    // Migration interrompue : l'installation du module est refusée
    let refused = runtime.install_package(package.clone()).await.unwrap_err();
    assert!(refused.to_string().contains("Applying"), "{refused}");

    // Abandon : toujours listée (abandonnée), avec la décision
    let abandoned = runtime
        .resolve_migration(decision(
            MigrationResolveAction::Abandon,
            "état partiel à examiner",
        ))
        .await
        .unwrap();
    assert_eq!(abandoned.status, "Abandoned");
    assert_eq!(status(&client).await, MigrationStatus::Abandoned);
    let listed = runtime
        .interrupted_migrations(MigrationInterruptedParams {
            module: Some(MODULE.to_string()),
        })
        .await
        .unwrap();
    assert_eq!(listed.len(), 1);
    assert_eq!(listed[0].state, "abandoned");
    let resolution = listed[0].resolution.as_ref().expect("décision gardée");
    assert_eq!(resolution.action, "abandon");
    assert_eq!(resolution.actor, "auth_identity:ops");
    assert_eq!(resolution.reason, "état partiel à examiner");
    assert_eq!(resolution.node_id, "node-b");

    // L'installation reste refusée, avec un motif clair, et rien n'est rejoué
    let refused = runtime.install_package(package.clone()).await.unwrap_err();
    assert!(
        refused.to_string().contains("Abandonnée par l'exploitant"),
        "{refused}"
    );
    assert!(matches!(
        run_migrations(&client).await.unwrap_err(),
        RuntimeError::MigrationRecoveryRequired { .. }
    ));
    assert_eq!(status(&client).await, MigrationStatus::Abandoned);

    // Une migration abandonnée n'accepte que retry
    match runtime
        .resolve_migration(decision(MigrationResolveAction::Abandon, "doublon"))
        .await
        .unwrap_err()
    {
        RuntimeError::MigrationNotInterrupted { status, .. } => assert_eq!(status, "Abandoned"),
        other => panic!("refus attendu, obtenu {other:?}"),
    }

    // Retry : la migration est rejouée par l'installation, qui aboutit
    let retried = runtime
        .resolve_migration(decision(MigrationResolveAction::Retry, "base vérifiée"))
        .await
        .unwrap();
    assert_eq!(retried.previous_status, "Abandoned");
    assert_eq!(retried.status, "RetryRequested");
    let report = runtime.install_package(package).await.unwrap();
    assert_eq!(report.outcome, ModuleInstallationOutcome::Installed);
    assert_eq!(report.migrations_applied, 1);
    assert_eq!(status(&client).await, MigrationStatus::Applied);
    assert!(runtime
        .interrupted_migrations(MigrationInterruptedParams::default())
        .await
        .unwrap()
        .is_empty());

    // Les deux décisions sont au journal, la plus récente d'abord
    let events = SurrealRuntimeEventJournal::new(client.clone())
        .by_module(&ModuleId::new(MODULE), 10)
        .await
        .unwrap();
    let actions: Vec<&str> = events
        .iter()
        .filter_map(|event| match &event.payload {
            RuntimeEventPayload::Migration(MigrationEvent::Resolved { action, .. }) => {
                Some(action.as_str())
            }
            _ => None,
        })
        .collect();
    assert_eq!(actions, ["retry", "abandon"]);
}

#[tokio::test]
async fn test_resolve_is_refused_when_not_interrupted_or_invalid() {
    let client = common::setup_db("recovery_refusal", "recovery_refusal").await;
    let ops = recovery(&client, "node-ops");

    // Migration inconnue
    match ops
        .resolve(decision(MigrationResolveAction::Retry, "inconnue"))
        .await
        .unwrap_err()
    {
        RuntimeError::MigrationNotInterrupted { status, .. } => assert_eq!(status, "unknown"),
        other => panic!("refus attendu, obtenu {other:?}"),
    }

    // Migration appliquée
    run_migrations(&client).await.unwrap();
    for action in [
        MigrationResolveAction::Retry,
        MigrationResolveAction::Abandon,
    ] {
        let refused = ops
            .resolve(decision(action, "appliquée"))
            .await
            .unwrap_err();
        assert_eq!(refused.code(), "RUNTIME_MIGRATION_NOT_INTERRUPTED");
        match refused {
            RuntimeError::MigrationNotInterrupted {
                module,
                migration,
                status,
            } => {
                assert_eq!(module, MODULE);
                assert_eq!(migration, MIGRATION);
                assert_eq!(status, "Applied");
            }
            other => panic!("refus attendu, obtenu {other:?}"),
        }
    }
    assert_eq!(status(&client).await, MigrationStatus::Applied);

    // Motif obligatoire et borné, auteur obligatoire
    run(&client, "UPDATE runtime_migration SET status = 'Applying';").await;
    for (reason, actor) in [
        ("   ".to_string(), "auth_identity:ops"),
        ("x".repeat(1001), "auth_identity:ops"),
        ("motif".to_string(), ""),
    ] {
        let mut params = decision(MigrationResolveAction::Retry, &reason);
        params.actor = actor.to_string();
        match ops.resolve(params).await.unwrap_err() {
            RuntimeError::InvalidParameters { fields, .. } => {
                assert!(fields.is_object(), "{fields}");
            }
            other => panic!("refus attendu, obtenu {other:?}"),
        }
    }
    assert_eq!(status(&client).await, MigrationStatus::Applying);

    // Aucun refus n'est tracé
    assert!(SurrealRuntimeEventJournal::new(client.clone())
        .recent(10)
        .await
        .unwrap()
        .is_empty());
}

#[tokio::test]
async fn test_resolve_requires_the_installation_lease() {
    let client = common::setup_db("recovery_lease", "recovery_lease").await;
    interrupt(&client).await;
    let ops = recovery(&client, "node-ops");
    let leases = SurrealInstallationLeaseManager::new(client.clone());
    let key = InstallationLockKey::new(ModuleId::new(MODULE), VERSION);

    // Appel direct sans bail d'installation détenu : refusé par la fonction, rien n'est écrit
    let call = "RETURN fn::runtime_migration_resolve({ module: $module, migration: $migration, action: 'retry', reason: 'sans bail', actor: 'auth_identity:ops', node_id: $node, generation: $generation });";
    let direct = |node: &'static str, generation: i64| {
        let client = client.clone();
        async move {
            let mut response = client
                .query(call)
                .bind(("module", MODULE))
                .bind(("migration", MIGRATION))
                .bind(("node", node))
                .bind(("generation", generation))
                .await
                .unwrap();
            let result: Option<RawResult> = response.take(0).unwrap();
            result.unwrap()
        }
    };
    let refused = direct("node-ops", 1).await;
    assert!(!refused.ok);
    assert_eq!(refused.error.unwrap().code, "RUNTIME_LEASE_FENCED");
    assert_eq!(status(&client).await, MigrationStatus::Applying);

    // Bail détenu par un autre nœud vivant (installation en cours ailleurs) : refusé
    let other = match leases
        .acquire(&key, &NodeId::new("node-c"), Duration::from_secs(30))
        .await
        .unwrap()
    {
        AcquireInstallationLeaseResult::Acquired(lease) => lease,
        other => panic!("bail attendu, obtenu {other:?}"),
    };
    let refused = ops
        .resolve(decision(MigrationResolveAction::Abandon, "bail pris"))
        .await
        .unwrap_err();
    assert_eq!(refused.code(), "RUNTIME_LEASE_FENCED");
    match refused {
        RuntimeError::LeaseFenced { key, owner, .. } => {
            assert_eq!(key, format!("{MODULE}:{VERSION}"));
            assert_eq!(owner, "node-c");
        }
        other => panic!("refus attendu, obtenu {other:?}"),
    }
    // Ni avec l'identité d'un autre nœud, ni avec une génération passée du détenteur
    let generation = i64::try_from(other.generation).unwrap();
    assert_eq!(
        direct("node-ops", generation).await.error.unwrap().code,
        "RUNTIME_LEASE_FENCED"
    );
    assert_eq!(
        direct("node-c", generation + 1).await.error.unwrap().code,
        "RUNTIME_LEASE_FENCED"
    );
    assert_eq!(status(&client).await, MigrationStatus::Applying);
    assert!(SurrealRuntimeEventJournal::new(client.clone())
        .recent(10)
        .await
        .unwrap()
        .is_empty());

    // Bail du nœud arrêté arrivé à échéance : repris, la décision passe
    run(
        &client,
        "UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1 WHERE kind = 'installation';",
    )
    .await;
    assert_eq!(
        direct("node-c", generation).await.error.unwrap().code,
        "RUNTIME_LEASE_FENCED"
    );
    let resolved = ops
        .resolve(decision(MigrationResolveAction::Abandon, "bail échu"))
        .await
        .unwrap();
    assert_eq!(resolved.status, "Abandoned");
    assert_eq!(status(&client).await, MigrationStatus::Abandoned);
}
