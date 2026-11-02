use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

use crate::common;
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct TaskAssigned {
    pub task_id: String,
}

impl Event for TaskAssigned {
    const EVENT_TYPE: &'static str = "task.assigned";
}

struct WorkerBHandler {
    pub processed: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<TaskAssigned> for WorkerBHandler {
    async fn handle(
        &self,
        _event: TaskAssigned,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        self.processed.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

#[tokio::test]
async fn test_worker_crash_and_lease_recovery() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_crash").use_db("test_crash").await.unwrap();

    common::setup_test_db(&db).await;

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

    // 1. Abonnement
    let sub = EventSubscription::new("task_sub", "lyxal_worker", "task.assigned", "execute_task");
    store.register_subscription(&sub).await.unwrap();

    // 2. Publication d'un événement
    let publisher =
        EventPublisher::new(store.clone(), "lyxal_orchestrator", EventContext::default());
    let event = TaskAssigned {
        task_id: "tsk_critical_1".to_string(),
    };
    publisher.publish(&event).await.unwrap();

    // 3. Worker A devient leader, séquence la livraison puis « plante » pendant le traitement :
    //    son handler ne rend jamais la main et sa tâche est interrompue sans libérer le bail.
    let mut a_registry = HandlerRegistry::new();
    a_registry.register(StuckHandler).unwrap();
    let worker_a = Arc::new(EventWorker::new(
        store.clone(),
        a_registry,
        common::fast_config("worker_a_doomed"),
    ));
    let a_task = {
        let worker_a = worker_a.clone();
        tokio::spawn(async move { worker_a.run(CancellationToken::new()).await })
    };
    let mut assigned = false;
    for _ in 0..200 {
        if common::delivery_statuses(&db).await == ["processing"] {
            assigned = true;
            break;
        }
        tokio::time::sleep(Duration::from_millis(25)).await;
    }
    assert!(assigned, "Worker A doit avoir séquencé la livraison");
    let seq_before = delivery_seq(&db).await;
    assert_eq!(seq_before, Some(1));
    a_task.abort();
    let _ = a_task.await;

    // 4. Le temps passe : le verrou de la livraison expire (simulé), le bail de A expire (2 s).
    db.query("UPDATE event_delivery SET locked_until = time::now() - 1s")
        .await
        .unwrap();

    // 5. Worker B prend le leadership, reprend la livraison orpheline et la livre.
    let b_count = Arc::new(AtomicUsize::new(0));
    let mut b_registry = HandlerRegistry::new();
    b_registry
        .register(WorkerBHandler {
            processed: b_count.clone(),
        })
        .unwrap();
    let worker_b = Arc::new(EventWorker::new(
        store.clone(),
        b_registry,
        common::fast_config("worker_b_survivor"),
    ));
    let delivered = common::run_worker_until(worker_b, Duration::from_secs(15), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["delivered"] }
    })
    .await;
    assert!(
        delivered,
        "Worker B doit livrer la livraison reprise : {:?}",
        common::delivery_statuses(&db).await
    );
    assert_eq!(b_count.load(Ordering::SeqCst), 1);

    // La reprise conserve le numéro de séquence d'origine (§5.6.4)
    assert_eq!(delivery_seq(&db).await, seq_before);
}

async fn delivery_seq(db: &surrealdb::Surreal<surrealdb::engine::any::Any>) -> Option<i64> {
    let mut res = db
        .query("RETURN (SELECT VALUE delivery_seq FROM event_delivery)[0]")
        .await
        .unwrap();
    res.take(0).unwrap()
}

/// Handler qui ne rend jamais la main (traitement interrompu par le crash).
struct StuckHandler;

#[async_trait::async_trait]
impl Handler<TaskAssigned> for StuckHandler {
    async fn handle(
        &self,
        _event: TaskAssigned,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        std::future::pending::<()>().await;
        Ok(())
    }
}
