use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::meta_api::*;
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
fn get_page_uses_get_and_token() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"p1"}));
	let _ = fb_get_page(&client, "tok", "p1").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Get);
	assert!(req.url.contains("/p1?"));
	assert!(req.url.contains("access_token=tok"));
}

#[test]
fn list_feed_with_cursor_and_limit() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_list_feed(&client, "tok", "p1", Some("c1"), Some(25)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("after=c1"));
	assert!(url.contains("limit=25"));
}

#[test]
fn create_post_payload_message_and_link() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"post1"}));
	let _ = fb_create_post(&client, "tok", "p1", "hello", Some("https://x")).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"message\":\"hello\""));
	assert!(body.contains("https://x"));
}

#[test]
fn delete_post_maps_429_to_rate_limited() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = fb_delete_post(&client, "tok", "post1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn create_photo_payload_caption() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"ph1"}));
	let _ = fb_create_photo(&client, "tok", "p1", "https://img", Some("caption")).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("https://img"));
	assert!(body.contains("caption"));
}

#[test]
fn create_video_payload_fields() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"v1"}));
	let _ = fb_create_video(&client, "tok", "p1", "https://file", Some("title"), Some("desc")).unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("https://file"));
	assert!(body.contains("title"));
	assert!(body.contains("desc"));
}

#[test]
fn list_scheduled_posts_cursor() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_list_scheduled_posts(&client, "tok", "p1", Some("c2"), Some(10)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("after=c2"));
	assert!(url.contains("limit=10"));
}

#[test]
fn create_scheduled_post_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"s1"}));
	let _ = fb_create_scheduled_post(&client, "tok", "p1", "later", 1_700_000_000).unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"published\":false"));
	assert!(body.contains("scheduled_publish_time"));
	assert!(body.contains("later"));
}

