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
fn list_comments_with_cursor() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_list_comments(&client, "tok", "obj1", Some("a1"), Some(20)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("/obj1/comments"));
	assert!(url.contains("after=a1"));
	assert!(url.contains("limit=20"));
}

#[test]
fn create_comment_body_message() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"c1"}));
	let _ = fb_create_comment(&client, "tok", "obj1", "hi").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"message\":\"hi\""));
}

#[test]
fn delete_comment_maps_401() {
	let client = MockHttp::with_response(401, serde_json::json!({}));
	let err = fb_delete_comment(&client, "tok", "c1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

#[test]
fn likes_list_and_remove() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_list_likes(&client, "tok", "obj1", None, None).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("/obj1/likes"));

	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = fb_remove_like(&client, "tok", "obj1").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Delete);
}

#[test]
fn set_reaction_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"success":true}));
	let _ = fb_set_reaction(&client, "tok", "obj1", "LOVE").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("LOVE"));
}

#[test]
fn clear_reactions_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = fb_clear_reactions(&client, "tok", "obj1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn list_messages_cursor() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_list_messages(&client, "tok", "conv1", Some("b2"), Some(15)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("/conv1/messages"));
	assert!(url.contains("after=b2"));
	assert!(url.contains("limit=15"));
}

#[test]
fn send_message_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"m1"}));
	let _ = fb_send_message(&client, "tok", "page1", "user1", "hello").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"id\":\"user1\""));
	assert!(body.contains("\"text\":\"hello\""));
}

