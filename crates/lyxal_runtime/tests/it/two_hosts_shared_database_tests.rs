//! Deux hôtes à jeux de modules différents sur une même base, moteur d'événements activé.
//!
//! Un hôte A (`p3_host_a`) héberge les modules `p3_shared` et `p3_alpha`, un hôte B
//! (`p3_host_b`) héberge `p3_shared` et `p3_beta`. Chaque hôte a son propre `LyxalRuntime`, son
//! propre store système, son propre gestionnaire de baux, son propre identifiant de nœud et son
//! propre chef des événements (`event_stream_lease:<hôte>`) ; seule la base est commune (moteur
//! embarqué `mem://`, ou serveur SurrealDB réel pour le test `ws://` ignoré par défaut).
//!
//! Événements : `p3.alpha.pinged` est traité par A, `p3.beta.pinged` par B, et `p3.shared.pinged`
//! par les deux (un abonnement par hôte). Chaque événement atteint le handler de son hôte, une
//! fois, sans dead letter ; les livraisons d'un hôte arrêté attendent son retour sans essai
//! compté.
//!
//! Les tests vérifient l'installation des deux jeux, les baux d'installation, que le hook
//! `install` d'un module n'est appelé qu'une fois pour toute la base (ni par le second hôte, ni
//! à un redémarrage), la présence des nœuds (`runtime_node`), que la réconciliation stricte d'un
//! hôte signale les modules de l'autre sans les viser, le refus d'une release de même version au
//! contenu différent, que le redémarrage ou l'arrêt d'un hôte laisse l'autre en marche, et la
//! ventilation simultanée des mêmes événements par les deux hôtes.

use crate::common;
use async_trait::async_trait;
use lyxal_event::{
    Event, EventContext, EventSubscription, EventWorkerConfig, Handler, HandlerContext,
    HandlerRegistry, LyxalEventEnvelope, LyxalEventError,
};
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::event_engine::{EventConsumerModule, EventEngineConfig};
use lyxal_runtime::lock::installation::{
    InstallationLeaseManager, InstallationLockKey, SurrealInstallationLeaseManager,
};
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::manifest::model::{ModuleDependency, CURRENT_MANIFEST_VERSION};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::reconciler::desired::DesiredRuntimeState;
use lyxal_runtime::reconciler::plan::{
    ActionKind, ForeignModule, ReconciliationAction, ReconciliationPlan, ReconciliationReason,
};
use lyxal_runtime::reconciler::reconciler::RuntimeReconciler;
use lyxal_runtime::reconciler::report::ConvergenceStatus;
use lyxal_runtime::resource::ResourceKind;
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::store::surreal::SurrealRuntimeStore;
use lyxal_runtime::store::traits::RuntimeStore;
use lyxal_runtime::types::{ModuleId, ModuleState};
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
    WorkerState,
};
use lyxal_runtime::RuntimeConfig;
use semver::Version;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
use surrealdb::Surreal;

const SHARED: &str = "p3_shared";
const ALPHA: &str = "p3_alpha";
const BETA: &str = "p3_beta";
const VERSION: &str = "0.1.0";
const HOST_A: &str = "p3_host_a";
const HOST_B: &str = "p3_host_b";
const ALPHA_EVENT: &str = "p3.alpha.pinged";
const BETA_EVENT: &str = "p3.beta.pinged";
const SHARED_EVENT: &str = "p3.shared.pinged";

/// Compteurs des hooks d'un module, communs à toutes ses instances (un hôte redémarré recrée
/// l'instance du module mais garde les mêmes compteurs).
#[derive(Clone, Default)]
struct Counters {
    installs: Arc<AtomicUsize>,
    starts: Arc<AtomicUsize>,
    stops: Arc<AtomicUsize>,
}

impl Counters {
    fn snapshot(&self) -> (usize, usize, usize) {
        (
            self.installs.load(Ordering::SeqCst),
            self.starts.load(Ordering::SeqCst),
            self.stops.load(Ordering::SeqCst),
        )
    }
}

struct HostedModule {
    descriptor: ModuleDescriptor,
    counters: Counters,
}

#[async_trait]
impl LyxalModule for HostedModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.counters.installs.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.counters.starts.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.counters.stops.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

/// Worker de fond d'un module : compte ses tours tant qu'il n'est pas annulé.
struct TickWorker {
    descriptor: WorkerDescriptor,
    ticks: Arc<AtomicUsize>,
}

#[async_trait]
impl LyxalWorker for TickWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(Duration::from_millis(10)) => {
                    self.ticks.fetch_add(1, Ordering::SeqCst);
                }
            }
        }
        Ok(())
    }
}

macro_rules! ping_event {
    ($name:ident, $type:expr) => {
        #[derive(Debug, Clone, Serialize, Deserialize)]
        struct $name {
            n: u32,
        }
        impl Event for $name {
            const EVENT_TYPE: &'static str = $type;
        }
    };
}
ping_event!(AlphaPinged, "p3.alpha.pinged");
ping_event!(BetaPinged, "p3.beta.pinged");
ping_event!(SharedPinged, "p3.shared.pinged");

/// Traitements d'un hôte : (type d'événement, numéro).
type Journal = Arc<Mutex<Vec<(String, u32)>>>;

/// Handler d'essai : note chaque événement reçu dans le journal de son hôte.
#[derive(Clone)]
struct Recorder {
    journal: Journal,
}

macro_rules! recorder_handler {
    ($event:ty) => {
        #[async_trait]
        impl Handler<$event> for Recorder {
            async fn handle(
                &self,
                event: $event,
                _ctx: &HandlerContext,
            ) -> Result<(), LyxalEventError> {
                self.journal
                    .lock()
                    .unwrap()
                    .push((<$event as Event>::EVENT_TYPE.to_string(), event.n));
                Ok(())
            }
        }
    };
}
recorder_handler!(AlphaPinged);
recorder_handler!(BetaPinged);
recorder_handler!(SharedPinged);

/// Consommateur d'un hôte : l'événement du module commun et celui de son module propre.
struct Consumer {
    own_module: &'static str,
    journal: Journal,
}

impl EventConsumerModule for Consumer {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        let recorder = Recorder {
            journal: self.journal.clone(),
        };
        let to_runtime = |e: LyxalEventError| RuntimeError::EventEngineError {
            message: e.to_string(),
        };
        registry
            .register::<SharedPinged, _>(recorder.clone())
            .map_err(to_runtime)?;
        if self.own_module == ALPHA {
            registry
                .register::<AlphaPinged, _>(recorder)
                .map_err(to_runtime)?;
        } else {
            registry
                .register::<BetaPinged, _>(recorder)
                .map_err(to_runtime)?;
        }
        Ok(())
    }
}

/// Moteur d'événements rapide de l'hôte `host` (chef de cet hôte, nœud `node`).
fn event_config(host: &str, node: &str) -> EventEngineConfig {
    let worker = EventWorkerConfig::new(host)
        .with_worker_id(format!("{node}-events"))
        .with_batch_size(50)
        .with_poll_interval(Duration::from_millis(20))
        .with_lease_ttl(Duration::from_secs(2))
        .with_lease_renew_interval(Duration::from_millis(500))
        .with_retry_base_delay(Duration::from_millis(10))
        .with_retry_max_delay(Duration::from_millis(50))
        .with_dispatch_timeout(Duration::from_secs(5));
    EventEngineConfig::new(&common::host(host))
        .with_auto_init_schema(false)
        .with_worker_config(worker)
}

/// Base partagée par les deux hôtes : socle, schéma du runtime et `lyxal_event` installés.
async fn shared_db(db: &str) -> Surreal<Any> {
    let client = common::setup_db(db, db).await;
    common::install_event(&client).await;
    client
}

/// Package d'un module de test : une table, une migration, une dépendance éventuelle.
fn package(id: &str, dependency: Option<&str>, counters: &Counters) -> ModulePackage {
    package_with_schema(
        id,
        dependency,
        counters,
        &format!("DEFINE TABLE OVERWRITE {id}_item SCHEMALESS;"),
    )
}

/// Package d'un module de test dont le fichier de schéma a le contenu donné.
fn package_with_schema(
    id: &str,
    dependency: Option<&str>,
    counters: &Counters,
    schema: &str,
) -> ModulePackage {
    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new(id),
        name: id.to_string(),
        version: Version::parse(VERSION).unwrap(),
        description: None,
        runtime: None,
        dependencies: dependency.into_iter().map(ModuleDependency::new).collect(),
        capabilities: Vec::new(),
        resources: Default::default(),
    };
    let provider = Arc::new(
        common::MemoryProvider::new()
            .add_resource(&format!("schema/{id}.surql"), ResourceKind::Schema, schema)
            .add_resource(
                "migrations/0001_initial.surql",
                ResourceKind::Migration,
                &format!("DEFINE FIELD OVERWRITE label ON TABLE {id}_item TYPE option<string>;"),
            ),
    );
    let module = Arc::new(HostedModule {
        descriptor: ModuleDescriptor::builder(id, VERSION)
            .dependencies(dependency.into_iter().map(ModuleId::new))
            .build(),
        counters: counters.clone(),
    });
    common::package(manifest, provider).with_module_impl(module)
}

/// Un hôte : un runtime, son store, son gestionnaire de baux et le worker de son module propre.
struct Host {
    runtime: Arc<LyxalRuntime>,
    store: Arc<SurrealRuntimeStore>,
    name: &'static str,
    own_module: &'static str,
    worker_id: WorkerId,
    ticks: Arc<AtomicUsize>,
    journal: Journal,
}

impl Host {
    async fn new(
        client: &Surreal<Any>,
        node: &str,
        name: &'static str,
        own_module: &'static str,
    ) -> Self {
        let store = Arc::new(SurrealRuntimeStore::new(client.clone()));
        let runtime = Arc::new(
            LyxalRuntime::new(RuntimeConfig::new(common::host(name)))
                .with_client(client.clone())
                .with_event_config(event_config(name, node))
                .with_store(store.clone())
                .with_installation_lease_manager(Arc::new(SurrealInstallationLeaseManager::new(
                    client.clone(),
                )))
                .with_node_id(NodeId::new(node)),
        );
        let module_id = ModuleId::new(own_module);
        let worker_id = WorkerId::new(&module_id, "ticker").unwrap();
        let ticks = Arc::new(AtomicUsize::new(0));
        runtime
            .register_worker(Arc::new(TickWorker {
                descriptor: WorkerDescriptor::new(worker_id.clone(), module_id, "ticker")
                    .with_criticality(WorkerCriticality::Required)
                    .with_restart_policy(RestartPolicy::Never)
                    .with_shutdown_timeout(Duration::from_millis(500)),
                ticks: ticks.clone(),
            }))
            .unwrap();
        let journal = Journal::default();
        runtime
            .register_event_consumer(Arc::new(Consumer {
                own_module,
                journal: journal.clone(),
            }))
            .await;
        Self {
            runtime,
            store,
            name,
            own_module,
            worker_id,
            ticks,
            journal,
        }
    }

    /// Événement du module propre de l'hôte.
    fn own_event(&self) -> &'static str {
        if self.own_module == ALPHA {
            ALPHA_EVENT
        } else {
            BETA_EVENT
        }
    }

    /// Abonnements de l'hôte, enregistrés par lui comme par l'hôte qui porte les handlers :
    /// l'événement du module commun et celui de son module propre.
    async fn subscribe(&self) {
        let events = self.runtime.event_store().unwrap();
        for (name, module, pattern) in [
            (format!("{}_shared", self.name), SHARED, SHARED_EVENT),
            (
                format!("{}_own", self.name),
                self.own_module,
                self.own_event(),
            ),
        ] {
            events
                .register_subscription(&EventSubscription::new(
                    name,
                    module,
                    pattern,
                    "p3.on_ping",
                    self.name,
                ))
                .await
                .unwrap();
        }
    }

    /// Publie des événements (type, numéro) par le publisher de cet hôte.
    async fn publish(&self, events: &[(&str, u32)]) {
        let publisher = self.runtime.event_publisher().unwrap();
        for (event_type, n) in events {
            match *event_type {
                ALPHA_EVENT => publisher.publish(&AlphaPinged { n: *n }).await,
                BETA_EVENT => publisher.publish(&BetaPinged { n: *n }).await,
                _ => publisher.publish(&SharedPinged { n: *n }).await,
            }
            .unwrap();
        }
    }

    /// Événements traités par cet hôte, triés.
    fn received(&self) -> Vec<(String, u32)> {
        let mut received = self.journal.lock().unwrap().clone();
        received.sort();
        received
    }

    /// Attend que cet hôte ait traité exactement `expected` (type, numéro), une fois chacun.
    async fn wait_received(&self, expected: &[(&str, u32)]) {
        let mut expected: Vec<(String, u32)> = expected
            .iter()
            .map(|(event_type, n)| (event_type.to_string(), *n))
            .collect();
        expected.sort();
        for _ in 0..500 {
            if self.journal.lock().unwrap().len() >= expected.len() {
                break;
            }
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
        // Délai de grâce : un doublon arriverait maintenant
        tokio::time::sleep(Duration::from_millis(100)).await;
        assert_eq!(
            self.received(),
            expected,
            "événements traités par {}",
            self.name
        );
    }

    fn packages(&self, shared: &Counters, own: &Counters) -> Vec<ModulePackage> {
        vec![
            package(SHARED, None, shared),
            package(self.own_module, Some(SHARED), own),
        ]
    }

    fn state(&self, module: &str) -> Option<ModuleState> {
        self.runtime.module_state(&ModuleId::new(module))
    }

    fn worker_state(&self) -> Option<WorkerState> {
        self.runtime.worker_supervisor().state(&self.worker_id)
    }

    /// Attend que le worker de l'hôte soit en marche (son démarrage est asynchrone).
    async fn worker_is_running(&self) -> bool {
        for _ in 0..100 {
            if self.worker_state() == Some(WorkerState::Running) {
                return true;
            }
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
        false
    }

    /// Vrai si le worker de l'hôte avance encore (au moins un tour pendant l'attente).
    async fn worker_progresses(&self) -> bool {
        let before = self.ticks.load(Ordering::SeqCst);
        tokio::time::sleep(Duration::from_millis(80)).await;
        self.ticks.load(Ordering::SeqCst) > before
    }
}

/// Ligne de `runtime_lease` lue par le test.
#[derive(Debug, SurrealValue)]
struct LeaseRow {
    key: String,
    owner_node_id: String,
    generation: i64,
    is_released: bool,
}

/// Photographie de ce que la base garde des modules : releases et migrations par module.
async fn database_snapshot(store: &SurrealRuntimeStore) -> BTreeMap<String, Vec<String>> {
    let mut snapshot = BTreeMap::new();
    for module in store.list_modules().await.unwrap() {
        let mut lines = Vec::new();
        for release in store.list_releases(&module.module_id).await.unwrap() {
            lines.push(format!(
                "release {} {} {:?}",
                release.version, release.status, release.installation_phase
            ));
        }
        for migration in store.list_migrations(&module.module_id).await.unwrap() {
            lines.push(format!("migration {migration:?}"));
        }
        snapshot.insert(module.module_id.to_string(), lines);
    }
    snapshot
}

async fn release_status(store: &SurrealRuntimeStore, module: &str) -> String {
    store
        .get_release(&ModuleId::new(module), VERSION)
        .await
        .unwrap()
        .unwrap_or_else(|| panic!("release de {module} absente"))
        .status
}

/// Livraison d'un hôte lue par le test.
#[derive(Debug, PartialEq, SurrealValue)]
struct DeliveryRow {
    status: String,
    attempts: i64,
}

/// Bail d'un chef des événements lu par le test.
#[derive(Debug, PartialEq, SurrealValue)]
struct EventLeaseRow {
    host: String,
    owner_node_id: String,
}

async fn count(client: &Surreal<Any>, sql: &str) -> i64 {
    let mut response = client.query(sql).await.unwrap();
    let total: Option<i64> = response.take(0).unwrap();
    total.unwrap()
}

async fn dead_letters(client: &Surreal<Any>) -> i64 {
    count(client, "RETURN count(SELECT * FROM event_dead_letter);").await
}

/// Livraisons non soldées de l'hôte `host`.
async fn open_deliveries(client: &Surreal<Any>, host: &str) -> Vec<DeliveryRow> {
    let mut response = client
        .query(
            "SELECT status, attempts FROM event_delivery \
             WHERE host = $host AND status NOT IN ['delivered', 'dead_letter', 'dropped']",
        )
        .bind(("host", host.to_string()))
        .await
        .unwrap();
    response.take(0).unwrap()
}

/// Vérifie que les livraisons de l'hôte arrêté `host` attendent, sans aucun essai compté.
async fn assert_waiting_untouched(client: &Surreal<Any>, host: &str, expected: usize) {
    // Le temps de plusieurs tours de l'autre chef des événements
    tokio::time::sleep(Duration::from_millis(300)).await;
    let open = open_deliveries(client, host).await;
    assert_eq!(open.len(), expected, "livraisons en attente de {host}");
    assert!(
        open.iter()
            .all(|d| d.status == "pending" && d.attempts == 0),
        "livraisons de {host} touchées : {open:?}"
    );
    assert_eq!(dead_letters(client).await, 0);
}

/// Baux des chefs des événements : un par hôte, détenu par son nœud.
async fn event_leases(client: &Surreal<Any>) -> Vec<EventLeaseRow> {
    let mut response = client
        .query("SELECT host, owner_node_id FROM event_stream_lease ORDER BY host")
        .await
        .unwrap();
    response.take(0).unwrap()
}

/// Installe les deux hôtes (simultanément si `concurrently`), enregistre leurs abonnements, les
/// démarre, puis vérifie que chaque événement atteint le handler de son hôte, une fois.
async fn start_two_hosts(
    client_a: &Surreal<Any>,
    client_b: &Surreal<Any>,
    concurrently: bool,
) -> (Host, Host, Counters, Counters, Counters) {
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(client_a, "host-a", HOST_A, ALPHA).await;
    let host_b = Host::new(client_b, "host-b", HOST_B, BETA).await;

    let (installed_a, installed_b) = if concurrently {
        tokio::join!(
            host_a
                .runtime
                .install_packages(host_a.packages(&shared, &alpha)),
            host_b
                .runtime
                .install_packages(host_b.packages(&shared, &beta)),
        )
    } else {
        let installed_a = host_a
            .runtime
            .install_packages(host_a.packages(&shared, &alpha))
            .await;
        let installed_b = host_b
            .runtime
            .install_packages(host_b.packages(&shared, &beta))
            .await;
        (installed_a, installed_b)
    };
    let (installed_a, installed_b) = (installed_a.unwrap(), installed_b.unwrap());
    for installed in [&installed_a, &installed_b] {
        assert!(
            installed.failed.is_empty() && installed.not_attempted.is_empty(),
            "{:?} {:?}",
            installed.failed,
            installed.not_attempted
        );
    }
    assert_eq!(shared.snapshot().0, 1, "hook install du module commun");

    host_a.subscribe().await;
    host_b.subscribe().await;
    host_a.runtime.start_all().await.unwrap();
    host_b.runtime.start_all().await.unwrap();
    assert!(host_a.worker_is_running().await);
    assert!(host_b.worker_is_running().await);

    // Chaque événement atteint le handler de son hôte, une fois ; l'événement commun atteint les
    // deux hôtes, une fois chacun ; aucune dead letter, quel que soit l'hôte qui publie.
    host_a.publish(&[(ALPHA_EVENT, 1), (SHARED_EVENT, 1)]).await;
    host_b.publish(&[(BETA_EVENT, 1)]).await;
    host_a
        .wait_received(&[(ALPHA_EVENT, 1), (SHARED_EVENT, 1)])
        .await;
    host_b
        .wait_received(&[(BETA_EVENT, 1), (SHARED_EVENT, 1)])
        .await;
    assert_eq!(dead_letters(client_a).await, 0);
    assert_eq!(
        event_leases(client_a).await,
        vec![
            EventLeaseRow {
                host: HOST_A.to_string(),
                owner_node_id: "host-a-events".to_string(),
            },
            EventLeaseRow {
                host: HOST_B.to_string(),
                owner_node_id: "host-b-events".to_string(),
            },
        ]
    );
    (host_a, host_b, shared, alpha, beta)
}

/// Installe et démarre les deux hôtes sur la même base embarquée, l'un après l'autre.
async fn two_running_hosts(db: &str) -> (Surreal<Any>, Host, Host, Counters, Counters, Counters) {
    let client = shared_db(db).await;
    let (host_a, host_b, shared, alpha, beta) = start_two_hosts(&client, &client, false).await;
    (client, host_a, host_b, shared, alpha, beta)
}

#[tokio::test]
async fn two_hosts_install_and_start_different_module_sets_on_one_database() {
    let client = shared_db("p3_install").await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA).await;
    let host_b = Host::new(&client, "host-b", HOST_B, BETA).await;

    // L'hôte A installe son jeu : tout est nouveau.
    let installed_a = host_a
        .runtime
        .install_packages(host_a.packages(&shared, &alpha))
        .await
        .unwrap();
    assert_eq!(
        installed_a.installed,
        vec![ModuleId::new(SHARED), ModuleId::new(ALPHA)]
    );
    assert!(installed_a.already_installed.is_empty());
    assert!(installed_a.failed.is_empty() && installed_a.not_attempted.is_empty());

    // L'hôte B installe le sien : le module commun est déjà là, il n'est pas réinstallé.
    let installed_b = host_b
        .runtime
        .install_packages(host_b.packages(&shared, &beta))
        .await
        .unwrap();
    assert_eq!(installed_b.installed, vec![ModuleId::new(BETA)]);
    assert_eq!(installed_b.already_installed, vec![ModuleId::new(SHARED)]);
    assert!(installed_b.failed.is_empty() && installed_b.not_attempted.is_empty());
    assert_eq!(shared.snapshot().0, 1, "hook install du module commun");
    assert_eq!((alpha.snapshot().0, beta.snapshot().0), (1, 1));
    // Pour l'hôte B, le module commun est installé sans que son hook ait été rejoué.
    assert_eq!(host_b.state(SHARED), Some(ModuleState::Installed));

    // La base connaît les trois modules, chacun avec une release installée et sa migration.
    let snapshot = database_snapshot(&host_a.store).await;
    assert_eq!(
        snapshot.keys().map(String::as_str).collect::<Vec<_>>(),
        vec![ALPHA, BETA, SHARED]
    );
    for module in [SHARED, ALPHA, BETA] {
        assert_eq!(release_status(&host_b.store, module).await, "Installed");
        let migrations = host_a
            .store
            .list_migrations(&ModuleId::new(module))
            .await
            .unwrap();
        assert_eq!(migrations.len(), 1, "migration de {module}");
        client
            .query(format!("CREATE {module}_item SET label = 'x'"))
            .await
            .unwrap()
            .check()
            .unwrap_or_else(|e| panic!("table de {module} inutilisable : {e}"));
    }

    // Baux d'installation : un par release, pris par l'hôte qui a installé, génération 1
    // (aucune reprise, aucun conflit), tous libérés. L'hôte B n'a pris aucun bail pour le
    // module commun, déjà installé.
    let mut response = client
        .query(
            "SELECT key, owner_node_id, generation, is_released FROM runtime_lease \
             WHERE kind = 'installation' ORDER BY key",
        )
        .await
        .unwrap();
    let rows: Vec<LeaseRow> = response.take(0).unwrap();
    let seen: Vec<(String, String, i64, bool)> = rows
        .into_iter()
        .map(|r| (r.key, r.owner_node_id, r.generation, r.is_released))
        .collect();
    let expected: Vec<(String, String, i64, bool)> =
        [(ALPHA, "host-a"), (BETA, "host-b"), (SHARED, "host-a")]
            .iter()
            .map(|(module, owner)| {
                let key = InstallationLockKey::new(ModuleId::new(*module), VERSION);
                (key.canonical_string(), owner.to_string(), 1, true)
            })
            .collect();
    assert_eq!(seen, expected);
    let leases = SurrealInstallationLeaseManager::new(client.clone());
    for module in [SHARED, ALPHA, BETA] {
        let key = InstallationLockKey::new(ModuleId::new(module), VERSION);
        assert!(
            leases.inspect(&key).await.unwrap().is_none(),
            "bail actif sur {module}"
        );
    }

    // Chaque hôte ne démarre que son jeu.
    host_a.runtime.start_all().await.unwrap();
    host_b.runtime.start_all().await.unwrap();
    assert_eq!(host_a.state(SHARED), Some(ModuleState::Running));
    assert_eq!(host_a.state(ALPHA), Some(ModuleState::Running));
    assert_eq!(host_a.state(BETA), None);
    assert_eq!(host_b.state(SHARED), Some(ModuleState::Running));
    assert_eq!(host_b.state(BETA), Some(ModuleState::Running));
    assert_eq!(host_b.state(ALPHA), None);
    assert!(host_a.worker_is_running().await);
    assert!(host_b.worker_is_running().await);
    // Le module commun est démarré une fois par hôte ; aucun hook d'arrêt n'est appelé. Le
    // démarrage n'appelle jamais le hook `install` : une seule fois pour le module commun, par
    // l'hôte qui l'a installé, une fois pour chaque module propre.
    assert_eq!(shared.snapshot(), (1, 2, 0));
    assert_eq!(alpha.snapshot(), (1, 1, 0));
    assert_eq!(beta.snapshot(), (1, 1, 0));

    // Présence : chaque nœud a écrit sa ligne, avec son hôte et ses modules.
    let nodes = host_a.runtime.nodes().await.unwrap();
    let mut seen: Vec<(String, String, Vec<String>, Option<bool>)> = nodes
        .into_iter()
        .map(|n| (n.node_id, n.host, n.modules, n.alive))
        .collect();
    seen.sort();
    assert_eq!(
        seen,
        vec![
            (
                "host-a".to_string(),
                HOST_A.to_string(),
                vec![ALPHA.to_string(), SHARED.to_string()],
                Some(true)
            ),
            (
                "host-b".to_string(),
                HOST_B.to_string(),
                vec![BETA.to_string(), SHARED.to_string()],
                Some(true)
            ),
        ]
    );

    // L'arrêt propre d'un hôte retire sa ligne et laisse celle de l'autre.
    host_a.runtime.stop_all().await.unwrap();
    let remaining: Vec<String> = host_b
        .runtime
        .nodes()
        .await
        .unwrap()
        .into_iter()
        .map(|n| n.node_id)
        .collect();
    assert_eq!(remaining, vec!["host-b".to_string()]);
    host_b.runtime.stop_all().await.unwrap();
    assert!(host_b.runtime.nodes().await.unwrap().is_empty());
}

#[tokio::test]
async fn starting_a_module_that_was_never_installed_is_refused() {
    let client = shared_db("p3_not_installed").await;
    let counters = Counters::default();
    let host = Host::new(&client, "host-a", HOST_A, ALPHA).await;
    host.runtime
        .register(Arc::new(HostedModule {
            descriptor: ModuleDescriptor::builder(SHARED, VERSION).build(),
            counters: counters.clone(),
        }))
        .unwrap();

    // `start_all` n'installe plus : un module resté `Registered` fait échouer le démarrage.
    let err = host.runtime.start_all().await.unwrap_err();
    match err {
        RuntimeError::InvalidStateTransition { module, from, to } => {
            assert_eq!(module, ModuleId::new(SHARED));
            assert_eq!(from, ModuleState::Registered);
            assert_eq!(to, ModuleState::Starting);
        }
        other => panic!("InvalidStateTransition attendu, obtenu {other:?}"),
    }
    assert_eq!(counters.snapshot(), (0, 0, 0));
    // Un nœud qui n'a pas démarré ne s'annonce pas dans la base.
    assert!(host.runtime.nodes().await.unwrap().is_empty());
}

#[tokio::test]
async fn a_release_with_the_same_version_and_another_content_is_refused() {
    let client = shared_db("p3_checksum").await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA).await;
    let host_b = Host::new(&client, "host-b", HOST_B, BETA).await;
    host_a
        .runtime
        .install_packages(host_a.packages(&shared, &alpha))
        .await
        .unwrap();

    // L'installateur a écrit l'empreinte de la release.
    let release = host_a
        .store
        .get_release(&ModuleId::new(SHARED), VERSION)
        .await
        .unwrap()
        .unwrap();
    let recorded = release.checksum.expect("empreinte de la release");
    assert_eq!(recorded.len(), 64);

    // L'hôte B embarque le module commun sous le même numéro, avec un autre contenu.
    let other_content = package_with_schema(
        SHARED,
        None,
        &shared,
        &format!("DEFINE TABLE OVERWRITE {SHARED}_item SCHEMAFULL;"),
    );
    let err = host_b
        .runtime
        .install_packages(vec![other_content, package(BETA, Some(SHARED), &beta)])
        .await
        .unwrap_err();
    assert_eq!(err.code(), "RUNTIME_RELEASE_CHECKSUM_MISMATCH");
    match err {
        RuntimeError::ReleaseChecksumMismatch {
            module,
            version,
            installed,
            embedded,
        } => {
            assert_eq!(module, ModuleId::new(SHARED));
            assert_eq!(version, VERSION);
            assert_eq!(installed, recorded);
            assert_ne!(embedded, recorded);
        }
        other => panic!("ReleaseChecksumMismatch attendu, obtenu {other:?}"),
    }

    // Rien n'a été installé par l'hôte B : ni son module propre, ni un second hook du commun.
    assert!(host_b
        .store
        .get_release(&ModuleId::new(BETA), VERSION)
        .await
        .unwrap()
        .is_none());
    assert_eq!((shared.snapshot().0, beta.snapshot().0), (1, 0));
    let unchanged = host_a
        .store
        .get_release(&ModuleId::new(SHARED), VERSION)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(unchanged.checksum, Some(recorded));
    assert_eq!(unchanged.status, "Installed");

    // Le même contenu est accepté.
    let accepted = host_b
        .runtime
        .install_packages(host_b.packages(&shared, &beta))
        .await
        .unwrap();
    assert_eq!(accepted.already_installed, vec![ModuleId::new(SHARED)]);
    assert_eq!(accepted.installed, vec![ModuleId::new(BETA)]);
}

#[tokio::test]
async fn two_hosts_install_concurrently_without_double_installation() {
    let client = shared_db("p3_concurrent").await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA).await;
    let host_b = Host::new(&client, "host-b", HOST_B, BETA).await;

    let (result_a, result_b) = tokio::join!(
        host_a
            .runtime
            .install_packages(host_a.packages(&shared, &alpha)),
        host_b
            .runtime
            .install_packages(host_b.packages(&shared, &beta)),
    );
    let (result_a, result_b) = (result_a.unwrap(), result_b.unwrap());
    assert!(result_a.failed.is_empty() && result_a.not_attempted.is_empty());
    assert!(result_b.failed.is_empty() && result_b.not_attempted.is_empty());

    // Le module commun est installé par un seul des deux hôtes, vu « déjà installé » par l'autre.
    let shared_id = ModuleId::new(SHARED);
    let installed_by = [&result_a, &result_b]
        .iter()
        .filter(|r| r.installed.contains(&shared_id))
        .count();
    let seen_installed_by = [&result_a, &result_b]
        .iter()
        .filter(|r| r.already_installed.contains(&shared_id))
        .count();
    assert_eq!((installed_by, seen_installed_by), (1, 1));
    assert_eq!(shared.snapshot().0, 1, "hook install du module commun");
    assert_eq!((alpha.snapshot().0, beta.snapshot().0), (1, 1));
    for module in [SHARED, ALPHA, BETA] {
        assert_eq!(release_status(&host_a.store, module).await, "Installed");
    }
}

#[tokio::test]
async fn reconciliation_of_one_host_leaves_the_other_hosts_modules_untouched() {
    let (client, host_a, host_b, _shared, _alpha, beta) = two_running_hosts("p3_reconcile").await;
    let before = database_snapshot(&host_b.store).await;
    let beta_before = beta.snapshot();

    let reconciler = RuntimeReconciler::new(host_a.runtime.clone());
    let available = host_a.packages(&Counters::default(), &Counters::default());

    // 1. État désiré de l'hôte A, mode ordinaire : il ne décrit que ses propres modules.
    let desired = DesiredRuntimeState::new().running(SHARED).running(ALPHA);
    let plan = reconciler.plan(&desired, &available).await.unwrap();
    assert!(
        plan.actions.is_empty(),
        "aucune action attendue : {:?}",
        plan.actions
    );
    let report = reconciler.reconcile(&desired, &available).await.unwrap();
    assert_eq!(report.convergence, ConvergenceStatus::Converged);
    assert_eq!(database_snapshot(&host_b.store).await, before);

    // 2. Mode strict : l'hôte A voit dans la base un module qu'il n'héberge pas. Il le signale
    //    comme module d'un autre hôte, avec l'hôte vivant qui le déclare, et ne planifie rien.
    let strict = desired.clone().with_strict(true);
    let strict_plan = reconciler.plan(&strict, &available).await.unwrap();
    assert!(
        strict_plan.actions.is_empty(),
        "aucune action attendue : {:?}",
        strict_plan.actions
    );
    assert!(strict_plan.blockers.is_empty());
    assert_eq!(
        strict_plan.foreign_modules,
        vec![ForeignModule {
            module_id: ModuleId::new(BETA),
            hosts: vec![HOST_B.to_string()],
        }]
    );
    let strict_report = reconciler.reconcile(&strict, &available).await.unwrap();
    assert_eq!(strict_report.planned_actions, 0);
    assert!(strict_report.executed.is_empty());
    assert!(strict_report.failed.is_empty());
    assert_eq!(strict_report.convergence, ConvergenceStatus::Converged);
    assert_eq!(database_snapshot(&host_b.store).await, before);
    assert_eq!(release_status(&host_b.store, BETA).await, "Installed");

    assert_eq!(host_b.state(BETA), Some(ModuleState::Running));
    assert_eq!(host_b.state(SHARED), Some(ModuleState::Running));
    assert_eq!(beta.snapshot(), beta_before);
    assert!(host_b.worker_is_running().await);
    assert!(host_b.worker_progresses().await);
    // L'hôte A garde aussi son propre jeu en marche.
    assert_eq!(host_a.state(ALPHA), Some(ModuleState::Running));
    assert_eq!(host_a.state(SHARED), Some(ModuleState::Running));
    // Les deux chefs des événements livrent toujours, chacun ses abonnements.
    host_b
        .publish(&[(ALPHA_EVENT, 2), (BETA_EVENT, 2), (SHARED_EVENT, 2)])
        .await;
    host_a
        .wait_received(&[
            (ALPHA_EVENT, 1),
            (SHARED_EVENT, 1),
            (ALPHA_EVENT, 2),
            (SHARED_EVENT, 2),
        ])
        .await;
    host_b
        .wait_received(&[
            (BETA_EVENT, 1),
            (SHARED_EVENT, 1),
            (BETA_EVENT, 2),
            (SHARED_EVENT, 2),
        ])
        .await;
    assert_eq!(dead_letters(&client).await, 0);

    // 3. Hôte B arrêté : son module reste signalé, sans hôte vivant qui le déclare.
    host_b.runtime.stop_all().await.unwrap();
    let plan_alone = reconciler.plan(&strict, &available).await.unwrap();
    assert!(plan_alone.actions.is_empty());
    assert_eq!(
        plan_alone.foreign_modules,
        vec![ForeignModule {
            module_id: ModuleId::new(BETA),
            hosts: Vec::new(),
        }]
    );
    assert_eq!(release_status(&host_a.store, BETA).await, "Installed");

    host_a.runtime.stop_all().await.unwrap();
}

#[tokio::test]
async fn marking_inactive_a_module_this_runtime_does_not_host_fails() {
    let (_client, host_a, host_b, _shared, _alpha, _beta) =
        two_running_hosts("p3_mark_inactive").await;
    let reconciler = RuntimeReconciler::new(host_a.runtime.clone());

    // Plan écrit à la main : le calcul du plan ne vise jamais le module d'un autre hôte.
    let mut plan = ReconciliationPlan::new();
    plan.actions.push(ReconciliationAction {
        module_id: ModuleId::new(BETA),
        kind: ActionKind::MarkInactive,
        reason: ReconciliationReason::new(None, "Installed", false),
        package: None,
        preconditions: Vec::new(),
    });
    let report = reconciler
        .apply(plan, &[], &DesiredRuntimeState::new())
        .await
        .unwrap();
    assert!(report.executed.is_empty(), "{:?}", report.executed);
    assert_eq!(report.failed.len(), 1);
    assert_eq!(report.failed[0].module_id, ModuleId::new(BETA));
    assert!(matches!(
        report.failed[0].error,
        RuntimeError::UnknownModule { .. }
    ));
    assert_eq!(release_status(&host_b.store, BETA).await, "Installed");

    host_a.runtime.stop_all().await.unwrap();
    host_b.runtime.stop_all().await.unwrap();
}

#[tokio::test]
async fn restarting_one_host_has_no_effect_on_the_other() {
    let (client, host_a, host_b, shared, alpha, beta) = two_running_hosts("p3_restart").await;
    let database_before = database_snapshot(&host_b.store).await;
    let beta_before = beta.snapshot();
    let shared_before = shared.snapshot();

    // Arrêt de l'hôte A.
    host_a.runtime.stop_all().await.unwrap();
    assert_eq!(host_a.state(ALPHA), Some(ModuleState::Stopped));
    assert_eq!(host_a.worker_state(), Some(WorkerState::Stopped));

    // L'hôte B ne voit rien : mêmes états, mêmes hooks, worker toujours actif, base inchangée.
    assert_eq!(host_b.state(BETA), Some(ModuleState::Running));
    assert_eq!(host_b.state(SHARED), Some(ModuleState::Running));
    assert!(host_b.worker_is_running().await);
    assert!(host_b.worker_progresses().await);
    assert_eq!(beta.snapshot(), beta_before);
    assert_eq!(database_snapshot(&host_b.store).await, database_before);

    // Événements publiés pendant l'arrêt de A : B livre les siens ; ceux de A attendent son retour,
    // sans essai compté ni dead letter.
    host_b
        .publish(&[(ALPHA_EVENT, 2), (SHARED_EVENT, 2), (BETA_EVENT, 2)])
        .await;
    host_b
        .wait_received(&[
            (BETA_EVENT, 1),
            (SHARED_EVENT, 1),
            (BETA_EVENT, 2),
            (SHARED_EVENT, 2),
        ])
        .await;
    assert_waiting_untouched(&client, HOST_A, 2).await;

    // Redémarrage de A : un nouveau processus (nouveau runtime, même nœud) rejoue installation
    // et démarrage. Rien n'est réinstallé.
    let host_a2 = Host::new(&client, "host-a", HOST_A, ALPHA).await;
    let reinstalled = host_a2
        .runtime
        .install_packages(host_a2.packages(&shared, &alpha))
        .await
        .unwrap();
    assert!(reinstalled.installed.is_empty());
    assert_eq!(
        reinstalled.already_installed,
        vec![ModuleId::new(SHARED), ModuleId::new(ALPHA)]
    );
    assert_eq!(alpha.snapshot().0, 1, "p3_alpha non réinstallé");
    assert_eq!(
        shared.snapshot().0,
        shared_before.0,
        "module commun non réinstallé"
    );
    host_a2.subscribe().await;
    host_a2.runtime.start_all().await.unwrap();
    assert_eq!(host_a2.state(ALPHA), Some(ModuleState::Running));
    assert!(host_a2.worker_is_running().await);
    // Le nouveau processus de A livre ce qui l'attendait, une fois, et rien de ce qui était déjà
    // livré avant son arrêt.
    host_a2
        .wait_received(&[(ALPHA_EVENT, 2), (SHARED_EVENT, 2)])
        .await;
    assert!(open_deliveries(&client, HOST_A).await.is_empty());
    assert_eq!(dead_letters(&client).await, 0);
    // Le redémarrage n'appelle aucun hook `install` : ni celui du module propre, ni celui du
    // module commun.
    assert_eq!(alpha.snapshot().0, 1, "hook install de p3_alpha");
    assert_eq!(
        shared.snapshot().0,
        shared_before.0,
        "hook install du module commun"
    );
    assert_eq!(shared_before.0, 1);

    // Toujours aucun effet sur B.
    assert_eq!(host_b.state(BETA), Some(ModuleState::Running));
    assert!(host_b.worker_is_running().await);
    assert!(host_b.worker_progresses().await);
    assert_eq!(beta.snapshot(), beta_before);
    assert_eq!(database_snapshot(&host_b.store).await, database_before);

    host_a2.runtime.stop_all().await.unwrap();
    host_b.runtime.stop_all().await.unwrap();
}

#[tokio::test]
async fn stopping_one_host_leaves_the_other_running() {
    let (client, host_a, host_b, _shared, alpha, beta) = two_running_hosts("p3_stop").await;
    let database_before = database_snapshot(&host_a.store).await;

    host_b.runtime.stop_all().await.unwrap();
    assert_eq!(host_b.state(BETA), Some(ModuleState::Stopped));
    assert_eq!(host_b.state(SHARED), Some(ModuleState::Stopped));
    assert_eq!(host_b.worker_state(), Some(WorkerState::Stopped));
    assert_eq!(beta.snapshot().2, 1);

    // L'hôte A continue : modules en marche, worker actif, aucun hook d'arrêt appelé.
    assert_eq!(host_a.state(ALPHA), Some(ModuleState::Running));
    assert_eq!(host_a.state(SHARED), Some(ModuleState::Running));
    assert!(host_a.worker_is_running().await);
    assert!(host_a.worker_progresses().await);
    assert_eq!(alpha.snapshot().2, 0);

    // Les événements de A sont livrés ; ceux de B attendent son retour, sans essai compté.
    host_a
        .publish(&[(BETA_EVENT, 2), (SHARED_EVENT, 2), (ALPHA_EVENT, 2)])
        .await;
    host_a
        .wait_received(&[
            (ALPHA_EVENT, 1),
            (SHARED_EVENT, 1),
            (ALPHA_EVENT, 2),
            (SHARED_EVENT, 2),
        ])
        .await;
    assert_waiting_untouched(&client, HOST_B, 2).await;

    // L'arrêt d'un hôte ne retire rien de la base : les releases de ses modules restent
    // installées et leurs tables utilisables par l'hôte restant.
    assert_eq!(database_snapshot(&host_a.store).await, database_before);
    assert_eq!(release_status(&host_a.store, BETA).await, "Installed");
    client
        .query(format!(
            "CREATE {SHARED}_item SET label = 'après arrêt de B'"
        ))
        .await
        .unwrap()
        .check()
        .unwrap();

    host_a.runtime.stop_all().await.unwrap();
    assert_eq!(host_a.state(ALPHA), Some(ModuleState::Stopped));
}

/// Paires (type, numéro) empruntées à une liste de traitements.
fn as_pairs(list: &[(String, u32)]) -> Vec<(&str, u32)> {
    list.iter().map(|(t, n)| (t.as_str(), *n)).collect()
}

/// Écrit vingt événements du module commun sans les ventiler (comme après un arrêt brutal
/// entre l'écriture dans l'outbox et la ventilation), puis les fait ventiler par les deux hôtes
/// en même temps : une livraison par abonnement et par événement, chaque hôte traite chaque
/// événement une fois, sans dead letter.
async fn fan_out_concurrently(client: &Surreal<Any>, host_a: &Host, host_b: &Host, first: u32) {
    let store = host_a.runtime.event_store().unwrap();
    let numbers: Vec<u32> = (first..first + 20).collect();
    let mut expected_a = host_a.received();
    let mut expected_b = host_b.received();
    for n in &numbers {
        let envelope =
            LyxalEventEnvelope::new(SHARED, EventContext::default(), &SharedPinged { n: *n })
                .unwrap();
        store.publish(&envelope, false).await.unwrap();
    }
    let (from_a, from_b) = tokio::join!(
        host_a.runtime.recover_pending_fanouts(100),
        host_b.runtime.recover_pending_fanouts(100),
    );
    from_a.unwrap();
    from_b.unwrap();
    assert_eq!(
        count(
            client,
            "RETURN count(SELECT * FROM event_outbox WHERE status = 'pending');"
        )
        .await,
        0
    );
    // Deux livraisons par événement commun (une par hôte), jamais plus
    assert_eq!(
        count(
            client,
            "RETURN count(SELECT * FROM (SELECT outbox_event, count() AS deliveries FROM event_delivery \
             WHERE outbox_event.event_type = 'p3.shared.pinged' GROUP BY outbox_event) WHERE deliveries != 2);",
        )
        .await,
        0
    );
    for n in &numbers {
        expected_a.push((SHARED_EVENT.to_string(), *n));
        expected_b.push((SHARED_EVENT.to_string(), *n));
    }
    host_a.wait_received(&as_pairs(&expected_a)).await;
    host_b.wait_received(&as_pairs(&expected_b)).await;
    assert_eq!(dead_letters(client).await, 0);
}

#[tokio::test]
async fn two_hosts_fan_out_the_same_events_concurrently() {
    let (client, host_a, host_b, _shared, _alpha, _beta) = two_running_hosts("p3_fanout").await;
    fan_out_concurrently(&client, &host_a, &host_b, 100).await;
    host_a.runtime.stop_all().await.unwrap();
    host_b.runtime.stop_all().await.unwrap();
}

/// Vie complète de deux hôtes, chacun sur sa connexion à la même base : installation simultanée,
/// démarrage, livraison des événements au bon hôte, réconciliation stricte, ventilation
/// simultanée, redémarrage d'un hôte avec des livraisons en attente, arrêt de l'autre.
async fn two_hosts_lifecycle(client_a: &Surreal<Any>, client_b: &Surreal<Any>) {
    let (host_a, host_b, shared, alpha, beta) = start_two_hosts(client_a, client_b, true).await;
    assert_eq!(
        (shared.snapshot(), alpha.snapshot(), beta.snapshot()),
        ((1, 2, 0), (1, 1, 0), (1, 1, 0))
    );

    // Réconciliation stricte de A : le module de B est signalé, sans action
    let reconciler = RuntimeReconciler::new(host_a.runtime.clone());
    let available = host_a.packages(&Counters::default(), &Counters::default());
    let strict = DesiredRuntimeState::new()
        .running(SHARED)
        .running(ALPHA)
        .with_strict(true);
    let report = reconciler.reconcile(&strict, &available).await.unwrap();
    assert_eq!(report.planned_actions, 0);
    assert!(report.executed.is_empty() && report.failed.is_empty());
    assert_eq!(host_b.state(BETA), Some(ModuleState::Running));
    let plan = reconciler.plan(&strict, &available).await.unwrap();
    assert_eq!(
        plan.foreign_modules,
        vec![ForeignModule {
            module_id: ModuleId::new(BETA),
            hosts: vec![HOST_B.to_string()],
        }]
    );

    // Ventilation simultanée des mêmes événements par les deux hôtes
    fan_out_concurrently(client_a, &host_a, &host_b, 100).await;

    // A arrêté : B livre les siens, ceux de A attendent ; au retour de A, livrés une fois
    host_a.runtime.stop_all().await.unwrap();
    let mut expected_b: Vec<(String, u32)> = host_b.received();
    host_b
        .publish(&[(ALPHA_EVENT, 2), (SHARED_EVENT, 2), (BETA_EVENT, 2)])
        .await;
    expected_b.push((BETA_EVENT.to_string(), 2));
    expected_b.push((SHARED_EVENT.to_string(), 2));
    host_b.wait_received(&as_pairs(&expected_b)).await;
    assert_waiting_untouched(client_b, HOST_A, 2).await;
    let host_a2 = Host::new(client_a, "host-a", HOST_A, ALPHA).await;
    let reinstalled = host_a2
        .runtime
        .install_packages(host_a2.packages(&shared, &alpha))
        .await
        .unwrap();
    assert!(reinstalled.installed.is_empty());
    host_a2.subscribe().await;
    host_a2.runtime.start_all().await.unwrap();
    host_a2
        .wait_received(&[(ALPHA_EVENT, 2), (SHARED_EVENT, 2)])
        .await;
    assert_eq!(shared.snapshot().0, 1, "hook install du module commun");
    assert_eq!(alpha.snapshot().0, 1, "hook install de p3_alpha");

    // B arrêté : ses livraisons attendent, A continue
    host_b.runtime.stop_all().await.unwrap();
    host_a2.publish(&[(BETA_EVENT, 3), (ALPHA_EVENT, 3)]).await;
    host_a2
        .wait_received(&[(ALPHA_EVENT, 2), (SHARED_EVENT, 2), (ALPHA_EVENT, 3)])
        .await;
    assert_waiting_untouched(client_a, HOST_B, 1).await;

    host_a2.runtime.stop_all().await.unwrap();
    assert!(host_a2.runtime.nodes().await.unwrap().is_empty());
    assert_eq!(dead_letters(client_a).await, 0);
}

#[tokio::test]
async fn two_hosts_lifecycle_with_events_on_an_embedded_database() {
    let client = shared_db("p3_lifecycle").await;
    two_hosts_lifecycle(&client, &client).await;
}

/// Serveur SurrealDB 3.3.4 réel (`ws://`) : chaque hôte a sa propre connexion à la même base.
/// `LYXAL_SURREAL_WS_URL`, `LYXAL_SURREAL_USER`, `LYXAL_SURREAL_PASS` (`scripts/ci/test_all.sh`).
#[tokio::test]
#[ignore = "nécessite un serveur SurrealDB distant (LYXAL_SURREAL_WS_URL)"]
async fn two_hosts_lifecycle_with_events_on_a_remote_server() {
    let namespace = "lyxal_runtime_ws";
    let database = format!("t{}", uuid::Uuid::now_v7().simple());
    let client_a = common::remote_db(namespace, &database).await;
    common::install_base(&client_a).await;
    common::install_event(&client_a).await;
    let client_b = common::remote_db(namespace, &database).await;

    two_hosts_lifecycle(&client_a, &client_b).await;

    client_a
        .query(format!("REMOVE DATABASE {database}"))
        .await
        .unwrap()
        .check()
        .unwrap();
}
