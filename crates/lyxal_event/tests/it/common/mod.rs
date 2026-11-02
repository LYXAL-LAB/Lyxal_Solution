use std::path::PathBuf;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Installe les dépendances de `lyxal_event` sur une base vierge : `lyxal_core` (validation des
/// entrées) et `lyxal_error` (contrat de résultat, définitions d'erreurs), depuis leurs
/// manifestes, phase par phase (schémas, puis fonctions, puis définitions d'erreurs).
pub async fn setup_test_db(db: &Surreal<Any>) {
    let crates = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("dossier crates")
        .to_path_buf();
    let modules = [crates.join("lyxal_core"), crates.join("lyxal_error")];
    let manifests: Vec<(PathBuf, toml::Value)> = modules
        .iter()
        .map(|dir| {
            let content = std::fs::read_to_string(dir.join("manifest.toml")).expect("manifeste");
            (
                dir.clone(),
                toml::from_str(&content).expect("manifeste TOML"),
            )
        })
        .collect();
    for key in ["schemas", "functions", "error_definitions"] {
        for (dir, manifest) in &manifests {
            let Some(files) = manifest
                .get("resources")
                .and_then(|r| r.get(key))
                .and_then(|v| v.as_array())
            else {
                continue;
            };
            let script: String = files
                .iter()
                .map(|f| {
                    let path = dir.join(f.as_str().expect("chemin"));
                    std::fs::read_to_string(&path)
                        .unwrap_or_else(|e| panic!("{} : {e}", path.display()))
                })
                .collect::<Vec<_>>()
                .join("\n");
            db.query(script)
                .await
                .and_then(|r| r.check())
                .unwrap_or_else(|e| panic!("{} [{key}] : {e}", dir.display()));
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
