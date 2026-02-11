//! Encapsulation du parsing cron.

use chrono::{DateTime, Utc};
use chrono_tz::Tz;
use cron::Schedule;
use std::str::FromStr;

use crate::errors::SchedulerError;

pub fn parse_cron(expr: &str) -> Result<Schedule, SchedulerError> {
    Schedule::from_str(expr).map_err(|_| SchedulerError::InvalidCron)
}

pub fn next_after(schedule: &Schedule, from: DateTime<Utc>, timezone: &str) -> Option<DateTime<Utc>> {
    let tz: Tz = timezone.parse().unwrap_or(chrono_tz::UTC);
    
    // Convert current UTC time to the target timezone
    let local_from = from.with_timezone(&tz);
    
    // Get next occurrence in that timezone
    // cron::Schedule::after works with DateTime<Tz>
    schedule.after(&local_from).next().map(|dt| dt.with_timezone(&Utc))
}
