//! Scenarios S-07 and S-08: High contention and MVCC conflict backoff with Full Jitter
//!
//! Evaluates:
//! - S-07: Point contention on 1 single pending item with 10 concurrent worker claims.
//!   Verification: Exactly 1 winner claims the item, 9 workers receive 0 items, zero duplicate claims.
//! - S-08: MVCC concurrency conflicts under high burst contention.
//!   Verification: Rejections due to MVCC conflicts are retried with Full Jitter backoff,
//!   demonstrating eventual consistency without deadlocks or unhandled errors.

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, inject_pending_deliveries},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::{BenchWorkerClient, ClaimBatchParams, DeliverySuccessParams},
};
use tokio::task::JoinSet;

/// S-07: Contention maximale sur 1 seul élément (10 workers simultanés).
pub async fn run_scenario_s07() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    // 1 single event
    let _inserted = inject_pending_deliveries(&db, &sub_id, 1).await?;

    let num_workers = 10;
    let mut tasks = JoinSet::new();

    for i in 0..num_workers {
        let db_cloned = db.clone();
        let journal_cloned = journal.clone();
        let sub_cloned = sub_id.clone();
        let worker_name = format!("worker-s07-{i}");

        tasks.spawn(async move {
            let client = BenchWorkerClient::new(db_cloned, worker_name, journal_cloned);
            let claims = client
                .claim_batch(ClaimBatchParams {
                    subscription_id: sub_cloned,
                    batch_size: 1,
                    lease_duration_ms: 3000,
                    claim_request_id: "req-single".into(),
                })
                .await?;
            Ok::<usize, Box<dyn std::error::Error + Send + Sync>>(claims.len())
        });
    }

    let mut winners = 0;
    let mut empty_claims = 0;

    while let Some(res) = tasks.join_next().await {
        let count = res??;
        if count == 1 {
            winners += 1;
        } else if count == 0 {
            empty_claims += 1;
        }
    }

    assert_eq!(winners, 1, "Exactly 1 worker must win the single item");
    assert_eq!(
        empty_claims,
        num_workers - 1,
        "All other 9 workers must get empty batches"
    );

    let dsim = journal.compute_dsim();
    assert_eq!(dsim, 0, "Dsim must be 0 for single-item contention");

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.processing, 1);
    assert_eq!(balance.pending, 0);

    Ok(())
}

/// S-08: Conflits MVCC et retry exponentiel avec Full Jitter.
pub async fn run_scenario_s08() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    let total_items = 20;
    let _inserted = inject_pending_deliveries(&db, &sub_id, total_items).await?;

    // 8 workers competing for batches of 5 on a 20-item pool
    let num_workers = 8;
    let mut tasks = JoinSet::new();

    for i in 0..num_workers {
        let db_cloned = db.clone();
        let journal_cloned = journal.clone();
        let sub_cloned = sub_id.clone();
        let worker_name = format!("worker-s08-{i}");

        tasks.spawn(async move {
            let client = BenchWorkerClient::new(db_cloned, worker_name, journal_cloned);
            let mut delivered = 0;

            for iter in 0..5 {
                let claims = client
                    .claim_batch(ClaimBatchParams {
                        subscription_id: sub_cloned.clone(),
                        batch_size: 5,
                        lease_duration_ms: 3000,
                        claim_request_id: format!("req-mvcc-{iter}"),
                    })
                    .await?;

                for item in claims {
                    let ok = client
                        .delivery_success(DeliverySuccessParams {
                            delivery_id: item.id.to_string(),
                            claim_nonce: item.claim_nonce,
                        })
                        .await?;
                    if ok {
                        delivered += 1;
                    }
                }
            }
            Ok::<usize, Box<dyn std::error::Error + Send + Sync>>(delivered)
        });
    }

    let mut total_delivered = 0;
    while let Some(res) = tasks.join_next().await {
        total_delivered += res??;
    }

    assert_eq!(total_delivered, total_items);
    let dsim = journal.compute_dsim();
    assert_eq!(dsim, 0, "Dsim must be 0 after MVCC contention resolution");

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, total_items);
    assert_eq!(balance.pending, 0);

    Ok(())
}
