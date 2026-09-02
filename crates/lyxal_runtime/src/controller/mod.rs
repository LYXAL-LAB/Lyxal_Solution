//! # Module Controller (Lyxal Runtime V1.7)
//!
//! Fournit le contrôleur de réconciliation continue et de supervision de santé :
//! - [`ReconciliationLoopConfig`]
//! - [`ReconciliationBackoff`]
//! - [`RuntimeStatusSnapshot`], [`ReconciliationReportSummary`]
//! - [`ContinuousReconciliationController`]

pub mod backoff;
pub mod config;
#[allow(clippy::module_inception)]
pub mod controller;
pub mod snapshot;

pub use backoff::ReconciliationBackoff;
pub use config::ReconciliationLoopConfig;
pub use controller::ContinuousReconciliationController;
pub use snapshot::{ReconciliationReportSummary, RuntimeStatusSnapshot};
