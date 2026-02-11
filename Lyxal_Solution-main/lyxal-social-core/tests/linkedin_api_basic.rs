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
fn me_uses_bearer() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"me"}));
	let _ = li_me(&client, "tok").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Get);
	assert!(req.headers.get("Authorization").unwrap().contains("tok"));
}

#[test]
fn email_projection() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_email(&client, "tok").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("q=members"));
	assert!(url.contains("projection="));
}

#[test]
fn org_admin_query() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_org_list_admin(&client, "tok", "pid").unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("role=ADMINISTRATOR"));
	assert!(url.contains("assignee=urn%3Ali%3Aperson%3Apid"));
}

#[test]
fn assets_register_body_owner_recipe() {
	let client = MockHttp::with_response(200, serde_json::json!({"value":"asset"}));
	let _ = li_assets_register_upload(&client, "tok", "urn:li:person:pid", "urn:li:digitalmediaRecipe:feedshare-image").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("registerUploadRequest"));
	assert!(body.contains("feedshare-image"));
}

#[test]
fn ugc_create_payload_text() {
	let client = MockHttp::with_response(200, serde_json::json!({"id":"urn:li:ugcPost:1"}));
	let _ = li_ugc_create(&client, "tok", "urn:li:person:me", "hello").unwrap();
	let req = &client.captured()[0];
	assert_eq!(req.method, HttpMethod::Post);
	let body = std::str::from_utf8(req.body.as_ref().unwrap()).unwrap();
	assert!(body.contains("hello"));
	assert!(body.contains("urn:li:person:me"));
}

#[test]
fn ugc_delete_maps_429() {
	let client = MockHttp::with_response(429, serde_json::json!({}));
	let err = li_ugc_delete(&client, "tok", "urn:li:ugcPost:1").unwrap_err();
	assert_eq!(err.code, SocialErrorCode::SOCIAL_RATE_LIMITED);
}

#[test]
fn shares_list_owner_pagination() {
	let client = MockHttp::with_response(200, serde_json::json!({"elements":[]}));
	let _ = li_shares_list_owner(&client, "tok", "123", Some(10), Some(5)).unwrap();
	let url = &client.captured()[0].url;
	assert!(url.contains("owners=urn%3Ali%3Aorganization%3A123"));
	assert!(url.contains("start=10"));
	assert!(url.contains("count=5"));
}

