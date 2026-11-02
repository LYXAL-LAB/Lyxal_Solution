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
    store.init_schema().await.unwrap();

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
    let delivery_id_str = delivery_id.to_sql();

    // =========================================================================
    // TEST 3 : fn::event_delivery_failure avec l'ancien DTO { "id": ..., "error_message": ... }
    // Doit être rejeté (retourner false) et NE PAS incrémenter ni muter.
    // =========================================================================
    let mut call3 = db
        .query("RETURN fn::event_delivery_failure($params)")
        .bind((
            "params",
            json!({
                "id": delivery_id_str,
                "error_message": "legacy failure message",
                "retry_delay_seconds": 15
            }),
        ))
        .await
        .unwrap();
    let res3: Option<LyxalResponse> = call3.take(0).unwrap();
    assert!(
        !res3.unwrap().data,
        "L'ancien DTO de failure doit être rejeté"
    );

    let unmutated3 = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(unmutated3.status, DeliveryStatus::Pending);
    assert_eq!(unmutated3.last_error, None);

    // Vérification qu'aucune dead-letter n'a été insérée
    let dead_letters = store.get_dead_letters().await.unwrap();
    assert_eq!(
        dead_letters.len(),
        0,
        "Aucune dead letter ne doit être créée lors d'un échec de contrat"
    );

    // =========================================================================
    // TEST 4 : fn::event_delivery_failure avec 'delivery_id' mais 'error_message' au lieu de 'error'
    // =========================================================================
    let mut call4 = db
        .query("RETURN fn::event_delivery_failure($params)")
        .bind((
            "params",
            json!({
                "delivery_id": delivery_id_str,
                "error_message": "missing canonical error field"
            }),
        ))
        .await
        .unwrap();
    let res4: Option<LyxalResponse> = call4.take(0).unwrap();
    assert!(
        !res4.unwrap().data,
        "L'absence du champ canonique 'error' doit provoquer le rejet immédiat"
    );

    let unmutated4 = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(unmutated4.status, DeliveryStatus::Pending);

    // =========================================================================
    // TEST 5 : Appel avec contrat canonique valide -> Mutation acceptée
    // =========================================================================
    let mut call5 = db
        .query("RETURN fn::event_delivery_failure($params)")
        .bind((
            "params",
            json!({
                "delivery_id": delivery_id_str,
                "error": "canonical network error",
                "retry_delay_seconds": 10
            }),
        ))
        .await
        .unwrap();
    let res5: Option<LyxalResponse> = call5.take(0).unwrap();
    assert!(
        res5.unwrap().data,
        "Le contrat canonique officiel doit être accepté"
    );

    let mutated = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(mutated.status, DeliveryStatus::Failed);
    assert_eq!(
        mutated.last_error.as_deref(),
        Some("canonical network error")
    );
}

#[tokio::test]
async fn test_delivery_fetch_pending_canonical_contract() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_fetch").await.unwrap();

    common::setup_test_db(&db).await;

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

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
            subscription: Some("event_subscription:sub_fetch_beta".to_string()),
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
