use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::tiktok_api::*;
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
fn add_data_request_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"request_id":"r1"}));
	let _ = data_portability_add_request(&client, "tok", "user1", vec!["profile".into(), "video".into()]).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"user_id\":\"user1\""));
	assert!(body.contains("\"data_types\""));
}

#[test]
fn check_status_query() {
	let client = MockHttp::with_response(200, serde_json::json!({"status":"ready"}));
	let _ = data_portability_check_status(&client, "tok", "req1").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("request_id=req1"));
}

#[test]
fn cancel_request_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = data_portability_cancel_request(&client, "tok", "req1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn commercial_search_params() {
	let client = MockHttp::with_response(200, serde_json::json!({"items":[]}));
	let _ = commercial_search(&client, "tok", "shoes", Some(2), Some(50)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("query=shoes"));
	assert!(url.contains("page=2"));
	assert!(url.contains("page_size=50"));
}

#[test]
fn commercial_detail_uses_id() {
	let client = MockHttp::with_response(200, serde_json::json!({"item":{}}));
	let _ = commercial_detail(&client, "tok", "id123").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("id=id123"));
}

#[test]
fn webhooks_subscribe_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"subscription_id":"s1"}));
	let _ = webhooks_subscribe(
		&client,
		"tok",
		"https://cb",
		vec!["event".to_string()],
		Some("sec".into()),
	)
	.unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	assert!(req.headers.get("Authorization").is_some());
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("callback_url"));
	assert!(body.contains("events"));
	assert!(body.contains("secret"));
}

#[test]
fn webhooks_unsubscribe_maps_401() {
	let client = MockHttp::with_response(401, serde_json::json!({}));
	let err = webhooks_unsubscribe(&client, "tok", "sub1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

