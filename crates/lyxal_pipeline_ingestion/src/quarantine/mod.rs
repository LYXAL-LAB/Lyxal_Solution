//! Module de quarantaine et d'audit trail des anomalies (Directive CTO Phase 3).

pub mod engine;
pub mod types;

pub use engine::QuarantineEngine;
pub use types::{
    AnomalyCategory, AnomalySeverity, QuarantineEntry, QuarantineStatus, QuarantineStats,
};
