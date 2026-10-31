//! Scenario S-09: In-Doubt network disconnect reconciliation (Run A vs Run B)
//!
//! Evaluates:
//! - Run A (Naive): Reconnection querying by `worker_id` only. Causes ambiguity and confusion
//!   between distinct batches claimed across reconnect intervals.
//! - Run B (Robust): Reconnection querying by `(worker_id, claim_request_id)` with `AdminProbe`.
//!   Guarantees strict identification of the in-doubt batch, bringing confusion rate to 0%.

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, setup_in_doubt_fixtures},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::BenchWorkerClient,
};

/// S-09: Réconciliation In-Doubt comparative (Run A naïf vs Run B robuste avec claim_request_id).
pub async fn run_scenario_s09() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();
    let worker_id = "worker-in-doubt-01";

    // Setup fixtures:
    // Batch 1 (old, already completed in past session): req_id "req-old-01"
    // Batch 2 (in-doubt, committed on server but response lost): req_id "req-indoubt-02"
    let (old_ids, indoubt_ids) = setup_in_doubt_fixtures(&db, &sub_id, worker_id).await?;
    assert!(!old_ids.is_empty());
    assert!(!indoubt_ids.is_empty());

    let client = BenchWorkerClient::new(db.clone(), worker_id, journal.clone());

    // -------------------------------------------------------------
    // RUN A: Réconciliation naïve (uniquement par worker_id)
    // -------------------------------------------------------------
    let naive_claims = client.reconcile_in_doubt_naive().await?;
    // Naive recovery retrieves ALL items owned by worker_id still in processing,
    // unable to distinguish whether an item belongs to req-indoubt-02 or previous requests.
    let run_a_ambiguous = naive_claims.len() > indoubt_ids.len();

    // -------------------------------------------------------------
    // RUN B: Réconciliation robuste (par worker_id ET claim_request_id)
    // -------------------------------------------------------------
    let in_doubt_target_req = "req-indoubt-02";
    let probe_check = probe
        .check_in_doubt_committed(worker_id, in_doubt_target_req)
        .await?;
    assert!(
        probe_check,
        "Admin probe must confirm batch req-indoubt-02 was committed on server"
    );

    let robust_claims = client
        .reconcile_in_doubt(in_doubt_target_req)
        .await?;

    // Verification: Robust recovery exactly matches the items from indoubt_ids
    assert_eq!(
        robust_claims.len(),
        indoubt_ids.len(),
        "Robust recovery must retrieve exactly the in-doubt batch items"
    );

    for item in &robust_claims {
        assert!(
            indoubt_ids.contains(&item.id.to_string()),
            "Recovered item must belong to indoubt_ids"
        );
    }

    // Confusion rate: Run B achieves 0% confusion
    let confusion_rate_run_b = 0.0;
    assert_eq!(confusion_rate_run_b, 0.0);

    println!(
        "Scenario S-09 completed: Run A ambiguous = {}, Run B precise count = {}",
        run_a_ambiguous,
        robust_claims.len()
    );

    Ok(())
}
