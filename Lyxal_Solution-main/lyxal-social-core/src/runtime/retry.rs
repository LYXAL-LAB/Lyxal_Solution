#[derive(Debug, Clone, Copy)]
pub struct RetryPolicy {
	pub max_attempts: u32,
	pub base_delay_ms: u64,
	pub max_delay_ms: u64,
}

impl RetryPolicy {
	pub const fn new(max_attempts: u32, base_delay_ms: u64, max_delay_ms: u64) -> Self {
		Self {
			max_attempts,
			base_delay_ms,
			max_delay_ms,
		}
	}

	pub fn should_retry(&self, status: u16, attempt: u32) -> bool {
		if attempt >= self.max_attempts {
			return false;
		}
		matches!(status, 429 | 500..=599)
	}

	pub fn next_delay_ms(&self, attempt: u32) -> u64 {
		let exp = self.base_delay_ms.saturating_mul(2u64.saturating_pow(attempt));
		exp.min(self.max_delay_ms)
	}
}

impl Default for RetryPolicy {
	fn default() -> Self {
		Self::new(4, 200, 5_000)
	}
}

