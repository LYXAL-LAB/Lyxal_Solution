use serde::{Deserialize, Serialize};

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::{ProviderKind, SocialAction};

const TIKTOK_API: &str = "https://open.tiktokapis.com";

fn auth_headers(token: &str, json: bool) -> HttpHeaders {
	let mut h = HttpHeaders::new();
	h.insert("Authorization".into(), format!("Bearer {token}"));
	if json {
		h.insert("Content-Type".into(), "application/json".into());
	}
	h
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(ProviderKind::TikTok),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(ProviderKind::TikTok),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::TikTok),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::TikTok),
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
		timeout: std::time::Duration::from_secs(15),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	serde_json::from_slice::<T>(&resp.body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::TikTok),
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
		timeout: std::time::Duration::from_secs(15),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	Ok(())
}

// Types

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct VideoStatus {
	pub video_id: String,
	pub status: Option<String>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct VideoList {
	pub videos: Vec<serde_json::Value>,
	#[serde(default)]
	pub cursor: Option<String>,
	#[serde(default)]
	pub has_more: Option<bool>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct CommentList {
	pub comments: Vec<serde_json::Value>,
	#[serde(default)]
	pub cursor: Option<String>,
	#[serde(default)]
	pub has_more: Option<bool>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct VideoStats {
	pub video_id: String,
	#[serde(default)]
	pub stats: Option<serde_json::Value>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct UserInfo {
	pub open_id: Option<String>,
	pub display_name: Option<String>,
	pub avatar: Option<String>,
	pub region: Option<String>,
	#[serde(default)]
	pub union_id: Option<String>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct VideoInsights {
	#[serde(default)]
	pub metrics: Option<serde_json::Value>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct UserInsights {
	#[serde(default)]
	pub metrics: Option<serde_json::Value>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct ResearchList {
	#[serde(default)]
	pub items: Vec<serde_json::Value>,
	#[serde(default)]
	pub cursor: Option<String>,
	#[serde(default)]
	pub has_more: Option<bool>,
}

// Content Posting

pub fn init_upload(
	client: &impl HttpClient,
	token: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v2/video/init_upload/");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::Publish,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::Publish,
	)
}

pub fn upload_part(
	client: &impl HttpClient,
	upload_url: &str,
	data: Vec<u8>,
) -> SocialResult<()> {
	let req = HttpRequest {
		method: HttpMethod::Post,
		url: upload_url.to_string(),
		headers: {
			let mut h = HttpHeaders::new();
			h.insert("Content-Type".into(), "application/octet-stream".into());
			h
		},
		body: Some(data),
		timeout: std::time::Duration::from_secs(30),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, SocialAction::Publish) {
		return Err(err);
	}
	Ok(())
}

pub fn publish_video(
	client: &impl HttpClient,
	token: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v2/video/publish/");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::Publish,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::Publish,
	)
}

pub fn query_video_status(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
) -> SocialResult<VideoStatus> {
	let url = format!("{TIKTOK_API}/v2/video/query/?video_id={}", urlencoding::encode(video_id));
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn list_videos(
	client: &impl HttpClient,
	token: &str,
	cursor: Option<String>,
	max_count: Option<u32>,
) -> SocialResult<VideoList> {
	let mut url = format!("{TIKTOK_API}/v2/video/list/");
	let mut q = vec![];
	if let Some(c) = cursor {
		q.push(format!("cursor={}", urlencoding::encode(&c)));
	}
	if let Some(m) = max_count {
		q.push(format!("max_count={m}"));
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn delete_video(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
) -> SocialResult<()> {
	let url = format!("{TIKTOK_API}/v2/video/delete/");
	let body = serde_json::json!({ "video_id": video_id });
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::Publish,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::Publish,
	)
}

pub fn upload_cover(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	data: Vec<u8>,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v2/video/cover/upload/?video_id={}", urlencoding::encode(video_id));
	let req = HttpRequest {
		method: HttpMethod::Post,
		url,
		headers: {
			let mut h = HttpHeaders::new();
			h.insert("Authorization".into(), format!("Bearer {token}"));
			h.insert("Content-Type".into(), "application/octet-stream".into());
			h
		},
		body: Some(data),
		timeout: std::time::Duration::from_secs(30),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, SocialAction::Publish) {
		return Err(err);
	}
	serde_json::from_slice::<serde_json::Value>(&resp.body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(ProviderKind::TikTok),
			SocialAction::Publish,
			"invalid json",
		)
	})
}

// Comments

pub fn list_comments(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	cursor: Option<String>,
	max_count: Option<u32>,
) -> SocialResult<CommentList> {
	let mut url = format!("{TIKTOK_API}/v2/video/comment/list/?video_id={}", urlencoding::encode(video_id));
	let mut q = vec![];
	if let Some(c) = cursor {
		q.push(format!("cursor={}", urlencoding::encode(&c)));
	}
	if let Some(m) = max_count {
		q.push(format!("max_count={m}"));
	}
	if !q.is_empty() {
		url.push('&');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn reply_comment(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	comment_id: &str,
	text: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v2/video/comment/reply/");
	let body = serde_json::json!({
		"video_id": video_id,
		"comment_id": comment_id,
		"text": text,
	});
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchComments,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchComments,
	)
}

pub fn delete_comment(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	comment_id: &str,
) -> SocialResult<()> {
	let url = format!("{TIKTOK_API}/v2/video/comment/delete/");
	let body = serde_json::json!({
		"video_id": video_id,
		"comment_id": comment_id,
	});
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchComments,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchComments,
	)
}

// Video stats / analytics

pub fn fetch_video_stats(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
) -> SocialResult<VideoStats> {
	let url = format!("{TIKTOK_API}/v2/video/data/?video_id={}", urlencoding::encode(video_id));
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// User Info / Insights

pub fn get_user_info(client: &impl HttpClient, token: &str) -> SocialResult<UserInfo> {
	let url = format!("{TIKTOK_API}/user/info/");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn fetch_video_insights(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
) -> SocialResult<VideoInsights> {
	let url = format!("{TIKTOK_API}/v2/video/insights/?video_id={}", urlencoding::encode(video_id));
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn fetch_user_insights(
	client: &impl HttpClient,
	token: &str,
	start_time: Option<i64>,
	end_time: Option<i64>,
	metrics: Option<Vec<String>>,
) -> SocialResult<UserInsights> {
	let mut url = format!("{TIKTOK_API}/v2/user/insights/");
	let mut q = vec![];
	if let Some(s) = start_time {
		q.push(format!("start_time={s}"));
	}
	if let Some(e) = end_time {
		q.push(format!("end_time={e}"));
	}
	if let Some(m) = metrics {
		if !m.is_empty() {
			q.push(format!("metrics={}", urlencoding::encode(&m.join(","))));
		}
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// Comment actions (like/pin)

pub fn like_comment(
	client: &impl HttpClient,
	token: &str,
	comment_id: &str,
	like: bool,
) -> SocialResult<()> {
	let url = format!("{TIKTOK_API}/v2/video/comment/like/");
	let body = serde_json::json!({
		"comment_id": comment_id,
		"action": if like { "like" } else { "unlike" },
	});
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchComments,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchComments,
	)
}

pub fn pin_comment(
	client: &impl HttpClient,
	token: &str,
	comment_id: &str,
	pin: bool,
) -> SocialResult<()> {
	let url = format!("{TIKTOK_API}/v2/video/comment/pin/");
	let body = serde_json::json!({
		"comment_id": comment_id,
		"action": if pin { "pin" } else { "unpin" },
	});
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchComments,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchComments,
	)
}

// Display / Embed

pub fn display_get_video(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v1/display/video/?video_id={}", urlencoding::encode(video_id));
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn display_get_creator(
	client: &impl HttpClient,
	token: &str,
	creator_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v1/display/creator/?creator_id={}", urlencoding::encode(creator_id));
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn embed_oembed(
	client: &impl HttpClient,
	url: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("https://www.tiktok.com/oembed?url={}", urlencoding::encode(url));
	do_json(
		client,
		HttpMethod::Get,
		url,
		HttpHeaders::new(),
		None,
		SocialAction::FetchStats,
	)
}

// Research API

pub fn research_video_info(
	client: &impl HttpClient,
	token: &str,
	video_ids: Vec<String>,
) -> SocialResult<serde_json::Value> {
	let joined = video_ids.join(",");
	let url = format!(
		"{TIKTOK_API}/v2/research/video/info/?video_ids={}",
		urlencoding::encode(&joined)
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

pub fn research_video_comments(
	client: &impl HttpClient,
	token: &str,
	video_id: &str,
	cursor: Option<String>,
	max_count: Option<u32>,
) -> SocialResult<CommentList> {
	let mut url = format!("{TIKTOK_API}/v2/research/video/comment/list/?video_id={}", urlencoding::encode(video_id));
	let mut q = vec![];
	if let Some(c) = cursor {
		q.push(format!("cursor={}", urlencoding::encode(&c)));
	}
	if let Some(m) = max_count {
		q.push(format!("max_count={m}"));
	}
	if !q.is_empty() {
		url.push('&');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchComments,
	)
}

pub fn research_video_search(
	client: &impl HttpClient,
	token: &str,
	query: &str,
	start_time: Option<i64>,
	end_time: Option<i64>,
	cursor: Option<String>,
	max_count: Option<u32>,
) -> SocialResult<ResearchList> {
	let mut url = format!("{TIKTOK_API}/v2/research/video/search/?query={}", urlencoding::encode(query));
	let mut q = vec![];
	if let Some(s) = start_time {
		q.push(format!("start_time={s}"));
	}
	if let Some(e) = end_time {
		q.push(format!("end_time={e}"));
	}
	if let Some(c) = cursor {
		q.push(format!("cursor={}", urlencoding::encode(&c)));
	}
	if let Some(m) = max_count {
		q.push(format!("max_count={m}"));
	}
	if !q.is_empty() {
		url.push('&');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn research_user_info(
	client: &impl HttpClient,
	token: &str,
	user_ids: Vec<String>,
) -> SocialResult<serde_json::Value> {
	let joined = user_ids.join(",");
	let url = format!(
		"{TIKTOK_API}/v2/research/user/info/?user_ids={}",
		urlencoding::encode(&joined)
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

pub fn research_hashtag_info(
	client: &impl HttpClient,
	token: &str,
	hashtag_ids: Vec<String>,
) -> SocialResult<serde_json::Value> {
	let joined = hashtag_ids.join(",");
	let url = format!(
		"{TIKTOK_API}/v2/research/hashtag/info/?hashtag_ids={}",
		urlencoding::encode(&joined)
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

pub fn research_hashtag_videos(
	client: &impl HttpClient,
	token: &str,
	hashtag_id: &str,
	cursor: Option<String>,
	max_count: Option<u32>,
) -> SocialResult<ResearchList> {
	let mut url = format!(
		"{TIKTOK_API}/v2/research/hashtag/video/list/?hashtag_id={}",
		urlencoding::encode(hashtag_id)
	);
	let mut q = vec![];
	if let Some(c) = cursor {
		q.push(format!("cursor={}", urlencoding::encode(&c)));
	}
	if let Some(m) = max_count {
		q.push(format!("max_count={m}"));
	}
	if !q.is_empty() {
		url.push('&');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// Data Portability

pub fn data_portability_add_request(
	client: &impl HttpClient,
	token: &str,
	user_id: &str,
	data_types: Vec<String>,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v1/data_portability/add_data_request");
	let body = serde_json::json!({
		"user_id": user_id,
		"data_types": data_types,
	});
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchStats,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchStats,
	)
}

pub fn data_portability_check_status(
	client: &impl HttpClient,
	token: &str,
	request_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!(
		"{TIKTOK_API}/v1/data_portability/check_data_request_status?request_id={}",
		urlencoding::encode(request_id)
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

pub fn data_portability_cancel_request(
	client: &impl HttpClient,
	token: &str,
	request_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/v1/data_portability/cancel_data_request");
	let body = serde_json::json!({ "request_id": request_id });
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchStats,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchStats,
	)
}

// Commercial Content

pub fn commercial_search(
	client: &impl HttpClient,
	token: &str,
	query: &str,
	page: Option<u32>,
	page_size: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut url = format!("{TIKTOK_API}/commercial_content/search?query={}", urlencoding::encode(query));
	let mut q = vec![];
	if let Some(p) = page {
		q.push(format!("page={p}"));
	}
	if let Some(ps) = page_size {
		q.push(format!("page_size={ps}"));
	}
	if !q.is_empty() {
		url.push('&');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

pub fn commercial_detail(
	client: &impl HttpClient,
	token: &str,
	id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/commercial_content/detail?id={}", urlencoding::encode(id));
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token, false),
		None,
		SocialAction::FetchStats,
	)
}

// Webhooks (simplifiés)

pub fn webhooks_subscribe(
	client: &impl HttpClient,
	token: &str,
	callback_url: &str,
	events: Vec<String>,
	secret: Option<String>,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/webhooks/subscribe");
	let body = serde_json::json!({
		"callback_url": callback_url,
		"events": events,
		"secret": secret,
	});
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchStats,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchStats,
	)
}

pub fn webhooks_unsubscribe(
	client: &impl HttpClient,
	token: &str,
	subscription_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{TIKTOK_API}/webhooks/unsubscribe");
	let body = serde_json::json!({ "subscription_id": subscription_id });
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(ProviderKind::TikTok),
			SocialAction::FetchStats,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token, true),
		Some(payload),
		SocialAction::FetchStats,
	)
}

