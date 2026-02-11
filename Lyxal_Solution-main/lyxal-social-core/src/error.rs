use std::fmt;

use crate::types::{ProviderKind, SocialAction};

#[derive(Debug, Clone, PartialEq, Eq)]
#[allow(non_camel_case_types)]
pub enum SocialErrorCode {
	SOCIAL_INVALID_PROVIDER,
	SOCIAL_INVALID_ARGUMENT,
	SOCIAL_NOT_CONNECTED,
	SOCIAL_ACTION_NOT_SUPPORTED,
	SOCIAL_PERMISSION_DENIED,
	SOCIAL_TOKEN_EXPIRED,
	SOCIAL_TOKEN_REFRESH_FAILED,
	SOCIAL_RATE_LIMITED,
	SOCIAL_PROVIDER_ERROR,
	SOCIAL_INTERNAL_ERROR,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SocialError {
	pub code: SocialErrorCode,
	pub provider: Option<ProviderKind>,
	pub action: SocialAction,
	pub message: String,
	pub request_id: Option<String>,
}

pub type SocialResult<T> = Result<T, SocialError>;

impl SocialError {
	pub fn new(
		code: SocialErrorCode,
		provider: Option<ProviderKind>,
		action: SocialAction,
		message: impl Into<String>,
	) -> Self {
		Self {
			code,
			provider,
			action,
			message: message.into(),
			request_id: None,
		}
	}

	pub fn with_request_id(mut self, request_id: impl Into<String>) -> Self {
		self.request_id = Some(request_id.into());
		self
	}
}

impl fmt::Display for SocialError {
	fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
		write!(
			f,
			"[{:?}] provider={:?} action={:?}: {}",
			self.code, self.provider, self.action, self.message
		)
	}
}

impl std::error::Error for SocialError {}

