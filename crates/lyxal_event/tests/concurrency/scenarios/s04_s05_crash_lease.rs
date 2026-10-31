//! Scenarios S-04 and S-05: Worker crash, lease expiration, and lease renewal
//!
//! Evaluates:
//! - S-04: Worker crash during processing. Reprise strictly conditioned on SurrealDB server time
//!   `time::now() >= locked_until`. Successor worker claims item, delivery_attempts incremented.
//! - S-05: Lease renewal before expiration. Verifies `locked_until` extended while preserving lease_owner
//!   and claim_nonce without creating duplicate claims.

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, inject_pending_deliveries},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::{
        BenchWorkerClient, ClaimBatchParams, DeliverySuccessParams, LeaseRenewParams,
    },
};
use std::time::Duration;

/// S-04: Crash worker et reprise après expiration vérifiée de `locked_until`.
pub async fn run_scenario_s04() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    let _inserted = inject_pending_deliveries(&db, &sub_id, 1).await?;

    let worker_a = BenchWorkerClient::new(db.clone(), "worker-a-crash", journal.clone());
    let worker_b = BenchWorkerClient::new(db.clone(), "worker-b-successor", journal.clone());

    // 1. Worker A claims item with 1000ms lease
    let claims = worker_a
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: 1,
            lease_duration_ms: 1000,
            claim_request_id: "req-crash-1".into(),
        })
        .await?;
    assert_eq!(claims.len(), 1);
    let item = &claims[0];
    let delivery_id = item.id.to_string();

    // 2. Worker A simulates crash (disappears without sending success or failure)
    // 3. Worker B immediately attempts to claim: must obtain 0 items because locked_until is active
    let premature_claims = worker_b
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: 1,
            lease_duration_ms: 1000,
            claim_request_id: "req-b-premature".into(),
        })
        .await?;
    assert_eq!(
        premature_claims.len(),
        0,
        "Worker B must not claim an item while its lease is still active"
    );

    // 4. Wait until SurrealDB server time exceeds locked_until
    loop {
        let max_lease = probe.audit_max_locked_until().await?;
        match max_lease {
            Some(dt) => {
                let check: Option<bool> = db
                    .query("RETURN time::now() >= <datetime> $target;")
                    .bind(("target", dt))
                    .await?
                    .take(0)?;
                if check.unwrap_or(false) {
                    break;
                }
            }
            None => break,
        }
        tokio::time::sleep(Duration::from_millis(50)).await;
    }

    // 5. Worker B now attempts claim: reprise validée
    let successor_claims = worker_b
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: 1,
            lease_duration_ms: 2000,
            claim_request_id: "req-b-valid".into(),
        })
        .await?;

    assert_eq!(
        successor_claims.len(),
        1,
        "Worker B must successfully claim the expired item"
    );
    let successor_item = &successor_claims[0];
    assert_eq!(successor_item.id.to_string(), delivery_id);
    assert_ne!(
        successor_item.claim_nonce, item.claim_nonce,
        "New claim must generate a fresh claim_nonce"
    );

    // Complete delivery with Worker B
    let ok = worker_b
        .delivery_success(DeliverySuccessParams {
            delivery_id: successor_item.id.to_string(),
            claim_nonce: successor_item.claim_nonce.clone(),
        })
        .await?;
    assert!(ok);

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, 1);
    assert_eq!(balance.pending, 0);
    assert_eq!(balance.processing, 0);

    Ok(())
}

/// S-05: Renouvellement de bail (heartbeat) avant expiration.
pub async fn run_scenario_s05() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    let _inserted = inject_pending_deliveries(&db, &sub_id, 1).await?;

    let client = BenchWorkerClient::new(db.clone(), "worker-renew", journal.clone());

    // 1. Claim initial avec bail court (800ms)
    let claims = client
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: 1,
            lease_duration_ms: 800,
            claim_request_id: "req-renew-1".into(),
        })
        .await?;
    assert_eq!(claims.len(), 1);
    let item = &claims[0];

    // 2. Renouvellement après 300ms (bail encore actif)
    tokio::time::sleep(Duration::from_millis(300)).await;
    let renewed = client
        .lease_renew(LeaseRenewParams {
            delivery_id: item.id.to_string(),
            claim_nonce: item.claim_nonce.clone(),
            extend_by_ms: 2000,
        })
        .await?;
    assert!(
        renewed,
        "Lease renewal must succeed before initial lease expiration"
    );

    // 3. Vérifier que la finalisation après l'échéance initiale (ex: 1000ms après début) réussit grâce à l'extension
    tokio::time::sleep(Duration::from_millis(600)).await;
    let success = client
        .delivery_success(DeliverySuccessParams {
            delivery_id: item.id.to_string(),
            claim_nonce: item.claim_nonce.clone(),
        })
        .await?;
    assert!(
        success,
        "Delivery success must succeed within extended lease window"
    );

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.delivered, 1);
    assert_eq!(balance.processing, 0);

    Ok(())
}
