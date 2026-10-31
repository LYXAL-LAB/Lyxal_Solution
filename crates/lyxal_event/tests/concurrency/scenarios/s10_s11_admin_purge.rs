//! Scenarios S-10 and S-11: Dead letter conflict resolution and administrative purge protection
//!
//! Evaluates:
//! - S-10: Concurrency conflict on dead-letter replay. A valid `dead_letter_id` associated with a delivery
//!   whose state was concurrently reactivated to `status = "processing"` with an active lease.
//!   Verification: Replay mutation must be safely rejected without corrupting active lease.
//! - S-11: Administrative purge isolation. Purge operation must only delete terminal, expired records,
//!   leaving active processing leases and pending items untouched.

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, setup_replay_conflict_fixtures},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::{BenchWorkerClient, ClaimBatchParams},
};

/// S-10: Conflit de replay sur dead-letter avec un dead_letter_id valide.
pub async fn run_scenario_s10() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let _journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    // Setup valid dead_letter_id where the underlying delivery is reactivated to 'processing'
    let (delivery_id, dead_letter_id) =
        setup_replay_conflict_fixtures(&db, &sub_id, "active-worker-10").await?;

    // Attempting an administrative replay or state override on an actively leased delivery
    let replay_attempt: Option<serde_json::Value> = db
        .query(
            "UPDATE type::thing('event_delivery', $del_id)
             SET status = 'pending', lease_owner = NONE, claim_nonce = NONE
             WHERE status = 'dead_letter'
             RETURN AFTER;",
        )
        .bind(("del_id", delivery_id.clone()))
        .await?
        .take(0)?;

    assert!(
        replay_attempt.is_none(),
        "Replay mutation must be rejected when delivery is in active 'processing' status"
    );

    // Verify delivery remains in processing with active lease intact
    let active_check: Option<String> = db
        .query("SELECT VALUE status FROM type::thing('event_delivery', $del_id);")
        .bind(("del_id", delivery_id))
        .await?
        .take(0)?;
    assert_eq!(active_check.as_deref(), Some("processing"));

    let balance = probe.audit_balance().await?;
    assert_eq!(balance.processing, 1);
    assert_eq!(balance.dead_letter, 0);

    // Verify dead_letter record still exists in dead letter log table
    let dl_exists: Option<String> = db
        .query("SELECT VALUE id FROM type::thing('event_dead_letter', $dl_id);")
        .bind(("dl_id", dead_letter_id))
        .await?
        .take(0)?;
    assert!(dl_exists.is_some(), "Dead letter log record preserved");

    Ok(())
}

/// S-11: Purge administrative et protection des baux actifs.
pub async fn run_scenario_s11() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    // 1. Inject an item that will be active (processing)
    let _active_ids = crate::concurrency::harness::fixtures::inject_pending_deliveries(
        &db, &sub_id, 1,
    )
    .await?;

    let client = BenchWorkerClient::new(db.clone(), "worker-active-s11", journal.clone());
    let claims = client
        .claim_batch(ClaimBatchParams {
            subscription_id: sub_id.clone(),
            batch_size: 1,
            lease_duration_ms: 10000,
            claim_request_id: "req-active-s11".into(),
        })
        .await?;
    assert_eq!(claims.len(), 1);

    // 2. Inject an item that is already delivered (terminal, eligible for purge)
    let _term: Option<serde_json::Value> = db
        .query(
            "CREATE event_delivery CONTENT {
                event_id: 'evt-term-s11',
                subscription_id: $sub_id,
                status: 'delivered',
                delivery_attempts: 1,
                delivered_at: time::now() - 3600s,
                created_at: time::now() - 3600s
            };",
        )
        .bind(("sub_id", sub_id.clone()))
        .await?
        .take(0)?;

    // 3. Run administrative purge: only delete delivered older than 1800s
    let _deleted: Vec<serde_json::Value> = db
        .query(
            "DELETE event_delivery
             WHERE status = 'delivered'
               AND delivered_at < time::now() - 1800s
             RETURN BEFORE;",
        )
        .await?
        .take(0)?;

    // 4. Verification: Active processing delivery is untouched
    let balance = probe.audit_balance().await?;
    assert_eq!(balance.processing, 1, "Active lease must remain intact");
    assert_eq!(balance.delivered, 0, "Terminal item was purged");

    Ok(())
}
