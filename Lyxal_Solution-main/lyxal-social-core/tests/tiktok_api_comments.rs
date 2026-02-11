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
fn list_comments_builds_query() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"comments":[{}],"cursor":"next","has_more":true}),
	);
	let res = list_comments(&client, "tok", "vid", Some("c".into()), Some(20)).unwrap();
	assert!(res.has_more.unwrap());
	let url = &client.captured()[0].url;
	assert!(url.contains("video_id=vid"));
	assert!(url.contains("cursor=c"));
	assert!(url.contains("max_count=20"));
}

#[test]
fn reply_comment_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"comment_id":"c1"}));
	let _ = reply_comment(&client, "tok", "vid", "com", "hello").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"video_id\":\"vid\""));
	assert!(body.contains("\"comment_id\":\"com\""));
	assert!(body.contains("\"text\":\"hello\""));
}

#[test]
fn delete_comment_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = delete_comment(&client, "tok", "vid", "cid").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn fetch_video_stats_uses_get() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"video_id":"vid","stats":{"views":10}}),
	);
	let res = fetch_video_stats(&client, "tok", "vid").unwrap();
	assert_eq!(res.video_id, "vid");
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Get);
	assert!(req.url.contains("video_id=vid"));
}

