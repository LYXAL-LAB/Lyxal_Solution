use std::time::{Duration, SystemTime};

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::types::{ProviderKind, SocialAction};

#[derive(Debug, Clone)]
pub struct OAuthTokenSet {
	pub access_token: String,
	pub refresh_token: String,
	pub expires_at: SystemTime,
}

pub trait OAuthClient: Send + Sync {
	fn refresh(
		&self,
		provider: ProviderKind,
		current: &OAuthTokenSet,
	) -> SocialResult<OAuthTokenSet>;
}

/// Implémentation fictive qui signale l’absence de backend OAuth réel.
#[derive(Debug, Default, Clone)]
pub struct NoopOAuthClient;

impl OAuthClient for NoopOAuthClient {
	fn refresh(
		&self,
		provider: ProviderKind,
		_current: &OAuthTokenSet,
	) -> SocialResult<OAuthTokenSet> {
		Err(SocialError::new(
			SocialErrorCode::SOCIAL_TOKEN_REFRESH_FAILED,
			Some(provider),
			SocialAction::Connect,
			"OAuth client non configuré",
		))
	}
}

pub fn is_expired(tokens: &OAuthTokenSet, now: SystemTime) -> bool {
	now >= tokens.expires_at
}

pub fn extend_expiry(seconds: u64) -> SystemTime {
	SystemTime::now() + Duration::from_secs(seconds)
}

