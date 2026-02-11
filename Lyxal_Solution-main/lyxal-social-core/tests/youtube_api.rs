use std::sync::{Arc, Mutex};

use lyxal_social_core::error::{SocialErrorCode, SocialResult};
use lyxal_social_core::providers::youtube_api::*;
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
fn channels_list_mine_with_pagination() {
	let client = MockHttp::with_response(200, serde_json::json!({"items":[]}));
	let _ = yt_channels_list(&client, "tok", "snippet", true, Some("p1"), Some(5)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("mine=true"));
	assert!(url.contains("pageToken=p1"));
	assert!(url.contains("maxResults=5"));
}

#[test]
fn videos_insert_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"vid"}));
	let body = serde_json::json!({"snippet":{"title":"hello"}});
	let _ = yt_videos_insert(&client, "tok", "snippet", body).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("hello"));
}

#[test]
fn captions_delete_maps_403() {
	let client = MockHttp::with_response(403, serde_json::json!({}));
	let err = yt_captions_delete(&client, "tok", "cap1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

#[test]
fn thumbnails_set_uses_video_param() {
	let client = MockHttp::with_response(200, serde_json::json!({"status":"ok"}));
	let _ = yt_thumbnails_set(&client, "tok", "vid1").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("videoId=vid1"));
}

#[test]
fn playlist_items_list_cursor() {
	let client = MockHttp::with_response(200, serde_json::json!({"items":[]}));
	let _ = yt_playlist_items_list(&client, "tok", "snippet", "pl1", Some("c1")).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("playlistId=pl1"));
	assert!(url.contains("pageToken=c1"));
}

#[test]
fn comment_threads_insert_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"ct1"}));
	let body = serde_json::json!({"snippet":{"topLevelComment":{"snippet":{"textOriginal":"hi"}}}});
	let _ = yt_comment_threads_insert(&client, "tok", "snippet", body).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("textOriginal"));
}

#[test]
fn comments_set_moderation_status_url() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = yt_comments_set_moderation_status(&client, "tok", "c1", "heldForReview").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("moderationStatus=heldForReview"));
}

#[test]
fn live_broadcasts_bind_params() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"b1"}));
	let _ = yt_live_broadcasts_bind(&client, "tok", "b1", "s1").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("streamId=s1"));
	assert!(url.contains("bind"));
}

#[test]
fn live_chat_insert_body() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"m1"}));
	let body = serde_json::json!({"snippet":{"textMessageDetails":{"messageText":"hi"}}});
	let _ = yt_live_chat_insert_message(&client, "tok", "snippet", body).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("messageText"));
}

#[test]
fn videos_rate_param() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = yt_videos_rate(&client, "tok", "vid1", "like").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("rating=like"));
}

#[test]
fn analytics_reports_params() {
	let client = MockHttp::with_response(200, serde_json::json!({"rows":[]}));
	let _ = yt_analytics_reports(&client, "tok", "channel==MINE", "2024-01-01", "2024-01-31", "views")
		.unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("ids=channel%3D%3DMINE"));
	assert!(url.contains("metrics=views"));
}

#[test]
fn reporting_jobs_create_payload() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"job1"}));
	let body = serde_json::json!({"name":"job"});
	let _ = yt_reporting_jobs_create(&client, "tok", body).unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("job"));
}

#[test]
fn pubsub_subscribe_form() {
	let client = MockHttp::with_response(200, serde_json::json!({}));
	let _ = yt_pubsub_subscribe(&client, "tok", "https://example.com/topic", "https://cb").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	assert_eq!(
		req.headers.get("Content-Type").unwrap(),
		"application/x-www-form-urlencoded"
	);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("hub.mode=subscribe"));
}

#[test]
fn captions_delete_429_maps_rate_limited() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = yt_captions_delete(&client, "tok", "cap2").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

