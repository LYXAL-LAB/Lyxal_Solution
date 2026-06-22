//! Simple per-connector rate limiter using a sliding window.
//!
//! Each connector has a `RateLimitConfig` defining `requests` (max count)
//! and `per_ms` (window size in milliseconds). This module enforces the
//! limit by tracking recent request timestamps per connector name.

use std::collections::VecDeque;
use std::sync::{LazyLock, Mutex};
use std::time::Instant;

use crate::lyxal_core_connector::err::ConnectorError;

/// Global rate limit state, keyed by connector name.
///
/// Each entry holds a `VecDeque<Instant>` representing the timestamps
/// of recent requests within the sliding window.
static RATE_LIMITERS: LazyLock<Mutex<std::collections::HashMap<String, VecDeque<Instant>>>> =
    LazyLock::new(|| Mutex::new(std::collections::HashMap::new()));

/// Checks the rate limit for a connector and records a new request.
///
/// Returns `Ok(())` if the request is allowed, or
/// `Err(ConnectorError::RateLimitExceeded)` if the limit is exceeded.
///
/// # Arguments
/// * `connector_name` — Name of the connector (used as the limiter key)
/// * `max_requests` — Maximum number of requests allowed in the window
/// * `window_ms` — Window size in milliseconds
pub fn check_rate_limit(
    connector_name: &str,
    max_requests: u32,
    window_ms: u64,
) -> Result<(), ConnectorError> {
    let now = Instant::now();
    let window = std::time::Duration::from_millis(window_ms);

    let mut limiters = RATE_LIMITERS.lock().unwrap_or_else(|e| e.into_inner());

    let timestamps = limiters
        .entry(connector_name.to_string())
        .or_insert_with(VecDeque::new);

    // Purge timestamps outside the current window
    while let Some(&front) = timestamps.front() {
        if now.duration_since(front) > window {
            timestamps.pop_front();
        } else {
            break;
        }
    }

    // Check if we're at the limit
    if timestamps.len() >= max_requests as usize {
        return Err(ConnectorError::RateLimitExceeded {
            connector: connector_name.to_string(),
            limit: max_requests,
            per_ms: window_ms,
        });
    }

    // Record this request
    timestamps.push_back(now);

    Ok(())
}
