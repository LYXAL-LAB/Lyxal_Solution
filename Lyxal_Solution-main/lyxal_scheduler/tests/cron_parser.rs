use chrono::Utc;
use lyxal_scheduler::cron_parser::{next_after, parse_cron};
use lyxal_scheduler::errors::SchedulerError;

#[test]
fn parse_cron_valid() {
    let schedule = parse_cron("* * * * * *").expect("cron doit être valide");
    let next = next_after(&schedule, Utc::now());
    assert!(next.is_some());
}

#[test]
fn parse_cron_invalid() {
    let schedule = parse_cron("not a cron");
    assert!(matches!(schedule, Err(SchedulerError::InvalidCron)));
}

#[test]
fn next_after_advances() {
    let schedule = parse_cron("* * * * * *").expect("cron valide");
    let now = Utc::now();
    let next = next_after(&schedule, now).expect("prochaine date");
    assert!(next > now);
}
