#![forbid(unsafe_code)]
#![deny(clippy::unwrap_used, clippy::expect_used)]

pub mod bootstrap;
pub mod config;
pub mod context;
pub mod database;
pub mod error;
pub mod health;
pub mod http;
pub mod metrics;
pub mod modules;
pub mod runtime;
pub mod shutdown;
pub mod telemetry;

pub use bootstrap::run;
