use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::types::{ProviderKind, SocialAction};

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct RateLimitKey {
	pub provider: ProviderKind,
	pub logical_account: String,
}

pub trait RateLimiter: Send + Sync {
	fn acquire(&self, key: &RateLimitKey) -> SocialResult<()>;
}

#[derive(Debug, Default, Clone)]
pub struct NoopRateLimiter;

impl RateLimiter for NoopRateLimiter {
	fn acquire(&self, _key: &RateLimitKey) -> SocialResult<()> {
		Ok(())
	}
}

#[derive(Debug, Clone)]
pub struct InMemoryRateLimiter {
	state: Arc<Mutex<HashMap<RateLimitKey, Instant>>>,
	min_interval: Duration,
}

impl InMemoryRateLimiter {
	pub fn new(min_interval: Duration) -> Self {
		Self {
			state: Arc::new(Mutex::new(HashMap::new())),
			min_interval,
		}
	}
}

impl RateLimiter for InMemoryRateLimiter {
	fn acquire(&self, key: &RateLimitKey) -> SocialResult<()> {
		let mut guard = self.state.lock().map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(key.provider),
				SocialAction::Connect,
				"mutex empoisonné",
			)
		})?;

		let now = Instant::now();
		if let Some(last) = guard.get(key) {
			if now.duration_since(*last) < self.min_interval {
				return Err(SocialError::new(
					SocialErrorCode::SOCIAL_RATE_LIMITED,
					Some(key.provider),
					SocialAction::Connect,
					"quota dépassé",
				));
			}
		}
		guard.insert(key.clone(), now);
		Ok(())
	}
}

