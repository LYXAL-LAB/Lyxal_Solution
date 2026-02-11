use lyxal_social_core::runtime::retry::RetryPolicy;
use lyxal_social_core::runtime::{InMemoryRateLimiter, RateLimitKey, RateLimiter};
use lyxal_social_core::types::ProviderKind;

#[test]
fn retry_policy_follows_status_rules() {
	let policy = RetryPolicy::default();
	assert!(policy.should_retry(429, 0));
	assert!(policy.should_retry(500, 1));
	assert!(!policy.should_retry(400, 0));
	assert!(!policy.should_retry(500, policy.max_attempts));
	assert!(policy.next_delay_ms(0) <= policy.max_delay_ms);
}

#[test]
fn in_memory_rate_limiter_blocks_fast_reuse() {
	let limiter = InMemoryRateLimiter::new(std::time::Duration::from_millis(200));
	let key = RateLimitKey {
		provider: ProviderKind::Discord,
		logical_account: "acc".to_string(),
	};

	limiter.acquire(&key).expect("premier passage OK");
	let second = limiter.acquire(&key);
	assert!(second.is_err(), "doit bloquer le second passage immédiat");
}

