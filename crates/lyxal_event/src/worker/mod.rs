pub mod config;
#[allow(clippy::module_inception)]
pub mod worker;

pub use config::EventWorkerConfig;
pub use worker::{EventWorker, EventWorkerMetrics};
