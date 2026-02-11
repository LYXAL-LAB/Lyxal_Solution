use std::collections::HashMap;
use std::time::Duration;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::types::{ProviderKind, SocialAction};

pub type HttpHeaders = HashMap<String, String>;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HttpMethod {
	Get,
	Post,
	Put,
	Delete,
	Patch,
}

#[derive(Debug, Clone)]
pub struct HttpRequest {
	pub method: HttpMethod,
	pub url: String,
	pub headers: HttpHeaders,
	pub body: Option<Vec<u8>>,
	pub timeout: Duration,
	pub allow_redirects: bool,
}

#[derive(Debug, Clone)]
pub struct HttpResponse {
	pub status: u16,
	pub headers: HttpHeaders,
	pub body: Vec<u8>,
	pub request_id: Option<String>,
}

pub trait HttpClient: Send + Sync {
	fn send(&self, request: HttpRequest) -> SocialResult<HttpResponse>;
}

/// Client fictif qui renvoie systématiquement une erreur contrôlée.
#[derive(Debug, Default, Clone)]
pub struct NoopHttpClient;

impl HttpClient for NoopHttpClient {
	fn send(&self, _request: HttpRequest) -> SocialResult<HttpResponse> {
		Err(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::Unknown),
			SocialAction::Connect,
			"HTTP client non configuré",
		))
	}
}

