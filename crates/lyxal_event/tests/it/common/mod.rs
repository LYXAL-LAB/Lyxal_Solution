use std::path::PathBuf;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Initialise les dépendances canoniques (notamment `lyxal_error`) nécessaires
/// à l'exécution des tests sur une base SurrealDB vierge (mem://).
///
/// Charge les ressources directement depuis le manifeste officiel de `lyxal_error`,
/// garantissant le respect strict de la propriété des primitives universelles.
pub async fn setup_test_db(db: &Surreal<Any>) {
    let error_manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Parent crates dir")
        .join("lyxal_error")
        .join("manifest.toml");

    let content = std::fs::read_to_string(&error_manifest_path).unwrap_or_else(|e| {
        panic!(
            "Failed to read lyxal_error manifest at {:?}: {}",
            error_manifest_path, e
        )
    });
    let parsed: toml::Value =
        toml::from_str(&content).expect("Failed to parse lyxal_error manifest");
    let resources = parsed
        .get("resources")
        .and_then(|v| v.as_table())
        .expect("Resources table in lyxal_error manifest");

    let error_base_dir = error_manifest_path.parent().expect("lyxal_error dir");

    // 1. Schémas de base lyxal_error
    if let Some(schemas) = resources.get("schemas").and_then(|v| v.as_array()) {
        for s in schemas {
            let rel = s.as_str().expect("schema rel path");
            let surql = std::fs::read_to_string(error_base_dir.join(rel))
                .unwrap_or_else(|e| panic!("Failed to read {}: {}", rel, e));
            db.query(&surql)
                .await
                .expect("query failed")
                .check()
                .expect("check failed");
        }
    }

    // 2. Fonctions canoniques lyxal_error (dont fn::result_ok, fn::error_result, etc.)
    if let Some(functions) = resources.get("functions").and_then(|v| v.as_array()) {
        for f in functions {
            let rel = f.as_str().expect("function rel path");
            let surql = std::fs::read_to_string(error_base_dir.join(rel))
                .unwrap_or_else(|e| panic!("Failed to read {}: {}", rel, e));
            let res = db
                .query(&surql)
                .await
                .unwrap_or_else(|e| panic!("Failed to execute function {}: {}", rel, e));
            if let Err(e) = res.check() {
                panic!("Failed check for function {}: {}", rel, e);
            }
        }
    }

    // 3. Définitions d'erreurs de lyxal_error
    if let Some(errors) = resources
        .get("error_definitions")
        .and_then(|v| v.as_array())
    {
        for e in errors {
            let rel = e.as_str().expect("error definition rel path");
            let surql = std::fs::read_to_string(error_base_dir.join(rel))
                .unwrap_or_else(|e| panic!("Failed to read {}: {}", rel, e));
            db.query(&surql)
                .await
                .expect("query failed")
                .check()
                .expect("check failed");
        }
    }
}

/// Fait tourner `EventWorker::run` (chemin de production) jusqu'à ce que `done` soit vrai ou que
/// `timeout` expire, puis l'arrête proprement. Renvoie `true` si la condition a été atteinte.
pub async fn run_worker_until<F, Fut>(
    worker: std::sync::Arc<lyxal_event::EventWorker>,
    timeout: std::time::Duration,
    mut done: F,
) -> bool
where
    F: FnMut() -> Fut,
    Fut: std::future::Future<Output = bool>,
{
    let cancel = tokio_util::sync::CancellationToken::new();
    let handle = {
        let worker = worker.clone();
        let cancel = cancel.clone();
        tokio::spawn(async move { worker.run(cancel).await })
    };
    let deadline = tokio::time::Instant::now() + timeout;
    let mut reached = false;
    while tokio::time::Instant::now() < deadline {
        if done().await {
            reached = true;
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(50)).await;
    }
    cancel.cancel();
    handle
        .await
        .expect("tâche du worker")
        .expect("EventWorker::run termine sans erreur");
    reached
}

/// Statuts des livraisons, triés.
pub async fn delivery_statuses(db: &Surreal<Any>) -> Vec<String> {
    let mut res = db
        .query("SELECT VALUE status FROM event_delivery ORDER BY status")
        .await
        .expect("statuts");
    res.take(0).expect("statuts")
}

/// Configuration de worker pour les tests : boucles et bail courts.
pub fn fast_config(worker_id: &str) -> lyxal_event::EventWorkerConfig {
    lyxal_event::EventWorkerConfig::default()
        .with_worker_id(worker_id)
        .with_batch_size(50)
        .with_poll_interval(std::time::Duration::from_millis(20))
        .with_lease_ttl(std::time::Duration::from_secs(2))
        .with_lease_renew_interval(std::time::Duration::from_millis(500))
        .with_retry_base_delay(std::time::Duration::from_millis(10))
        .with_retry_max_delay(std::time::Duration::from_millis(50))
        .with_dispatch_timeout(std::time::Duration::from_secs(5))
}
