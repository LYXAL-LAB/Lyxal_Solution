use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

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

    // 3. Worker A démarre, réclame le lot avec un bail court de 1 seconde, puis crash immédiatement (drop)
    let claimed_by_a = store
        .claim_batch(1, 1, "worker_a_doomed", None)
        .await
        .unwrap();
    assert_eq!(
        claimed_by_a.len(),
        1,
        "Worker A must have claimed the delivery"
    );
    assert_eq!(claimed_by_a[0].status, DeliveryStatus::Processing);
    assert_eq!(
        claimed_by_a[0].lease_owner.as_deref(),
        Some("worker_a_doomed")
    );

    // Simule le crash brutal : Worker A est détruit sans jamais appeler delivery_success ou delivery_failure.
    drop(claimed_by_a);

    // Si Worker B essaie immédiatement de réclamer avant l'expiration du bail, il ne doit rien obtenir
    let early_claim_by_b = store
        .claim_batch(1, 5, "worker_b_survivor", None)
        .await
        .unwrap();
    assert_eq!(
        early_claim_by_b.len(),
        0,
        "Worker B must not steal delivery while lease is still valid"
    );

    // 4. On attend l'expiration du bail (1 seconde)
    tokio::time::sleep(Duration::from_millis(1200)).await;

    // 5. Worker B se réveille après expiration du bail et réclame la livraison orpheline
    let b_count = Arc::new(AtomicUsize::new(0));
    let mut b_registry = HandlerRegistry::new();
    b_registry
        .register(WorkerBHandler {
            processed: b_count.clone(),
        })
        .unwrap();

    let b_config = EventWorkerConfig::default().with_worker_id("worker_b_survivor");
    let worker_b = EventWorker::new(store.clone(), b_registry, b_config);
    let cancel = CancellationToken::new();

    let b_processed = worker_b.poll_cycle(&cancel).await.unwrap();
    assert_eq!(
        b_processed, 1,
        "Worker B must recover and process the expired delivery"
    );
    assert_eq!(
        b_count.load(Ordering::SeqCst),
        1,
        "Handler B must have successfully executed the recovered delivery"
    );

    // Vérifie que la livraison est définitivement en statut 'delivered'
    let mut query = db.query("SELECT * FROM ONLY event_delivery").await.unwrap();
    let final_delivery: Option<EventDelivery> = query.take(0).unwrap();
    let d = final_delivery.expect("Delivery must exist");
    assert_eq!(d.status, DeliveryStatus::Delivered);
    assert!(d.delivered_at.is_some());
}
