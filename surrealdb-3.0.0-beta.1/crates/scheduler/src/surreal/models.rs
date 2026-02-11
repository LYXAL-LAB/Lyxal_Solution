use chrono::{DateTime, Utc};
use serde::Deserialize;
use serde_json::Value;

#[derive(Debug, Deserialize)]
pub struct SurrealJob {
    pub id: String,
    pub name: String,
    pub cron: String,
    pub max_retries: i64,
    pub attempts: i64,
    pub payload: Value,
    pub enabled: bool,
    pub next_run: DateTime<Utc>,
    pub instance_id: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct SurrealHistory {
    pub job_id: String,
    pub result: Value,
    pub timestamp: DateTime<Utc>,
    pub duration_ms: i64,
}

#[derive(Debug, Deserialize)]
pub struct SurrealDeadLetter {
    pub job_id: String,
    pub reason: String,
    pub failed_payload: Value,
    pub timestamp: DateTime<Utc>,
}
