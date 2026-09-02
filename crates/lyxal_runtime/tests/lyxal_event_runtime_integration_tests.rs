use async_trait::async_trait;
use lyxal_event::{
    DeliveryStatus, Event, EventContext, EventDelivery, EventStore, EventSubscription, Handler,
    HandlerContext, HandlerRegistry, LyxalEventError,
};
use lyxal_runtime::config::RuntimeConfig;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::event_engine::{EventConsumerModule, EventEngineConfig};
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::context::WorkerContext;
use lyxal_runtime::worker::definition::LyxalWorker;
use lyxal_runtime::worker::descriptor::{WorkerCriticality, WorkerDescriptor};
use lyxal_runtime::worker::id::WorkerId;
use lyxal_runtime::worker::restart::{RestartPolicy, WorkerRestartBackoff};
use lyxal_runtime::worker::state::WorkerState;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio::sync::Mutex;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
struct BookingCreated {
    pub booking_id: String,
    pub customer_email: String,
}

impl Event for BookingCreated {
    const EVENT_TYPE: &'static str = "booking.created";
}

#[derive(Clone)]
struct MockNotificationHandler {
    tracker: Arc<Mutex<Vec<BookingCreated>>>,
}

#[async_trait]
impl Handler<BookingCreated> for MockNotificationHandler {
    async fn handle(
        &self,
        event: BookingCreated,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        let mut list = self.tracker.lock().await;
        list.push(event);
        Ok(())
    }
}

struct MockNotificationModule {
    descriptor: ModuleDescriptor,
    handler: MockNotificationHandler,
}

impl MockNotificationModule {
    fn new(handler: MockNotificationHandler) -> Self {
        let module_id = ModuleId::new("lyxal_notification");
        Self {
            descriptor: ModuleDescriptor::new(module_id, "0.1.0"),
            handler,
        }
    }
}

#[async_trait]
impl LyxalModule for MockNotificationModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }
}

impl EventConsumerModule for MockNotificationModule {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        registry
            .register(self.handler.clone())
            .map_err(|e| RuntimeError::Internal {
                code: "REG_FAILED",
                message: e.to_string(),
            })?;
        Ok(())
    }
}

/// Helper pour créer une base de données mémoire SurrealDB isolée
async fn setup_db(ns: &str, db: &str) -> surrealdb::Surreal<surrealdb::engine::any::Any> {
    let client = connect("mem://").await.expect("connect mem://");
    client.use_ns(ns).use_db(db).await.expect("use_ns/use_db");
    client
}

// ---------------------------------------------------------------------------
// TEST 1 : Démarrage automatique d'EventWorker par le Runtime & Dispatch E2E
// ---------------------------------------------------------------------------
#[tokio::test]
async fn test_runtime_event_worker_auto_start_and_dispatch() {
    let client = setup_db("test_ns", "test_db").await;
    let tracker = Arc::new(Mutex::new(Vec::new()));
    let handler = MockNotificationHandler {
        tracker: tracker.clone(),
    };
    let notification_module = Arc::new(MockNotificationModule::new(handler));

    let mut event_config = EventEngineConfig::default();
    event_config.worker_config.poll_interval = Duration::from_millis(50);

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client.clone())
        .with_event_config(event_config);

    // Enregistrement du module et de son consommateur d'événements
    runtime
        .register(notification_module.clone())
        .expect("register module");
    runtime.register_event_consumer(notification_module).await;

    // Définir la souscription dans SurrealDB
    let event_store = runtime.event_store().unwrap();
    event_store.init_schema().await.expect("init event schema");

    let sub = EventSubscription::new(
        "sub_notif_booking",
        "lyxal_notification",
        "booking.created",
        "notification.booking_created_handler",
    );
    event_store
        .register_subscription(&sub)
        .await
        .expect("register subscription");

    // Démarrage complet orchestré par le Runtime
    runtime.start_all().await.expect("runtime start_all");
    tokio::time::sleep(Duration::from_millis(100)).await;

    // Vérifier que le worker d'événements a bien été lancé sous supervision
    let worker_id = WorkerId::parse("lyxal_event:event_worker").unwrap();
    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Running)
    );

    // Publication d'un événement métier
    let publisher = runtime.event_publisher().unwrap();
    let payload = BookingCreated {
        booking_id: "book_123".to_string(),
        customer_email: "alice@lyxal.com".to_string(),
    };
    let published_outbox = publisher
        .publish(&payload)
        .await
        .expect("publish booking.created");

    // Attente du traitement asynchrone par l'EventWorker managé
    tokio::time::sleep(Duration::from_millis(400)).await;

    // Assertions
    let received = tracker.lock().await;
    assert_eq!(received.len(), 1);
    assert_eq!(received[0].booking_id, "book_123");
    assert_eq!(received[0].customer_email, "alice@lyxal.com");

    // Vérification en base que la livraison est marquée 'delivered'
    let outbox_id = published_outbox.id.unwrap();
    let mut resp = client
        .query("SELECT * FROM event_delivery WHERE outbox_event = $outbox")
        .bind(("outbox", outbox_id))
        .await
        .expect("query delivery");
    let deliveries: Vec<EventDelivery> = resp.take(0).expect("take delivery");
    assert_eq!(deliveries.len(), 1);
    assert_eq!(deliveries[0].status, DeliveryStatus::Delivered);

    // Arrêt gracieux orchestré
    runtime.stop_all().await.expect("runtime stop_all");
}

// ---------------------------------------------------------------------------
// TEST 2 : DEFINE EVENT SurrealDB E2E avec Runtime
// ---------------------------------------------------------------------------
#[tokio::test]
async fn test_runtime_define_event_e2e() {
    let client = setup_db("test_ns", "test_db").await;
    let tracker = Arc::new(Mutex::new(Vec::new()));
    let handler = MockNotificationHandler {
        tracker: tracker.clone(),
    };
    let notification_module = Arc::new(MockNotificationModule::new(handler));

    let mut event_config = EventEngineConfig::default();
    event_config.worker_config.poll_interval = Duration::from_millis(50);

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client.clone())
        .with_event_config(event_config);

    runtime
        .register(notification_module.clone())
        .expect("register module");
    runtime.register_event_consumer(notification_module).await;

    let event_store = runtime.event_store().unwrap();
    event_store.init_schema().await.expect("init schema");

    let sub = EventSubscription::new(
        "sub_notif_booking_define_event",
        "lyxal_notification",
        "booking.created",
        "notification.booking_created_handler",
    );
    event_store
        .register_subscription(&sub)
        .await
        .expect("register subscription");

    // Définition de la table et du DEFINE EVENT SurrealQL
    client
        .query(
            r#"
            DEFINE TABLE OVERWRITE booking SCHEMALESS;
            DEFINE EVENT OVERWRITE booking_created_event ON TABLE booking WHEN $event = "CREATE" THEN (
                fn::event_publish({
                    event_id: rand::uuid::v7(),
                    event_type: "booking.created",
                    producer: "lyxal_booking",
                    instance_id: "default",
                    namespace: "test_ns",
                    database: "test_db",
                    payload: {
                        booking_id: <string> $after.id,
                        customer_email: $after.customer_email
                    },
                    metadata: {}
                })
            );
            "#,
        )
        .await
        .expect("define event schema");

    runtime.start_all().await.expect("runtime start_all");

    // Insertion d'un booking déclenchant le DEFINE EVENT
    client
        .query(
            r#"
            CREATE booking:bk_999 CONTENT {
                customer_email: "bob@lyxal.com"
            };
            "#,
        )
        .await
        .expect("create booking");

    // Attente du traitement par le worker Runtime
    tokio::time::sleep(Duration::from_millis(400)).await;

    let received = tracker.lock().await;
    assert_eq!(received.len(), 1);
    assert_eq!(received[0].customer_email, "bob@lyxal.com");

    runtime.stop_all().await.expect("stop_all");
}

// ---------------------------------------------------------------------------
// TEST 3 : Arrêt gracieux du Runtime & Invariant Zéro Zombie
// ---------------------------------------------------------------------------
#[tokio::test]
async fn test_runtime_shutdown_graceful_no_zombies() {
    let client = setup_db("test_ns", "test_db").await;

    let mut event_config = EventEngineConfig::default();
    event_config.worker_config.poll_interval = Duration::from_millis(50);
    event_config.gc_interval = Duration::from_millis(50);

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_event_config(event_config);

    let event_store = runtime.event_store().unwrap();
    event_store.init_schema().await.expect("init schema");

    // Démarrage complet
    runtime.start_all().await.expect("start_all");

    tokio::time::sleep(Duration::from_millis(100)).await;

    let worker_id = WorkerId::parse("lyxal_event:event_worker").unwrap();
    let gc_id = WorkerId::parse("lyxal_event:event_gc").unwrap();

    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Running)
    );
    assert_eq!(
        runtime.worker_supervisor().state(&gc_id),
        Some(WorkerState::Running)
    );

    // Arrêt ordonné complet
    runtime.stop_all().await.expect("stop_all");

    // Vérifier que tous les workers sont passés dans l'état Stopped
    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Stopped)
    );
    assert_eq!(
        runtime.worker_supervisor().state(&gc_id),
        Some(WorkerState::Stopped)
    );
}

// ---------------------------------------------------------------------------
// TEST 4 : Reprise des Fan-outs interrompus au Boot du Runtime
// ---------------------------------------------------------------------------
#[tokio::test]
async fn test_runtime_restart_and_fanout_recovery() {
    let client = setup_db("test_ns", "test_db").await;
    let event_store = Arc::new(EventStore::new(client.clone()));
    event_store.init_schema().await.expect("init schema");

    let sub = EventSubscription::new(
        "sub_notif_booking_recovery",
        "lyxal_notification",
        "booking.created",
        "notification.booking_created_handler",
    );
    event_store
        .register_subscription(&sub)
        .await
        .expect("register subscription");

    // Simulation d'un crash antérieur : publication avec auto_fanout = false
    let event = BookingCreated {
        booking_id: "book_recovered_456".to_string(),
        customer_email: "charlie@lyxal.com".to_string(),
    };
    let envelope =
        lyxal_event::LyxalEventEnvelope::new("lyxal_booking", EventContext::default(), &event)
            .unwrap();
    event_store
        .publish(&envelope, false)
        .await
        .expect("publish pending crash outbox");

    // Démarrage du Runtime avec auto_recover_fanouts activé
    let tracker = Arc::new(Mutex::new(Vec::new()));
    let handler = MockNotificationHandler {
        tracker: tracker.clone(),
    };
    let notification_module = Arc::new(MockNotificationModule::new(handler));

    let mut event_config = EventEngineConfig::default();
    event_config.auto_recover_fanouts = true;
    event_config.worker_config.poll_interval = Duration::from_millis(50);

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client.clone())
        .with_event_config(event_config);

    runtime
        .register(notification_module.clone())
        .expect("register module");
    runtime.register_event_consumer(notification_module).await;

    // Le boot du runtime doit automatiquement appeler recover_pending_fanouts
    runtime.start_all().await.expect("start_all with recovery");

    // Attente que le worker traite la livraison issue du fan-out recouvré
    tokio::time::sleep(Duration::from_millis(400)).await;

    let received = tracker.lock().await;
    assert_eq!(received.len(), 1);
    assert_eq!(received[0].booking_id, "book_recovered_456");
    assert_eq!(received[0].customer_email, "charlie@lyxal.com");

    runtime.stop_all().await.expect("stop_all");
}

// ---------------------------------------------------------------------------
// TEST 5 : Isolation stricte Multi-Instance
// ---------------------------------------------------------------------------
#[tokio::test]
async fn test_runtime_multi_instance_isolation() {
    let client_alpha = setup_db("alpha_ns", "alpha_db").await;
    let client_beta = setup_db("beta_ns", "beta_db").await;

    let tracker_alpha = Arc::new(Mutex::new(Vec::new()));
    let tracker_beta = Arc::new(Mutex::new(Vec::new()));

    let handler_alpha = MockNotificationHandler {
        tracker: tracker_alpha.clone(),
    };
    let handler_beta = MockNotificationHandler {
        tracker: tracker_beta.clone(),
    };

    let module_alpha = Arc::new(MockNotificationModule::new(handler_alpha));
    let module_beta = Arc::new(MockNotificationModule::new(handler_beta));

    let mut config_alpha = EventEngineConfig::default();
    config_alpha.worker_config.poll_interval = Duration::from_millis(50);
    config_alpha.worker_config.instance_id = Some("instance_alpha".to_string());

    let mut config_beta = EventEngineConfig::default();
    config_beta.worker_config.poll_interval = Duration::from_millis(50);
    config_beta.worker_config.instance_id = Some("instance_beta".to_string());

    let runtime_alpha = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client_alpha)
        .with_event_config(config_alpha);

    let runtime_beta = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client_beta)
        .with_event_config(config_beta);

    runtime_alpha
        .register(module_alpha.clone())
        .expect("reg alpha");
    runtime_alpha.register_event_consumer(module_alpha).await;

    runtime_beta
        .register(module_beta.clone())
        .expect("reg beta");
    runtime_beta.register_event_consumer(module_beta).await;

    let store_alpha = runtime_alpha.event_store().unwrap();
    store_alpha.init_schema().await.expect("init alpha");
    let sub_alpha = EventSubscription::new(
        "sub_alpha",
        "lyxal_notification",
        "booking.created",
        "notification.booking_created_handler",
    );
    store_alpha
        .register_subscription(&sub_alpha)
        .await
        .expect("sub alpha");

    let store_beta = runtime_beta.event_store().unwrap();
    store_beta.init_schema().await.expect("init beta");
    let sub_beta = EventSubscription::new(
        "sub_beta",
        "lyxal_notification",
        "booking.created",
        "notification.booking_created_handler",
    );
    store_beta
        .register_subscription(&sub_beta)
        .await
        .expect("sub beta");

    runtime_alpha.start_all().await.expect("start alpha");
    runtime_beta.start_all().await.expect("start beta");

    // Publication uniquement dans Alpha
    let publisher_alpha = runtime_alpha.event_publisher().unwrap();
    publisher_alpha
        .publish(&BookingCreated {
            booking_id: "alpha_100".to_string(),
            customer_email: "alpha@lyxal.com".to_string(),
        })
        .await
        .expect("pub alpha");

    tokio::time::sleep(Duration::from_millis(400)).await;

    // Assertions d'étanchéité stricte
    assert_eq!(tracker_alpha.lock().await.len(), 1);
    assert_eq!(tracker_beta.lock().await.len(), 0);

    // Publication dans Beta
    let publisher_beta = runtime_beta.event_publisher().unwrap();
    publisher_beta
        .publish(&BookingCreated {
            booking_id: "beta_200".to_string(),
            customer_email: "beta@lyxal.com".to_string(),
        })
        .await
        .expect("pub beta");

    tokio::time::sleep(Duration::from_millis(400)).await;

    assert_eq!(tracker_alpha.lock().await.len(), 1);
    assert_eq!(tracker_beta.lock().await.len(), 1);

    runtime_alpha.stop_all().await.expect("stop alpha");
    runtime_beta.stop_all().await.expect("stop beta");
}

// ---------------------------------------------------------------------------
// TEST 6 : Comportement face à un Handler Non Enregistré
// ---------------------------------------------------------------------------
#[tokio::test]
async fn test_runtime_missing_handler_behavior() {
    let client = setup_db("test_ns", "test_db").await;

    let mut event_config = EventEngineConfig::default();
    event_config.worker_config.poll_interval = Duration::from_millis(50);

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client.clone())
        .with_event_config(event_config);

    let event_store = runtime.event_store().unwrap();
    event_store.init_schema().await.expect("init schema");

    // Enregistrement d'une souscription pointant vers un handler inexistant
    let sub = EventSubscription::new(
        "sub_unknown",
        "lyxal_unknown",
        "booking.created",
        "unknown.non_existent_handler",
    );
    event_store
        .register_subscription(&sub)
        .await
        .expect("reg subscription");

    runtime.start_all().await.expect("start_all");

    let publisher = runtime.event_publisher().unwrap();
    let published_outbox = publisher
        .publish(&BookingCreated {
            booking_id: "ghost_booking".to_string(),
            customer_email: "ghost@lyxal.com".to_string(),
        })
        .await
        .expect("publish");

    tokio::time::sleep(Duration::from_millis(400)).await;

    // Vérifier que la livraison est marquée 'failed' avec tentative enregistrée (pas de crash runtime)
    let outbox_id = published_outbox.id.unwrap();
    let mut resp = client
        .query("SELECT * FROM event_delivery WHERE outbox_event = $outbox")
        .bind(("outbox", outbox_id))
        .await
        .expect("query delivery");
    let deliveries: Vec<EventDelivery> = resp.take(0).expect("take delivery");
    assert_eq!(deliveries.len(), 1);
    assert_eq!(deliveries[0].status, DeliveryStatus::Failed);
    assert!(deliveries[0].attempts > 0);
    assert!(deliveries[0].last_error.is_some());

    runtime.stop_all().await.expect("stop_all");
}

// ---------------------------------------------------------------------------
// TEST 7 : Supervision réelle & Reprise après Crash d'un Worker
// ---------------------------------------------------------------------------
static CRASH_COUNT: AtomicU32 = AtomicU32::new(0);

struct CrashingWorker {
    descriptor: WorkerDescriptor,
    runs: Arc<AtomicU32>,
}

impl CrashingWorker {
    fn new(runs: Arc<AtomicU32>) -> Self {
        let module_id = ModuleId::new("lyxal_test");
        let worker_id = WorkerId::new(&module_id, "crashing_worker").unwrap();
        let mut descriptor = WorkerDescriptor::new(worker_id, module_id, "Crashing Test Worker")
            .with_criticality(WorkerCriticality::Required)
            .with_shutdown_timeout(Duration::from_secs(2));
        descriptor.restart_policy = RestartPolicy::Always {
            max_retries: Some(5),
            backoff: WorkerRestartBackoff::new(
                Duration::from_millis(50),
                Duration::from_millis(200),
                1.5,
            ),
        };
        Self { descriptor, runs }
    }
}

#[async_trait]
impl LyxalWorker for CrashingWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let count = self.runs.fetch_add(1, Ordering::SeqCst);
        if count == 0 {
            // Premier démarrage : simulation d'un crash / erreur fatale
            return Err(RuntimeError::Internal {
                code: "SIMULATED_WORKER_CRASH",
                message: "Worker crashed on first boot".to_string(),
            });
        }

        // Démarrages suivants : maintien en exécution jusqu'à annulation coopérative
        while !ctx.is_cancelled() {
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
        Ok(())
    }
}

#[tokio::test]
async fn test_runtime_event_worker_crash_supervision() {
    CRASH_COUNT.store(0, Ordering::SeqCst);
    let runs = Arc::new(AtomicU32::new(0));
    let worker = Arc::new(CrashingWorker::new(runs.clone()));
    let worker_id = worker.descriptor().id.clone();

    let runtime = LyxalRuntime::new(RuntimeConfig::default());
    runtime
        .register_worker(worker)
        .expect("register crashing worker");

    // Démarrage du superviseur
    runtime
        .worker_supervisor()
        .start_worker(&worker_id)
        .await
        .expect("start worker");

    // Attente que le premier crash se produise et que le superviseur applique le redémarrage
    tokio::time::sleep(Duration::from_millis(300)).await;

    // Vérifier que le worker a été relancé (runs > 1) et est actuellement Running
    let total_runs = runs.load(Ordering::SeqCst);
    assert!(
        total_runs >= 2,
        "Expected supervisor to restart worker, total_runs = {}",
        total_runs
    );
    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Running)
    );

    // Arrêt propre
    runtime
        .worker_supervisor()
        .stop_worker(&worker_id)
        .await
        .expect("stop worker");
    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Stopped)
    );
}
