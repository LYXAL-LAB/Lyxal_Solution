use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct TenantSecretRotated {
    pub key_id: String,
}

impl Event for TenantSecretRotated {
    const EVENT_TYPE: &'static str = "tenant.secret_rotated";
}

struct TenantHandler {
    pub handled_instances: Arc<std::sync::Mutex<Vec<String>>>,
    pub count: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<TenantSecretRotated> for TenantHandler {
    async fn handle(
        &self,
        _event: TenantSecretRotated,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        self.handled_instances
            .lock()
            .unwrap()
            .push(ctx.context.instance_id.clone());
        self.count.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

#[tokio::test]
async fn test_strict_multi_instance_isolation() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("cluster").use_db("main").await.unwrap();

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

    // Abonnement global
    let sub = EventSubscription::new(
        "secret_rotation_sub",
        "lyxal_crypto",
        "tenant.secret_rotated",
        "notify_services",
    );
    store.register_subscription(&sub).await.unwrap();

    // Publication de 2 événements dans 2 contextes d'instances différents
    let ctx_alpha = EventContext::new("inst_alpha", "client_alpha", "prod");
    let ctx_beta = EventContext::new("inst_beta", "client_beta", "prod");

    let pub_alpha = EventPublisher::new(store.clone(), "lyxal_auth", ctx_alpha);
    let pub_beta = EventPublisher::new(store.clone(), "lyxal_auth", ctx_beta);

    pub_alpha
        .publish(&TenantSecretRotated {
            key_id: "k_alpha_1".into(),
        })
        .await
        .unwrap();
    pub_beta
        .publish(&TenantSecretRotated {
            key_id: "k_beta_1".into(),
        })
        .await
        .unwrap();

    // Vérifie qu'il y a 2 deliveries (une pour alpha, une pour beta)
    let all_deliveries = store.claim_batch(10, 30, "probe", None).await.unwrap();
    assert_eq!(all_deliveries.len(), 2);
    // Libère le claim probe
    db.query(
        "UPDATE event_delivery SET status = 'pending', locked_until = NONE, lease_owner = NONE",
    )
    .await
    .unwrap();

    // 3. Worker dédié EXCLUSIVEMENT à l'instance Alpha
    let alpha_instances = Arc::new(std::sync::Mutex::new(Vec::new()));
    let alpha_count = Arc::new(AtomicUsize::new(0));

    let mut registry_alpha = HandlerRegistry::new();
    registry_alpha
        .register(TenantHandler {
            handled_instances: alpha_instances.clone(),
            count: alpha_count.clone(),
        })
        .unwrap();

    let config_alpha = EventWorkerConfig::default()
        .with_worker_id("worker_for_alpha_only")
        .with_instance_id("inst_alpha");

    let worker_alpha = EventWorker::new(store.clone(), registry_alpha, config_alpha);
    let cancel = CancellationToken::new();

    let processed_by_alpha = worker_alpha.poll_cycle(&cancel).await.unwrap();
    assert_eq!(
        processed_by_alpha, 1,
        "Worker Alpha must claim ONLY the single delivery belonging to inst_alpha"
    );

    let instances_seen = alpha_instances.lock().unwrap().clone();
    assert_eq!(
        instances_seen,
        vec!["inst_alpha".to_string()],
        "Worker Alpha must never process inst_beta events"
    );

    // 4. Vérifie que la delivery Beta est TOUJOURS en attente ('pending')
    let mut check_beta = db
        .query("SELECT * FROM ONLY event_delivery WHERE context.instance_id = 'inst_beta'")
        .await
        .unwrap();
    let beta_delivery: Option<EventDelivery> = check_beta.take(0).unwrap();
    let b = beta_delivery.expect("Beta delivery must exist");
    assert_eq!(
        b.status,
        DeliveryStatus::Pending,
        "Beta delivery must remain untouched in pending status"
    );
}
