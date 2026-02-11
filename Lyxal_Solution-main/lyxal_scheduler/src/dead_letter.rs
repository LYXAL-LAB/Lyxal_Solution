//! Gestion de la dead-letter queue.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct DeadLetter {
    pub job_id: Uuid,
    pub reason: String,
    pub failed_payload: Value,
    pub timestamp: DateTime<Utc>,
}
