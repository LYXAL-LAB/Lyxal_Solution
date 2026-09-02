//! # Module Health Engine (Lyxal Runtime V1.7)
//!
//! Fournit le moteur de supervision de santé du Runtime local :
//! - [`HealthStatus`], [`GlobalHealthStatus`]
//! - [`HealthCheckResult`], [`ModuleHealthCheck`]
//! - [`HealthRegistry`]
//! - [`HealthConfig`], [`HealthEngine`]
//! - [`HealthSnapshot`], [`HealthTransition`]
//! - [`HealthStore`], [`SurrealHealthStore`], [`MemoryHealthStore`]

pub mod check;
pub mod engine;
pub mod registry;
pub mod snapshot;
pub mod status;
pub mod store;

pub use check::{chrono_now_string, HealthCheckResult, ModuleHealthCheck};
pub use engine::{HealthConfig, HealthEngine};
pub use registry::HealthRegistry;
pub use snapshot::{HealthSnapshot, HealthTransition};
pub use status::{GlobalHealthStatus, HealthStatus};
pub use store::{HealthStore, MemoryHealthStore, SurrealHealthStore};
