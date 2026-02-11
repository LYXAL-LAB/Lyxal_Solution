#![cfg(feature = "surreal")]

use chrono::Utc;
use lyxal_scheduler::errors::SchedulerError;
use lyxal_scheduler::instance::InstanceId;
use lyxal_scheduler::surreal::mapper::{core_job_to_update, surreal_job_to_core};
use lyxal_scheduler::surreal::models::SurrealJob;
use serde_json::json;

#[test]
fn surreal_job_is_mapped_to_core() {
    let sj = SurrealJob {
        id: "00000000-0000-0000-0000-000000000001".into(),
        name: "job1".into(),
        cron: "* * * * * *".into(),
        max_retries: 3,
        attempts: 1,
        payload: json!({"k": "v"}),
        enabled: true,
        next_run: Utc::now(),
        instance_id: Some("tenantA".into()),
    };

    let job = surreal_job_to_core(sj).expect("mapping");
    assert_eq!(job.name, "job1");
    assert_eq!(job.max_retries, 3);
    assert_eq!(job.attempts, 1);
    assert!(job.enabled);
    assert_eq!(job.instance_id, Some(InstanceId("tenantA".into())));
}

#[test]
fn surreal_job_invalid_id_fails() {
    let sj = SurrealJob {
        id: "not-a-uuid".into(),
        name: "job1".into(),
        cron: "* * * * * *".into(),
        max_retries: 3,
        attempts: 1,
        payload: json!({}),
        enabled: true,
        next_run: Utc::now(),
        instance_id: None,
    };

    let res = surreal_job_to_core(sj);
    assert!(matches!(res, Err(SchedulerError::PersistenceError(_))));
}

#[test]
fn core_job_to_update_contains_fields() {
    let sj = SurrealJob {
        id: "00000000-0000-0000-0000-000000000001".into(),
        name: "job1".into(),
        cron: "* * * * * *".into(),
        max_retries: 3,
        attempts: 0,
        payload: json!({"k": "v"}),
        enabled: true,
        next_run: Utc::now(),
        instance_id: None,
    };

    let job = surreal_job_to_core(sj).unwrap();
    let update = core_job_to_update(&job);
    assert_eq!(update["name"], "job1");
    assert_eq!(update["cron"], "* * * * * *");
    assert_eq!(update["max_retries"], 3);
    assert_eq!(update["attempts"], 0);
}
