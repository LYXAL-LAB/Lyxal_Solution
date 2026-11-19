//! Plusieurs hôtes sur une même base : un chef des événements par hôte
//! (`event_stream_lease:<hôte>`), chaque abonnement appartient à un hôte et seul le chef de cet
//! hôte lit, numérote et solde ses livraisons.
//!
//! Hôtes d'essai : `host_a` (handlers `mail.received` et `user.created`) et `host_b` (handlers
//! `booking.created` et `user.created`). Chaque hôte a son propre `EventWorker` et son propre
//! registre de handlers ; seule la base est commune (moteur embarqué `mem://`).

use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;
use tokio::sync::Mutex;
use tokio_util::sync::CancellationToken;

use crate::common;

const HOST_A: &str = "host_a";
const HOST_B: &str = "host_b";

#[derive(Debug, Clone, Serialize, Deserialize)]
struct MailReceived {
    n: u32,
}
impl Event for MailReceived {
    const EVENT_TYPE: &'static str = "mail.received";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct BookingCreated {
    n: u32,
}
impl Event for BookingCreated {
    const EVENT_TYPE: &'static str = "booking.created";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct UserCreated {
    n: u32,
}
impl Event for UserCreated {
    const EVENT_TYPE: &'static str = "user.created";
}

/// Journal partagé des traitements : (hôte, type d'événement, numéro, identifiant d'événement).
type Journal = Arc<Mutex<Vec<(String, String, u32, String)>>>;

struct Recorder {
    host: &'static str,
    journal: Journal,
}

macro_rules! recorder_handler {
    ($event:ty) => {
        #[async_trait::async_trait]
        impl Handler<$event> for Recorder {
            async fn handle(
                &self,
                event: $event,
                ctx: &HandlerContext,
            ) -> Result<(), LyxalEventError> {
                self.journal.lock().await.push((
                    self.host.to_string(),
                    <$event as Event>::EVENT_TYPE.to_string(),
                    event.n,
                    ctx.event_id.to_string(),
                ));
                Ok(())
            }
        }
    };
}
recorder_handler!(MailReceived);
recorder_handler!(BookingCreated);
recorder_handler!(UserCreated);

async fn shared_db(db: &str) -> (Surreal<Any>, Arc<EventStore>) {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test_multi_host").use_db(db).await.unwrap();
    common::setup_test_db(&client).await;
    let store = Arc::new(EventStore::new(client.clone()));
    common::install_event(store.client()).await;
    (client, store)
}

/// Abonnements des deux hôtes : chacun son type propre, et `user.created` écouté par les deux.
async fn register_subscriptions(store: &EventStore) {
    for sub in [
        EventSubscription::new(
            "a_mail",
            "mod_mail",
            "mail.received",
            "mail.on_received",
            HOST_A,
        ),
        EventSubscription::new("a_user", "mod_mail", "user.created", "mail.on_user", HOST_A),
        EventSubscription::new(
            "b_booking",
            "mod_booking",
            "booking.created",
            "booking.on_created",
            HOST_B,
        ),
        EventSubscription::new(
            "b_user",
            "mod_booking",
            "user.created",
            "booking.on_user",
            HOST_B,
        ),
    ] {
        store.register_subscription(&sub).await.unwrap();
    }
}

fn worker(
    store: &Arc<EventStore>,
    host: &'static str,
    node: &str,
    journal: &Journal,
) -> Arc<EventWorker> {
    let mut registry = HandlerRegistry::new();
    let recorder = || Recorder {
        host,
        journal: journal.clone(),
    };
    if host == HOST_A {
        registry.register::<MailReceived, _>(recorder()).unwrap();
    } else {
        registry.register::<BookingCreated, _>(recorder()).unwrap();
    }
    registry.register::<UserCreated, _>(recorder()).unwrap();
    Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_host_config(host, node),
    ))
}

/// Worker démarré en tâche de fond : arrêt propre par le jeton, ou « crash » par `abort`.
struct Running {
    cancel: CancellationToken,
    task: tokio::task::JoinHandle<Result<(), LyxalEventError>>,
}

fn start(worker: Arc<EventWorker>) -> Running {
    let cancel = CancellationToken::new();
    let task = {
        let cancel = cancel.clone();
        tokio::spawn(async move { worker.run(cancel).await })
    };
    Running { cancel, task }
}

impl Running {
    async fn stop(self) {
        self.cancel.cancel();
        self.task
            .await
            .expect("tâche du worker")
            .expect("arrêt propre");
    }

    async fn crash(self) {
        self.task.abort();
        let _ = self.task.await;
    }
}

async fn publish(store: &Arc<EventStore>, events: &[(&str, u32)]) {
    let publisher = EventPublisher::new(store.clone(), "lyxal_test", EventContext::default());
    for (event_type, n) in events {
        match *event_type {
            "mail.received" => publisher.publish(&MailReceived { n: *n }).await,
            "booking.created" => publisher.publish(&BookingCreated { n: *n }).await,
            _ => publisher.publish(&UserCreated { n: *n }).await,
        }
        .unwrap();
    }
}

async fn query_value(db: &Surreal<Any>, sql: &str) -> serde_json::Value {
    // Valeur de la dernière instruction (les précédentes sont des LET)
    let mut res = db.query(sql).await.unwrap().check().unwrap();
    let last = res.num_statements() - 1;
    let value: lyxal_surreal::Value = res.take(last).unwrap();
    value.into_json_value()
}

/// Livraisons d'un hôte, par statut.
async fn statuses(db: &Surreal<Any>, host: &str) -> Vec<String> {
    let mut res = db
        .query("SELECT VALUE status FROM event_delivery WHERE host = $host ORDER BY status")
        .bind(("host", host.to_string()))
        .await
        .unwrap();
    res.take(0).unwrap()
}

async fn all_delivered(db: &Surreal<Any>, expected: usize) -> bool {
    let mut res = db
        .query("SELECT VALUE status FROM event_delivery")
        .await
        .unwrap();
    let all: Vec<String> = res.take(0).unwrap();
    all.len() == expected && all.iter().all(|s| s == "delivered")
}

async fn wait_until<F, Fut>(timeout: Duration, mut done: F) -> bool
where
    F: FnMut() -> Fut,
    Fut: std::future::Future<Output = bool>,
{
    let deadline = tokio::time::Instant::now() + timeout;
    while tokio::time::Instant::now() < deadline {
        if done().await {
            return true;
        }
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
    false
}

/// Deux hôtes, handlers différents, une base : chaque événement atteint le handler de son hôte,
/// une seule fois, aucune dead letter ; `user.created`, écouté sur les deux hôtes, est traité une
/// fois par chacun.
#[tokio::test]
async fn test_two_hosts_each_event_reaches_its_host_once() {
    let (db, store) = shared_db("two_hosts").await;
    register_subscriptions(&store).await;
    let journal: Journal = Arc::default();
    let a = start(worker(&store, HOST_A, "node_a1", &journal));
    let b = start(worker(&store, HOST_B, "node_b1", &journal));

    let mut events = Vec::new();
    for n in 1..=5 {
        events.extend([
            ("mail.received", n),
            ("booking.created", n),
            ("user.created", n),
        ]);
    }
    publish(&store, &events).await;

    // 5 mails (A) + 5 réservations (B) + 5 utilisateurs × 2 hôtes
    let delivered = wait_until(Duration::from_secs(20), || all_delivered(&db, 20)).await;
    a.stop().await;
    b.stop().await;
    assert!(
        delivered,
        "A : {:?}, B : {:?}",
        statuses(&db, HOST_A).await,
        statuses(&db, HOST_B).await
    );

    let journal = journal.lock().await;
    let count = |host: &str, event_type: &str| {
        journal
            .iter()
            .filter(|(h, t, _, _)| h == host && t == event_type)
            .count()
    };
    assert_eq!(count(HOST_A, "mail.received"), 5);
    assert_eq!(count(HOST_B, "booking.created"), 5);
    assert_eq!(count(HOST_A, "user.created"), 5);
    assert_eq!(count(HOST_B, "user.created"), 5);
    assert_eq!(
        count(HOST_A, "booking.created") + count(HOST_B, "mail.received"),
        0
    );
    assert_eq!(journal.len(), 20, "chaque livraison traitée une seule fois");

    let dead = query_value(&db, "RETURN count(SELECT * FROM event_dead_letter)").await;
    assert_eq!(dead, 0, "aucune dead letter");
    // Chaque livraison porte l'hôte de son abonnement ; un bail par hôte
    let mismatched = query_value(
        &db,
        "RETURN count(SELECT * FROM event_delivery WHERE host != subscription.host)",
    )
    .await;
    assert_eq!(mismatched, 0);
    let leases = query_value(
        &db,
        "RETURN (SELECT VALUE record::id(id) FROM event_stream_lease ORDER BY id)",
    )
    .await;
    assert_eq!(leases, serde_json::json!([HOST_A, HOST_B]));
}

/// Un hôte arrêté : ses livraisons restent `pending`, sans essai compté ni dead letter, pendant
/// que l'autre livre les siennes ; `fn::event_backlog` le montre sans chef. À son retour, tout est
/// livré, dans l'ordre des numéros de séquence.
#[tokio::test]
async fn test_stopped_host_deliveries_wait_then_flow_in_order() {
    let (db, store) = shared_db("stopped_host").await;
    register_subscriptions(&store).await;
    let journal: Journal = Arc::default();
    let a = start(worker(&store, HOST_A, "node_a1", &journal));

    let events: Vec<(&str, u32)> = (1..=6)
        .flat_map(|n| [("booking.created", n), ("mail.received", n)])
        .collect();
    publish(&store, &events).await;

    let a_done = wait_until(Duration::from_secs(20), || {
        let db = db.clone();
        async move { statuses(&db, HOST_A).await == vec!["delivered"; 6] }
    })
    .await;
    assert!(
        a_done,
        "A livre les siennes : {:?}",
        statuses(&db, HOST_A).await
    );
    // Quelques tours de plus du chef de A : il ne touche jamais aux livraisons de B
    tokio::time::sleep(Duration::from_millis(500)).await;
    let waiting = query_value(
        &db,
        "RETURN (SELECT status, attempts, delivery_seq, lease_owner FROM event_delivery WHERE host = 'host_b')",
    )
    .await;
    let waiting = waiting.as_array().unwrap();
    assert_eq!(waiting.len(), 6);
    for delivery in waiting {
        assert_eq!(delivery["status"], "pending", "{delivery}");
        assert_eq!(delivery["attempts"], 0, "{delivery}");
        assert!(
            delivery
                .get("delivery_seq")
                .is_none_or(serde_json::Value::is_null),
            "{delivery}"
        );
    }
    assert_eq!(
        query_value(&db, "RETURN count(SELECT * FROM event_dead_letter)").await,
        0
    );

    // L'attente se voit par hôte : B sans chef, A avec son chef
    let backlog = store.backlog(Duration::from_secs(1)).await.unwrap();
    assert_eq!(backlog.len(), 1, "{backlog:?}");
    assert_eq!(backlog[0].host, HOST_B);
    assert_eq!(backlog[0].pending, 6);
    assert!(!backlog[0].leader_alive);
    assert_eq!(backlog[0].leader_node, None);

    // Retour de B : tout est livré, dans l'ordre des numéros
    let b = start(worker(&store, HOST_B, "node_b1", &journal));
    let all = wait_until(Duration::from_secs(20), || all_delivered(&db, 12)).await;
    a.stop().await;
    b.stop().await;
    assert!(all, "B : {:?}", statuses(&db, HOST_B).await);
    let order: Vec<u32> = journal
        .lock()
        .await
        .iter()
        .filter(|(h, t, _, _)| h == HOST_B && t == "booking.created")
        .map(|(_, _, n, _)| *n)
        .collect();
    assert_eq!(order, vec![1, 2, 3, 4, 5, 6], "ordre de publication");
    let seqs = query_value(
        &db,
        "RETURN (SELECT VALUE delivery_seq FROM event_delivery WHERE host = 'host_b' ORDER BY created_at, id)",
    )
    .await;
    assert_eq!(
        seqs,
        serde_json::json!([1, 2, 3, 4, 5, 6]),
        "numéros dans l'ordre des événements"
    );
    assert_eq!(
        query_value(&db, "RETURN count(SELECT * FROM event_dead_letter)").await,
        0
    );
    assert!(store
        .backlog(Duration::from_secs(1))
        .await
        .unwrap()
        .is_empty());
}

/// Deux nœuds du même hôte : un seul chef. Chef tué : le second reprend après l'échéance du bail,
/// les numéros sont conservés et l'écriture de l'ancien chef est refusée
/// (`EVENT_STALE_LEADER_FENCED`).
#[tokio::test]
async fn test_two_nodes_of_one_host_single_leader_and_failover() {
    let (db, store) = shared_db("two_nodes").await;
    register_subscriptions(&store).await;
    let journal: Journal = Arc::default();
    let n1 = worker(&store, HOST_A, "node_a1", &journal);
    let n2 = worker(&store, HOST_A, "node_a2", &journal);
    let r1 = start(n1.clone());
    let r2 = start(n2.clone());

    publish(&store, &[("mail.received", 1), ("mail.received", 2)]).await;
    let first = wait_until(Duration::from_secs(20), || all_delivered(&db, 2)).await;
    assert!(first, "{:?}", statuses(&db, HOST_A).await);

    // Un seul chef pour l'hôte : une seule acquisition, et un seul bail
    let acquisitions = |w: &Arc<EventWorker>| {
        w.metrics()
            .leadership_acquisitions
            .load(std::sync::atomic::Ordering::SeqCst)
    };
    assert_eq!(acquisitions(&n1) + acquisitions(&n2), 1);
    let lease = query_value(
        &db,
        "RETURN event_stream_lease:host_a.{ owner_node_id, generation }",
    )
    .await;
    let leader = lease["owner_node_id"].as_str().unwrap().to_string();
    let old_generation = lease["generation"].as_u64().unwrap();
    assert_eq!(
        query_value(&db, "RETURN count(SELECT * FROM event_stream_lease)").await,
        1
    );

    // Le chef « plante » sans libérer son bail
    let (dead, survivor) = if leader == "node_a1" {
        (r1, r2)
    } else {
        (r2, r1)
    };
    dead.crash().await;
    publish(&store, &[("mail.received", 3), ("mail.received", 4)]).await;
    let resumed = wait_until(Duration::from_secs(20), || all_delivered(&db, 4)).await;
    survivor.stop().await;
    assert!(resumed, "{:?}", statuses(&db, HOST_A).await);

    let lease = query_value(
        &db,
        "RETURN event_stream_lease:host_a.{ owner_node_id, generation }",
    )
    .await;
    assert_ne!(
        lease["owner_node_id"].as_str().unwrap(),
        leader,
        "le second nœud a repris"
    );
    assert!(lease["generation"].as_u64().unwrap() > old_generation);
    let seqs = query_value(
        &db,
        "RETURN (SELECT VALUE delivery_seq FROM event_delivery WHERE subscription.name = 'a_mail' ORDER BY delivery_seq)",
    )
    .await;
    assert_eq!(
        seqs,
        serde_json::json!([1, 2, 3, 4]),
        "numéros contigus, conservés"
    );

    // Écriture de l'ancien chef, sous son ancienne génération : refusée
    let refused = db
        .query(
            "LET $sub = (SELECT VALUE id FROM ONLY event_subscription WHERE name = 'a_mail' LIMIT 1);
             RETURN fn::event_flush_batch({ subscription: $sub, target_cursor: 4, host: 'host_a', node_id: $node, generation: $generation });",
        )
        .bind(("node", leader))
        .bind(("generation", old_generation))
        .await
        .unwrap()
        .check();
    let message = refused.expect_err("écriture refusée").to_string();
    assert!(message.contains("EVENT_STALE_LEADER_FENCED"), "{message}");
}

/// Écriture du chef d'un hôte sur l'abonnement ou la livraison d'un autre hôte :
/// `EVENT_SUBSCRIPTION_NOT_OWNED`, sans effet.
#[tokio::test]
async fn test_write_on_another_host_subscription_is_not_owned() {
    let (db, store) = shared_db("not_owned").await;
    register_subscriptions(&store).await;
    publish(&store, &[("booking.created", 1)]).await;

    let result = query_value(
        &db,
        "LET $lease = fn::event_lease_acquire({ host: 'host_a', node_id: 'node_a1', ttl_seconds: 60 });
         LET $sub = (SELECT VALUE id FROM ONLY event_subscription WHERE name = 'b_booking' LIMIT 1);
         LET $delivery = (SELECT * FROM ONLY event_delivery WHERE subscription = $sub LIMIT 1);
         LET $generation = $lease.data.generation;
         RETURN {
             assign: fn::event_delivery_assign_seq({ host: 'host_a', node_id: 'node_a1', generation: $generation, outbox_event: $delivery.outbox_event, subscription: $sub, target_module: 'mod_booking' }).error.code,
             flush: fn::event_flush_batch({ host: 'host_a', node_id: 'node_a1', generation: $generation, subscription: $sub, target_cursor: 0 }).error.code,
             dead_letter: fn::event_dead_letter_transfer({ host: 'host_a', node_id: 'node_a1', generation: $generation, delivery_id: $delivery.id, error: 'test' }).error.code
         };",
    )
    .await;
    assert_eq!(
        result,
        serde_json::json!({
            "assign": "EVENT_SUBSCRIPTION_NOT_OWNED",
            "flush": "EVENT_SUBSCRIPTION_NOT_OWNED",
            "dead_letter": "EVENT_SUBSCRIPTION_NOT_OWNED"
        })
    );
    // Rien n'a bougé : la livraison de B attend toujours, sans numéro
    assert_eq!(statuses(&db, HOST_B).await, ["pending"]);
    assert_eq!(
        query_value(&db, "RETURN count(SELECT * FROM event_dead_letter)").await,
        0
    );
}

/// Même abonnement réclamé par deux hôtes : refus ; changement d'hôte refusé tant que le chef de
/// l'ancien hôte est vivant, puis accepté : ses livraisons en attente passent au nouvel hôte,
/// qui les livre.
#[tokio::test]
async fn test_subscription_conflict_then_transfer() {
    let (db, store) = shared_db("transfer").await;
    register_subscriptions(&store).await;

    // Conflit : B réclame l'abonnement de A
    let conflict = store
        .register_subscription(&EventSubscription::new(
            "a_mail",
            "mod_mail",
            "mail.received",
            "mail.on_received",
            HOST_B,
        ))
        .await;
    assert!(
        matches!(&conflict, Err(LyxalEventError::Surreal(e)) if e.is_business_code("EVENT_SUBSCRIPTION_HOST_CONFLICT")),
        "{conflict:?}"
    );

    // A est en marche : il livre un premier mail, puis s'arrête en gardant un bail vivant
    let journal: Journal = Arc::default();
    let a = start(worker(&store, HOST_A, "node_a1", &journal));
    publish(&store, &[("mail.received", 1)]).await;
    assert!(wait_until(Duration::from_secs(20), || all_delivered(&db, 1)).await);
    a.crash().await;
    publish(&store, &[("mail.received", 2), ("mail.received", 3)]).await;

    let refused = store.transfer_subscription("a_mail", HOST_B).await;
    assert!(
        matches!(&refused, Err(LyxalEventError::Surreal(e)) if e.is_business_code("EVENT_HOST_ACTIVE")),
        "{refused:?}"
    );

    // Bail de A expiré : le changement d'hôte est accepté
    db.query("UPDATE event_stream_lease:host_a SET expires_at = time::now() - 1s")
        .await
        .unwrap()
        .check()
        .unwrap();
    let moved = store.transfer_subscription("a_mail", HOST_B).await.unwrap();
    assert_eq!(moved.previous_host, HOST_A);
    assert_eq!(moved.host, HOST_B);
    assert_eq!(moved.deliveries, 2);

    // B porte désormais le handler des mails : il livre les deux en attente, numéros 2 et 3
    let mut registry = HandlerRegistry::new();
    registry
        .register::<MailReceived, _>(Recorder {
            host: HOST_B,
            journal: journal.clone(),
        })
        .unwrap();
    let b = start(Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_host_config(HOST_B, "node_b1"),
    )));
    let done = wait_until(Duration::from_secs(20), || all_delivered(&db, 3)).await;
    b.stop().await;
    assert!(done, "{:?}", statuses(&db, HOST_B).await);
    let by_b: Vec<u32> = journal
        .lock()
        .await
        .iter()
        .filter(|(h, _, _, _)| h == HOST_B)
        .map(|(_, _, n, _)| *n)
        .collect();
    assert_eq!(by_b, vec![2, 3]);
    let seqs = query_value(
        &db,
        "RETURN (SELECT VALUE delivery_seq FROM event_delivery ORDER BY delivery_seq)",
    )
    .await;
    assert_eq!(seqs, serde_json::json!([1, 2, 3]));
}

/// Mesure (plan §10) : lecture des livraisons en attente d'un hôte parmi 100 000 livraisons, avec
/// l'index `(host, status, next_retry_at)`. Lancée à la demande :
/// `cargo test -p lyxal_event --release -- --ignored fetch_pending_on_100k`.
#[tokio::test]
#[ignore = "mesure de performance, lancée à la demande"]
async fn fetch_pending_on_100k_deliveries() {
    let (db, store) = shared_db("bench_100k").await;
    // 100 000 livraisons : 90 000 livrées, 9 000 en attente de l'autre hôte, 1 000 en attente
    // de l'hôte mesuré
    db.query(
        "CREATE event_outbox:bench CONTENT { event_id: <string> rand::uuid::v7(), event_type: 'bench.item', producer: 'bench', context: { instance_id: 'default', namespace: 'default', database: 'default' }, correlation_id: <string> rand::uuid::v7(), payload: {}, status: 'fanned_out' };
         FOR $i IN <array>(0..100000) {
             CREATE event_delivery CONTENT {
                 outbox_event: event_outbox:bench,
                 subscription: type::record('event_subscription', 'bench_' + <string> $i),
                 host: IF $i < 90000 { IF $i % 2 == 0 { 'host_a' } ELSE { 'host_b' } } ELSE IF $i < 99000 { 'host_b' } ELSE { 'host_a' },
                 target_module: 'bench',
                 context: { instance_id: 'default', namespace: 'default', database: 'default' },
                 status: IF $i < 90000 { 'delivered' } ELSE { 'pending' },
                 created_at: time::now() - 1h + <duration> (<string> $i + 'ms')
             };
         };",
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    let mut timings = Vec::new();
    for _ in 0..5 {
        let started = std::time::Instant::now();
        let batch = store
            .fetch_pending_deliveries(lyxal_event::engine::dto::DeliveryFetchPendingParams {
                host: HOST_A.to_string(),
                limit: 50,
                instance_id: None,
                subscription: None,
            })
            .await
            .unwrap();
        timings.push(started.elapsed());
        assert_eq!(batch.len(), 50);
    }
    let started = std::time::Instant::now();
    let backlog = store.backlog(Duration::from_secs(60)).await.unwrap();
    let backlog_time = started.elapsed();
    assert_eq!(backlog.iter().map(|h| h.pending).sum::<u64>(), 10_000);
    let plan = query_value(
        &db,
        "RETURN (SELECT id FROM event_delivery WHERE host = 'host_a' AND status = 'pending' EXPLAIN)",
    )
    .await;
    println!("fetch_pending (host_a, 1 000 en attente sur 100 000) : {timings:?}");
    println!("event_backlog (10 000 en attente sur 100 000) : {backlog_time:?}");
    println!("plan : {plan}");
}
