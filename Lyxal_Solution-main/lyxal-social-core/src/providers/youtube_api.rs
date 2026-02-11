use serde::Deserialize;

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const YT_API: &str = "https://www.googleapis.com";
const YT_ANALYTICS: &str = "https://youtubeanalytics.googleapis.com";
const YT_REPORTING: &str = "https://youtubereporting.googleapis.com";
const YT_PUBSUB: &str = "https://pubsubhubbub.appspot.com";

fn auth_headers(token: &str, json: bool, form: bool) -> HttpHeaders {
	let mut h = HttpHeaders::new();
	h.insert("Authorization".into(), format!("Bearer {token}"));
	if json {
		h.insert("Content-Type".into(), "application/json".into());
	}
	if form {
		h.insert("Content-Type".into(), "application/x-www-form-urlencoded".into());
	}
	h
}

fn make_url(base: &str, path: &str, params: &[(&str, String)]) -> String {
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
	format!("{base}{path}{query}")
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::YouTube),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::YouTube),
			action,
			"permission denied or quota",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::YouTube),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::YouTube),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::YouTube),
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
		timeout: std::time::Duration::from_secs(30),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	serde_json::from_slice::<T>(&resp.body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::YouTube),
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
		timeout: std::time::Duration::from_secs(30),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	Ok(())
}

// Channels / subscriptions

pub fn yt_channels_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	mine: bool,
	page_token: Option<&str>,
	max_results: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string())];
	if mine {
		params.push(("mine", "true".into()));
	}
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	if let Some(m) = max_results {
		params.push(("maxResults", m.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/channels", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_subscriptions_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	mine: bool,
	channel_id: Option<&str>,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string())];
	if mine {
		params.push(("mine", "true".into()));
	}
	if let Some(c) = channel_id {
		params.push(("channelId", c.to_string()));
	}
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/subscriptions", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_subscriptions_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/subscriptions", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_subscriptions_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/subscriptions", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

// Videos / captions / thumbnails

pub fn yt_videos_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	id: Option<&str>,
	page_token: Option<&str>,
	max_results: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string())];
	if let Some(i) = id {
		params.push(("id", i.to_string()));
	}
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	if let Some(m) = max_results {
		params.push(("maxResults", m.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/videos", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_videos_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/videos", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_videos_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/videos", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_videos_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/videos", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_captions_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	video_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		YT_API,
		"/youtube/v3/captions",
		&[("part", part.to_string()), ("videoId", video_id.to_string())],
	);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_captions_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/captions", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_captions_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/captions", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_captions_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/captions", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_thumbnails_set(client: &impl HttpClient, token: &str, video_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(
		YT_API,
		"/youtube/v3/thumbnails/set",
		&[("videoId", video_id.to_string())],
	);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false, false),
		None,
		SocialAction::Publish,
	)
}

// Playlists

pub fn yt_playlists_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	channel_id: Option<&str>,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string())];
	if let Some(c) = channel_id {
		params.push(("channelId", c.to_string()));
	}
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/playlists", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_playlists_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/playlists", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_playlists_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/playlists", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_playlists_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/playlists", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_playlist_items_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	playlist_id: &str,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string()), ("playlistId", playlist_id.to_string())];
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/playlistItems", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_playlist_items_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/playlistItems", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_playlist_items_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/playlistItems", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_playlist_items_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/playlistItems", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

// Search

pub fn yt_search_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	q: &str,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string()), ("q", q.to_string())];
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/search", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

// Comments / comment threads / moderation

pub fn yt_comment_threads_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	video_id: &str,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string()), ("videoId", video_id.to_string())];
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/commentThreads", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchComments)
}

pub fn yt_comment_threads_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/commentThreads", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn yt_comments_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	parent_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		YT_API,
		"/youtube/v3/comments",
		&[("part", part.to_string()), ("parentId", parent_id.to_string())],
	);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchComments)
}

pub fn yt_comments_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/comments", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn yt_comments_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/comments", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::FetchComments,
	)
}

pub fn yt_comments_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/comments", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::FetchComments)
}

pub fn yt_comments_set_moderation_status(
	client: &impl HttpClient,
	token: &str,
	id: &str,
	status: &str,
) -> SocialResult<()> {
	let url = make_url(
		YT_API,
		"/youtube/v3/comments/setModerationStatus",
		&[("id", id.to_string()), ("moderationStatus", status.to_string())],
	);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::FetchComments)
}

pub fn yt_comments_mark_spam(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/comments/markAsSpam", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::FetchComments)
}

// Live chat

pub fn yt_live_chat_list_messages(
	client: &impl HttpClient,
	token: &str,
	live_chat_id: &str,
	part: &str,
	page_token: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("liveChatId", live_chat_id.to_string()), ("part", part.to_string())];
	if let Some(p) = page_token {
		params.push(("pageToken", p.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/liveChat/messages", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchMessages)
}

pub fn yt_live_chat_insert_message(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveChat/messages", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::SendMessage,
	)
}

pub fn yt_live_chat_delete_message(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/liveChat/messages/delete", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::SendMessage)
}

pub fn yt_live_chat_bans(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveChat/bans", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::SendMessage,
	)
}

pub fn yt_live_chat_moderators(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveChat/moderators", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::SendMessage,
	)
}

// Ratings

pub fn yt_videos_rate(client: &impl HttpClient, token: &str, id: &str, rating: &str) -> SocialResult<()> {
	let url = make_url(
		YT_API,
		"/youtube/v3/videos/rate",
		&[("id", id.to_string()), ("rating", rating.to_string())],
	);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_videos_get_rating(
	client: &impl HttpClient,
	token: &str,
	id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/videos/getRating", &[("id", id.to_string())]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

// Live streaming

pub fn yt_live_broadcasts_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	broadcast_status: Option<&str>,
) -> SocialResult<serde_json::Value> {
	let mut params = vec![("part", part.to_string())];
	if let Some(s) = broadcast_status {
		params.push(("broadcastStatus", s.to_string()));
	}
	let url = make_url(YT_API, "/youtube/v3/liveBroadcasts", &params);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_live_broadcasts_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveBroadcasts", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_live_broadcasts_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveBroadcasts", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_live_broadcasts_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/liveBroadcasts", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_live_broadcasts_bind(
	client: &impl HttpClient,
	token: &str,
	id: &str,
	stream_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		YT_API,
		"/youtube/v3/liveBroadcasts/bind",
		&[("id", id.to_string()), ("streamId", stream_id.to_string()), ("part", "id".into())],
	);
	do_json(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_live_streams_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveStreams", &[("part", part.to_string())]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_live_streams_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveStreams", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_live_streams_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/liveStreams", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_live_streams_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/liveStreams", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

// Analytics / reporting

pub fn yt_analytics_reports(
	client: &impl HttpClient,
	token: &str,
	ids: &str,
	start_date: &str,
	end_date: &str,
	metrics: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(
		YT_ANALYTICS,
		"/v2/reports",
		&[
			("ids", ids.to_string()),
			("startDate", start_date.to_string()),
			("endDate", end_date.to_string()),
			("metrics", metrics.to_string()),
		],
	);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_analytics_groups(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_ANALYTICS, "/v2/groups", &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_analytics_group_items(client: &impl HttpClient, token: &str, group_id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_ANALYTICS, "/v2/groupItems", &[("groupId", group_id.to_string())]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_reporting_jobs_list(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_REPORTING, "/v1/jobs", &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_reporting_jobs_create(
	client: &impl HttpClient,
	token: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_REPORTING, "/v1/jobs", &[]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_reporting_jobs_get(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_REPORTING, &format!("/v1/jobs/{id}"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_reporting_jobs_reports(
	client: &impl HttpClient,
	token: &str,
	id: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_REPORTING, &format!("/v1/jobs/{id}/reports"), &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_reporting_reports_list(client: &impl HttpClient, token: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_REPORTING, "/v1/reports", &[]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

// Channel sections / branding / memberships

pub fn yt_channel_sections_list(
	client: &impl HttpClient,
	token: &str,
	part: &str,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/channelSections", &[("part", part.to_string())]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

pub fn yt_channel_sections_insert(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/channelSections", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_channel_sections_update(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/channelSections", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_channel_sections_delete(client: &impl HttpClient, token: &str, id: &str) -> SocialResult<()> {
	let url = make_url(YT_API, "/youtube/v3/channelSections", &[("id", id.to_string())]);
	do_empty(client, HttpMethod::Delete, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_watermarks_set(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<()> {
	let url = make_url(
		YT_API,
		"/youtube/v3/watermarks/set",
		&[("channelId", channel_id.to_string())],
	);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_watermarks_unset(client: &impl HttpClient, token: &str, channel_id: &str) -> SocialResult<()> {
	let url = make_url(
		YT_API,
		"/youtube/v3/watermarks/unset",
		&[("channelId", channel_id.to_string())],
	);
	do_empty(client, HttpMethod::Post, url, auth_headers(token, false, false), None, SocialAction::Publish)
}

pub fn yt_channels_update_branding(
	client: &impl HttpClient,
	token: &str,
	part: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/channels", &[("part", part.to_string())]);
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token, true, false),
		Some(serde_json::to_vec(&body).unwrap()),
		SocialAction::Publish,
	)
}

pub fn yt_members_list(client: &impl HttpClient, token: &str, part: &str) -> SocialResult<serde_json::Value> {
	let url = make_url(YT_API, "/youtube/v3/members", &[("part", part.to_string())]);
	do_json(client, HttpMethod::Get, url, auth_headers(token, false, false), None, SocialAction::FetchStats)
}

// PubSubHubbub

pub fn yt_pubsub_subscribe(
	client: &impl HttpClient,
	token: &str,
	topic: &str,
	callback: &str,
) -> SocialResult<()> {
	let body = format!(
		"hub.mode=subscribe&hub.topic={}&hub.callback={}",
		urlencoding::encode(topic),
		urlencoding::encode(callback)
	)
	.into_bytes();
	let url = format!("{YT_PUBSUB}/subscribe");
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false, true),
		Some(body),
		SocialAction::Publish,
	)
}

pub fn yt_pubsub_unsubscribe(
	client: &impl HttpClient,
	token: &str,
	topic: &str,
	callback: &str,
) -> SocialResult<()> {
	let body = format!(
		"hub.mode=unsubscribe&hub.topic={}&hub.callback={}",
		urlencoding::encode(topic),
		urlencoding::encode(callback)
	)
	.into_bytes();
	let url = format!("{YT_PUBSUB}/subscribe");
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, false, true),
		Some(body),
		SocialAction::Publish,
	)
}

