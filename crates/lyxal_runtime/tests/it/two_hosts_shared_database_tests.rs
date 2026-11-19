//! Deux hôtes à jeux de modules différents sur une même base.
//!
//! Un hôte A (`p3_host_a`) héberge les modules `p3_shared` et `p3_alpha`, un hôte B
//! (`p3_host_b`) héberge `p3_shared` et `p3_beta`. Chaque hôte a son propre `LyxalRuntime`, son
//! propre store système, son propre gestionnaire de baux et son propre identifiant de nœud ;
//! seule la base est commune (moteur embarqué `mem://`, comme les autres tests à plusieurs
//! nœuds du crate).
//!
//! Les tests vérifient l'installation des deux jeux, les baux d'installation, que le hook
//! `install` d'un module n'est appelé qu'une fois pour toute la base (ni par le second hôte, ni
//! à un redémarrage), la présence des nœuds (`runtime_node`), que la réconciliation stricte d'un
//! hôte signale les modules de l'autre sans les viser, le refus d'une release de même version au
//! contenu différent, et que le redémarrage ou l'arrêt d'un hôte laisse l'autre en marche.
//!
//! Le moteur d'événements est désactivé sur les deux hôtes : la livraison des événements à
//! plusieurs hôtes (un chef des événements par hôte, `event_stream_lease:<hôte>`) est vérifiée par
//! les tests de `lyxal_event` (`tests/it/integration_multi_host.rs`).

use crate::common;
use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::event_engine::EventEngineConfig;
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
use std::collections::BTreeMap;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
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
    own_module: &'static str,
    worker_id: WorkerId,
    ticks: Arc<AtomicUsize>,
}

impl Host {
    fn new(client: &Surreal<Any>, node: &str, host: &str, own_module: &'static str) -> Self {
        let store = Arc::new(SurrealRuntimeStore::new(client.clone()));
        let runtime = Arc::new(
            LyxalRuntime::new(RuntimeConfig::new(common::host(host)))
                .with_client(client.clone())
                .with_event_config(EventEngineConfig::new(&common::host(host)).with_enabled(false))
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
        Self {
            runtime,
            store,
            own_module,
            worker_id,
            ticks,
        }
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

/// Installe et démarre les deux hôtes sur la même base, l'un après l'autre.
async fn two_running_hosts(db: &str) -> (Surreal<Any>, Host, Host, Counters, Counters, Counters) {
    let client = common::setup_db(db, db).await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA);
    let host_b = Host::new(&client, "host-b", HOST_B, BETA);

    let installed_a = host_a
        .runtime
        .install_packages(host_a.packages(&shared, &alpha))
        .await
        .unwrap();
    assert!(installed_a.failed.is_empty() && installed_a.not_attempted.is_empty());
    let installed_b = host_b
        .runtime
        .install_packages(host_b.packages(&shared, &beta))
        .await
        .unwrap();
    assert!(installed_b.failed.is_empty() && installed_b.not_attempted.is_empty());

    host_a.runtime.start_all().await.unwrap();
    host_b.runtime.start_all().await.unwrap();
    assert!(host_a.worker_is_running().await);
    assert!(host_b.worker_is_running().await);
    (client, host_a, host_b, shared, alpha, beta)
}

#[tokio::test]
async fn two_hosts_install_and_start_different_module_sets_on_one_database() {
    let client = common::setup_db("p3_install", "p3_install").await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA);
    let host_b = Host::new(&client, "host-b", HOST_B, BETA);

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
    let client = common::setup_db("p3_not_installed", "p3_not_installed").await;
    let counters = Counters::default();
    let host = Host::new(&client, "host-a", HOST_A, ALPHA);
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
    let client = common::setup_db("p3_checksum", "p3_checksum").await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA);
    let host_b = Host::new(&client, "host-b", HOST_B, BETA);
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
    let client = common::setup_db("p3_concurrent", "p3_concurrent").await;
    let (shared, alpha, beta) = (
        Counters::default(),
        Counters::default(),
        Counters::default(),
    );
    let host_a = Host::new(&client, "host-a", HOST_A, ALPHA);
    let host_b = Host::new(&client, "host-b", HOST_B, BETA);

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
    let (_client, host_a, host_b, _shared, _alpha, beta) = two_running_hosts("p3_reconcile").await;
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

    // Redémarrage de A : un nouveau processus (nouveau runtime, même nœud) rejoue installation
    // et démarrage. Rien n'est réinstallé.
    let host_a2 = Host::new(&client, "host-a", HOST_A, ALPHA);
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
    host_a2.runtime.start_all().await.unwrap();
    assert_eq!(host_a2.state(ALPHA), Some(ModuleState::Running));
    assert!(host_a2.worker_is_running().await);
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
