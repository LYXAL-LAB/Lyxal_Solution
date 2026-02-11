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
fn fb_insights_page_metrics() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_insights_page(&client, "tok", "p1", "page_impressions").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("/p1/insights"));
	assert!(url.contains("metric=page_impressions"));
}

#[test]
fn fb_insights_post_metrics() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = fb_insights_post(&client, "tok", "post1", "post_engaged_users").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("/post1/insights"));
}

#[test]
fn ig_insights_user_period() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = ig_insights_user(&client, "tok", "ig1", "impressions,reach", "day").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("metric=impressions%2Creach"));
	assert!(url.contains("period=day"));
}

#[test]
fn ads_insights_fields_level() {
	let client = MockHttp::with_response(200, serde_json::json!({"data":[]}));
	let _ = ads_insights(&client, "tok", "123", "campaign_name,spend", "campaign").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("fields=campaign_name%2Cspend"));
	assert!(url.contains("level=campaign"));
}

#[test]
fn admins_assign_and_remove() {
	let client = MockHttp::with_response(200, serde_json::json!({"success":true}));
	let _ = fb_assign_admin(&client, "tok", "p1", "u1").unwrap();
	let captured = client.captured();
	let body = std::str::from_utf8(captured[0].body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"user\":\"u1\""));

	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = fb_remove_admin(&client, "tok", "p1", "u1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn webhooks_subscribe_body_and_delete() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"s1"}));
	let _ = meta_webhooks_subscribe_app(&client, "tok", "app1", "page", "https://cb", "vtoken", "feed").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("\"object\":\"page\""));
	assert!(body.contains("https://cb"));

	let client = MockHttp::with_response(403, serde_json::json!({}));
	let err = meta_webhooks_delete_app(&client, "tok", "app1", "page").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_PERMISSION_DENIED);
}

