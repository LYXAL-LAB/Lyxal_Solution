use lyxal_scheduler::executor::{JobExecutor, MockExecutor};
use lyxal_scheduler::task::{Job, JobResult};
use serde_json::json;

#[tokio::test]
async fn mock_executor_success() {
    let exec = MockExecutor;
    let job = Job::new("ok", "* * * * * *", 1, json!({ "force_status": "success" })).unwrap();
    let res = exec.execute(&job).await.unwrap();
    assert_eq!(res, JobResult::Success);
}

#[tokio::test]
async fn mock_executor_failed_with_reason() {
    let exec = MockExecutor;
    let job = Job::new(
        "fail",
        "* * * * * *",
        1,
        json!({ "force_status": "failed", "reason": "nope" }),
    )
    .unwrap();
    let res = exec.execute(&job).await.unwrap();
    assert_eq!(res, JobResult::Failed("nope".into()));
}

#[tokio::test]
async fn mock_executor_timeout() {
    let exec = MockExecutor;
    let job = Job::new(
        "timeout",
        "* * * * * *",
        1,
        json!({ "force_status": "timeout" }),
    )
    .unwrap();
    let res = exec.execute(&job).await.unwrap();
    assert_eq!(res, JobResult::Timeout);
}
