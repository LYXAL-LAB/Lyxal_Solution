//! Moteur de scheduler basé sur des expressions cron (phase 1 standalone).
//! Ce crate fournit un cœur de planification simple avec exécution asynchrone.

pub mod api;
pub mod cron_parser;
pub mod dead_letter;
pub mod dispatcher;
pub mod errors;
pub mod executor;
pub mod history;
pub mod instance;
pub mod instance_manager;
pub mod persistence;
pub mod retry;
pub mod scheduler;
pub mod supervisor;
pub mod task;
pub mod timeout;
pub mod worker;
pub mod worker_pool;

#[cfg(feature = "surreal")]
pub mod surreal;

// Re-exports pour faciliter l'utilisation
pub use persistence::{TaskStore, InMemoryStore};
pub use scheduler::Scheduler;
pub use executor::JobExecutor;
