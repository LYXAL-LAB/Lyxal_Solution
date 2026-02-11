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
fn user_info_gets_endpoint() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"open_id":"u","display_name":"n"}),
	);
	let res = get_user_info(&client, "tok").unwrap();
	assert_eq!(res.open_id.as_deref(), Some("u"));
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Get);
	assert!(req.url.ends_with("/user/info/"));
}

#[test]
fn video_insights_query() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"metrics":{"views":10}}),
	);
	let _ = fetch_video_insights(&client, "tok", "vid").unwrap();
	let req = &client.captured()[0];
	assert!(req.url.contains("video_id=vid"));
}

#[test]
fn user_insights_with_params() {
	let client = MockHttp::with_response(200, serde_json::json!({"metrics":{}}));
	let _ = fetch_user_insights(&client, "tok", Some(1), Some(2), Some(vec!["views".into()])).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("start_time=1"));
	assert!(url.contains("end_time=2"));
	assert!(url.contains("metrics=views"));
}

#[test]
fn comment_like_maps_401() {
	let client = MockHttp::with_response(401, serde_json::json!({}));
	let err = like_comment(&client, "tok", "cid", true).unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

#[test]
fn display_video_uses_token() {
	let client = MockHttp::with_response(200, serde_json::json!({"video":{}}));
	let _ = display_get_video(&client, "tok", "vid").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Get);
	assert!(req.headers.get("Authorization").is_some());
	assert!(req.url.contains("video_id=vid"));
}

#[test]
fn embed_oembed_no_auth() {
	let client = MockHttp::with_response(200, serde_json::json!({"html":"<iframe>"}));
	let _ = embed_oembed(&client, "https://www.tiktok.com/@x/video/1").unwrap();
	let req = &client.captured()[0];
	assert!(req.url.contains("oembed"));
	assert!(req.headers.get("Authorization").is_none());
}

