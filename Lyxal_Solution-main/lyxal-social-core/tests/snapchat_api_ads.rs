use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::snapchat_api::*;
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
fn list_accounts_with_pagination() {
	let client = MockHttp::with_response(200, serde_json::json!({"accounts":[]}));
	let _ = sc_list_accounts(&client, "tok", Some(50), Some(10)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("limit=50"));
	assert!(url.contains("offset=10"));
}

#[test]
fn create_campaign_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"c1"}));
	let _ = sc_create_campaign(&client, "tok", "acc1", "name").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"name\":\"name\""));
}

#[test]
fn update_adset_patch() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"as1"}));
	let _ = sc_update_adset(&client, "tok", "acc1", "as1", Some("new")).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Patch);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("new"));
}

#[test]
fn create_ad_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"ad1"}));
	let _ = sc_create_ad(&client, "tok", "acc1", "adname").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("adname"));
}

#[test]
fn list_creatives_uses_get() {
	let client = MockHttp::with_response(200, serde_json::json!({"creatives":[]}));
	let _ = sc_list_creatives(&client, "tok", "acc1").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Get);
}

#[test]
fn upload_asset_bytes() {
	let client = MockHttp::with_response(200, serde_json::json!({"asset":"a1"}));
	let _ = sc_upload_asset(&client, "tok", "acc1", b"abc").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	assert_eq!(req.body.as_ref().unwrap(), b"abc");
}

#[test]
fn create_audience_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"aud1"}));
	let _ = sc_create_audience(&client, "tok", "acc1", "aud").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("aud"));
}

#[test]
fn conversions_post_events() {
	let client = MockHttp::with_response(200, serde_json::json!({"status":"ok"}));
	let events = serde_json::json!([{"event_type":"PAGE_VIEW"}]);
	let _ = sc_post_conversions(&client, "tok", "acc1", events).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("events"));
}

#[test]
fn reports_query_param() {
	let client = MockHttp::with_response(200, serde_json::json!({"report_id":"r1"}));
	let _ = sc_reports(&client, "tok", "acc1", "adsquad").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("report_type=adsquad"));
}

#[test]
fn webhooks_status_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = sc_webhooks_status(&client, "tok", "acc1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

