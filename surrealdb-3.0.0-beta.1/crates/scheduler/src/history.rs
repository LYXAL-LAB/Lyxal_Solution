//! Historisation des exécutions.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
// use uuid::Uuid; // Removed unused import

use crate::task::JobResult;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct JobHistory {
    pub job_id: String,
    pub result: JobResult,
    pub timestamp: DateTime<Utc>,
    pub duration_ms: u64,
}
