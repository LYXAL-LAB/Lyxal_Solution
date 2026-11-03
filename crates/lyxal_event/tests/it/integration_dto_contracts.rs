use lyxal_event::prelude::*;
use lyxal_surreal::{SurrealValue, ToSql};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::sync::Arc;
use surrealdb::engine::any::connect;

use crate::common;
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct TestEvent {
    pub val: u64,
}

impl Event for TestEvent {
    const EVENT_TYPE: &'static str = "test.event";
}

#[derive(SurrealValue, Debug)]
#[allow(dead_code)]
struct LyxalResponse {
    pub ok: bool,
    pub data: bool,
}

#[tokio::test]
async fn test_rejection_of_legacy_dto_and_negative_contracts() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_db").await.unwrap();

    common::setup_test_db(&db).await;

    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    // 1. Enregistrement d'un abonnement actif
    let sub = EventSubscription::new(
        "sub_test_contracts",
        "test_consumer_module",
        "test.event",
        "handle_test_event",
    )
    .with_max_attempts(3);
    store.register_subscription(&sub).await.unwrap();

    // 2. Publication standard via EventPublisher pour créer l'outbox et la delivery canonique
    let publisher = EventPublisher::new(store.clone(), "test_producer", EventContext::default());
    publisher.publish(&TestEvent { val: 100 }).await.unwrap();

    // 3. Récupération de la livraison créée en statut 'pending'
    let deliveries: Vec<EventDelivery> = db
        .query("SELECT * FROM event_delivery WHERE status = 'pending'")
        .await
        .unwrap()
        .take(0)
        .unwrap();
    assert_eq!(deliveries.len(), 1, "Une livraison doit être initialisée");
    let delivery_id = deliveries[0].id.clone();

    // 1. Ancien DTO { id, error_message } : refusé, rapport par champ, aucune mutation
    let legacy = call_json(
        &db,
        "RETURN fn::event_delivery_failure($params)",
        json!({ "id": delivery_id.to_sql(), "error_message": "legacy", "retry_delay_seconds": 15 }),
    )
    .await;
    assert_eq!(legacy["ok"], false);
    assert_eq!(legacy["error"]["code"], "EVENT_INVALID_PARAMETERS");
    assert!(legacy["error"]["details"]["fields"]["delivery_id"].is_array());
    assert!(legacy["error"]["details"]["fields"]["error"].is_array());

    // 2. Identifiant transmis en chaîne au lieu d'un Record ID : refusé
    let stringly = call_json(
        &db,
        "RETURN fn::event_delivery_failure($params)",
        json!({ "delivery_id": delivery_id.to_sql(), "error": "network error" }),
    )
    .await;
    assert_eq!(stringly["error"]["code"], "EVENT_INVALID_PARAMETERS");
    assert!(stringly["error"]["details"]["fields"]["delivery_id"].is_array());

    let unmutated = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(unmutated.status, DeliveryStatus::Pending);
    assert_eq!(unmutated.last_error, None);
    assert!(store.get_dead_letters().await.unwrap().is_empty());

    // 3. Livraison inconnue : EVENT_DELIVERY_NOT_FOUND
    let mut res = db
        .query("RETURN fn::event_delivery_failure($params)")
        .bind((
            "params",
            lyxal_event::engine::dto::DeliveryFailureParams {
                delivery_id: lyxal_surreal::RecordId::new("event_delivery", "inexistante"),
                error: "network error".into(),
                retry_delay_seconds: 10,
            },
        ))
        .await
        .unwrap();
    let not_found: Option<lyxal_surreal::Value> = res.take(0).unwrap();
    let not_found = not_found.unwrap().into_json_value();
    assert_eq!(not_found["error"]["code"], "EVENT_DELIVERY_NOT_FOUND");

    // 4. Contrat typé : échec transitoire enregistré
    let mut res = db
        .query("RETURN fn::event_delivery_failure($params)")
        .bind((
            "params",
            lyxal_event::engine::dto::DeliveryFailureParams {
                delivery_id: delivery_id.clone(),
                error: "canonical network error".into(),
                retry_delay_seconds: 10,
            },
        ))
        .await
        .unwrap();
    let accepted: Option<LyxalResponse> = res.take(0).unwrap();
    assert!(accepted.unwrap().data, "le contrat typé doit être accepté");

    let mutated = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(mutated.status, DeliveryStatus::Failed);
    assert_eq!(
        mutated.last_error.as_deref(),
        Some("canonical network error")
    );
}

/// Exécute une requête avec des paramètres JSON bruts (cas de contrat invalide) et renvoie le
/// résultat `{ ok, data, error }` en JSON.
async fn call_json(
    db: &surrealdb::Surreal<surrealdb::engine::any::Any>,
    query: &str,
    params: serde_json::Value,
) -> serde_json::Value {
    let mut res = db.query(query).bind(("params", params)).await.unwrap();
    let value: Option<lyxal_surreal::Value> = res.take(0).unwrap();
    value.unwrap().into_json_value()
}

#[tokio::test]
async fn test_delivery_fetch_pending_canonical_contract() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_fetch").await.unwrap();

    common::setup_test_db(&db).await;

    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    // 1. Déclaration de 2 abonnements
    let sub1 = EventSubscription::new(
        "sub_fetch_alpha",
        "test_consumer_module",
        "test.event",
        "handle_alpha",
    );
    let sub2 = EventSubscription::new(
        "sub_fetch_beta",
        "test_consumer_module",
        "test.event",
        "handle_beta",
    );
    store.register_subscription(&sub1).await.unwrap();
    store.register_subscription(&sub2).await.unwrap();

    // Insertion de 9 outbox events distincts (un par delivery pour respecter idx_delivery_unique_fanout)
    for i in 1..=9 {
        db.query(format!(
            r#"
            CREATE event_outbox:ev{} CONTENT {{
                event_id: <string> rand::uuid::v7(),
                event_type: "test.event",
                version: 1,
                producer: "test_producer",
                source: NONE,
                context: {{ instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" }},
                correlation_id: <string> rand::uuid::v7(),
                causation_id: NONE,
                payload: {{ value: {} }},
                metadata: {{}},
                status: "fanned_out",
                fanned_out_at: time::now()
            }};
            "#,
            i, i
        ))
        .await
        .unwrap()
        .check()
        .unwrap();
    }

    // 2. Création de divers états de livraison
    // D1: Éligible standard (pending, non séquencé, non verrouillé)
    db.query(
        r#"
        CREATE event_delivery:d1 CONTENT {
            outbox_event: event_outbox:ev1,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "pending",
            attempts: 0,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: time::now() - 10s,
            created_at: time::now() - 30s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // D2: Éligible reprise crash (séquencé, processing mais verrou expiré)
    db.query(
        r#"
        CREATE event_delivery:d2 CONTENT {
            outbox_event: event_outbox:ev2,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "processing",
            delivery_seq: 10,
            attempts: 1,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: time::now() - 5s,
            next_retry_at: NONE,
            created_at: time::now() - 25s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // D3: Non éligible car verrou actif (en cours de traitement par un worker vivant)
    db.query(
        r#"
        CREATE event_delivery:d3 CONTENT {
            outbox_event: event_outbox:ev3,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "processing",
            attempts: 1,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: time::now() + 60s,
            next_retry_at: NONE,
            created_at: time::now() - 20s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // D4: Non éligible car retry dans le futur
    db.query(
        r#"
        CREATE event_delivery:d4 CONTENT {
            outbox_event: event_outbox:ev4,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "failed",
            attempts: 1,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: time::now() + 120s,
            created_at: time::now() - 15s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // D5, D6, D7: Terminaux exclus (delivered, dead_letter, dropped)
    db.query(
        r#"
        CREATE event_delivery:d5 CONTENT {
            outbox_event: event_outbox:ev5,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "delivered",
            attempts: 1,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: NONE,
            created_at: time::now() - 10s
        };
        CREATE event_delivery:d6 CONTENT {
            outbox_event: event_outbox:ev6,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "dead_letter",
            attempts: 3,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: NONE,
            created_at: time::now() - 8s
        };
        CREATE event_delivery:d7 CONTENT {
            outbox_event: event_outbox:ev7,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "dropped",
            attempts: 1,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: NONE,
            created_at: time::now() - 6s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // D8: Éligible mais autre instance (inst_beta)
    db.query(
        r#"
        CREATE event_delivery:d8 CONTENT {
            outbox_event: event_outbox:ev8,
            subscription: event_subscription:sub_fetch_alpha,
            target_module: "test_consumer_module",
            status: "pending",
            attempts: 0,
            context: { instance_id: "inst_beta", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: NONE,
            created_at: time::now() - 5s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // D9: Éligible mais autre subscription (sub_fetch_beta)
    db.query(
        r#"
        CREATE event_delivery:d9 CONTENT {
            outbox_event: event_outbox:ev9,
            subscription: event_subscription:sub_fetch_beta,
            target_module: "test_consumer_module",
            status: "pending",
            attempts: 0,
            context: { instance_id: "inst_alpha", namespace: "test_ns", database: "test_fetch" },
            locked_until: NONE,
            next_retry_at: NONE,
            created_at: time::now() - 4s
        };
        "#,
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // =========================================================================
    // Test 1 : Requête sans filtre instance/subscription -> doit ramener d1, d2, d8, d9
    // (exclut d3 [verrou], d4 [retry futur], d5 [delivered], d6 [dead_letter], d7 [dropped])
    // =========================================================================
    let all = store
        .fetch_pending_deliveries(lyxal_event::engine::dto::DeliveryFetchPendingParams {
            limit: 50,
            instance_id: None,
            subscription: None,
        })
        .await
        .unwrap();
    let ids: Vec<String> = all.iter().map(|d| d.id.to_sql()).collect();
    assert_eq!(
        ids.len(),
        4,
        "Doit retourner exactement 4 livraisons éligibles"
    );
    assert!(ids.contains(&"event_delivery:d1".to_string()));
    assert!(ids.contains(&"event_delivery:d2".to_string()));
    assert!(ids.contains(&"event_delivery:d8".to_string()));
    assert!(ids.contains(&"event_delivery:d9".to_string()));

    // =========================================================================
    // Test 2 : Filtre par instance 'inst_alpha' -> doit ramener d1, d2, d9 (exclut d8)
    // =========================================================================
    let alpha_only = store
        .fetch_pending_deliveries(lyxal_event::engine::dto::DeliveryFetchPendingParams {
            limit: 50,
            instance_id: Some("inst_alpha".to_string()),
            subscription: None,
        })
        .await
        .unwrap();
    let alpha_ids: Vec<String> = alpha_only.iter().map(|d| d.id.to_sql()).collect();
    assert_eq!(alpha_ids.len(), 3);
    assert!(!alpha_ids.contains(&"event_delivery:d8".to_string()));

    // =========================================================================
    // Test 3 : Filtre par subscription 'event_subscription:sub_fetch_beta' -> d9 seulement
    // =========================================================================
    let beta_sub_only = store
        .fetch_pending_deliveries(lyxal_event::engine::dto::DeliveryFetchPendingParams {
            limit: 50,
            instance_id: None,
            subscription: Some(lyxal_surreal::RecordId::new(
                "event_subscription",
                "sub_fetch_beta",
            )),
        })
        .await
        .unwrap();
    let beta_sub_ids: Vec<String> = beta_sub_only.iter().map(|d| d.id.to_sql()).collect();
    assert_eq!(beta_sub_ids, vec!["event_delivery:d9".to_string()]);

    // =========================================================================
    // Test 4 : Respect du limit
    // =========================================================================
    let limited = store
        .fetch_pending_deliveries(lyxal_event::engine::dto::DeliveryFetchPendingParams {
            limit: 2,
            instance_id: None,
            subscription: None,
        })
        .await
        .unwrap();
    assert_eq!(
        limited.len(),
        2,
        "La limite doit être strictement respectée"
    );
    // L'ordre doit être created_at ASC : d1 puis d2
    assert_eq!(limited[0].id.to_sql(), "event_delivery:d1");
    assert_eq!(limited[1].id.to_sql(), "event_delivery:d2");
}

/// Les fonctions appelées de l'extérieur valident leurs entrées par le moteur de `lyxal_core` :
/// un champ inconnu ou invalide renvoie `EVENT_INVALID_PARAMETERS` avec le rapport par champ.
#[tokio::test]
async fn test_external_functions_validate_inputs_with_core() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_inputs").await.unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    let publish = call_json(
        &db,
        "RETURN fn::event_publish($params)",
        json!({
            "event_id": "not-a-native-uuid",
            "event_type": "Booking Created",
            "producer": "lyxal_booking",
            "instance_id": "legacy_top_level"
        }),
    )
    .await;
    assert_eq!(publish["error"]["code"], "EVENT_INVALID_PARAMETERS");
    let fields = &publish["error"]["details"]["fields"];
    assert!(fields["event_id"].is_array(), "{fields}");
    assert!(fields["event_type"].is_array(), "{fields}");
    assert!(
        fields["instance_id"].is_array(),
        "champ inconnu refusé : {fields}"
    );

    let register = call_json(
        &db,
        "RETURN fn::event_subscription_register($params)",
        json!({ "name": "sub_x", "target_module": "lyxal_x", "event_pattern": "x.*", "handler_name": "h", "max_attempts": 0 }),
    )
    .await;
    assert_eq!(register["error"]["code"], "EVENT_INVALID_PARAMETERS");
    assert!(register["error"]["details"]["fields"]["max_attempts"].is_array());
}
