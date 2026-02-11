//! Stratégie de retry/backoff.

use chrono::{DateTime, Duration, Utc};
use crate::task::RetryStrategy;
use rand::Rng;

/// Backoff avancé avec support des stratégies linéaire/exponentielle et du jitter.
pub fn compute_advanced_backoff(
    attempts: u32,
    strategy: &RetryStrategy,
    base_delay: u64,
    max_delay: u64,
) -> Duration {
    if attempts == 0 {
        return Duration::zero();
    }

    let mut rng = rand::thread_rng();
    // Jitter entre 80% et 120% pour lisser la charge (Phase 3.2)
    let jitter_factor = rng.gen_range(0.8..1.2);

    let secs = match strategy {
        RetryStrategy::Linear => base_delay * (attempts as u64),
        RetryStrategy::Exponential => {
            // 2^(attempts-1) * base_delay
            let exponential_factor = 2_u64.saturating_pow(attempts.saturating_sub(1).min(30));
            base_delay.saturating_mul(exponential_factor)
        }
    };

    let with_jitter = (secs as f64 * jitter_factor) as u64;
    let capped = with_jitter.min(max_delay).max(1);
    
    Duration::seconds(capped as i64)
}

/// Backoff exponentiel simple, plafonné à 5 minutes (Legacy support).
pub fn compute_backoff(attempts: u32) -> Duration {
    compute_advanced_backoff(attempts, &RetryStrategy::Exponential, 2, 300)
}

pub fn next_retry_time(now: DateTime<Utc>, attempts: u32) -> DateTime<Utc> {
    now + compute_backoff(attempts)
}
