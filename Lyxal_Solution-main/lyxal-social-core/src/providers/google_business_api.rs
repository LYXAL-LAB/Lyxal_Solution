use serde::Deserialize;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const GMB_API: &str = "https://mybusiness.googleapis.com";

fn auth_headers(token: &str, json: bool) -> HttpHeaders {
	let mut h = HttpHeaders::new();
	h.insert("Authorization".into(), format!("Bearer {token}"));
	if json {
		h.insert("Content-Type".into(), "application/json".into());
	}
	h
}

fn make_url(path: &str, params: &[(&str, String)]) -> String {
	let mut query = String::new();
	if !params.is_empty() {
		query.push('?');
		for (i, (k, v)) in params.iter().enumerate() {
			if i > 0 {
				query.push('&');
			}
			query.push_str(k);
			query.push('=');
			query.push_str(&urlencoding::encode(v));
		}
	}
	format!("{GMB_API}{path}{query}")
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::GoogleBusiness),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::GoogleBusiness),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::GoogleBusiness),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::GoogleBusiness),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::GoogleBusiness),
			action,
			"unexpected response",
		)),
	}
}

fn do_json<T: for<'de> Deserialize<'de>>(
	client: &impl HttpClient,
	method: HttpMethod,
	url: String,
	headers: HttpHeaders,
	body: Option<Vec<u8>>,
	action: SocialAction,
) -> SocialResult<T> {
	let req = HttpRequest {
		method,
		url,
		headers,
		body,
		timeout: std::time::Duration::from_secs(20),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	serde_json::from_slice::<T>(&resp.body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::GoogleBusiness),
			action,
			"invalid json",
		)
	})
}

fn do_empty(
	client: &impl HttpClient,
	method: HttpMethod,
	url: String,
	headers: HttpHeaders,
	body: Option<Vec<u8>>,
	action: SocialAction,
) -> SocialResult<()> {
	let req = HttpRequest {
		method,
		url,
		headers,
		body,
		timeout: std::time::Duration::from_secs(20),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	Ok(())
}

// Locations

pub fn gmb_locations_list(
	client: &impl HttpClient,
	token: &str,
	account: &str,
	page_token: Option<&str>,
	page_size: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	if let Some(s) = page_size {
		params.push(("pageSize", s.to_string()));
	}
	let url = make_url(&format!("/v4/accounts/{account}/locations"), &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn gmb_locations_get(client: &impl HttpClient, token: &str, name: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v4/{name}"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

// Reviews

pub fn gmb_reviews_list(
	client: &impl HttpClient,
	token: &str,
	location_name: &str,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(&format!("/v4/{location_name}/reviews"), &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchComments)
}

pub fn gmb_reviews_reply(
	client: &impl HttpClient,
	token: &str,
	review_name: &str,
	comment: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "comment": comment });
	let url = make_url(&format!("/v4/{review_name}:reply"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn gmb_reviews_delete_reply(client: &impl HttpClient, token: &str, review_name: &str) -> SocialResult<()> {
	let url = make_url(&format!("/v4/{review_name}:deleteReply"), &[]);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false), None, SocialAction::FetchComments)
}

// Media

pub fn gmb_media_list(client: &impl HttpClient, token: &str, location_name: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v4/{location_name}/media"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn gmb_media_create(
	client: &impl HttpClient,
	token: &str,
	location_name: &str,
	source_url: &str,
	description: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({
		"mediaFormat": "PHOTO",
		"sourceUrl": source_url
	});
	if let Some(d) = description {
		body["description"] = serde_json::Value::String(d.to_string());
	}
	let url = make_url(&format!("/v4/{location_name}/media"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn gmb_media_delete(client: &impl HttpClient, token: &str, media_name: &str) -> SocialResult<()> {
	let url = make_url(&format!("/v4/{media_name}"), &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::Publish)
}

