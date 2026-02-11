use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::x_api::*;
use lyxal_social_core::runtime::http::{HttpClient, HttpMethod, HttpRequest, HttpResponse};

#[derive(Clone)]
struct MockHttp {
	reqs: Arc<Mutex<Vec<HttpRequest>>>,
	resp: HttpResponse,
}

impl MockHttp {
	fn with_response(status: u16, body: serde_json::Value) -> Self {
		Self {
			reqs: Arc::new(Mutex::new(Vec::new())),
			resp: HttpResponse {
				status,
				headers: Default::default(),
				body: serde_json::to_vec(&body).unwrap(),
				request_id: None,
			},
		}
	}

	fn captured(&self) -> Vec<HttpRequest> {
		self.reqs.lock().unwrap().clone()
	}
}

impl HttpClient for MockHttp {
	fn send(&self, req: HttpRequest) -> SocialResult<HttpResponse> {
		self.reqs.lock().unwrap().push(req);
		Ok(self.resp.clone())
	}
}

#[test]
fn tweets_create_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"1"}));
	let _ = x_tweets_create(&client, "tok", "hello").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("hello"));
}

#[test]
fn tweets_delete_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = x_tweets_delete(&client, "tok", "1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn likes_create_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = x_likes_create(&client, "tok", "u1", "t1").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("t1"));
}

#[test]
fn search_recent_query() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = x_search_recent(&client, "tok", "rust", Some("n1")).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("query=rust"));
	assert!(url.contains("next_token=n1"));
}

#[test]
fn stream_rules_update_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let body = serde_json::json!({"add":[{"value":"rust"}]});
	let _ = x_stream_rules_update(&client, "tok", body).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let b = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(b.contains("rust"));
}

#[test]
fn users_by_username_path() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":{}}));
	let _ = x_users_by_username(&client, "tok", "jack").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("/by/username/jack"));
}

#[test]
fn follows_delete_url() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = x_follows_delete(&client, "tok", "src", "dst").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("src/following/dst"));
}

#[test]
fn media_init_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"media_id_string":"m1"}));
	let _ = x_media_init_upload(&client, "tok", 123, "video/mp4").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("INIT"));
	assert!(body.contains("video/mp4"));
}

#[test]
fn media_append_base64() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = x_media_append_upload(&client, "tok", "m1", 0, b"abc").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("APPEND"));
	assert!(body.contains("YWJj")); // base64 of abc
}

#[test]
fn dm_send_to_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"dm1"}));
	let _ = x_dm_send_to(&client, "tok", "p1", "hi").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("recipient_id"));
	assert!(body.contains("hi"));
}

#[test]
fn compliance_create_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"job"}));
	let _ = x_compliance_create_job(&client, "tok", "tweets").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("tweets"));
}

#[test]
fn aaa_register_webhook_url_param() {
	let client = MockHttp::with_response(200, serde_json::json!({"ok":true}));
	let _ = x_aaa_register_webhook(&client, "tok", "dev", "https://cb").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("account_activity"));
	assert!(url.contains("webhooks"));
}

#[test]
fn aaa_delete_webhook_maps_401() {
	let client = MockHttp::with_response(401, serde_json::json!({}));
	let err = x_aaa_delete_webhook(&client, "tok", "dev", "w1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

