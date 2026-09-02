use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct BenchmarkItem {
    pub seq: usize,
}

impl Event for BenchmarkItem {
    const EVENT_TYPE: &'static str = "benchmark.item";
}

struct ConcurrencyItemHandler {
    pub processed_ids: Arc<Mutex<HashSet<String>>>,
    pub total_count: Arc<AtomicUsize>,
    pub duplicate_claims: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<BenchmarkItem> for ConcurrencyItemHandler {
    async fn handle(
        &self,
        _event: BenchmarkItem,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        let id_str = ctx.delivery_id.to_string();
        self.total_count.fetch_add(1, Ordering::SeqCst);

        let mut lock = self.processed_ids.lock().unwrap();
        if lock.contains(&id_str) {
            self.duplicate_claims.fetch_add(1, Ordering::SeqCst);
        } else {
            lock.insert(id_str);
        }

        Ok(())
    }
}

#[tokio::test]
async fn test_massive_concurrency_1000_deliveries_10_workers() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_concurrency")
        .use_db("test_concurrency")
        .await
        .unwrap();

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

    // 1. Déclaration de l'abonnement
    let sub = EventSubscription::new("bench_sub", "lyxal_bench", "benchmark.item", "handle_item");
    store.register_subscription(&sub).await.unwrap();

    // 2. Injection rapide de 1000 événements et fan-out
    let total_items = 1000;
    for i in 0..total_items {
        let event = BenchmarkItem { seq: i };
        let envelope =
            LyxalEventEnvelope::new("bench_prod", EventContext::default(), &event).unwrap();
        store.publish(&envelope, true).await.unwrap();
    }

    // Vérification que 1000 livraisons ont bien été créées
    let mut count_query = db
        .query("SELECT count() AS total FROM event_delivery GROUP ALL")
        .await
        .unwrap();
    #[derive(Deserialize)]
    struct CountRow {
        total: usize,
    }
    let rows: Vec<CountRow> = count_query.take(0).unwrap();
    assert_eq!(
        rows[0].total, 1000,
        "Must have exactly 1000 event deliveries pending"
    );

    // 3. Configuration du tracking partagé
    let processed_ids = Arc::new(Mutex::new(HashSet::new()));
    let total_count = Arc::new(AtomicUsize::new(0));
    let duplicate_claims = Arc::new(AtomicUsize::new(0));

    let handler = ConcurrencyItemHandler {
        processed_ids: processed_ids.clone(),
        total_count: total_count.clone(),
        duplicate_claims: duplicate_claims.clone(),
    };

    let mut registry = HandlerRegistry::new();
    registry.register(handler).unwrap();

    // 4. Lancement de 10 workers concurrents
    let cancel = CancellationToken::new();
    let worker_count = 10;
    let mut handles = Vec::new();

    for w_idx in 0..worker_count {
        let w_store = store.clone();
        let w_registry = registry.clone();
        let w_cancel = cancel.clone();
        let w_config = EventWorkerConfig::default()
            .with_worker_id(format!("worker_concurrent_{w_idx}"))
            .with_batch_size(25)
            .with_poll_interval(Duration::from_millis(5))
            .with_dispatch_timeout(Duration::from_secs(5));

        let worker = EventWorker::new(w_store, w_registry, w_config);
        let handle = tokio::spawn(async move {
            while !w_cancel.is_cancelled() {
                match worker.poll_cycle(&w_cancel).await {
                    Ok(0) => {
                        tokio::time::sleep(Duration::from_millis(10)).await;
                    }
                    Ok(_) => {}
                    Err(_err) => {
                        let jitter = fastrand::u64(5..30);
                        tokio::time::sleep(Duration::from_millis(jitter)).await;
                    }
                }
            }
        });
        handles.push(handle);
    }

    // Attente active jusqu'à ce que les 1000 éléments soient traités (ou timeout de sécurité)
    let start = std::time::Instant::now();
    loop {
        let current_count = processed_ids.lock().unwrap().len();
        if current_count >= total_items || start.elapsed() > Duration::from_secs(60) {
            break;
        }
        tokio::time::sleep(Duration::from_millis(20)).await;
    }

    // Arrêt gracieux de tous les workers
    cancel.cancel();
    for h in handles {
        let _ = h.await;
    }

    // 5. ASSERTIONS OBLIGATOIRES DU TEST DE CONCURRENCE
    let final_processed = total_count.load(Ordering::SeqCst);
    let duplicates = duplicate_claims.load(Ordering::SeqCst);
    let unique_ids_count = processed_ids.lock().unwrap().len();

    assert!(
        final_processed >= 1000,
        "At least 1000 deliveries must be processed (found {final_processed})"
    );
    assert_eq!(
        unique_ids_count, 1000,
        "Exactly 1000 unique delivery IDs must be recorded"
    );
    assert_eq!(
        duplicates, 0,
        "Zero double claims allowed across concurrent workers"
    );

    // Vérifie en base que toutes les livraisons sont en statut 'delivered'
    let mut delivered_query = db
        .query("SELECT count() AS total FROM event_delivery WHERE status = 'delivered' GROUP ALL")
        .await
        .unwrap();
    let delivered_rows: Vec<CountRow> = delivered_query.take(0).unwrap();
    assert_eq!(
        delivered_rows[0].total, 1000,
        "All 1000 deliveries in database must have status = delivered"
    );
}
