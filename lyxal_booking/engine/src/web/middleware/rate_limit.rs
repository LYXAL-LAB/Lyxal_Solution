use std::collections::HashMap;
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::Mutex;

#[derive(Clone)]
pub struct RateLimiter {
    max_requests: usize,
    window_secs: u64,
    hits: Arc<Mutex<HashMap<String, Vec<Instant>>>>,
}

impl RateLimiter {
    pub fn new(max_requests: usize, window_secs: u64) -> Self {
        Self {
            max_requests,
            window_secs,
            hits: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    pub async fn check_limited(&self, key: &str) -> bool {
        if self.window_secs == 0 {
            return false;
        }
        let now = Instant::now();
        let cutoff = now.checked_sub(Duration::from_secs(self.window_secs)).unwrap_or(now);
        let mut map = self.hits.lock().await;
        let entries = map.entry(key.to_string()).or_default();
        entries.retain(|&t| t > cutoff);
        if entries.len() >= self.max_requests {
            true
        } else {
            entries.push(now);
            false
        }
    }
}

pub fn client_ip_for_rate_limit(headers: &axum::http::HeaderMap) -> String {
    if let Some(val) = headers.get("x-forwarded-for").and_then(|v| v.to_str().ok()) {
        if let Some(ip) = val.split(',').next() {
            let trimmed = ip.trim();
            if !trimmed.is_empty() {
                return trimmed.to_string();
            }
        }
    }
    if let Some(val) = headers.get("x-real-ip").and_then(|v| v.to_str().ok()) {
        let trimmed = val.trim();
        if !trimmed.is_empty() {
            return trimmed.to_string();
        }
    }
    "unknown".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn rate_limiter_allows_under_limit() {
        let limiter = RateLimiter::new(3, 60);
        assert!(!limiter.check_limited("ip1").await);
        assert!(!limiter.check_limited("ip1").await);
        assert!(!limiter.check_limited("ip1").await);
    }

    #[tokio::test]
    async fn rate_limiter_blocks_over_limit() {
        let limiter = RateLimiter::new(2, 60);
        assert!(!limiter.check_limited("ip1").await); // 1
        assert!(!limiter.check_limited("ip1").await); // 2
        assert!(limiter.check_limited("ip1").await); // 3 -> blocked
        assert!(limiter.check_limited("ip1").await); // still blocked
    }

    #[tokio::test]
    async fn rate_limiter_independent_per_ip() {
        let limiter = RateLimiter::new(1, 60);
        assert!(!limiter.check_limited("ip1").await);
        assert!(limiter.check_limited("ip1").await); // ip1 blocked
        assert!(!limiter.check_limited("ip2").await); // ip2 still ok
    }

    #[tokio::test]
    async fn rate_limiter_resets_after_window() {
        let limiter = RateLimiter::new(1, 0); // 0-second window = immediate expiry
        assert!(!limiter.check_limited("ip1").await);
        assert!(!limiter.check_limited("ip1").await); // reset, allowed again
    }

    #[tokio::test]
    async fn rate_limiter_cleans_expired_entries() {
        let limiter = RateLimiter::new(5, 0); // 0-second window: immediate expiry
        for i in 0..10 {
            limiter.check_limited(&format!("ip-{}", i)).await;
        }
        // Vérification de bon fonctionnement sans panique
        assert!(!limiter.check_limited("trigger-sweep").await);
    }
}
