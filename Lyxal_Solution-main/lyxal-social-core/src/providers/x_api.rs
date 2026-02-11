use base64::Engine;
use serde::Deserialize;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const X_API: &str = "https://api.twitter.com";

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
	format!("{X_API}{path}{query}")
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::X),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::X),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::X),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::X),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::X),
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
			Some(ProviderKind::X),
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

// Tweets / engagement

pub fn x_tweets_get(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/2/tweets/{id}"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_tweets_batch_get(
	client: &impl HttpClient,
	token: &str,
	ids: &[String],
) -> SocialResult<serde_json::Value> {
	let ids_join = ids.join(",");
	let url = make_url("/2/tweets", &[("ids", ids_join)]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_tweets_create(
	client: &impl HttpClient,
	token: &str,
	text: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "text": text });
	let url = make_url("/2/tweets", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn x_tweets_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/2/tweets/{id}"), &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::Publish)
}

pub fn x_tweets_hide_reply(client: &impl HttpClient, token: &str, id: &str, hidden: bool) -> SocialResult<()> {
	let body = serde_json::json!({ "hidden": hidden });
	let url = make_url(&format!("/2/tweets/{id}/hidden"), &[]);
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn x_likes_create(client: &impl HttpClient, token: &str, user_id: &str, tweet_id: &str) -> SocialResult<()> {
	let body = serde_json::json!({ "tweet_id": tweet_id });
	let url = make_url(&format!("/2/users/{user_id}/likes"), &[]);
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn x_likes_delete(client: &impl HttpClient, token: &str, user_id: &str, tweet_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/2/users/{user_id}/likes/{tweet_id}"), &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::FetchComments)
}

pub fn x_retweets_create(client: &impl HttpClient, token: &str, user_id: &str, tweet_id: &str) -> SocialResult<()> {
	let body = serde_json::json!({ "tweet_id": tweet_id });
	let url = make_url(&format!("/2/users/{user_id}/retweets"), &[]);
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn x_retweets_delete(
	client: &impl HttpClient,
	token: &str,
	source_user_id: &str,
	tweet_id: &str,
) -> SocialResult<()> {
	let url = make_url(&format!("/2/users/{source_user_id}/retweets/{tweet_id}"), &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::Publish)
}

pub fn x_bookmarks_create(client: &impl HttpClient, token: &str, user_id: &str, tweet_id: &str) -> SocialResult<()> {
	let body = serde_json::json!({ "tweet_id": tweet_id });
	let url = make_url(&format!("/2/users/{user_id}/bookmarks"), &[]);
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn x_bookmarks_delete(client: &impl HttpClient, token: &str, user_id: &str, tweet_id: &str) -> SocialResult<()> {
	let url = make_url(&format!("/2/users/{user_id}/bookmarks/{tweet_id}"), &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::FetchComments)
}

// Timelines / search

fn list_with_pagination(
	client: &impl HttpClient,
	token: &str,
	path: String,
	pagination_token: Option<&str>,
	max_results: Option<u32>,
	action: SocialAction,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(p) = pagination_token {
		params.push(("pagination_token", p.to_string()));
	}
	if let Some(m) = max_results {
		params.push(("max_results", m.to_string()));
	}
	let url = make_url(&path, &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, action)
}

pub fn x_user_tweets(
	client: &impl HttpClient,
	token: &str,
	user_id: &str,
	pagination_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let path = format!("/2/users/{user_id}/tweets");
	list_with_pagination(client, token, path, pagination_token, None, SocialAction::FetchStats)
}

pub fn x_search_recent(
	client: &impl HttpClient,
	token: &str,
	query: &str,
	next_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("query", query.to_string())];
	if let Some(n) = next_token {
		params.push(("next_token", n.to_string()));
	}
	let url = make_url("/2/tweets/search/recent", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_stream_rules_list(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/2/tweets/search/stream/rules", &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_stream_rules_update(
	client: &impl HttpClient,
	token: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url("/2/tweets/search/stream/rules", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

// Users / follows

pub fn x_users_lookup(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/2/users/{id}"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_users_by_username(client: &impl HttpClient, token: &str, username: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/2/users/by/username/{username}"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_follows_create(client: &impl HttpClient, token: &str, user_id: &str, target_user_id: &str) -> SocialResult<()> {
	let body = serde_json::json!({ "target_user_id": target_user_id });
	let url = make_url(&format!("/2/users/{user_id}/following"), &[]);
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn x_follows_delete(
	client: &impl HttpClient,
	token: &str,
	source_user_id: &str,
	target_user_id: &str,
) -> SocialResult<()> {
	let url = make_url(
		&format!("/2/users/{source_user_id}/following/{target_user_id}"),
		&[],
	);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::Publish)
}

// Media upload v1.1

pub fn x_media_init_upload(client: &impl HttpClient, token: &str, total_bytes: u64, media_type: &str) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"command": "INIT",
		"total_bytes": total_bytes,
		"media_type": media_type
	});
	let url = make_url("/1.1/media/upload", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn x_media_append_upload(
	client: &impl HttpClient,
	token: &str,
	media_id: &str,
	segment_index: u32,
	data: &[u8],
) -> SocialResult<()> {
	let body = serde_json::json!({
		"command": "APPEND",
		"media_id": media_id,
		"segment_index": segment_index,
		"media": base64::engine::general_purpose::STANDARD.encode(data),
	});
	let url = make_url("/1.1/media/upload", &[]);
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn x_media_finalize_upload(client: &impl HttpClient, token: &str, media_id: &str) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"command": "FINALIZE",
		"media_id": media_id
	});
	let url = make_url("/1.1/media/upload", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn x_media_status(client: &impl HttpClient, token: &str, media_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/1.1/media/upload", &[("command", "STATUS".into()), ("media_id", media_id.to_string())]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

// DMs (v2)

pub fn x_dm_send_to(
	client: &impl HttpClient,
	token: &str,
	participant_id: &str,
	text: &str,
) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({
		"event": {
			"type": "message_create",
			"message_create": {
				"target": { "recipient_id": participant_id },
				"message_data": { "text": text }
			}
		}
	});
	let url = make_url(&format!("/2/dm_conversations/with/{participant_id}/messages"), &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::SendMessage,
	)
}

pub fn x_dm_list_with(
	client: &impl HttpClient,
	token: &str,
	participant_id: &str,
	pagination_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = Vec::new();
	if let Some(p) = pagination_token {
		params.push(("pagination_token", p.to_string()));
	}
	let url = make_url(
		&format!("/2/dm_conversations/with/{participant_id}/dm_events"),
		&params,
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchMessages,
	)
}

// Compliance

pub fn x_compliance_create_job(client: &impl HttpClient, token: &str, job_type: &str) -> SocialResult<serde_json::Value> {
	let body = serde_json::json!({ "type": job_type });
	let url = make_url("/2/compliance/jobs", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchStats,
	)
}

pub fn x_compliance_list_jobs(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/2/compliance/jobs", &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

// Account Activity API

pub fn x_aaa_register_webhook(
	client: &impl HttpClient,
	token: &str,
	env: &str,
	url_cb: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/1.1/account_activity/all/{env}/webhooks.json"), &[("url", url_cb.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false),
		None,
		SocialAction::Publish,
	)
}

pub fn x_aaa_list_webhooks(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url("/1.1/account_activity/all/webhooks.json", &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

pub fn x_aaa_delete_webhook(
	client: &impl HttpClient,
	token: &str,
	env: &str,
	id: &str,
) -> SocialResult<()> {
	let url = make_url(&format!("/1.1/account_activity/all/{env}/webhooks/{id}.json"), &[]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false), None, SocialAction::Publish)
}

pub fn x_aaa_subscribe(client: &impl HttpClient, token: &str, env: &str) -> SocialResult<()> {
	let url = make_url(&format!("/1.1/account_activity/all/{env}/subscriptions.json"), &[]);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false), None, SocialAction::Publish)
}

pub fn x_aaa_list_subscriptions(client: &impl HttpClient, token: &str, env: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(&format!("/1.1/account_activity/all/{env}/subscriptions/list.json"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false), None, SocialAction::FetchStats)
}

