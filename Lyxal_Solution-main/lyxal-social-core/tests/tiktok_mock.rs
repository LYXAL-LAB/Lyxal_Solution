use std::sync::{Arc, Mutex};
use std::time::SystemTime;

use lyxal_social_core::capabilities::Capabilities;
use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::tiktok::TikTokProvider;
use lyxal_social_core::providers::Provider;
use lyxal_social_core::runtime::oauth::{extend_expiry, OAuthClient, OAuthTokenSet};
use lyxal_social_core::runtime::rate_limit::NoopRateLimiter;
use lyxal_social_core::runtime::secret_store::InMemorySecretStore;
use lyxal_social_core::runtime::{HttpClient, HttpMethod, HttpRequest, HttpResponse};
use lyxal_social_core::types::{ProviderAccountKey, ProviderKind};
use serde_json::Value;

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

#[derive(Clone, Default)]
struct MockOAuth;

impl OAuthClient for MockOAuth {
	fn refresh(
		&self,
		_provider: ProviderKind,
		current: &OAuthTokenSet,
	) -> lyxal_social_core::error::SocialResult<OAuthTokenSet> {
		Ok(OAuthTokenSet {
			access_token: format!("refresh-{}", current.access_token),
			refresh_token: current.refresh_token.clone(),
			expires_at: extend_expiry(3600),
		})
	}
}

fn account() -> ProviderAccountKey {
	ProviderAccountKey {
		provider: ProviderKind::TikTok,
		logical_account: "tiktok-user".into(),
	}
}

fn token_set(expire_in: u64) -> OAuthTokenSet {
	OAuthTokenSet {
		access_token: "access".into(),
		refresh_token: "refresh".into(),
		expires_at: extend_expiry(expire_in),
	}
}

#[test]
fn tiktok_capabilities_match_scopes() {
	let provider = TikTokProvider::new(
		MockHttp::default(),
		InMemorySecretStore::default(),
		NoopRateLimiter,
		MockOAuth,
	);
	provider
		.connect_with_tokens(&account(), token_set(3600), true, false)
		.expect("stockage tokens");
	let caps = provider
		.capabilities(&account())
		.expect("capabilities TikTok");
	assert_eq!(caps, Capabilities::tiktok(true, false));
}

#[test]
fn tiktok_publish_checks_payload() {
	let provider = TikTokProvider::new(
		MockHttp::default(),
		InMemorySecretStore::default(),
		NoopRateLimiter,
		MockOAuth,
	);
	provider
		.connect_with_tokens(&account(), token_set(1), true, true)
		.expect("stockage tokens");
	let err = provider
		.publish(&account(), " ")
		.expect_err("payload vide doit échouer");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_INVALID_ARGUMENT);
}

#[test]
fn tiktok_publish_builds_request_and_uses_bearer() {
	let http = MockHttp::with_responses(vec![HttpResponse {
		status: 200,
		headers: Default::default(),
		body: Vec::new(),
		request_id: Some("req-ok".into()),
	}]);
	let provider =
		TikTokProvider::new(http.clone(), InMemorySecretStore::default(), NoopRateLimiter, MockOAuth);
	provider
		.connect_with_tokens(&account(), token_set(3600), true, true)
		.unwrap();
	provider.publish(&account(), "video-payload").unwrap();
	let calls = http.captured();
	assert_eq!(calls.len(), 1);
	let req = &calls[0];
	assert!(req.url.ends_with("/post/publish/"));
	assert_eq!(req.method, HttpMethod::Post);
	assert_eq!(
		req.headers.get("Authorization").map(String::as_str),
		Some("Bearer access")
	);
	let body: Value = serde_json::from_slice(req.body.as_ref().unwrap()).unwrap();
	assert_eq!(body["payload"], "video-payload");
}

#[test]
fn tiktok_publish_maps_status_codes() {
	let http = MockHttp::with_responses(vec![
		HttpResponse {
			status: 400,
			headers: Default::default(),
			body: Vec::new(),
			request_id: Some("req-400".into()),
		},
		HttpResponse {
			status: 429,
			headers: Default::default(),
			body: Vec::new(),
			request_id: Some("req-429".into()),
		},
	]);
	let provider =
		TikTokProvider::new(http.clone(), InMemorySecretStore::default(), NoopRateLimiter, MockOAuth);
	provider
		.connect_with_tokens(&account(), token_set(3600), true, true)
		.unwrap();
	let err = provider
		.publish(&account(), "payload")
		.expect_err("400 doit échouer");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_INVALID_ARGUMENT);
	assert_eq!(err.request_id.as_deref(), Some("req-400"));
	let err = provider
		.publish(&account(), "payload")
		.expect_err("429 doit échouer");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
	assert_eq!(err.request_id.as_deref(), Some("req-429"));
}

#[test]
fn tiktok_refreshes_expired_token_and_uses_refreshed_access() {
	let http = MockHttp::with_responses(vec![HttpResponse {
		status: 200,
		headers: Default::default(),
		body: Vec::new(),
		request_id: Some("req-refreshed".into()),
	}]);
	let provider =
		TikTokProvider::new(http.clone(), InMemorySecretStore::default(), NoopRateLimiter, MockOAuth);
	provider
		.connect_with_tokens(&account(), OAuthTokenSet {
			access_token: "expired".into(),
			refresh_token: "refresh".into(),
			expires_at: SystemTime::UNIX_EPOCH,
		}, true, true)
		.expect("stockage tokens expirés");
	let result = provider.publish(&account(), "payload");
	assert!(result.is_ok(), "le refresh mock doit permettre l'action");
	let calls = http.captured();
	let auth = calls[0].headers.get("Authorization").cloned().unwrap();
	assert_eq!(auth, "Bearer refresh-expired");
}

#[test]
fn tiktok_fetch_stats_requires_scope() {
	let provider =
		TikTokProvider::new(MockHttp::default(), InMemorySecretStore::default(), NoopRateLimiter, MockOAuth);
	provider
		.connect_with_tokens(&account(), token_set(3600), true, false)
		.unwrap();
	let err = provider
		.fetch_stats(&account())
		.expect_err("stats non autorisé");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_ACTION_NOT_SUPPORTED);
}

#[test]
fn tiktok_fetch_stats_maps_permission_denied() {
	let http = MockHttp::with_responses(vec![HttpResponse {
		status: 403,
		headers: Default::default(),
		body: Vec::new(),
		request_id: Some("req-403".into()),
	}]);
	let provider =
		TikTokProvider::new(http, InMemorySecretStore::default(), NoopRateLimiter, MockOAuth);
	provider
		.connect_with_tokens(&account(), token_set(3600), false, true)
		.unwrap();
	let err = provider
		.fetch_stats(&account())
		.expect_err("403 doit échouer");
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
	assert_eq!(err.request_id.as_deref(), Some("req-403"));
}
