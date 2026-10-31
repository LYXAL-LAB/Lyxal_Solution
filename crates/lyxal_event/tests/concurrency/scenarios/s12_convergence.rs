//! Scenario S-12: System convergence and conservation protocol across 6 ordered phases
//!
//! Evaluates the complete lifecycle under multi-worker chaos and verifies strict conservation:
//! - Phase 1: Freeze injections and capture initial ledger count N.
//! - Phase 2: Drain processing and retries with recalibrated timeout (20s).
//! - Phase 3: Verify progressive convergence toward terminal states.
//! - Phase 4: Definitive halt of new claims and lease renewals.
//! - Phase 5: Final silence wait derived from max persisted locked_until, verify 0 active leases.
//! - Phase 6: Final ledger conservation audit:
//!   N == Delivered + DeadLetter
//!   Failed == 0, Processing == 0, Pending == 0.

use crate::concurrency::harness::{
    fixtures::{create_test_db, generate_sub_id, inject_pending_deliveries},
    journal::AuditJournal,
    probe::AdminProbe,
    worker_client::{
        BenchWorkerClient, ClaimBatchParams, DeadLetterParams, DeliveryFailureParams,
        DeliverySuccessParams,
    },
};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::task::JoinSet;

/// S-12: Protocole complet de convergence ordonné en 6 phases.
pub async fn run_scenario_s12() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let db = create_test_db().await?;
    let journal = AuditJournal::new();
    let probe = AdminProbe::new(db.clone());
    let sub_id = generate_sub_id();

    // -------------------------------------------------------------
    // PHASE 1: Arrêt des injections et fixation du périmètre initial
    // -------------------------------------------------------------
    let total_injected = 60;
    let _ids = inject_pending_deliveries(&db, &sub_id, total_injected).await?;
    let initial_balance = probe.audit_balance().await?;
    assert_eq!(
        initial_balance.pending, total_injected,
        "Phase 1: Initial ledger must match injected count"
    );
    let n_initial = initial_balance.total_deliveries;

    // Control flags
    let halt_new_claims = Arc::new(AtomicBool::new(false));

    // Launch 4 workers processing items with simulated failures and dead letters
    let num_workers = 4;
    let mut worker_tasks = JoinSet::new();

    for w_idx in 0..num_workers {
        let db_cloned = db.clone();
        let journal_cloned = journal.clone();
        let sub_cloned = sub_id.clone();
        let halt_flag = halt_new_claims.clone();
        let worker_name = format!("worker-s12-{w_idx}");

        worker_tasks.spawn(async move {
            let client = BenchWorkerClient::new(db_cloned, worker_name, journal_cloned);
            let mut iter = 0;

            while !halt_flag.load(Ordering::Relaxed) {
                iter += 1;
                let claims = client
                    .claim_batch(ClaimBatchParams {
                        subscription_id: sub_cloned.clone(),
                        batch_size: 5,
                        lease_duration_ms: 2000,
                        claim_request_id: format!("req-s12-{iter}"),
                    })
                    .await?;

                if claims.is_empty() {
                    tokio::time::sleep(Duration::from_millis(50)).await;
                    continue;
                }

                for item in claims {
                    // Simulate: 70% success, 20% transient failure, 10% dead-letter
                    let hash_val = (item.id.to_string().chars().last().unwrap_or('0') as u32 + w_idx) % 10;
                    if hash_val < 7 {
                        let _ = client
                            .delivery_success(DeliverySuccessParams {
                                delivery_id: item.id.to_string(),
                                claim_nonce: item.claim_nonce,
                            })
                            .await;
                    } else if hash_val < 9 {
                        let _ = client
                            .delivery_failure(DeliveryFailureParams {
                                delivery_id: item.id.to_string(),
                                claim_nonce: item.claim_nonce,
                                error_code: "TRANSIENT_ERR".into(),
                                retry_after_ms: 100,
                            })
                            .await;
                    } else {
                        let _ = client
                            .dead_letter(DeadLetterParams {
                                delivery_id: item.id.to_string(),
                                claim_nonce: item.claim_nonce,
                                reason: "FATAL_ERR".into(),
                            })
                            .await;
                    }
                }
            }
            Ok::<(), Box<dyn std::error::Error + Send + Sync>>(())
        });
    }

    // -------------------------------------------------------------
    // PHASE 2 & 3: Drain des traitements avec timeout recalibré (20s)
    // -------------------------------------------------------------
    let drain_start = Instant::now();
    let recalibrated_timeout = Duration::from_secs(20);
    let mut converged = false;

    while drain_start.elapsed() < recalibrated_timeout {
        let b = probe.audit_balance().await?;
        if b.pending == 0 && b.processing == 0 {
            converged = true;
            break;
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }

    assert!(
        converged,
        "Phase 2 & 3: Drain must complete within recalibrated 20s timeout"
    );

    // -------------------------------------------------------------
    // PHASE 4: Arrêt définitif des nouveaux claims et renouvellements
    // -------------------------------------------------------------
    halt_new_claims.store(true, Ordering::Relaxed);
    while let Some(res) = worker_tasks.join_next().await {
        res??;
    }

    // -------------------------------------------------------------
    // PHASE 5: Attente du silence final depuis max(locked_until)
    // -------------------------------------------------------------
    if let Some(max_until) = probe.audit_max_locked_until().await? {
        // Wait until server clock exceeds max_until
        loop {
            let passed: Option<bool> = db
                .query("RETURN time::now() > <datetime> $target + 100ms;")
                .bind(("target", max_until.clone()))
                .await?
                .take(0)?;
            if passed.unwrap_or(true) {
                break;
            }
            tokio::time::sleep(Duration::from_millis(50)).await;
        }
    }

    let active_leases = probe.audit_active_leases().await?;
    assert_eq!(
        active_leases, 0,
        "Phase 5: Zero active leases must remain after silence interval"
    );

    // -------------------------------------------------------------
    // PHASE 6: Vérification du bilan terminal et bilan de conservation
    // -------------------------------------------------------------
    let final_balance = probe.audit_balance().await?;

    assert_eq!(
        final_balance.pending, 0,
        "Phase 6: Pending deliveries must be strictly 0"
    );
    assert_eq!(
        final_balance.processing, 0,
        "Phase 6: Processing deliveries must be strictly 0"
    );
    assert_eq!(
        final_balance.failed, 0,
        "Phase 6: Failed deliveries must be strictly 0 (all resolved or dead-lettered)"
    );

    let terminal_count = final_balance.delivered + final_balance.dead_letter;
    assert_eq!(
        terminal_count, n_initial,
        "Phase 6: Strict conservation: N_initial ({}) == Delivered ({}) + DeadLetter ({})",
        n_initial, final_balance.delivered, final_balance.dead_letter
    );

    let dsim = journal.compute_dsim();
    assert_eq!(dsim, 0, "Dsim must be 0 across the entire S-12 execution");

    Ok(())
}
