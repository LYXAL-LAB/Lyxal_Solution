use std::sync::{Arc, Mutex};

use lyxal_social_core::capabilities::Capabilities;
use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::discord::DiscordProvider;
use lyxal_social_core::providers::Provider;
use lyxal_social_core::runtime::rate_limit::NoopRateLimiter;
use lyxal_social_core::runtime::secret_store::InMemorySecretStore;
use lyxal_social_core::runtime::{HttpClient, HttpMethod, HttpRequest, HttpResponse};
use lyxal_social_core::types::{ProviderAccountKey, ProviderKind};
use serde_json::Value;

fn account() -> ProviderAccountKey {
	ProviderAccountKey {
		provider: ProviderKind::Discord,
		logical_account: "logical".into(),
	}
}

#[test]
fn discord_capabilities_messages_only() {
	let provider = DiscordProvider::new(MockHttp::default(), InMemorySecretStore::default(), NoopRateLimiter);
	let caps = provider
		.capabilities(&account())
		.expect("capabilities Discord");
	assert_eq!(caps, Capabilities::discord_messages_only());
}

#[test]
fn discord_send_message_requires_token() {
	let provider = DiscordProvider::new(MockHttp::default(), InMemorySecretStore::default(), NoopRateLimiter);
	let err = provider
		.send_message(&account(), "chan", "hello")
		.expect_err("pas de token => erreur attendue");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_NOT_CONNECTED);
}

#[test]
fn discord_send_message_builds_proper_request() {
	let http = MockHttp::with_responses(vec![HttpResponse {
		status: 200,
		headers: Default::default(),
		body: Vec::new(),
		request_id: Some("req-123".into()),
	}]);
	let secrets = InMemorySecretStore::default();
	let provider = DiscordProvider::new(http.clone(), secrets.clone(), NoopRateLimiter);
	let acc = account();
	provider.store_bot_token(&acc, "bot_token").unwrap();

	provider.send_message(&acc, "123", "hello world").unwrap();

	let captured = http.captured();
	assert_eq!(captured.len(), 1);
	let req = &captured[0];
	assert!(req.url.ends_with("/channels/123/messages"));
	assert_eq!(req.method, HttpMethod::Post);
	assert_eq!(
		req.headers.get("Authorization").map(String::as_str),
		Some("Bot bot_token")
	);
	assert_eq!(
		req.headers.get("Content-Type").map(String::as_str),
		Some("application/json")
	);
	let body: Value = serde_json::from_slice(req.body.as_ref().unwrap()).unwrap();
	assert_eq!(body["content"], "hello world");
}

#[test]
fn discord_send_message_maps_401_to_permission_denied() {
	let http = MockHttp::with_responses(vec![HttpResponse {
		status: 401,
		headers: Default::default(),
		body: Vec::new(),
		request_id: Some("req-unauth".into()),
	}]);
	let secrets = InMemorySecretStore::default();
	let provider = DiscordProvider::new(http, secrets.clone(), NoopRateLimiter);
	let acc = account();
	provider.store_bot_token(&acc, "invalid").unwrap();

	let err = provider
		.send_message(&acc, "123", "test")
		.expect_err("401 doit échouer");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
	assert_eq!(err.request_id.as_deref(), Some("req-unauth"));
}

#[test]
fn discord_send_message_maps_429_to_rate_limited() {
	let http = MockHttp::with_responses(vec![HttpResponse {
		status: 429,
		headers: Default::default(),
		body: Vec::new(),
		request_id: Some("req-rl".into()),
	}]);
	let secrets = InMemorySecretStore::default();
	let provider = DiscordProvider::new(http, secrets.clone(), NoopRateLimiter);
	let acc = account();
	provider.store_bot_token(&acc, "token").unwrap();

	let err = provider
		.send_message(&acc, "123", "test")
		.expect_err("429 doit échouer");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
	assert_eq!(err.request_id.as_deref(), Some("req-rl"));
}

#[derive(Clone, Default)]
struct MockHttp {
	responses: Arc<Mutex<Vec<HttpResponse>>>,
	calls: Arc<Mutex<Vec<HttpRequest>>>,
}

impl MockHttp {
	fn with_responses(responses: Vec<HttpResponse>) -> Self {
		Self {
			responses: Arc::new(Mutex::new(responses)),
			calls: Arc::new(Mutex::new(Vec::new())),
		}
	}

	fn captured(&self) -> Vec<HttpRequest> {
		self.calls.lock().unwrap().clone()
	}
}

impl HttpClient for MockHttp {
	fn send(&self, req: HttpRequest) -> SocialResult<HttpResponse> {
		self.calls.lock().unwrap().push(req);
		let resp = self
			.responses
			.lock()
			.unwrap()
			.remove(0);
		Ok(resp)
	}
}
