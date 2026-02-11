use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::google_business_api::*;
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
fn locations_list_pagination() {
	let client = MockHttp::with_response(200, serde_json::json!({"locations":[]}));
	let _ = gmb_locations_list(&client, "tok", "acc1", Some("p1"), Some(50)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("pageToken=p1"));
	assert!(url.contains("pageSize=50"));
	assert!(url.contains("accounts/acc1/locations"));
}

#[test]
fn reviews_reply_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"reply":"ok"}));
	let _ = gmb_reviews_reply(&client, "tok", "locations/1/reviews/2", "merci").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("merci"));
	assert!(req.url.contains("deleteReply") == false);
}

#[test]
fn delete_reply_maps_403() {
	let client = MockHttp::with_response(403, serde_json::json!({}));
	let err = gmb_reviews_delete_reply(&client, "tok", "locations/1/reviews/2").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

#[test]
fn media_create_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"name":"m1"}));
	let _ = gmb_media_create(&client, "tok", "locations/1", "https://img", Some("desc")).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("https://img"));
	assert!(body.contains("desc"));
}

#[test]
fn media_delete_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = gmb_media_delete(&client, "tok", "locations/1/media/2").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

