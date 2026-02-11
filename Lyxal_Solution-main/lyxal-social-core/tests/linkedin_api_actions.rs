use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::linkedin_api::*;
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
fn reactions_create_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"r1"}));
	let _ = li_reactions_create(&client, "tok", "urn:li:person:me", "urn:li:share:1", "LIKE").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("LIKE"));
	assert!(body.contains("urn:li:share:1"));
}

#[test]
fn reactions_list_pagination() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_reactions_list(&client, "tok", "urn:li:share:1", Some(5), Some(10)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("start=5"));
	assert!(url.contains("count=10"));
}

#[test]
fn reactions_delete_maps_401() {
	let client = MockHttp::with_response(401, serde_json::json!({}));
	let err = li_reactions_delete(&client, "tok", "actor", "obj").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

#[test]
fn comments_create_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"c1"}));
	let _ = li_comments_create(&client, "tok", "urn:li:activity:1", "urn:li:person:me", "hello").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("hello"));
	let url = &captured[0].url;
	assert!(url.contains("socialActions/urn:li:activity:1/comments"));
}

#[test]
fn comments_list_pagination() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_comments_list(&client, "tok", "urn:li:activity:1", Some(1), Some(2)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("start=1"));
	assert!(url.contains("count=2"));
}

#[test]
fn comments_delete_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = li_comments_delete(&client, "tok", "c1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn stats_org_entity_share_url() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_stats_org_entity_share(&client, "tok", "123", "List(timeRange:(start:1,end:2))").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("organizationalEntity=urn%3Ali%3Aorganization%3A123"));
	assert!(url.contains("timeIntervals=List"));
}

#[test]
fn ads_analytics_params() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_ads_analytics(&client, "tok", "List((start:1,end:2))").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("dateRange=List"));
	assert!(url.contains("pivot=ACCOUNT"));
}

#[test]
fn messaging_send_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"m1"}));
	let _ = li_messages_send(
		&client,
		"tok",
		&vec!["urn:li:person:x".into()],
		"subject",
		"body",
	)
	.unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("subject"));
	assert!(body.contains("body"));
}

#[test]
fn webhooks_subscribe_payload_and_delete() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"w1"}));
	let _ = li_webhooks_subscribe(&client, "tok", "adAccount", "https://cb").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("adAccount"));
	assert!(body.contains("https://cb"));

	let client = MockHttp::with_response(403, serde_json::json!({}));
	let err = li_webhooks_delete(&client, "tok", "w1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

