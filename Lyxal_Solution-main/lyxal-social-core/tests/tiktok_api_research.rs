use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::tiktok_api::*;
use lyxal_social_core::runtime::http::{HttpClient, HttpRequest, HttpResponse};

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
fn research_video_info_query() {
	let client = MockHttp::with_response(200, serde_json::json!({"items":[]}));
	let _ = research_video_info(&client, "tok", vec!["v1".into(), "v2".into()]).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("video_ids=v1%2Cv2"));
}

#[test]
fn research_video_comments_cursor() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"comments":[],"cursor":"c","has_more":false}),
	);
	let res = research_video_comments(&client, "tok", "vid", Some("c1".into()), Some(10)).unwrap();
	assert_eq!(res.cursor.as_deref(), Some("c"));
	let url = &client.captured()[0].url;
	assert!(url.contains("cursor=c1"));
	assert!(url.contains("max_count=10"));
}

#[test]
fn research_video_search_params() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"items":[],"cursor":"n","has_more":true}),
	);
	let _ = research_video_search(&client, "tok", "cats", Some(1), Some(2), Some("c".into()), Some(20)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("query=cats"));
	assert!(url.contains("start_time=1"));
	assert!(url.contains("end_time=2"));
	assert!(url.contains("cursor=c"));
	assert!(url.contains("max_count=20"));
}

#[test]
fn research_user_info_joined() {
	let client = MockHttp::with_response(200, serde_json::json!({"users":[]}));
	let _ = research_user_info(&client, "tok", vec!["u1".into(), "u2".into()]).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("user_ids=u1%2Cu2"));
}

#[test]
fn research_hashtag_videos_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = research_hashtag_videos(&client, "tok", "h1", None, None).unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

