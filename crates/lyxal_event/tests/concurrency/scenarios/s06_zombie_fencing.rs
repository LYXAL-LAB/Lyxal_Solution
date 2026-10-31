//! Scenario S-06: Zombie fencing across 3 categories of late mutations
//!
//! Evaluates:
//! - Category C-1: Expired lease, same nonce, item still in 'processing'.
//! - Category C-2: Item claimed by another worker (new claim_nonce, new lease_owner).
//! - Category C-3: Item already transitioned to terminal state ('delivered' or 'dead_letter').
//!
//! Salve requirement: At least 50 late mutations tested.
//! Target metric: M_rejet = 100% (all late zombie mutations rejected without modifying database state).

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, inject_pending_deliveries},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::{BenchWorkerClient, ClaimBatchParams, DeliverySuccessParams},
};
use std::time::Duration;

/// S-06: Fencing exhaustif de workers zombies (50 mutations tardives réparties sur C-1, C-2, C-3).
pub async fn run_scenario_s06() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    // Inject 50 events to cover at least 50 zombie attempts
    let total_items = 50;
    let _inserted = inject_pending_deliveries(&db, &sub_id, total_items).await?;

    let zombie_worker = BenchWorkerClient::new(db.clone(), "worker-zombie", journal.clone());
    let legit_worker = BenchWorkerClient::new(db.clone(), "worker-legit", journal.clone());

    // 1. Initial claim by zombie worker with short lease (200ms)
    let claims = zombie_worker
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: total_items,
            lease_duration_ms: 200,
            claim_request_id: "req-zombie-initial".into(),
        })
        .await?;
    assert_eq!(claims.len(), total_items);

    // Let the initial lease expire completely
    tokio::time::sleep(Duration::from_millis(350)).await;

    // Partition into 3 categories:
    // C-1: items 0..15 (still processing in DB, but lease expired)
    // C-2: items 15..35 (reclaimed by legit_worker with new nonce)
    // C-3: items 35..50 (reclaimed by legit_worker AND marked delivered)

    // Reclaim C-2 and C-3 by legit worker
    let mut reclaimed = Vec::new();
    loop {
        let batch = legit_worker
            .claim_batch(ClaimBatchParams {
                subscription_id: sub_id.clone(),
                batch_size: 35,
                lease_duration_ms: 5000,
                claim_request_id: "req-legit-reclaim".into(),
            })
            .await?;
        if batch.is_empty() {
            break;
        }
        reclaimed.extend(batch);
        if reclaimed.len() >= 35 {
            break;
        }
    }

    // For C-3 (the last 15 of reclaimed), legit worker finalizes delivery
    for item in reclaimed.iter().skip(20) {
        let ok = legit_worker
            .delivery_success(DeliverySuccessParams {
                delivery_id: item.id.to_string(),
                claim_nonce: item.claim_nonce.clone(),
            })
            .await?;
        assert!(ok);
    }

    // 2. Salve of 50 zombie mutations from zombie_worker
    let mut rejected_count = 0;
    for claim in &claims {
        let result = zombie_worker
            .delivery_success(DeliverySuccessParams {
                delivery_id: claim.id.to_string(),
                claim_nonce: claim.claim_nonce.clone(),
            })
            .await?;

        if !result {
            rejected_count += 1;
        }
    }

    assert_eq!(
        rejected_count, total_items,
        "All 50 zombie mutations must be rejected"
    );

    let m_rejet = journal.compute_m_rejet();
    assert!(
        (m_rejet - 100.0).abs() < f64::EPSILON,
        "M_rejet must be strictly 100.0%"
    );

    // Audit terminal state: legit delivered items remain delivered, C-1 and C-2 uncorrupted
    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, 15, "Only the 15 legit items in C-3 were marked delivered");

    Ok(())
}
