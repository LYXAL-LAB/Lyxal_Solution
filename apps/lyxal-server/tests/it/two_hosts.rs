//! `lyxal-server` à côté d'un second hôte sur la même base.
//!
//! Le second hôte (`lyxal_peer`) est un `LyxalRuntime` d'essai qui héberge `lyxal_scheduler` et
//! ses dépendances, avec un planificateur et un exécuteur de la file `default` mais aucun handler.
//! Les trois tâches de fond de l'hôte (`auth.purge`, `storage.cleanup`, `secrets.maintenance`)
//! ne sont exécutées que par `lyxal-server` : le second hôte ne les réserve jamais, même quand
//! `lyxal-server` est arrêté ; elles attendent alors son retour, sans échec ni tentative
//! comptée. La route système des modules liste les nœuds vivants des deux hôtes.

use axum::http::StatusCode;
use lyxal_host::health::HealthRegistry;
use lyxal_runtime::lock::{SurrealInstallationLeaseManager, SurrealLeaderLeaseManager};
use lyxal_runtime::{
    EventEngineConfig, HostId, LyxalRuntime, ModuleId, ModuleState, RuntimeConfig,
    SurrealRuntimeStore,
};
use lyxal_scheduler::models::{
    Overlap, Run, RunRefParams, RunState, ScheduleTriggerParams, SchedulerRecordId,
};
use lyxal_scheduler::{
    ExecutorTiming, HandlerRegistry, SchedulerEngine, SchedulerExecutorWorker,
    SchedulerLeaderWorker, SchedulerStore,
};
use lyxal_server::modules::tasks::{HostTask, HOST_TASKS};
use lyxal_server::{modules, runtime};
use serde_json::Value;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::host_tasks::schedule_of;
use crate::startup::{config_with, database};
use crate::system_routes::{platform_admin, router_with_auth, send, AUTH, MODULES};

/// Hôte d'essai, à côté de `lyxal_server`.
const PEER: &str = "lyxal_peer";

/// Modules du second hôte : `lyxal_scheduler` et ses dépendances.
const PEER_MODULES: [&str; 5] = [
    "lyxal_auth",
    "lyxal_core",
    "lyxal_error",
    "lyxal_event",
    "lyxal_scheduler",
];

/// Second hôte : runtime propre (hôte `lyxal_peer`, nœud propre), planificateur et exécuteur de
/// la file `default` sans aucun handler. Les modules sont déjà installés par `lyxal-server` : le
/// second hôte les trouve installés, sans rejouer leur hook `install`.
async fn start_peer(client: &Surreal<Any>) -> Arc<LyxalRuntime> {
    let host = HostId::new(PEER).expect("hôte d'essai");
    let runtime = LyxalRuntime::new(RuntimeConfig::new(host.clone()))
        .with_event_config(EventEngineConfig::new(&host).with_auto_init_schema(false))
        .with_client(client.clone())
        .with_store(Arc::new(SurrealRuntimeStore::new(client.clone())))
        .with_installation_lease_manager(Arc::new(SurrealInstallationLeaseManager::new(
            client.clone(),
        )));
    let engine = SchedulerEngine::new(
        SchedulerStore::new(client.clone()),
        HandlerRegistry::new(),
        runtime.node_id().clone(),
        host,
    );
    runtime
        .register_worker(Arc::new(
            SchedulerLeaderWorker::new(
                engine.clone(),
                SurrealLeaderLeaseManager::new(client.clone()),
            )
            .expect("planificateur"),
        ))
        .expect("planificateur");
    let timing = ExecutorTiming {
        poll: Duration::from_millis(100),
        ..ExecutorTiming::default()
    };
    runtime
        .register_worker(Arc::new(
            SchedulerExecutorWorker::with_timing(engine, "default", 2, timing).expect("exécuteur"),
        ))
        .expect("exécuteur");

    let packages = modules::packages(client)
        .expect("packages")
        .into_iter()
        .filter(|package| PEER_MODULES.contains(&package.id().as_str()))
        .collect::<Vec<_>>();
    let report = runtime
        .install_packages(packages)
        .await
        .expect("installation du second hôte");
    assert!(report.installed.is_empty(), "{:?}", report.installed);
    assert_eq!(report.already_installed.len(), PEER_MODULES.len());
    runtime.start_all().await.expect("démarrage du second hôte");
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal_scheduler")),
        Some(ModuleState::Running)
    );
    Arc::new(runtime)
}

async fn count(client: &Surreal<Any>, query: &str) -> i64 {
    let mut response = client.query(query).await.expect("requête");
    let total: Option<i64> = response.take(0).expect("total");
    total.expect("total")
}

async fn eventually(what: &str, within: Duration, query: &str, client: &Surreal<Any>) {
    let deadline = tokio::time::Instant::now() + within;
    while count(client, query).await == 0 {
        assert!(tokio::time::Instant::now() < deadline, "{what}");
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
}

/// Déclenche la planification de la tâche en session système : exécution `queued`.
async fn trigger(store: &SchedulerStore, task: HostTask) -> SchedulerRecordId {
    let schedule = schedule_of(store, task).await;
    store
        .schedule_trigger(ScheduleTriggerParams {
            schedule,
            overlap: Some(Overlap::AllowAll),
            language: None,
        })
        .await
        .unwrap_or_else(|error| panic!("déclenchement de {} : {error}", task.task))
        .id
}

async fn run_of(store: &SchedulerStore, run: &SchedulerRecordId) -> Run {
    store
        .run_get(RunRefParams {
            run: run.clone(),
            language: None,
        })
        .await
        .expect("exécution")
}

/// Attend la fin de l'exécution : terminée, en une seule tentative, sans erreur.
async fn completed_once(store: &SchedulerStore, task: HostTask, run: &SchedulerRecordId) {
    for _ in 0..300 {
        let current = run_of(store, run).await;
        match current.state {
            RunState::Completed => {
                assert_eq!(current.attempt, 1, "{} : {current:?}", task.task);
                assert!(current.error.is_none(), "{} : {current:?}", task.task);
                return;
            }
            RunState::Queued | RunState::Running => {
                tokio::time::sleep(Duration::from_millis(100)).await
            }
            other => panic!("{} : {other:?} ({:?})", task.task, current.error),
        }
    }
    panic!("l'exécution de {} n'a pas abouti", task.task);
}

/// Route système des modules, appelée par un administrateur de la plateforme : `data` de la
/// réponse.
async fn system_modules(started: &runtime::Started, client: &Surreal<Any>) -> Value {
    // Même base que les deux hôtes : la session de l'appelant y est ouverte
    let config = Arc::new(config_with("two_hosts_tasks", AUTH));
    let (router, host) = router_with_auth(
        config,
        client,
        started.runtime.clone(),
        HealthRegistry::default(),
    )
    .await;
    let admin = platform_admin(client, &host).await;
    let (status, reply) = send(&router, "GET", MODULES, Some(&admin), None).await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    reply["data"].clone()
}

#[tokio::test]
async fn host_tasks_are_executed_only_by_lyxal_server_beside_another_host() {
    let config = config_with("two_hosts_tasks", "");
    let client = database("two_hosts_tasks").await;
    let store = SchedulerStore::new(client.clone());

    let server = runtime::start(&config, &client)
        .await
        .expect("démarrage de lyxal-server");
    let peer = start_peer(&client).await;
    let peer_node = peer.node_id().to_string();

    // Le second hôte réserve dans la file `default`, sans aucun handler
    eventually(
        "le second hôte n'a pas réservé dans la file default",
        Duration::from_secs(10),
        "RETURN count(SELECT * FROM scheduler_node WHERE host = 'lyxal_peer' AND record::id(queue) = 'default' AND handlers = []);",
        &client,
    )
    .await;

    // Route système : les nœuds vivants des deux hôtes, chacun avec ses modules
    let system = system_modules(&server, &client).await;
    assert_eq!(system["host"], "lyxal_server", "{system}");
    let nodes = system["nodes"].as_array().expect("nœuds");
    assert_eq!(nodes.len(), 2, "{system}");
    let server_node = server.runtime.node_id().to_string();
    let node = |id: &str| {
        nodes
            .iter()
            .find(|n| n["node_id"] == id)
            .unwrap_or_else(|| panic!("nœud {id} absent : {system}"))
    };
    assert_eq!(node(&server_node)["host"], "lyxal_server");
    assert_eq!(node(&server_node)["current"], true);
    assert_eq!(node(&peer_node)["host"], PEER);
    assert_eq!(node(&peer_node)["current"], false);
    assert_eq!(
        node(&peer_node)["modules"],
        serde_json::json!(PEER_MODULES),
        "{system}"
    );

    // Les deux hôtes en marche : chaque tâche est exécutée une fois, du premier coup ; le second
    // hôte ne l'a jamais réservée (il aurait échoué sans handler, tentative comptée)
    for task in HOST_TASKS {
        let run = trigger(&store, task).await;
        completed_once(&store, task, &run).await;
    }

    // lyxal-server arrêté : les exécutions attendent, jamais réservées par le second hôte, qui
    // continue de réserver dans la même file
    server
        .runtime
        .stop_all()
        .await
        .expect("arrêt de lyxal-server");
    let mut waiting = Vec::new();
    for task in HOST_TASKS {
        waiting.push((task, trigger(&store, task).await));
    }
    tokio::time::sleep(Duration::from_millis(1500)).await;
    for (task, run) in &waiting {
        let current = run_of(&store, run).await;
        assert_eq!(
            current.state,
            RunState::Queued,
            "{} : {current:?}",
            task.task
        );
        assert_eq!(current.attempt, 0, "{}", task.task);
        assert!(current.error.is_none(), "{}", task.task);
    }
    assert!(
        count(
            &client,
            "RETURN count(SELECT * FROM scheduler_node WHERE host = 'lyxal_peer' AND seen_at > time::now() - 1s);"
        )
        .await
            > 0,
        "le second hôte ne réserve plus"
    );

    // Retour de lyxal-server (nouveau nœud) : les exécutions en attente sont faites, une fois
    let restarted = runtime::start(&config, &client)
        .await
        .expect("redémarrage de lyxal-server");
    for (task, run) in &waiting {
        completed_once(&store, *task, run).await;
    }
    // Aucune exécution des tâches de l'hôte n'a échoué ni été réessayée
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT * FROM scheduler_run WHERE task IN [scheduler_task:⟨auth.purge⟩, scheduler_task:⟨storage.cleanup⟩, scheduler_task:⟨secrets.maintenance⟩] AND (attempt > 1 OR error IS NOT NONE OR state IN ['retrying', 'dead']));"
        )
        .await,
        0
    );

    restarted.runtime.stop_all().await.expect("arrêt");
    peer.stop_all().await.expect("arrêt du second hôte");
}
