use chrono::Utc;
use serde_json::{json, Value};
use uuid::Uuid;

use crate::cron_parser::parse_cron;
use crate::errors::SchedulerError;
use crate::instance::InstanceId;
use crate::task::Job;

use super::models::SurrealJob;

pub fn surreal_job_to_core(sj: SurrealJob) -> Result<Job, SchedulerError> {
    let id = Uuid::parse_str(&sj.id)
        .map_err(|_| SchedulerError::PersistenceError("invalid job id".into()))?;

    if sj.max_retries < 0 || sj.attempts < 0 {
        return Err(SchedulerError::PersistenceError(
            "negative retries/attempts".into(),
        ));
    }

    let schedule = parse_cron(&sj.cron)?;
    let mut job = Job {
        id,
        name: sj.name,
        cron: sj.cron,
        schedule,
        max_retries: sj.max_retries as u32,
        attempts: sj.attempts as u32,
        payload: sj.payload,
        enabled: sj.enabled,
        next_run: sj.next_run,
        instance_id: sj.instance_id.map(InstanceId),
    };
    // S'assure que next_run est cohérent avec le schedule.
    job.recompute_next_run(job.next_run);
    Ok(job)
}

pub fn core_job_to_update(job: &Job) -> Value {
    json!({
        "name": job.name,
        "cron": job.cron,
        "max_retries": job.max_retries as i64,
        "attempts": job.attempts as i64,
        "payload": job.payload,
        "enabled": job.enabled,
        "next_run": job.next_run,
        "instance_id": job.instance_id.as_ref().map(|i| i.0.clone()),
        "updated_at": Utc::now(),
    })
}
