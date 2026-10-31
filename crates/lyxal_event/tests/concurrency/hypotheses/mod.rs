//! Suite d'expérimentation des hypothèses techniques (H-01 à H-08)
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §5

pub mod h01_h02_atomic_update;
pub mod h03_h05_transport_time;
pub mod h06_h08_txn_feeds;
pub mod h07_client_transactions;

pub use h01_h02_atomic_update::{test_hypothesis_h01, test_hypothesis_h02};
pub use h03_h05_transport_time::{test_hypothesis_h03, test_hypothesis_h05};
pub use h06_h08_txn_feeds::{test_hypothesis_h06, test_hypothesis_h08};
pub use h07_client_transactions::{verify_h07_feasibility, run_h07_controlled_experiment};

