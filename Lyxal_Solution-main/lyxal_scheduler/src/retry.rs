//! Stratégie de retry/backoff.

use chrono::{DateTime, Duration, Utc};

/// Backoff exponentiel simple, plafonné à 5 minutes.
pub fn compute_backoff(attempts: u32) -> Duration {
    let secs = 2_u64
        .saturating_pow(attempts.min(20)) // éviter overflow
        .max(1);
    let capped = secs.min(5 * 60); // 5 minutes max
    Duration::seconds(capped as i64)
}

pub fn next_retry_time(now: DateTime<Utc>, attempts: u32) -> DateTime<Utc> {
    now + compute_backoff(attempts)
}
