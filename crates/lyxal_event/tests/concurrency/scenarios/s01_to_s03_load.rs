//! Scenarios S-01 to S-03: Nominal flow and multi-worker concurrent claims
//!
//! Evaluates:
//! - S-01: Baseline nominal flow (single worker, batch claiming, processing, delivery)
//! - S-02: Nominal concurrent load (5 workers, 50 events, batch_size=5, zero duplicate claims)
//! - S-03: Heavy multi-worker concurrency (10 workers, 200 events, strict claim disjointness Dsim = 0)

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, inject_pending_deliveries},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::{BenchWorkerClient, ClaimBatchParams, DeliverySuccessParams},
};
use tokio::task::JoinSet;

/// S-01: Flux nominal unitaire (1 worker, 10 livraisons, transition complète vers 'delivered').
pub async fn run_scenario_s01() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    let inserted = inject_pending_deliveries(&db, &sub_id, 10).await?;
    assert_eq!(inserted.len(), 10);

    let client = BenchWorkerClient::new(db.clone(), "worker-s01", journal.clone());
    let claims = client
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: 10,
            lease_duration_ms: 5000,
            claim_request_id: "req-s01".into(),
        })
        .await?;

    assert_eq!(claims.len(), 10, "Worker-s01 must claim all 10 items");

    for claim in &claims {
        let success = client
            .delivery_success(DeliverySuccessParams {
                delivery_id: claim.id.to_string(),
                claim_nonce: claim.claim_nonce.clone(),
            })
            .await?;
        assert!(success, "Delivery success must return true under valid lease");
    }

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, 10);
    assert_eq!(balance.pending, 0);
    assert_eq!(balance.processing, 0);
    assert_eq!(journal.compute_dsim(), 0, "Dsim must be strictly 0");

    Ok(())
}

/// S-02: Concurrence nominale (5 workers, 50 événements, batch_size=5).
pub async fn run_scenario_s02() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    let total_events = 50;
    let _inserted = inject_pending_deliveries(&db, &sub_id, total_events).await?;

    let num_workers = 5;
    let mut tasks = JoinSet::new();

    for i in 0..num_workers {
        let db_cloned = db.clone();
        let journal_cloned = journal.clone();
        let sub_cloned = sub_id.clone();
        let worker_name = format!("worker-s02-{i}");

        tasks.spawn(async move {
            let client = BenchWorkerClient::new(db_cloned, worker_name, journal_cloned);
            let mut processed = 0;

            loop {
                let claims = client
                    .claim_batch(ClaimBatchParams {
                        subscription_id: sub_cloned.clone(),
                        batch_size: 5,
                        lease_duration_ms: 4000,
                        claim_request_id: format!("req-{processed}"),
                    })
                    .await?;

                if claims.is_empty() {
                    break;
                }

                for item in claims {
                    let ok = client
                        .delivery_success(DeliverySuccessParams {
                            delivery_id: item.id.to_string(),
                            claim_nonce: item.claim_nonce,
                        })
                        .await?;
                    if ok {
                        processed += 1;
                    }
                }
            }
            Ok::<usize, Box<dyn std::error::Error + Send + Sync>>(processed)
        });
    }

    let mut total_processed = 0;
    while let Some(res) = tasks.join_next().await {
        total_processed += res??;
    }

    assert_eq!(total_processed, total_events);
    let dsim = journal.compute_dsim();
    assert_eq!(dsim, 0, "Dsim must be strictly 0 under nominal 5-worker load");

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, total_events);
    assert_eq!(balance.processing, 0);
    assert_eq!(balance.pending, 0);

    Ok(())
}

/// S-03: Concurrence lourde (10 workers concurrents, 200 événements).
pub async fn run_scenario_s03() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    let total_events = 200;
    let _inserted = inject_pending_deliveries(&db, &sub_id, total_events).await?;

    let num_workers = 10;
    let mut tasks = JoinSet::new();

    for i in 0..num_workers {
        let db_cloned = db.clone();
        let journal_cloned = journal.clone();
        let sub_cloned = sub_id.clone();
        let worker_name = format!("worker-s03-{i}");

        tasks.spawn(async move {
            let client = BenchWorkerClient::new(db_cloned, worker_name, journal_cloned);
            let mut processed = 0;

            loop {
                let claims = client
                    .claim_batch(ClaimBatchParams {
                        subscription_id: sub_cloned.clone(),
                        batch_size: 10,
                        lease_duration_ms: 3000,
                        claim_request_id: format!("req-{processed}"),
                    })
                    .await?;

                if claims.is_empty() {
                    break;
                }

                for item in claims {
                    let ok = client
                        .delivery_success(DeliverySuccessParams {
                            delivery_id: item.id.to_string(),
                            claim_nonce: item.claim_nonce,
                        })
                        .await?;
                    if ok {
                        processed += 1;
                    }
                }
            }
            Ok::<usize, Box<dyn std::error::Error + Send + Sync>>(processed)
        });
    }

    let mut total_processed = 0;
    while let Some(res) = tasks.join_next().await {
        total_processed += res??;
    }

    assert_eq!(total_processed, total_events);
    let dsim = journal.compute_dsim();
    assert_eq!(dsim, 0, "Dsim must remain 0 under heavy 10-worker concurrency");

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, total_events);
    assert_eq!(balance.pending, 0);

    Ok(())
}
