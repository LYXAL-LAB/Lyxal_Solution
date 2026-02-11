use serde::Deserialize;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const SNAP_API: &str = "https://adsapi.snapchat.com";

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
	format!("{SNAP_API}{path}{query}")
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::Snapchat),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::Snapchat),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::Snapchat),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::Snapchat),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::Snapchat),
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
			Some(ProviderKind::Snapchat),
			action,
			"invalid json",
		)
	})
}

// Ads Accounts / Orgs

pub fn sc_list_accounts(
	client: &impl HttpClient,
	token: &str,
	limit: Option<u32>,
	offset: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	if let Some(o) = offset {
		params.push(("offset", o.to_string()));
	}
	let url = make_url("/v1/adaccounts", &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_get_account(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{id}"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_list_organizations(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/v1/organizations", &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// Campaign hierarchy

pub fn sc_list_campaigns(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	limit: Option<u32>,
	offset: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	if let Some(o) = offset {
		params.push(("offset", o.to_string()));
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/campaigns"), &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_create_campaign(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	name: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "name": name });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/campaigns"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_update_campaign(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	campaign_id: &str,
	name: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({});
	if let Some(n) = name {
		body["name"] = serde_json::Value::String(n.to_string());
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/campaigns/{campaign_id}"), &[]);
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_list_adsets(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	limit: Option<u32>,
	offset: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	if let Some(o) = offset {
		params.push(("offset", o.to_string()));
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/adsets"), &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_create_adset(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	name: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "name": name });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/adsets"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_update_adset(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	adset_id: &str,
	name: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({});
	if let Some(n) = name {
		body["name"] = serde_json::Value::String(n.to_string());
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/adsets/{adset_id}"), &[]);
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_list_ads(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	limit: Option<u32>,
	offset: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	if let Some(o) = offset {
		params.push(("offset", o.to_string()));
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/ads"), &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_create_ad(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	name: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "name": name });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/ads"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_update_ad(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	ad_id: &str,
	name: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({});
	if let Some(n) = name {
		body["name"] = serde_json::Value::String(n.to_string());
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/ads/{ad_id}"), &[]);
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

// Creatives / media

pub fn sc_list_creatives(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/creatives"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_create_creative(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	name: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "name": name });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/creatives"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_update_creative(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	creative_id: &str,
	name: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({});
	if let Some(n) = name {
		body["name"] = serde_json::Value::String(n.to_string());
	}
	let url = make_url(&format!("/v1/adaccounts/{account_id}/creatives/{creative_id}"), &[]);
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_upload_asset(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	bytes: &[u8],
) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/assets"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false),
		Some(bytes.to_vec()),
		SocialAction::Publish,
	)
}

// Audiences / Catalogs

pub fn sc_list_audiences(client: &impl HttpClient, token: &str, account_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/audiences"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_create_audience(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	name: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "name": name });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/audiences"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_list_catalogs(client: &impl HttpClient, token: &str, account_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/catalogs"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_create_catalog(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	name: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "name": name });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/catalogs"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

// Conversions / Pixels

pub fn sc_create_pixel(client: &impl HttpClient, token: &str, account_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/pixels"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false),
		None,
		SocialAction::Publish,
	)
}

pub fn sc_list_conversions(client: &impl HttpClient, token: &str, account_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/conversions"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn sc_post_conversions(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	events: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "events": events });
	let url = make_url(&format!("/v1/adaccounts/{account_id}/conversions"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

// Reporting

pub fn sc_reports(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	report_type: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/v1/adaccounts/{account_id}/reports"),
		&[("report_type", report_type.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// Webhooks / ingestion status

pub fn sc_webhooks_subscribe(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
	event: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/conversions"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&event).unwrap()),
		SocialAction::Publish,
	)
}

pub fn sc_webhooks_status(client: &impl HttpClient, token: &str, account_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/v1/adaccounts/{account_id}/conversions"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

