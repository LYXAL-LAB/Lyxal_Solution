//! Module d'outillage et d'infrastructure de test isolé pour le banc de concurrence
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §2.1

pub mod fixtures;
pub mod journal;
pub mod probe;
pub mod process_supervisor;
pub mod tcp_interceptor;
pub mod worker_client;

pub use fixtures::BenchFixtures;
pub use journal::{ImmutableAuditJournal, ClaimInterval, ZombieAttempt};
pub use probe::{AdminProbe, PartitionCounts};
pub use process_supervisor::ProcessSupervisor;
pub use tcp_interceptor::TcpDropInterceptor;
pub use worker_client::{BenchWorkerClient, ClaimedItem};

