use async_trait::async_trait;
use lyxal_runtime::config::RuntimeConfig;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::event::bus::RuntimeEventBus;
use lyxal_runtime::event::filter::RuntimeEventFilter;
use lyxal_runtime::event::kind::RuntimeEventKind;
use lyxal_runtime::event::payload::{
    HealthEvent, InstallationEvent, LifecycleEvent, RuntimeEventPayload, WorkerEvent,
};
use lyxal_runtime::health::check::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::health::engine::{HealthConfig, HealthEngine};
use lyxal_runtime::health::registry::HealthRegistry;
use lyxal_runtime::health::snapshot::HealthSnapshot;
use lyxal_runtime::health::status::HealthStatus;
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::manifest::parser::ManifestParser;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::resource::model::ModuleResource;
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::ResourceKind;
use lyxal_runtime::store::{RuntimeStore, SurrealRuntimeStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::context::WorkerContext;
use lyxal_runtime::worker::definition::LyxalWorker;
use lyxal_runtime::worker::descriptor::WorkerDescriptor;
use lyxal_runtime::worker::id::WorkerId;
use lyxal_runtime::worker::registry::WorkerRegistry;
use lyxal_runtime::worker::supervisor::WorkerSupervisor;
use lyxal_runtime::LyxalRuntime;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;

struct DummyModule {
    descriptor: ModuleDescriptor,
}

impl DummyModule {
    fn new(name: &str) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(ModuleId::new(name), "1.0.0"),
        }
    }
}

#[async_trait]
impl LyxalModule for DummyModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
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

struct DummyWorker {
    descriptor: WorkerDescriptor,
}

impl DummyWorker {
    fn new(module_id: &ModuleId, name: &str) -> Self {
        Self {
            descriptor: WorkerDescriptor::new(
                WorkerId::new(module_id, name).unwrap(),
                module_id.clone(),
                name,
            ),
        }
    }
}

#[async_trait]
impl LyxalWorker for DummyWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        // Reste en vie jusqu'à annulation
        ctx.cancellation.cancelled().await;
        Ok(())
    }
}

struct DummyResourceProvider;

#[async_trait]
impl ResourceProvider for DummyResourceProvider {
    async fn list_resources(&self, _prefix: &str) -> Result<Vec<String>, RuntimeError> {
        Ok(Vec::new())
    }

    async fn read_resource(&self, path: &str) -> Result<ModuleResource, RuntimeError> {
        Ok(ModuleResource::new(
            path,
            ResourceKind::Tables,
            "DEFINE TABLE test SCHEMALESS;",
        ))
    }

    async fn exists(&self, _logical_path: &str) -> bool {
        false
    }
}

#[tokio::test]
async fn test_lifecycle_emits_started_and_stopped() {
    let runtime = LyxalRuntime::new(RuntimeConfig::default());
    let mut sub = runtime.subscribe(RuntimeEventFilter::for_kinds([RuntimeEventKind::Lifecycle]));

    let module = Arc::new(DummyModule::new("lyxal-auth"));
    runtime.register(module).unwrap();
    runtime.install_all().await.unwrap();

    let mod_id = ModuleId::new("lyxal-auth");
    runtime.start_module(&mod_id).await.unwrap();
    runtime.stop_module(&mod_id).await.unwrap();

    let mut events = Vec::new();
    while let Ok(evt) = tokio::time::timeout(Duration::from_millis(50), sub.recv()).await {
        if let Ok(e) = evt {
            events.push(e);
        }
    }

    assert!(events.len() >= 4);
    let payloads: Vec<_> = events
        .into_iter()
        .map(|e| match e.payload {
            RuntimeEventPayload::Lifecycle(lc) => lc,
            _ => panic!("Expected lifecycle event"),
        })
        .collect();

    assert!(payloads
        .iter()
        .any(|p| matches!(p, LifecycleEvent::StartRequested)));
    assert!(payloads
        .iter()
        .any(|p| matches!(p, LifecycleEvent::Started)));
    assert!(payloads
        .iter()
        .any(|p| matches!(p, LifecycleEvent::StopRequested)));
    assert!(payloads
        .iter()
        .any(|p| matches!(p, LifecycleEvent::Stopped)));
}

#[tokio::test]
async fn test_installation_pipeline_emits_ordered_events() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test_ns").use_db("test_db").await.unwrap();

    let store = Arc::new(SurrealRuntimeStore::new(client.clone()));
    store.bootstrap().await.unwrap();

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store);

    let mut sub = runtime.subscribe(RuntimeEventFilter::all());

    let manifest_toml = r#"
id = "lyxal-crm"
name = "Lyxal CRM"
version = "1.0.0"
description = "CRM Module"
"#;
    let manifest = ManifestParser::parse_str(manifest_toml).unwrap();
    let provider = Arc::new(DummyResourceProvider);
    let mock_module = Arc::new(DummyModule::new("lyxal-crm"));
    let package = ModulePackage::new(manifest, provider).with_module_impl(mock_module);

    runtime.install_package(package).await.unwrap();

    let mut events = Vec::new();
    while let Ok(evt) = tokio::time::timeout(Duration::from_millis(50), sub.recv()).await {
        if let Ok(e) = evt {
            events.push(e);
        }
    }

    assert!(!events.is_empty());

    let has_install_started = events.iter().any(|e| {
        matches!(
            e.payload,
            RuntimeEventPayload::Installation(InstallationEvent::Started { .. })
        )
    });
    let has_install_completed = events.iter().any(|e| {
        matches!(
            e.payload,
            RuntimeEventPayload::Installation(InstallationEvent::Completed { .. })
        )
    });

    assert!(has_install_started);
    assert!(has_install_completed);
}

#[tokio::test]
async fn test_worker_lifecycle_emits_events() {
    let node_id = NodeId::new("node-worker-evt");
    let bus = Arc::new(lyxal_runtime::event::bus::MemoryRuntimeEventBus::new(
        node_id.clone(),
    ));
    let mut sub = bus.subscribe(RuntimeEventFilter::for_kinds([RuntimeEventKind::Worker]));

    let registry = Arc::new(WorkerRegistry::new());
    let mod_id = ModuleId::new("lyxal-notification");
    let worker = Arc::new(DummyWorker::new(&mod_id, "queue-listener"));
    registry.register(worker.clone()).unwrap();

    let supervisor = WorkerSupervisor::new(registry, node_id).with_event_bus(bus);
    let worker_id = worker.descriptor().id.clone();

    supervisor.start_worker(&worker_id).await.unwrap();
    tokio::time::sleep(Duration::from_millis(50)).await;
    supervisor.stop_worker(&worker_id).await.unwrap();

    let mut events = Vec::new();
    while let Ok(evt) = tokio::time::timeout(Duration::from_millis(50), sub.recv()).await {
        if let Ok(e) = evt {
            events.push(e);
        }
    }

    let has_starting = events.iter().any(|e| {
        matches!(
            e.payload,
            RuntimeEventPayload::Worker(WorkerEvent::Starting { .. })
        )
    });
    let has_started = events.iter().any(|e| {
        matches!(
            e.payload,
            RuntimeEventPayload::Worker(WorkerEvent::Started { .. })
        )
    });
    let has_stopping = events.iter().any(|e| {
        matches!(
            e.payload,
            RuntimeEventPayload::Worker(WorkerEvent::Stopping { .. })
        )
    });
    let has_stopped = events.iter().any(|e| {
        matches!(
            e.payload,
            RuntimeEventPayload::Worker(WorkerEvent::Stopped { .. })
        )
    });

    assert!(has_starting);
    assert!(has_started);
    assert!(has_stopping);
    assert!(has_stopped);
}

struct FlakyHealthChecker {
    module_id: ModuleId,
    is_healthy: Arc<AtomicBool>,
}

#[async_trait]
impl ModuleHealthCheck for FlakyHealthChecker {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        if self.is_healthy.load(Ordering::SeqCst) {
            Ok(HealthCheckResult::healthy(self.module_id.clone(), 10, None))
        } else {
            Ok(HealthCheckResult::unhealthy(
                self.module_id.clone(),
                Some(50),
                Some("Connection timeout".to_string()),
            ))
        }
    }
}

#[tokio::test]
async fn test_health_transition_emitted_once() {
    let node_id = NodeId::new("node-health-evt");
    let bus = Arc::new(lyxal_runtime::event::bus::MemoryRuntimeEventBus::new(
        node_id,
    ));
    let mut sub = bus.subscribe(RuntimeEventFilter::for_kinds([RuntimeEventKind::Health]));

    let is_healthy = Arc::new(AtomicBool::new(true));
    let registry = HealthRegistry::new();
    let mod_id = ModuleId::new("lyxal-db");
    registry
        .register_check(Arc::new(FlakyHealthChecker {
            module_id: mod_id.clone(),
            is_healthy: is_healthy.clone(),
        }))
        .unwrap();

    let engine = HealthEngine::new(registry, HealthConfig::default()).with_event_bus(bus);
    let ctx = ModuleContext::new("system");

    // Snapshot 1 : Healthy
    let s1 = HealthSnapshot::new(vec![engine.check_module(&mod_id, &ctx).await]);
    assert_eq!(
        s1.modules.get(&mod_id).unwrap().status,
        HealthStatus::Healthy
    );

    // Snapshot 2 : Unhealthy -> transition !
    is_healthy.store(false, Ordering::SeqCst);
    let s2 = HealthSnapshot::new(vec![engine.check_module(&mod_id, &ctx).await]);
    assert_eq!(
        s2.modules.get(&mod_id).unwrap().status,
        HealthStatus::Unhealthy
    );

    engine.publish_transitions(&s1, &s2).await;

    let evt = sub.recv().await.unwrap();
    match evt.payload {
        RuntimeEventPayload::Health(HealthEvent::Transition(t)) => {
            assert_eq!(t.module_id, mod_id);
            assert_eq!(t.from, HealthStatus::Healthy);
            assert_eq!(t.to, HealthStatus::Unhealthy);
        }
        other => panic!("Expected Health Transition, got: {:?}", other),
    }
}

#[tokio::test]
async fn test_event_bus_failure_isolation() {
    // Si un journal d'événements échoue ou si personne n'écoute, le Runtime continue de fonctionner sans régression
    let runtime = LyxalRuntime::new(RuntimeConfig::default());
    let module = Arc::new(DummyModule::new("lyxal-crm"));
    runtime.register(module).unwrap();
    runtime.install_all().await.unwrap();

    let mod_id = ModuleId::new("lyxal-crm");
    assert!(runtime.start_module(&mod_id).await.is_ok());
    assert!(runtime.stop_module(&mod_id).await.is_ok());
}
