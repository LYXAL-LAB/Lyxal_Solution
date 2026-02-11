//! Définition des tâches planifiées.

use chrono::{DateTime, Utc};
use cron::Schedule;
use serde::de::{self, Deserializer};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use uuid::Uuid;

use crate::cron_parser::{next_after, parse_cron};
use crate::errors::SchedulerError;
use crate::instance::InstanceId;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum JobResult {
    Success,
    Failed(String),
    Timeout,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum JobStatus {
    Pending,
    Running,
    Failed,
    Dlq,
    Disabled,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum RetryStrategy {
    Linear,
    Exponential,
}

impl Default for RetryStrategy {
    fn default() -> Self {
        Self::Linear
    }
}

impl Default for JobStatus {
    fn default() -> Self {
        Self::Pending
    }
}

impl From<JobStatus> for String {
    fn from(s: JobStatus) -> Self {
        match s {
            JobStatus::Pending => "pending".to_string(),
            JobStatus::Running => "running".to_string(),
            JobStatus::Failed => "failed".to_string(),
            JobStatus::Dlq => "dlq".to_string(),
            JobStatus::Disabled => "disabled".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct Job {
    pub id: String,
    pub name: String,
    pub cron: String,
    pub action: String,
    #[serde(skip)]
    pub schedule: Schedule,
    pub max_retries: u32,
    pub attempts: u32,
    pub payload: Value,
    pub enabled: bool,
    pub status: JobStatus,
    pub next_run: DateTime<Utc>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub instance_id: Option<InstanceId>,
    #[serde(default)]
    pub priority: i32,
    #[serde(default)]
    pub run_as: Option<String>,
    #[serde(default)]
    pub one_shot: bool,
    #[serde(default)]
    pub on_success: Option<String>,
    #[serde(default)]
    pub on_failure: Option<String>,
    #[serde(default)]
    pub idempotency_key: Option<String>, // Bloc 11.1.3
    #[serde(default)]
    pub progress: i32, // Bloc 11.3.2
    #[serde(default)]
    pub timezone: String, // Bloc 11.3.3
    #[serde(default)]
    pub preferred_node: Option<String>, // Bloc 11.2.1
    #[serde(default)]
    pub depends_on: Vec<String>, // Bloc 11.3.1
    #[serde(default)]
    pub critical: bool, // Bloc 12.3
    #[serde(default)]
    pub encrypted: bool, // Phase 2.3
    #[serde(default)]
    pub retry_strategy: RetryStrategy, // Phase 3.2
    #[serde(default)]
    pub retry_base_delay: u64, // Phase 3.2 (seconds)
    #[serde(default)]
    pub retry_max_delay: u64, // Phase 3.2 (seconds)
    #[serde(default)]
    pub state: Value, // Phase 3.3: Saga State
    #[serde(default)]
    pub allow_egress: bool, // Phase 3.4
}

impl Job {
    pub fn new(
        name: impl Into<String>,
        cron: impl Into<String>,
        action: impl Into<String>,
        max_retries: u32,
        payload: Value,
        timezone: impl Into<String>,
    ) -> Result<Self, SchedulerError> {
        let cron_expr = cron.into();
        let timezone_str = timezone.into();
        let schedule = parse_cron(&cron_expr)?;
        let now = Utc::now();
        let next_run = next_after(&schedule, now, &timezone_str).ok_or(SchedulerError::InvalidCron)?;

        Ok(Self {
            id: Uuid::new_v4().to_string(),
            name: name.into(),
            cron: cron_expr,
            action: action.into(),
            schedule,
            max_retries,
            attempts: 0,
            payload,
            enabled: true,
            status: JobStatus::Pending,
            next_run,
            instance_id: None,
            priority: 0,
            run_as: None,
            one_shot: false,
            on_success: None,
            on_failure: None,
            idempotency_key: None,
            progress: 0,
            timezone: timezone_str,
            preferred_node: None,
            depends_on: Vec::new(),
            critical: false,
            encrypted: false,
            retry_strategy: RetryStrategy::Linear,
            retry_base_delay: 60, // 1m
            retry_max_delay: 3600, // 1h
            state: Value::Null, // Phase 3.3
            allow_egress: false, // Phase 3.4 (Default secure)
        })
    }

    pub fn recompute_next_run(&mut self, from: DateTime<Utc>) {
        if self.one_shot {
            self.enabled = false;
            return;
        }
        if let Some(next) = next_after(&self.schedule, from, &self.timezone) {
            self.next_run = next;
        } else {
            self.enabled = false;
        }
    }
}

#[derive(Deserialize)]
struct JobSerde {
    pub id: String,
    pub name: String,
    pub cron: String,
    pub action: String,
    pub max_retries: u32,
    pub attempts: u32,
    pub payload: Value,
    pub enabled: bool,
    #[serde(default)]
    pub status: JobStatus,
    pub next_run: DateTime<Utc>,
    #[serde(default)]
    pub instance_id: Option<InstanceId>,
    #[serde(default)]
    pub priority: i32,
    #[serde(default)]
    pub run_as: Option<String>,
    #[serde(default)]
    pub one_shot: bool,
    #[serde(default)]
    pub on_success: Option<String>,
    #[serde(default)]
    pub on_failure: Option<String>,
    #[serde(default)]
    pub idempotency_key: Option<String>,
    #[serde(default)]
    pub progress: i32,
    #[serde(default)]
    pub timezone: Option<String>,
    #[serde(default)]
    pub preferred_node: Option<String>,
    #[serde(default)]
    pub depends_on: Vec<String>,
    #[serde(default)]
    pub critical: bool,
    #[serde(default)]
    pub encrypted: bool,
    #[serde(default)]
    pub retry_strategy: RetryStrategy,
    #[serde(default)]
    pub retry_base_delay: Value,
    #[serde(default)]
    pub retry_max_delay: Value,
    #[serde(default)]
    pub state: Value,
    #[serde(default)]
    pub allow_egress: bool,
}

impl<'de> Deserialize<'de> for Job {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let data = JobSerde::deserialize(deserializer)?;
        let schedule = parse_cron(&data.cron).map_err(de::Error::custom)?;
        let job = Job {
            id: data.id,
            name: data.name,
            cron: data.cron,
            action: data.action,
            schedule,
            max_retries: data.max_retries,
            attempts: data.attempts,
            payload: data.payload,
            enabled: data.enabled,
            status: data.status,
            next_run: data.next_run,
            instance_id: data.instance_id,
            priority: data.priority,
            run_as: data.run_as,
            one_shot: data.one_shot,
            on_success: data.on_success,
            on_failure: data.on_failure,
            idempotency_key: data.idempotency_key,
            progress: data.progress,
            timezone: data.timezone.unwrap_or_else(|| "UTC".to_string()),
            preferred_node: data.preferred_node,
            depends_on: data.depends_on,
            critical: data.critical,
            encrypted: data.encrypted,
            retry_strategy: data.retry_strategy,
            retry_base_delay: parse_u64_robust(&data.retry_base_delay).unwrap_or(60),
            retry_max_delay: parse_u64_robust(&data.retry_max_delay).unwrap_or(3600),
            state: data.state,
            allow_egress: data.allow_egress,
        };
        Ok(job)
    }
}

fn parse_u64_robust(v: &Value) -> Option<u64> {
    if let Some(n) = v.as_u64() {
        return Some(n);
    }
    if let Some(obj) = v.as_object() {
        // Handle { "secs": 60, ... }
        if let Some(secs) = obj.get("secs").and_then(|s| s.as_u64()) {
            return Some(secs);
        }
        // Handle { "Duration": { "secs": 60, ... } }
        if let Some(secs) = obj.get("Duration").and_then(|d| d.as_object()).and_then(|o| o.get("secs")).and_then(|s| s.as_u64()) {
            return Some(secs);
        }
    }
    if let Some(s) = v.as_str() {
        return s.parse::<u64>().ok();
    }
    None
}
