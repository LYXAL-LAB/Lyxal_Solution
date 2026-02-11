//! Encapsulation du parsing cron.

use chrono::{DateTime, Utc};
use cron::Schedule;
use std::str::FromStr;

use crate::errors::SchedulerError;

pub fn parse_cron(expr: &str) -> Result<Schedule, SchedulerError> {
    Schedule::from_str(expr).map_err(|_| SchedulerError::InvalidCron)
}

pub fn next_after(schedule: &Schedule, from: DateTime<Utc>) -> Option<DateTime<Utc>> {
    schedule.after(&from).next()
}
