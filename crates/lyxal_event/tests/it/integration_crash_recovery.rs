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
    common::install_event(store.client()).await;

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

/// Publie `count` événements, puis laisse un worker « condamné » séquencer toutes les
/// livraisons avant de l'interrompre sans libérer son bail (crash). Les verrous sont expirés.
async fn crash_after_sequencing(
    db: &surrealdb::Surreal<surrealdb::engine::any::Any>,
    store: &Arc<EventStore>,
    count: usize,
) {
    let sub = EventSubscription::new("task_sub", "lyxal_worker", "task.assigned", "execute_task");
    store.register_subscription(&sub).await.unwrap();
    let publisher =
        EventPublisher::new(store.clone(), "lyxal_orchestrator", EventContext::default());
    for i in 1..=count {
        publisher
            .publish(&TaskAssigned {
                task_id: format!("tsk_{i}"),
            })
            .await
            .unwrap();
    }

    let mut registry = HandlerRegistry::new();
    registry.register(StuckHandler).unwrap();
    let worker = Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_doomed"),
    ));
    let task = {
        let worker = worker.clone();
        tokio::spawn(async move { worker.run(CancellationToken::new()).await })
    };
    let expected = vec!["processing".to_string(); count];
    let mut sequenced = false;
    for _ in 0..200 {
        if common::delivery_statuses(db).await == expected {
            sequenced = true;
            break;
        }
        tokio::time::sleep(Duration::from_millis(25)).await;
    }
    assert!(sequenced, "toutes les livraisons doivent être séquencées");
    task.abort();
    let _ = task.await;
    db.query("UPDATE event_delivery SET locked_until = time::now() - 1s")
        .await
        .unwrap();
}

async fn persisted_cursor(db: &surrealdb::Surreal<surrealdb::engine::any::Any>) -> Option<i64> {
    let mut res = db
        .query("RETURN (SELECT VALUE last_persisted_cursor FROM event_subscription_progress)[0]")
        .await
        .unwrap();
    res.take(0).unwrap()
}

fn survivor(store: &Arc<EventStore>, processed: &Arc<AtomicUsize>) -> Arc<EventWorker> {
    let mut registry = HandlerRegistry::new();
    registry
        .register(WorkerBHandler {
            processed: processed.clone(),
        })
        .unwrap();
    Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_survivor"),
    ))
}

/// Une livraison déjà séquencée dont l'événement d'origine a disparu part en dead letter à la
/// reprise, et sa séquence est résolue : elle ne bloque pas les livraisons suivantes.
#[tokio::test]
async fn test_recovery_resolves_sequenced_incomplete_delivery() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_crash")
        .use_db("test_seq_incomplete")
        .await
        .unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    common::install_event(store.client()).await;

    crash_after_sequencing(&db, &store, 3).await;
    db.query("DELETE (SELECT VALUE outbox_event FROM event_delivery WHERE delivery_seq = 2)")
        .await
        .unwrap();

    let processed = Arc::new(AtomicUsize::new(0));
    let resolved = common::run_worker_until(
        survivor(&store, &processed),
        Duration::from_secs(15),
        || {
            let db = db.clone();
            async move {
                common::delivery_statuses(&db).await == ["dead_letter", "delivered", "delivered"]
                    && persisted_cursor(&db).await == Some(3)
            }
        },
    )
    .await;
    assert!(
        resolved,
        "statuts {:?}, curseur {:?}",
        common::delivery_statuses(&db).await,
        persisted_cursor(&db).await
    );
    assert_eq!(processed.load(Ordering::SeqCst), 2);
}

/// À la reprise, la fenêtre part du curseur persisté : une séquence encore en attente de retry
/// n'est pas dépassée par une séquence suivante déjà éligible, puis elle est livrée.
#[tokio::test]
async fn test_recovery_starts_from_persisted_cursor() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_crash")
        .use_db("test_seq_cursor")
        .await
        .unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    common::install_event(store.client()).await;

    crash_after_sequencing(&db, &store, 2).await;
    // La séquence 1 attend son prochain essai au-delà de l'expiration du bail de A (2 s) ;
    // la séquence 2 est éligible dès la prise du bail
    db.query("UPDATE event_delivery SET next_retry_at = time::now() + 5s WHERE delivery_seq = 1")
        .await
        .unwrap();

    let processed = Arc::new(AtomicUsize::new(0));
    let worker = survivor(&store, &processed);
    let delivered = common::run_worker_until(worker.clone(), Duration::from_secs(15), || {
        let db = db.clone();
        async move {
            common::delivery_statuses(&db).await == ["delivered", "delivered"]
                && persisted_cursor(&db).await == Some(2)
        }
    })
    .await;
    assert!(
        delivered,
        "statuts {:?}, curseur {:?}",
        common::delivery_statuses(&db).await,
        persisted_cursor(&db).await
    );
    assert_eq!(processed.load(Ordering::SeqCst), 2);
    // Un seul terme : la séquence 1 a été livrée sans perte ni reprise du bail
    let metrics = worker.metrics();
    assert_eq!(metrics.leadership_acquisitions.load(Ordering::SeqCst), 1);
    assert_eq!(metrics.leadership_losses.load(Ordering::SeqCst), 0);
    assert_eq!(metrics.fencing_conflicts.load(Ordering::SeqCst), 0);
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
