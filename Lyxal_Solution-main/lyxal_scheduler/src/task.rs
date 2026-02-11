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
pub enum JobResult {
    Success,
    Failed(String),
    Timeout,
}

#[derive(Debug, Clone, Serialize)]
pub struct Job {
    pub id: Uuid,
    pub name: String,
    pub cron: String,
    #[serde(skip)]
    pub schedule: Schedule,
    pub max_retries: u32,
    pub attempts: u32,
    pub payload: Value,
    pub enabled: bool,
    pub next_run: DateTime<Utc>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub instance_id: Option<InstanceId>,
    #[serde(default)]
    pub priority: i32,
}

impl Job {
    pub fn new(
        name: impl Into<String>,
        cron: impl Into<String>,
        max_retries: u32,
        payload: Value,
    ) -> Result<Self, SchedulerError> {
        let cron_expr = cron.into();
        let schedule = parse_cron(&cron_expr)?;
        let now = Utc::now();
        let next_run = next_after(&schedule, now).ok_or(SchedulerError::InvalidCron)?;

        Ok(Self {
            id: Uuid::new_v4(),
            name: name.into(),
            cron: cron_expr,
            schedule,
            max_retries,
            attempts: 0,
            payload,
            enabled: true,
            next_run,
            instance_id: None,
            priority: 0,
        })
    }

    pub fn recompute_next_run(&mut self, from: DateTime<Utc>) {
        if let Some(next) = next_after(&self.schedule, from) {
            self.next_run = next;
        } else {
            self.enabled = false;
        }
    }
}

#[derive(Deserialize)]
struct JobSerde {
    id: Uuid,
    name: String,
    cron: String,
    max_retries: u32,
    attempts: u32,
    payload: Value,
    enabled: bool,
    next_run: DateTime<Utc>,
    #[serde(default)]
    instance_id: Option<InstanceId>,
    #[serde(default)]
    priority: i32,
}

impl<'de> Deserialize<'de> for Job {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let data = JobSerde::deserialize(deserializer)?;
        let schedule = parse_cron(&data.cron).map_err(de::Error::custom)?;
        let mut job = Job {
            id: data.id,
            name: data.name,
            cron: data.cron,
            schedule,
            max_retries: data.max_retries,
            attempts: data.attempts,
            payload: data.payload,
            enabled: data.enabled,
            next_run: data.next_run,
            instance_id: data.instance_id,
            priority: data.priority,
        };
        job.recompute_next_run(job.next_run);
        Ok(job)
    }
}
