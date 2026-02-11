use serde::Deserialize;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const LINKEDIN_API: &str = "https://api.linkedin.com/v2";

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
	format!("{LINKEDIN_API}{path}{query}")
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::LinkedIn),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::LinkedIn),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::LinkedIn),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::LinkedIn),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::LinkedIn),
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
			Some(ProviderKind::LinkedIn),
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

// Users / Email

pub fn li_me(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/me", &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn li_email(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(
		"/emailAddress",
		&[("q", "members".into()), ("projection", "(elements*(handle~))".into())],
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

// Organizations

pub fn li_org_get(client: &impl HttpClient, token: &str, org_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/organizations/{org_id}"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn li_org_list_admin(client: &impl HttpClient, token: &str, person_id: &str) -> SocialResult<serde_json::Value> {
	let assignee = format!("urn:li:person:{person_id}");
	let url = make_url(
		"/organizationAcls",
		&[
			("q", "roleAssignee".into()),
			("role", "ADMINISTRATOR".into()),
			("assignee", assignee),
		],
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

pub fn li_org_list_acls(client: &impl HttpClient, token: &str, org_id: &str) -> SocialResult<serde_json::Value> {
	let org = format!("urn:li:organization:{org_id}");
	let url = make_url(
		"/organizationAcls",
		&[("q", "organization".into()), ("organization", org)],
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

// Assets

pub fn li_assets_register_upload(
	client: &impl HttpClient,
	token: &str,
	owner: &str,
	recipe: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"registerUploadRequest": {
			"owner": owner,
			"recipes": [recipe]
		}
	});
	let url = make_url("/assets", &[("action", "registerUpload".into())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn li_assets_complete(client: &impl HttpClient, token: &str, asset: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/assets/{asset}"), &[("action", "complete".into())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false),
		None,
		SocialAction::Publish,
	)
}

// UGC Posts

pub fn li_ugc_create(
	client: &impl HttpClient,
	token: &str,
	author: &str,
	text: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"author": author,
		"lifecycleState": "PUBLISHED",
		"specificContent": {
			"com.linkedin.ugc.ShareContent": {
				"shareCommentary": { "text": text },
				"shareMediaCategory": "NONE"
			}
		},
		"visibility": {
			"com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
		}
	});
	let url = make_url("/ugcPosts", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn li_ugc_get(client: &impl HttpClient, token: &str, ugc_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/ugcPosts/{ugc_id}"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn li_ugc_delete(client: &impl HttpClient, token: &str, ugc_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/ugcPosts/{ugc_id}"), &[]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token, false),
		None,
		SocialAction::Publish,
	)
}

// Shares

pub fn li_shares_create(
	client: &impl HttpClient,
	token: &str,
	owner: &str,
	text: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"owner": owner,
		"text": { "text": text },
		"distribution": { "linkedInDistributionTarget": {} }
	});
	let url = make_url("/shares", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn li_shares_list_owner(
	client: &impl HttpClient,
	token: &str,
	org_id: &str,
	start: Option<u32>,
	count: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let owner = format!("urn:li:organization:{org_id}");
	let mut params = vec![("q", "owners".into()), ("owners", owner)];
	if let Some(s) = start {
		params.push(("start", s.to_string()));
	}
	if let Some(c) = count {
		params.push(("count", c.to_string()));
	}
	let url = make_url("/shares", &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// Reactions

pub fn li_reactions_create(
	client: &impl HttpClient,
	token: &str,
	actor: &str,
	object: &str,
	reaction_type: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"actor": actor,
		"object": object,
		"type": reaction_type
	});
	let url = make_url("/reactions", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn li_reactions_delete(client: &impl HttpClient, token: &str, actor: &str, object: &str) -> SocialResult<()> {
	let url = make_url(
		"/reactions/(actor,object)",
		&[("actor", actor.to_string()), ("object", object.to_string())],
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn li_reactions_list(
	client: &impl HttpClient,
	token: &str,
	object: &str,
	start: Option<u32>,
	count: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("object", object.to_string())];
	if let Some(s) = start {
		params.push(("start", s.to_string()));
	}
	if let Some(c) = count {
		params.push(("count", c.to_string()));
	}
	let url = make_url("/reactions/(object)", &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchComments,
	)
}

// Comments

pub fn li_comments_create(
	client: &impl HttpClient,
	token: &str,
	social_action_urn: &str,
	actor: &str,
	message: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"actor": actor,
		"message": { "text": message }
	});
	let url = make_url(&format!("/socialActions/{social_action_urn}/comments"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn li_comments_list(
	client: &impl HttpClient,
	token: &str,
	social_action_urn: &str,
	start: Option<u32>,
	count: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(s) = start {
		params.push(("start", s.to_string()));
	}
	if let Some(c) = count {
		params.push(("count", c.to_string()));
	}
	let url = make_url(&format!("/socialActions/{social_action_urn}/comments"), &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn li_comments_delete(client: &impl HttpClient, token: &str, comment_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/comments/{comment_id}"), &[]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchComments,
	)
}

// Stats / Analytics

pub fn li_stats_org_entity_share(
	client: &impl HttpClient,
	token: &str,
	org_id: &str,
	time_intervals: &str,
) -> SocialResult<serde_json::Value> {
	let org = format!("urn:li:organization:{org_id}");
	let url = make_url(
		"/organizationalEntityShareStatistics",
		&[
			("q", "organizationalEntity".into()),
			("organizationalEntity", org),
			("timeIntervals", time_intervals.to_string()),
		],
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

pub fn li_stats_network_size(
	client: &impl HttpClient,
	token: &str,
	org_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/networkSizes/urn:li:organization:{org_id}"),
		&[("edgeType", "CompanyFollowedBy".into())],
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

// Ads

pub fn li_ads_list_accounts(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/adAccounts", &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn li_ads_list_campaigns(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/adAccounts/{account_id}/campaigns"), &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn li_ads_list_creatives(
	client: &impl HttpClient,
	token: &str,
	account_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		"/adCreatives",
		&[("q", "account".into()), ("account", format!("urn:li:sponsoredAccount:{account_id}"))],
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

pub fn li_ads_analytics(
	client: &impl HttpClient,
	token: &str,
	date_range: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		"/adAnalytics",
		&[
			("q", "analytics".into()),
			("dateRange", date_range.to_string()),
			("pivot", "ACCOUNT".into()),
		],
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

// Messaging (limited)

pub fn li_messages_send(
	client: &impl HttpClient,
	token: &str,
	recipients: &[String],
	subject: &str,
	body: &str,
) -> SocialResult<serde_json::Value> {
	let to = recipients
		.iter()
		.map(|r| serde_json::json!({ "person": r }))
		.collect::<Vec<_>>();
	let payload = serde_json::json!({
		"recipients": { "values": to },
		"subject": subject,
		"body": body
	});
	let url = make_url("/messages", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&payload).unwrap()),
		SocialAction::SendMessage,
	)
}

pub fn li_messages_list(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/messages", &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchMessages,
	)
}

// Webhooks (resthooks)

pub fn li_webhooks_subscribe(
	client: &impl HttpClient,
	token: &str,
	event_type: &str,
	callback_url: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"eventType": event_type,
		"callbackUrl": callback_url
	});
	let url = make_url("/resthooks", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn li_webhooks_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/resthooks/{id}"), &[]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token, false),
		None,
		SocialAction::Publish,
	)
}

