use std::time::Duration;

use serde::Serialize;

use crate::capabilities::Capabilities;
use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::providers::Provider;
use crate::runtime::rate_limit::RateLimiter;
use crate::runtime::secret_store::{SecretKey, SecretStore};
use crate::runtime::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderAccountKey, ProviderKind, SocialAction};

const DISCORD_BOT_TOKEN_LABEL: &str = "bot_token";
const DISCORD_API_BASE: &str = "https://discord.com/api/v10";

#[allow(dead_code)]
pub struct DiscordProvider<H: HttpClient, S: SecretStore, R: RateLimiter> {
	http: H,
	secrets: S,
	rate_limiter: R,
	user_agent: String,
	timeout: Duration,
}

impl<H: HttpClient, S: SecretStore, R: RateLimiter> DiscordProvider<H, S, R> {
	pub fn new(http: H, secrets: S, rate_limiter: R) -> Self {
		Self {
			http,
			secrets,
			rate_limiter,
			user_agent: "lyxal-social-core/discord".to_string(),
			timeout: Duration::from_secs(10),
		}
	}

	pub fn store_bot_token(
		&self,
		account: &ProviderAccountKey,
		bot_token: &str,
	) -> SocialResult<()> {
		let key = SecretKey::new(self.kind(), &account.logical_account, DISCORD_BOT_TOKEN_LABEL);
		self.secrets.put(key, bot_token.to_string())
	}

	fn bot_token(&self, account: &ProviderAccountKey) -> SocialResult<String> {
		let key = SecretKey::new(self.kind(), &account.logical_account, DISCORD_BOT_TOKEN_LABEL);
		self.secrets.get(&key)?.ok_or_else(|| {
			SocialError::new(
				SocialErrorCode::SOCIAL_NOT_CONNECTED,
				Some(self.kind()),
				SocialAction::SendMessage,
				"bot token manquant",
			)
		})
	}
}

impl<H: HttpClient, S: SecretStore, R: RateLimiter> Provider for DiscordProvider<H, S, R> {
	fn kind(&self) -> ProviderKind {
		ProviderKind::Discord
	}

	fn capabilities(&self, _account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		Ok(Capabilities::discord_messages_only())
	}

	fn send_message(
		&self,
		account: &ProviderAccountKey,
		channel_id: &str,
		content: &str,
	) -> SocialResult<()> {
		self.rate_limiter.acquire(&self.rate_limit_key(account))?;
		let _token = self.bot_token(account)?;
		validate_channel(channel_id, self.kind())?;
		validate_content(content, self.kind())?;

		let request = self.build_send_request(channel_id, content, account)?;
		let response = self.http.send(request)?;
		self.map_send_response(response)
	}
}

fn validate_channel(channel_id: &str, provider: ProviderKind) -> SocialResult<()> {
	if channel_id.trim().is_empty() {
		return Err(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(provider),
			SocialAction::SendMessage,
			"channel_id vide",
		));
	}
	Ok(())
}

fn validate_content(content: &str, provider: ProviderKind) -> SocialResult<()> {
	if content.trim().is_empty() {
		return Err(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(provider),
			SocialAction::SendMessage,
			"contenu vide",
		));
	}
	Ok(())
}

#[derive(Serialize)]
struct DiscordMessagePayload<'a> {
	content: &'a str,
}

impl<H: HttpClient, S: SecretStore, R: RateLimiter> DiscordProvider<H, S, R> {
	fn build_send_request(
		&self,
		channel_id: &str,
		content: &str,
		account: &ProviderAccountKey,
	) -> SocialResult<HttpRequest> {
		let token = self.bot_token(account)?;
		let url = format!("{DISCORD_API_BASE}/channels/{channel_id}/messages");
		if !url.starts_with("https://") {
			return Err(SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(self.kind()),
				SocialAction::SendMessage,
				"url non sécurisée",
			));
		}

		let payload =
			serde_json::to_vec(&DiscordMessagePayload { content }).map_err(|_| {
				SocialError::new(
					SocialErrorCode::SOCIAL_INTERNAL_ERROR,
					Some(self.kind()),
					SocialAction::SendMessage,
					"serialization JSON échouée",
				)
			})?;

		let mut headers: HttpHeaders = HttpHeaders::new();
		headers.insert("Authorization".into(), format!("Bot {token}"));
		headers.insert("Content-Type".into(), "application/json".into());
		headers.insert("User-Agent".into(), self.user_agent.clone());

		Ok(HttpRequest {
			method: HttpMethod::Post,
			url,
			headers,
			body: Some(payload),
			timeout: self.timeout,
			allow_redirects: false,
		})
	}

	fn map_send_response(&self, response: crate::runtime::HttpResponse) -> SocialResult<()> {
		let code = response.status;
		match code {
			200..=299 => Ok(()),
			401 | 403 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_PERMISSION_DENIED,
				Some(self.kind()),
				SocialAction::SendMessage,
				"token invalide ou accès refusé",
			)
			.with_request_id_opt(response.request_id)),
			429 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_RATE_LIMITED,
				Some(self.kind()),
				SocialAction::SendMessage,
				"discord a renvoyé 429",
			)
			.with_request_id_opt(response.request_id)),
			400..=499 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
				Some(self.kind()),
				SocialAction::SendMessage,
				"requête Discord invalide",
			)
			.with_request_id_opt(response.request_id)),
			500..=599 => Err(SocialError::new(
				SocialErrorCode::SOCIAL_PROVIDER_ERROR,
				Some(self.kind()),
				SocialAction::SendMessage,
				"erreur serveur Discord",
			)
			.with_request_id_opt(response.request_id)),
			_ => Err(SocialError::new(
				SocialErrorCode::SOCIAL_PROVIDER_ERROR,
				Some(self.kind()),
				SocialAction::SendMessage,
				"réponse Discord non gérée",
			)
			.with_request_id_opt(response.request_id)),
		}
	}
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

