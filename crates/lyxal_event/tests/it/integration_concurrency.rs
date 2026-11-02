//! Concurrence sur le chemin de production (`EventWorker::run`) : plusieurs workers et plusieurs
//! abonnements au même événement. Un seul worker détient le bail ; chaque livraison est traitée
//! exactement une fois, et les abonnements ne se gênent pas (un curseur contigu par abonnement).

use lyxal_event::prelude::*;
use lyxal_surreal::ToSql;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

use crate::common;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct BenchmarkItem {
    pub seq: usize,
}

impl Event for BenchmarkItem {
    const EVENT_TYPE: &'static str = "benchmark.item";
}

/// Compte les traitements par identifiant de livraison.
struct CountingHandler {
    pub seen: Arc<Mutex<HashMap<String, usize>>>,
}

#[async_trait::async_trait]
impl Handler<BenchmarkItem> for CountingHandler {
    async fn handle(
        &self,
        _event: BenchmarkItem,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        let mut seen = self.seen.lock().unwrap();
        *seen.entry(ctx.delivery_id.to_sql()).or_insert(0) += 1;
        Ok(())
    }
}

const SUBSCRIPTIONS: usize = 3;
const EVENTS: usize = 100;
const WORKERS: usize = 3;

#[tokio::test]
async fn test_concurrent_workers_and_subscriptions_deliver_exactly_once() {
    if std::env::var("LYXAL_TEST_TRACE").is_ok() {
        let _ = tracing_subscriber::fmt()
            .with_test_writer()
            .with_max_level(tracing::Level::DEBUG)
            .try_init();
    }
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns")
        .use_db("test_concurrency")
        .await
        .unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

    for i in 0..SUBSCRIPTIONS {
        let sub = EventSubscription::new(
            format!("bench_sub_{i}"),
            format!("lyxal_consumer_{i}"),
            "benchmark.item",
            "handle_item",
        );
        store.register_subscription(&sub).await.unwrap();
    }

    let publisher = EventPublisher::new(store.clone(), "lyxal_bench", EventContext::default());
    for seq in 0..EVENTS {
        publisher.publish(&BenchmarkItem { seq }).await.unwrap();
    }
    let expected = SUBSCRIPTIONS * EVENTS;

    // Plusieurs workers concurrents : un seul obtient le bail, les autres attendent.
    let seen = Arc::new(Mutex::new(HashMap::new()));
    let cancel = CancellationToken::new();
    let mut handles = Vec::new();
    for w in 0..WORKERS {
        let mut registry = HandlerRegistry::new();
        registry
            .register(CountingHandler { seen: seen.clone() })
            .unwrap();
        let worker = Arc::new(EventWorker::new(
            store.clone(),
            registry,
            common::fast_config(&format!("bench_worker_{w}")),
        ));
        let cancel = cancel.clone();
        handles.push(tokio::spawn(async move { worker.run(cancel).await }));
    }

    let deadline = tokio::time::Instant::now() + Duration::from_secs(60);
    loop {
        let delivered = common::delivery_statuses(&db)
            .await
            .iter()
            .filter(|s| s.as_str() == "delivered")
            .count();
        if delivered == expected || tokio::time::Instant::now() > deadline {
            break;
        }
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
    cancel.cancel();
    for handle in handles {
        handle
            .await
            .expect("tâche du worker")
            .expect("EventWorker::run termine sans erreur");
    }

    let statuses = common::delivery_statuses(&db).await;
    assert_eq!(statuses.len(), expected);
    assert!(
        statuses.iter().all(|s| s == "delivered"),
        "toutes les livraisons doivent être livrées : {:?}",
        statuses
            .iter()
            .filter(|s| s.as_str() != "delivered")
            .collect::<Vec<_>>()
    );
    let counts: Vec<usize> = seen.lock().unwrap().values().copied().collect();
    assert_eq!(counts.len(), expected, "chaque livraison doit être traitée");
    assert!(
        counts.iter().all(|&n| n == 1),
        "aucune livraison ne doit être traitée deux fois"
    );

    // Chaque abonnement a un curseur contigu jusqu'au dernier numéro de séquence.
    let mut res = db
        .query("SELECT VALUE last_persisted_cursor FROM event_subscription_progress")
        .await
        .unwrap();
    let cursors: Vec<i64> = res.take(0).unwrap();
    assert_eq!(cursors, vec![EVENTS as i64; SUBSCRIPTIONS]);
}
