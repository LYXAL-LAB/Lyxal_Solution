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
fn init_upload_builds_request() {
	let client = MockHttp::with_response(200, serde_json::json!({"upload_url":"u","video_id":"v"}));
	let body = serde_json::json!({"file_size":123});
	let res = init_upload(&client, "token", body).unwrap();
	assert_eq!(res["video_id"], "v");
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	assert!(req.url.ends_with("/v2/video/init_upload/"));
	assert_eq!(req.headers.get("Authorization").map(String::as_str), Some("Bearer token"));
}

#[test]
fn upload_part_uses_octet_stream() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = upload_part(&client, "https://upload", vec![1, 2, 3]).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	assert_eq!(req.headers.get("Content-Type").map(String::as_str), Some("application/octet-stream"));
}

#[test]
fn publish_video_maps_401() {
	let client = MockHttp::with_response(401, serde_json::json!({}));
	let err = publish_video(&client, "tok", serde_json::json!({"video_id":"v"})).unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

#[test]
fn list_videos_with_cursor() {
	let client = MockHttp::with_response(
		200,
		serde_json::json!({"videos":[{}],"cursor":"next","has_more":true}),
	);
	let res = list_videos(&client, "tok", Some("c".into()), Some(50)).unwrap();
	assert!(res.has_more.unwrap());
	let url = &client.captured()[0].url;
	assert!(url.contains("cursor=c"));
	assert!(url.contains("max_count=50"));
}

#[test]
fn delete_video_uses_delete_body() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = delete_video(&client, "tok", "vid").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Delete);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"video_id\":\"vid\""));
}

#[test]
fn cover_upload_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = upload_cover(&client, "tok", "vid", vec![0u8; 1]).unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

