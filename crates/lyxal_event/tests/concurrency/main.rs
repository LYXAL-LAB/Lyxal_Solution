//! Concurrency benchmark integration test runner for lyxal_event Lot 2.
//!
//! Note: All experimental scenarios and hypothesis test runners are marked with
//! `#[ignore = "Requires explicit CTO execution mandate"]` to strictly comply with
//! the CTO instruction: COMPILATION ONLY until authorization.

pub mod harness;
pub mod hypotheses;
pub mod scenarios;
pub mod server_transaction_bench;
pub mod deterministic_lock_bench;

pub mod concurrency {
    pub use crate::harness;
    pub use crate::hypotheses;
    pub use crate::scenarios;
}

#[test]
fn bench_target_compilation_smoke_check() {
    // Pure compilation verification
    let _ = true;
}

// Hypotheses wrappers (Porte 1 autorisée nominativement)
#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h01_latched_read() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    let ok = hypotheses::h01_h02_atomic_update::test_hypothesis_h01(&db)
        .await
        .unwrap();
    assert!(ok, "H-01 validation failed: Latched read / single winner exclusivity not met");
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h02_row_uuid() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    let ok = hypotheses::h01_h02_atomic_update::test_hypothesis_h02(&db, 20)
        .await
        .unwrap();
    assert!(ok, "H-02 validation failed: Row-level UUID v7 nonces not all unique");
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h03_sdk_transport() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    hypotheses::h03_h05_transport_time::test_hypothesis_h03(&db, 10)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h05_server_time() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    let ok = hypotheses::h03_h05_transport_time::test_hypothesis_h05(&db)
        .await
        .unwrap();
    assert!(ok, "H-05 validation failed");
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h06_multi_statement() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    let ok = hypotheses::h06_h08_txn_feeds::test_hypothesis_h06(&db)
        .await
        .unwrap();
    assert!(ok, "H-06 validation failed: Multi-statement atomic rollback on THROW not met");
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h07_client_transactions() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    let res = hypotheses::h07_client_transactions::verify_h07_feasibility(&db)
        .await
        .unwrap();
    println!("\n[H-07 RÉSUMÉ FAISABILITÉ] {:?}", res);
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_server_transaction_investigation() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    let (_pass_count, fail_count, _zero_count, _mvcc_count) =
        server_transaction_bench::run_step2_server_transactions(&db, 1)
            .await
            .unwrap();
    server_transaction_bench::run_step3_function_transactional_probe(&db)
        .await
        .unwrap();
    assert_eq!(fail_count, 0, "Double confirmation detected during server transaction benchmark");
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_deterministic_claim_lock_investigation() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    
    // Phase 1.1 : 2 workers (100 itérations)
    let (pass2, fail2, _zero2, rejections2) =
        deterministic_lock_bench::run_phase1_two_workers(&db, 100)
            .await
            .unwrap();
    assert_eq!(fail2, 0, "Double confirmation detected in 2-worker deterministic lock phase");
    assert_eq!(pass2, 100, "Expected 100 single winners in 2-worker phase");
    assert_eq!(rejections2, 100, "Expected 100 AlreadyExists rejections in 2-worker phase");

    // Phase 1.2 : 10 workers saturation (100 itérations)
    let (pass10, fail10, _zero10, rejections10) =
        deterministic_lock_bench::run_phase1_ten_workers(&db, 100)
            .await
            .unwrap();
    assert_eq!(fail10, 0, "Double confirmation detected in 10-worker saturation phase");
    assert_eq!(pass10, 100, "Expected 100 single winners in 10-worker saturation phase");
    assert_eq!(rejections10, 900, "Expected 900 AlreadyExists rejections in 10-worker saturation phase");
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_hypothesis_h08_change_feeds() {
    let db = harness::fixtures::create_test_db().await.unwrap();
    hypotheses::h06_h08_txn_feeds::test_hypothesis_h08(&db)
        .await
        .unwrap();
}

// Scenarios S-01 to S-12 wrappers (Strictement interdits en Porte 1)
#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s01_nominal() {
    scenarios::s01_to_s03_load::run_scenario_s01()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s02_nominal_concurrency() {
    scenarios::s01_to_s03_load::run_scenario_s02()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s03_heavy_concurrency() {
    scenarios::s01_to_s03_load::run_scenario_s03()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s04_worker_crash() {
    scenarios::s04_s05_crash_lease::run_scenario_s04()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s05_lease_renew() {
    scenarios::s04_s05_crash_lease::run_scenario_s05()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s06_zombie_fencing() {
    scenarios::s06_zombie_fencing::run_scenario_s06()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s07_point_contention() {
    scenarios::s07_s08_contention::run_scenario_s07()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s08_mvcc_jitter() {
    scenarios::s07_s08_contention::run_scenario_s08()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s09_in_doubt_recovery() {
    scenarios::s09_in_doubt_recovery::run_scenario_s09()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s10_dead_letter_conflict() {
    scenarios::s10_s11_admin_purge::run_scenario_s10()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s11_admin_purge() {
    scenarios::s10_s11_admin_purge::run_scenario_s11()
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "Requires explicit CTO execution mandate"]
async fn bench_scenario_s12_system_convergence() {
    scenarios::s12_convergence::run_scenario_s12()
        .await
        .unwrap();
}
