use serde::Deserialize;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const META_API: &str = "https://graph.facebook.com/v18.0";

fn auth_headers(json: bool) -> HttpHeaders {
	let mut h = HttpHeaders::new();
	if json {
		h.insert("Content-Type".into(), "application/json".into());
	}
	h
}

fn make_url(path: &str, token: &str, params: &[(&str, String)]) -> String {
	let mut query = format!("access_token={}", urlencoding::encode(token));
	for (k, v) in params {
		query.push('&');
		query.push_str(k);
		query.push('=');
		query.push_str(&urlencoding::encode(v));
	}
	format!("{META_API}{path}?{query}")
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::Meta),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::Meta),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::Meta),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::Meta),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::Meta),
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
			Some(ProviderKind::Meta),
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

// Facebook Pages — Contenu

pub fn fb_get_page(client: &impl HttpClient, token: &str, page_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{page_id}"), token, &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_list_feed(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{page_id}/feed"), token, &params);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_create_post(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	message: &str,
	link: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({ "message": message });
	if let Some(l) = link {
		body["link"] = serde_json::Value::String(l.to_string());
	}
	let url = make_url(&format!("/{page_id}/feed"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn fb_get_post(client: &impl HttpClient, token: &str, post_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{post_id}"), token, &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_update_post(
	client: &impl HttpClient,
	token: &str,
	post_id: &str,
	message: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "message": message });
	let url = make_url(&format!("/{post_id}"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn fb_delete_post(client: &impl HttpClient, token: &str, post_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/{post_id}"), token, &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(false), None, SocialAction::Publish)
}

pub fn fb_list_photos(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{page_id}/photos"), token, &params);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_create_photo(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	url: &str,
	caption: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({ "url": url });
	if let Some(c) = caption {
		body["caption"] = serde_json::Value::String(c.to_string());
	}
	let url = make_url(&format!("/{page_id}/photos"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn fb_list_videos(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{page_id}/videos"), token, &params);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_create_video(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	file_url: &str,
	title: Option<&str>,
	description: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({ "file_url": file_url });
	if let Some(t) = title {
		body["title"] = serde_json::Value::String(t.to_string());
	}
	if let Some(d) = description {
		body["description"] = serde_json::Value::String(d.to_string());
	}
	let url = make_url(&format!("/{page_id}/videos"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn fb_get_video(client: &impl HttpClient, token: &str, video_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{video_id}"), token, &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_delete_video(client: &impl HttpClient, token: &str, video_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/{video_id}"), token, &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(false), None, SocialAction::Publish)
}

pub fn fb_update_video(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	title: Option<&str>,
	description: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut body = serde_json::json!({});
	if let Some(t) = title {
		body["title"] = serde_json::Value::String(t.to_string());
	}
	if let Some(d) = description {
		body["description"] = serde_json::Value::String(d.to_string());
	}
	let url = make_url(&format!("/{video_id}"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn fb_list_published_posts(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{page_id}/published_posts"), token, &params);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_list_scheduled_posts(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{page_id}/scheduled_posts"), token, &params);
	do_json(client, HttpMethod::Get, url, auth_headers(false), None, SocialAction::FetchStats)
}

pub fn fb_create_scheduled_post(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	message: &str,
	scheduled_publish_time: i64,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"message": message,
		"published": false,
		"scheduled_publish_time": scheduled_publish_time
	});
	let url = make_url(&format!("/{page_id}/scheduled_posts"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

// Engagement — Comments

pub fn fb_list_comments(
	client: &impl HttpClient,
	token: &str,
	object_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{object_id}/comments"), token, &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn fb_create_comment(
	client: &impl HttpClient,
	token: &str,
	object_id: &str,
	message: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "message": message });
	let url = make_url(&format!("/{object_id}/comments"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn fb_delete_comment(client: &impl HttpClient, token: &str, comment_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/{comment_id}"), token, &[]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn fb_get_comment(client: &impl HttpClient, token: &str, comment_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{comment_id}"), token, &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn fb_update_comment(
	client: &impl HttpClient,
	token: &str,
	comment_id: &str,
	message: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "message": message });
	let url = make_url(&format!("/{comment_id}"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

// Engagement — Likes

pub fn fb_list_likes(
	client: &impl HttpClient,
	token: &str,
	object_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{object_id}/likes"), token, &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn fb_add_like(client: &impl HttpClient, token: &str, object_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{object_id}/likes"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn fb_remove_like(client: &impl HttpClient, token: &str, object_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/{object_id}/likes"), token, &[]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

// Engagement — Reactions

pub fn fb_list_reactions(
	client: &impl HttpClient,
	token: &str,
	object_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{object_id}/reactions"), token, &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn fb_set_reaction(
	client: &impl HttpClient,
	token: &str,
	object_id: &str,
	reaction_type: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "type": reaction_type });
	let url = make_url(&format!("/{object_id}/reactions"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn fb_clear_reactions(client: &impl HttpClient, token: &str, object_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/{object_id}/reactions"), token, &[]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchComments,
	)
}

// Messaging

pub fn fb_list_conversations(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{page_id}/conversations"), token, &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn fb_list_messages(
	client: &impl HttpClient,
	token: &str,
	conversation_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/{conversation_id}/messages"), token, &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn fb_send_message(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	recipient_id: &str,
	text: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"recipient": { "id": recipient_id },
		"message": { "text": text }
	});
	let url = make_url(&format!("/{page_id}/messages"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::SendMessage,
	)
}

// Insights

pub fn fb_insights_page(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	metrics: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/{page_id}/insights"),
		token,
		&[("metric", metrics.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn fb_insights_post(
	client: &impl HttpClient,
	token: &str,
	post_id: &str,
	metrics: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/{post_id}/insights"),
		token,
		&[("metric", metrics.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn fb_insights_video(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	metrics: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/{video_id}/insights"),
		token,
		&[("metric", metrics.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn ig_insights_user(
	client: &impl HttpClient,
	token: &str,
	user_id: &str,
	metrics: &str,
	period: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/{user_id}/insights"),
		token,
		&[("metric", metrics.to_string()), ("period", period.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn ig_insights_media(
	client: &impl HttpClient,
	token: &str,
	media_id: &str,
	metrics: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/{media_id}/insights"),
		token,
		&[("metric", metrics.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn ig_insights_reel(
	client: &impl HttpClient,
	token: &str,
	reel_id: &str,
	metrics: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/{reel_id}/insights"),
		token,
		&[("metric", metrics.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

// Admins / Roles

pub fn fb_list_admins(client: &impl HttpClient, token: &str, page_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{page_id}/admins"), token, &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn fb_assign_admin(
	client: &impl HttpClient,
	token: &str,
	page_id: &str,
	user_id: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "user": user_id });
	let url = make_url(&format!("/{page_id}/admins"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchStats,
	)
}

pub fn fb_remove_admin(client: &impl HttpClient, token: &str, page_id: &str, user_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/{page_id}/admins"), token, &[("user", user_id.to_string())]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

// Webhooks

pub fn meta_webhooks_subscribe_app(
	client: &impl HttpClient,
	token: &str,
	app_id: &str,
	object: &str,
	callback_url: &str,
	verify_token: &str,
	fields: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"object": object,
		"callback_url": callback_url,
		"verify_token": verify_token,
		"fields": fields
	});
	let url = make_url(&format!("/{app_id}/subscriptions"), token, &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn meta_webhooks_list_app(client: &impl HttpClient, token: &str, app_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/{app_id}/subscriptions"), token, &[]);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn meta_webhooks_delete_app(
	client: &impl HttpClient,
	token: &str,
	app_id: &str,
	object: &str,
) -> SocialResult<()> {
	let url = make_url(&format!("/{app_id}/subscriptions"), token, &[("object", object.to_string())]);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(false),
		None,
		SocialAction::Publish,
	)
}

// Ads / Marketing (simplifié pour tests)

pub fn ads_list_campaigns(
	client: &impl HttpClient,
	token: &str,
	ad_account_id: &str,
	after: Option<&str>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(a) = after {
		params.push(("after", a.to_string()));
	}
	if let Some(l) = limit {
		params.push(("limit", l.to_string()));
	}
	let url = make_url(&format!("/act_{ad_account_id}/campaigns"), token, &params);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn ads_insights(
	client: &impl HttpClient,
	token: &str,
	ad_account_id: &str,
	fields: &str,
	level: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		&format!("/act_{ad_account_id}/insights"),
		token,
		&[("fields", fields.to_string()), ("level", level.to_string())],
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(false),
		None,
		SocialAction::FetchStats,
	)
}

