use std::path::PathBuf;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Installe les dépendances de `lyxal_event` sur une base vierge, par le runtime : `lyxal_core`
/// (validation des entrées) et `lyxal_error` (contrat de résultat, définitions d'erreurs), depuis
/// leurs manifestes, phase par phase.
pub async fn setup_test_db(db: &Surreal<Any>) {
    let crates = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("dossier crates")
        .to_path_buf();
    let modules: Vec<_> = ["lyxal_core", "lyxal_error"]
        .iter()
        .map(|name| {
            let dir = crates.join(name);
            let manifest =
                lyxal_runtime::manifest::ManifestParser::parse_file(dir.join("manifest.toml"))
                    .expect("manifeste");
            (
                manifest,
                lyxal_runtime::resource::FilesystemResourceProvider::new(dir),
            )
        })
        .collect();
    let batch: Vec<(
        &lyxal_runtime::manifest::ModuleManifest,
        &dyn lyxal_runtime::resource::ResourceProvider,
    )> = modules
        .iter()
        .map(|(m, p)| (m, p as &dyn lyxal_runtime::resource::ResourceProvider))
        .collect();
    lyxal_runtime::schema::install_batch(db, &batch)
        .await
        .expect("installation de lyxal_core et lyxal_error");
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

/// Installe `lyxal_event` comme en production : par `lyxal_runtime`, depuis son manifeste et ses
/// fichiers embarqués.
pub async fn install_event(db: &Surreal<Any>) {
    lyxal_runtime::schema::install_embedded(
        db,
        lyxal_event::MANIFEST,
        lyxal_event::EMBEDDED_RESOURCES,
    )
    .await
    .expect("installation de lyxal_event par le runtime");
}
