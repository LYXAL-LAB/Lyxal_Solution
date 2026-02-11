use std::time::{Duration, SystemTime};

use serde::Serialize;

use crate::capabilities::Capabilities;
use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::providers::Provider;
use crate::runtime::oauth::{is_expired, OAuthClient, OAuthTokenSet};
use crate::runtime::rate_limit::RateLimiter;
use crate::runtime::secret_store::{SecretKey, SecretStore};
use crate::runtime::{HttpClient, HttpHeaders, HttpMethod, HttpRequest, HttpResponse};
use crate::types::{ProviderAccountKey, ProviderKind, SocialAction};

const ACCESS_TOKEN_LABEL: &str = "access_token";
const REFRESH_TOKEN_LABEL: &str = "refresh_token";
const EXPIRES_AT_LABEL: &str = "expires_at";
const SCOPE_PUBLISH: &str = "scope_publish";
const SCOPE_STATS: &str = "scope_stats";
const TIKTOK_API_BASE: &str = "https://open.tiktokapis.com/v2";

#[allow(dead_code)]
pub struct TikTokProvider<H: HttpClient, S: SecretStore, R: RateLimiter, O: OAuthClient> {
	http: H,
	secrets: S,
	rate_limiter: R,
	oauth: O,
	user_agent: String,
	timeout: Duration,
}

impl<H, S, R, O> TikTokProvider<H, S, R, O>
where
	H: HttpClient,
	S: SecretStore,
	R: RateLimiter,
	O: OAuthClient,
{
	pub fn new(http: H, secrets: S, rate_limiter: R, oauth: O) -> Self {
		Self {
			http,
			secrets,
			rate_limiter,
			oauth,
			user_agent: "lyxal-social-core/tiktok".to_string(),
			timeout: Duration::from_secs(10),
		}
	}

	pub fn connect_with_tokens(
		&self,
		account: &ProviderAccountKey,
		token_set: OAuthTokenSet,
		scope_publish: bool,
		scope_stats: bool,
	) -> SocialResult<()> {
		let base = SecretKey::new(self.kind(), &account.logical_account, "");
		self.secrets.put(
			SecretKey {
				label: ACCESS_TOKEN_LABEL.to_string(),
				..base.clone()
			},
			token_set.access_token,
		)?;
		self.secrets.put(
			SecretKey {
				label: REFRESH_TOKEN_LABEL.to_string(),
				..base.clone()
			},
			token_set.refresh_token,
		)?;
		self.secrets.put(
			SecretKey {
				label: EXPIRES_AT_LABEL.to_string(),
				..base.clone()
			},
			token_set
				.expires_at
				.duration_since(SystemTime::UNIX_EPOCH)
				.map_err(|_| {
					SocialError::new(
						SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
						Some(self.kind()),
						SocialAction::Connect,
						"expiration invalide",
					)
				})?
				.as_secs()
				.to_string(),
		)?;
		self.secrets.put(
			SecretKey {
				label: SCOPE_PUBLISH.to_string(),
				..base.clone()
			},
			scope_publish.to_string(),
		)?;
		self.secrets.put(
			SecretKey {
				label: SCOPE_STATS.to_string(),
				..base
			},
			scope_stats.to_string(),
		)?;
		Ok(())
	}

	fn tokens(&self, account: &ProviderAccountKey) -> SocialResult<OAuthTokenSet> {
		let base = SecretKey::new(self.kind(), &account.logical_account, "");
		let access = self
			.secrets
			.get(&SecretKey {
				label: ACCESS_TOKEN_LABEL.to_string(),
				..base.clone()
			})?
			.ok_or_else(|| {
				SocialError::new(
					SocialErrorCode::SOCIAL_NOT_CONNECTED,
					Some(self.kind()),
					SocialAction::Publish,
					"token manquant",
				)
			})?;
		let refresh = self
			.secrets
			.get(&SecretKey {
				label: REFRESH_TOKEN_LABEL.to_string(),
				..base.clone()
			})?
			.ok_or_else(|| {
				SocialError::new(
					SocialErrorCode::SOCIAL_NOT_CONNECTED,
					Some(self.kind()),
					SocialAction::Publish,
					"refresh token manquant",
				)
			})?;
		let expires_at = self
			.secrets
			.get(&SecretKey {
				label: EXPIRES_AT_LABEL.to_string(),
				..base
			})?
			.ok_or_else(|| {
				SocialError::new(
					SocialErrorCode::SOCIAL_NOT_CONNECTED,
					Some(self.kind()),
					SocialAction::Publish,
					"expiration manquante",
				)
			})?;

		let ts_secs = expires_at.parse::<u64>().map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
				Some(self.kind()),
				SocialAction::Publish,
				"timestamp invalide",
			)
		})?;

		Ok(OAuthTokenSet {
			access_token: access,
			refresh_token: refresh,
			expires_at: SystemTime::UNIX_EPOCH + std::time::Duration::from_secs(ts_secs),
		})
	}

	fn capability_flags(&self, account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		let base = SecretKey::new(self.kind(), &account.logical_account, "");
		let publish = self
			.secrets
			.get(&SecretKey {
				label: SCOPE_PUBLISH.to_string(),
				..base.clone()
			})?
			.unwrap_or_else(|| "false".to_string())
			== "true";
		let stats = self
			.secrets
			.get(&SecretKey {
				label: SCOPE_STATS.to_string(),
				..base
			})?
			.unwrap_or_else(|| "false".to_string())
			== "true";
		Ok(Capabilities::tiktok(publish, stats))
	}

	fn ensure_token_fresh(
		&self,
		account: &ProviderAccountKey,
		tokens: OAuthTokenSet,
	) -> SocialResult<OAuthTokenSet> {
		if is_expired(&tokens, SystemTime::now()) {
			let caps = self.capability_flags(account)?;
			let refreshed = self
				.oauth
				.refresh(self.kind(), &tokens)
				.map_err(|_| {
					SocialError::new(
						SocialErrorCode::SOCIAL_TOKEN_REFRESH_FAILED,
						Some(self.kind()),
						SocialAction::Publish,
						"refresh token échoué",
					)
				})?;
			self.connect_with_tokens(account, refreshed.clone(), caps.publish, caps.stats)?;
			return Ok(refreshed);
		}
		Ok(tokens)
	}

	fn build_request(
		&self,
		action: SocialAction,
		path: &str,
		body: Option<Vec<u8>>,
		token: &str,
	) -> SocialResult<HttpRequest> {
		let url = format!("{TIKTOK_API_BASE}{path}");
		if !url.starts_with("https://") {
			return Err(SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(self.kind()),
				action,
				"url non sécurisée",
			));
		}
		let mut headers: HttpHeaders = HttpHeaders::new();
		headers.insert("Authorization".into(), format!("Bearer {token}"));
		headers.insert("Content-Type".into(), "application/json".into());
		headers.insert("User-Agent".into(), self.user_agent.clone());
		Ok(HttpRequest {
			method: HttpMethod::Post,
			url,
			headers,
			body,
			timeout: self.timeout,
			allow_redirects: false,
		})
	}

	fn map_response(&self, action: SocialAction, response: HttpResponse) -> SocialResult<()> {
		match response.status {
			200..=299 => Ok(()),
			401 | 403 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_PERMISSION_DENIED,
				Some(self.kind()),
				action,
				"permission refusée TikTok",
			)
			.with_request_id_opt(response.request_id)),
			400 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
				Some(self.kind()),
				action,
				"requête invalide TikTok",
			)
			.with_request_id_opt(response.request_id)),
			429 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_RATE_LIMITED,
				Some(self.kind()),
				action,
				"quota dépassé TikTok",
			)
			.with_request_id_opt(response.request_id)),
			500..=599 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_PROVIDER_ERROR,
				Some(self.kind()),
				action,
				"erreur serveur TikTok",
			)
			.with_request_id_opt(response.request_id)),
			_ => Err(SocialError::new(
				SocialErrorCode::SOCIAL_PROVIDER_ERROR,
				Some(self.kind()),
				action,
				"réponse TikTok non gérée",
			)
			.with_request_id_opt(response.request_id)),
		}
	}

	fn capability_guard(
		&self,
		account: &ProviderAccountKey,
		required: impl FnOnce(Capabilities) -> bool,
		action: SocialAction,
		desc: &str,
	) -> SocialResult<Capabilities> {
		let caps = self.capabilities(account)?;
		if !required(caps) {
			return Err(SocialError::new(
				SocialErrorCode::SOCIAL_ACTION_NOT_SUPPORTED,
				Some(self.kind()),
				action,
				desc,
			));
		}
		Ok(caps)
	}
}

impl<H, S, R, O> Provider for TikTokProvider<H, S, R, O>
where
	H: HttpClient,
	S: SecretStore,
	R: RateLimiter,
	O: OAuthClient,
{
	fn kind(&self) -> ProviderKind {
		ProviderKind::TikTok
	}

	fn capabilities(&self, account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		self.capability_flags(account)
	}

	fn publish(&self, account: &ProviderAccountKey, payload: &str) -> SocialResult<()> {
		self.capability_guard(account, |c| c.publish, SocialAction::Publish, "capability publish absente")?;
		if payload.trim().is_empty() {
			return Err(SocialError::new(
				SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
				Some(self.kind()),
				SocialAction::Publish,
				"payload vide",
			));
		}

		self.rate_limiter.acquire(&self.rate_limit_key(account))?;
		let tokens = self.tokens(account)?;
		let fresh = self.ensure_token_fresh(account, tokens)?;
		let body = serde_json::to_vec(&PublishPayload { payload }).map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(self.kind()),
				SocialAction::Publish,
				"serialization JSON échouée",
			)
		})?;
		let request =
			self.build_request(SocialAction::Publish, "/post/publish/", Some(body), &fresh.access_token)?;
		let response = self.http.send(request)?;
		self.map_response(SocialAction::Publish, response)
	}

	fn fetch_stats(&self, account: &ProviderAccountKey) -> SocialResult<()> {
		self.capability_guard(account, |c| c.stats, SocialAction::FetchStats, "capability stats absente")?;
		self.rate_limiter.acquire(&self.rate_limit_key(account))?;
		let tokens = self.tokens(account)?;
		let fresh = self.ensure_token_fresh(account, tokens)?;
		let request =
			self.build_request(SocialAction::FetchStats, "/post/stats/", None, &fresh.access_token)?;
		let response = self.http.send(request)?;
		self.map_response(SocialAction::FetchStats, response)
	}
}

#[derive(Serialize)]
struct PublishPayload<'a> {
	payload: &'a str,
}

trait RequestIdExt {
	fn with_request_id_opt(self, request_id: Option<String>) -> Self;
}

impl RequestIdExt for SocialError {
	fn with_request_id_opt(mut self, request_id: Option<String>) -> Self {
		self.request_id = request_id;
		self
	}
}

