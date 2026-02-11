use crate::capabilities::Capabilities;
use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::rate_limit::RateLimitKey;
use crate::types::{ProviderAccountKey, ProviderKind, SocialAction};

pub mod discord;
pub mod linkedin;
pub mod meta;
pub mod tiktok;
pub mod snapchat;
pub mod youtube;
pub mod x;
pub mod google_business;
pub mod discord_api;
pub mod tiktok_api;
pub mod meta_api;
pub mod linkedin_api;
pub mod snapchat_api;
pub mod youtube_api;
pub mod x_api;
pub mod google_business_api;

pub trait Provider: Send + Sync {
	fn kind(&self) -> ProviderKind;
	fn capabilities(&self, account: &ProviderAccountKey) -> SocialResult<Capabilities>;

	fn connect(&self, _account: &ProviderAccountKey) -> SocialResult<()> {
		Err(self.unsupported(SocialAction::Connect))
	}

	fn disconnect(&self, _account: &ProviderAccountKey) -> SocialResult<()> {
		Err(self.unsupported(SocialAction::Disconnect))
	}

	fn publish(&self, _account: &ProviderAccountKey, _payload: &str) -> SocialResult<()> {
		Err(self.unsupported(SocialAction::Publish))
	}

	fn send_message(&self, _account: &ProviderAccountKey, _channel_id: &str, _content: &str) -> SocialResult<()> {
		Err(self.unsupported(SocialAction::SendMessage))
	}

	fn fetch_messages(&self, _account: &ProviderAccountKey) -> SocialResult<Vec<String>> {
		Err(self.unsupported(SocialAction::FetchMessages))
	}

	fn fetch_comments(&self, _account: &ProviderAccountKey) -> SocialResult<Vec<String>> {
		Err(self.unsupported(SocialAction::FetchComments))
	}

	fn fetch_stats(&self, _account: &ProviderAccountKey) -> SocialResult<()> {
		Err(self.unsupported(SocialAction::FetchStats))
	}

	fn rate_limit_key(&self, account: &ProviderAccountKey) -> RateLimitKey {
		RateLimitKey {
			provider: self.kind(),
			logical_account: account.logical_account.clone(),
		}
	}

	fn unsupported(&self, action: SocialAction) -> SocialError {
		SocialError::new(
			SocialErrorCode::SOCIAL_ACTION_NOT_SUPPORTED,
			Some(self.kind()),
			action,
			"action non supportée",
		)
	}
}

pub type ProviderActionResult<T = ()> = SocialResult<T>;

