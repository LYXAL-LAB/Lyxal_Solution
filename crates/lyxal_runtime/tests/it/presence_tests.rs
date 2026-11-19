//! Présence des nœuds (`runtime_node`) et socle installé (`runtime_foundation`).
//!
//! Les tests vérifient le battement d'un nœud démarré, le retrait de sa ligne et de ses lignes
//! `runtime_worker` / `runtime_health` à l'arrêt, la purge des nœuds disparus, l'installation du
//! socle sous un seul bail par deux nœuds, et la sonde « dégradé » d'un nœud dont le socle a été
//! remplacé par un autre binaire.

use crate::common;
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::manifest::model::CURRENT_MANIFEST_VERSION;
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::resource::{ResourceKind, ResourceProvider};
use lyxal_runtime::schema::{install_foundation, FOUNDATION_LEASE_KEY};
use lyxal_runtime::worker::SurrealWorkerStore;
use lyxal_runtime::{
    EventEngineConfig, FoundationInstallation, LyxalRuntime, ModuleContext, ModuleId, NodeId,
    PresenceConfig, PresenceStore, RuntimeConfig, RuntimeNodeUpsertParams,
};
use semver::Version;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
use surrealdb::Surreal;

const HOST: &str = "p4_host";

/// Présence au battement rapide, pour ne pas attendre dix secondes par test.
fn fast_presence() -> PresenceConfig {
    PresenceConfig {
        heartbeat_interval: Duration::from_millis(50),
        alive_within: Duration::from_secs(1),
        purge_interval: Duration::from_millis(50),
        purge_after: Duration::from_secs(60),
    }
}

fn runtime(client: &Surreal<Any>) -> LyxalRuntime {
    LyxalRuntime::new(RuntimeConfig::new(common::host(HOST)).with_presence(fast_presence()))
        .with_client(client.clone())
        .with_event_config(EventEngineConfig::default().with_enabled(false))
}

/// Installe le socle de ce dépôt (`lyxal_core`, `lyxal_error`, schéma du runtime), plus un
/// module d'essai quand `extra` est donné (socle d'un « autre binaire »).
async fn install(
    client: &Surreal<Any>,
    host: &str,
    node: &str,
    extra: Option<&str>,
) -> FoundationInstallation {
    let modules = common::foundation_modules();
    let mut batch: Vec<(&ModuleManifest, &dyn ResourceProvider)> = modules
        .iter()
        .map(|(m, p)| (m, p as &dyn ResourceProvider))
        .collect();
    let extra_module = extra.map(|table| {
        let provider = common::MemoryProvider::new().add_resource(
            "schema/extra.surql",
            ResourceKind::Schema,
            &format!("DEFINE TABLE OVERWRITE {table} SCHEMALESS;"),
        );
        let manifest = ModuleManifest {
            manifest_version: CURRENT_MANIFEST_VERSION,
            id: ModuleId::new("p4_extra"),
            name: "p4_extra".to_string(),
            version: Version::new(0, 1, 0),
            description: None,
            runtime: None,
            dependencies: Vec::new(),
            capabilities: Vec::new(),
            resources: provider.resources(),
        };
        (manifest, provider)
    });
    if let Some((manifest, provider)) = &extra_module {
        batch.push((manifest, provider as &dyn ResourceProvider));
    }
    install_foundation(client, &common::host(host), &NodeId::new(node), &batch)
        .await
        .expect("installation du socle")
}

async fn count(client: &Surreal<Any>, table: &str, node: &str) -> i64 {
    let mut response = client
        .query(format!(
            "RETURN count(SELECT * FROM {table} WHERE node_id = $node);"
        ))
        .bind(("node", node.to_string()))
        .await
        .unwrap();
    response.take::<Option<i64>>(0).unwrap().unwrap()
}

async fn run(client: &Surreal<Any>, query: &str) {
    client.query(query).await.unwrap().check().unwrap();
}

/// Ligne de `runtime_lease` lue par le test.
#[derive(Debug, SurrealValue)]
struct LeaseRow {
    generation: i64,
    is_released: bool,
}

#[tokio::test]
async fn a_started_node_beats_and_a_clean_stop_removes_its_rows() {
    let client = common::setup_db("p4_beat", "p4_beat").await;
    let runtime =
        runtime(&client).with_worker_store(Arc::new(SurrealWorkerStore::new(client.clone())));
    let node = runtime.node_id().to_string();

    // Avant le démarrage, le nœud n'est pas annoncé.
    assert!(runtime.nodes().await.unwrap().is_empty());

    runtime.start_all().await.unwrap();
    let first = runtime.nodes().await.unwrap();
    assert_eq!(first.len(), 1);
    assert_eq!(first[0].node_id, node);
    assert_eq!(first[0].host, HOST);
    assert!(first[0].modules.is_empty());
    assert_eq!(first[0].foundation_checksum, None);
    assert_eq!(first[0].alive, Some(true));
    assert_eq!(runtime.host_id().as_str(), HOST);

    // Le battement rafraîchit la ligne sans changer la date de démarrage.
    tokio::time::sleep(Duration::from_millis(400)).await;
    let later = runtime.nodes().await.unwrap();
    assert_eq!(later.len(), 1);
    assert_eq!(later[0].started_at, first[0].started_at);
    assert!(
        later[0].seen_at > first[0].seen_at,
        "battement attendu : {:?} puis {:?}",
        first[0].seen_at,
        later[0].seen_at
    );

    // Le nœud a des lignes de worker (son worker de présence) et de santé.
    run(
        &client,
        &format!(
            "fn::runtime_health_record({{ node_id: '{node}', module_id: 'p4_module', status: 'healthy' }});"
        ),
    )
    .await;
    assert!(count(&client, "runtime_worker", &node).await >= 1);
    assert_eq!(count(&client, "runtime_health", &node).await, 1);

    // Arrêt propre : la ligne de présence et les lignes du nœud disparaissent.
    runtime.stop_all().await.unwrap();
    assert!(runtime.nodes().await.unwrap().is_empty());
    assert_eq!(count(&client, "runtime_worker", &node).await, 0);
    assert_eq!(count(&client, "runtime_health", &node).await, 0);

    // Un redémarrage du même runtime réinscrit le nœud.
    runtime.start_all().await.unwrap();
    assert_eq!(runtime.nodes().await.unwrap().len(), 1);
    runtime.stop_all().await.unwrap();
}

#[tokio::test]
async fn a_node_without_heartbeat_is_reported_dead_then_purged_with_its_rows() {
    let client = common::setup_db("p4_purge", "p4_purge").await;
    let store = PresenceStore::new(client.clone());

    // Un nœud disparu sans arrêt propre (coupure) : sa ligne et celles de ses workers restent.
    store
        .upsert_node(RuntimeNodeUpsertParams {
            node_id: "node-disparu".to_string(),
            host: "p4_other".to_string(),
            modules: vec!["p4_module".to_string()],
            foundation_checksum: None,
        })
        .await
        .unwrap();
    for node in ["node-disparu", "node-sans-ligne"] {
        run(
            &client,
            &format!(
                "fn::runtime_worker_upsert({{ node_id: '{node}', worker_id: 'p4_module:w', module_id: 'p4_module', state: 'running', criticality: 'required', restart_count: 0, failure_count: 0 }}); \
                 fn::runtime_health_record({{ node_id: '{node}', module_id: 'p4_module', status: 'healthy' }});"
            ),
        )
        .await;
    }

    // Un battement récent : le nœud est vivant, et la purge ne le touche pas.
    let nodes = store.list_nodes(Duration::from_secs(1)).await.unwrap();
    assert_eq!(nodes.len(), 1);
    assert_eq!(nodes[0].alive, Some(true));
    let nothing = store.purge_nodes(Duration::from_secs(60)).await.unwrap();
    assert_eq!((nothing.nodes, nothing.workers, nothing.health), (0, 0, 0));

    // Passé le délai sans battement, il n'est plus vivant.
    tokio::time::sleep(Duration::from_millis(1200)).await;
    let nodes = store.list_nodes(Duration::from_secs(1)).await.unwrap();
    assert_eq!(nodes[0].alive, Some(false));
    assert_eq!(nodes[0].host, "p4_other");

    // Après le délai de purge (ici simulé en vieillissant la ligne du nœud disparu et les
    // lignes sans nœud), le worker de présence d'un nœud en marche retire le nœud avec ses
    // lignes, même récentes, et les lignes anciennes restées sans nœud.
    run(
        &client,
        "UPDATE runtime_node SET seen_at = time::now() - 2m; \
         UPDATE runtime_worker SET updated_at = time::now() - 2m WHERE node_id = 'node-sans-ligne'; \
         UPDATE runtime_health SET updated_at = time::now() - 2m WHERE node_id = 'node-sans-ligne';",
    )
    .await;
    let runtime = runtime(&client);
    runtime.start_all().await.unwrap();
    let mut purged = false;
    for _ in 0..100 {
        if count(&client, "runtime_node", "node-disparu").await == 0 {
            purged = true;
            break;
        }
        tokio::time::sleep(Duration::from_millis(20)).await;
    }
    assert!(purged, "nœud disparu non purgé");
    for node in ["node-disparu", "node-sans-ligne"] {
        assert_eq!(count(&client, "runtime_worker", node).await, 0, "{node}");
        assert_eq!(count(&client, "runtime_health", node).await, 0, "{node}");
    }
    // Le nœud en marche est toujours là.
    let alive = runtime.nodes().await.unwrap();
    assert_eq!(alive.len(), 1);
    assert_eq!(alive[0].node_id, runtime.node_id().to_string());
    runtime.stop_all().await.unwrap();
}

#[tokio::test]
async fn two_nodes_starting_together_install_the_foundation_under_one_lease() {
    let client = common::setup_db("p4_foundation", "p4_foundation").await;

    let (a, b) = tokio::join!(
        install(&client, "p4_host_a", "node-a", None),
        install(&client, "p4_host_a", "node-b", None),
    );

    // Même binaire : même empreinte ; un seul des deux nœuds a installé, l'autre a trouvé
    // l'empreinte en base en prenant le bail à son tour.
    assert_eq!(a.checksum, b.checksum);
    assert_eq!(a.checksum.len(), 64);
    assert_eq!(
        [a.installed, b.installed].iter().filter(|i| **i).count(),
        1,
        "{a:?} {b:?}"
    );
    let installer = if a.installed { "node-a" } else { "node-b" };

    let recorded = PresenceStore::new(client.clone())
        .foundation()
        .await
        .unwrap()
        .expect("socle enregistré");
    assert_eq!(recorded.checksum, a.checksum);
    assert_eq!(recorded.node_id, installer);
    assert_eq!(recorded.host, "p4_host_a");

    // Le bail du socle a été pris deux fois, l'un après l'autre, et rendu.
    let mut response = client
        .query("SELECT generation, is_released FROM runtime_lease WHERE kind = 'installation' AND key = $key")
        .bind(("key", FOUNDATION_LEASE_KEY))
        .await
        .unwrap();
    let leases: Vec<LeaseRow> = response.take(0).unwrap();
    assert_eq!(leases.len(), 1);
    assert_eq!(leases[0].generation, 2);
    assert!(leases[0].is_released);

    // Un troisième démarrage ne réinstalle rien.
    let again = install(&client, "p4_host_a", "node-c", None).await;
    assert!(!again.installed);
    let unchanged = PresenceStore::new(client.clone())
        .foundation()
        .await
        .unwrap()
        .unwrap();
    assert_eq!(unchanged, recorded);
}

#[tokio::test]
async fn a_blank_database_receives_the_foundation_and_its_checksum() {
    let client = common::blank_db("p4_blank", "p4_blank").await;

    let first = install(&client, "p4_host_a", "node-a", None).await;
    assert!(first.installed);
    let recorded = PresenceStore::new(client.clone())
        .foundation()
        .await
        .unwrap()
        .expect("socle enregistré");
    assert_eq!(recorded.checksum, first.checksum);
    assert_eq!(recorded.node_id, "node-a");

    // Les fonctions du runtime sont utilisables : la base a bien reçu le socle.
    run(
        &client,
        "fn::runtime_module_upsert({ module_id: 'p4_module', name: 'Essai' });",
    )
    .await;

    let second = install(&client, "p4_host_a", "node-b", None).await;
    assert!(!second.installed);
    assert_eq!(second.checksum, first.checksum);
}

#[tokio::test]
async fn a_foundation_replaced_by_another_binary_degrades_the_running_node() {
    let client = common::blank_db("p4_replaced", "p4_replaced").await;
    let own = install(&client, "p4_host_a", "node-a", None).await;

    let runtime = runtime(&client).with_foundation_checksum(own.checksum.clone());
    let probe = runtime.foundation_health_check(ModuleId::new("lyxal_core"));
    let ctx = ModuleContext::new(ModuleId::new("lyxal_core"));
    runtime.start_all().await.unwrap();

    // La ligne de présence porte l'empreinte du binaire ; la sonde est saine.
    let nodes = runtime.nodes().await.unwrap();
    assert_eq!(nodes[0].foundation_checksum, Some(own.checksum.clone()));
    assert_eq!(
        probe.check(&ctx).await.unwrap().status,
        HealthStatus::Healthy
    );

    // Un autre binaire (autre hôte, socle au contenu différent) démarre sur la même base : il
    // installe son socle et l'enregistre.
    let other = install(&client, "p4_host_b", "node-b", Some("p4_extra_item")).await;
    assert!(other.installed);
    assert_ne!(other.checksum, own.checksum);
    run(&client, "CREATE p4_extra_item SET label = 'x';").await;

    // Le premier nœud le voit à son battement : sa sonde passe à « dégradé » et nomme l'hôte.
    let mut result = probe.check(&ctx).await.unwrap();
    for _ in 0..100 {
        if result.status == HealthStatus::Degraded {
            break;
        }
        tokio::time::sleep(Duration::from_millis(20)).await;
        result = probe.check(&ctx).await.unwrap();
    }
    assert_eq!(result.status, HealthStatus::Degraded, "{result:?}");
    let message = result.message.unwrap_or_default();
    assert!(message.contains("p4_host_b"), "{message}");
    assert!(message.contains(&other.checksum), "{message}");

    // Le premier binaire redémarre : il réinstalle son socle, la sonde redevient saine.
    let back = install(&client, "p4_host_a", "node-a2", None).await;
    assert!(back.installed);
    assert_eq!(back.checksum, own.checksum);
    let mut result = probe.check(&ctx).await.unwrap();
    for _ in 0..100 {
        if result.status == HealthStatus::Healthy {
            break;
        }
        tokio::time::sleep(Duration::from_millis(20)).await;
        result = probe.check(&ctx).await.unwrap();
    }
    assert_eq!(result.status, HealthStatus::Healthy, "{result:?}");

    runtime.stop_all().await.unwrap();
}
