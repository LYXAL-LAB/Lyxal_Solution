use std::collections::HashMap;

use serde::{Deserialize, Serialize};

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::runtime::http::{HttpClient, HttpHeaders, HttpMethod, HttpRequest};
use crate::types::SocialAction;

const DISCORD_API: &str = "https://discord.com/api/v10";

fn auth_headers(token: &str) -> HttpHeaders {
	let mut h = HttpHeaders::new();
	h.insert("Authorization".into(), format!("Bot {token}"));
	h.insert("Content-Type".into(), "application/json".into());
	h
}

fn map_status(code: u16, action: SocialAction) -> Option<SocialError> {
	match code {
		200..=299 => None,
		400 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			action,
			"invalid argument",
		)),
		401 | 403 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PERMISSION_DENIED,
			Some(crate::types::ProviderKind::Discord),
			action,
			"permission denied",
		)),
		429 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_RATE_LIMITED,
			Some(crate::types::ProviderKind::Discord),
			action,
			"rate limited",
		)),
		500..=599 => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(crate::types::ProviderKind::Discord),
			action,
			"provider error",
		)),
		_ => Some(SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(crate::types::ProviderKind::Discord),
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
		timeout: std::time::Duration::from_secs(10),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	serde_json::from_slice::<T>(&resp.body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_PROVIDER_ERROR,
			Some(crate::types::ProviderKind::Discord),
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
		timeout: std::time::Duration::from_secs(10),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, action) {
		return Err(err);
	}
	Ok(())
}

// Channels

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Channel {
	pub id: String,
	pub name: Option<String>,
	#[serde(default)]
	pub r#type: Option<u8>,
}

pub fn get_channel(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<Channel> {
	let url = format!("{DISCORD_API}/channels/{channel_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn update_channel(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	body: serde_json::Value,
) -> SocialResult<Channel> {
	let url = format!("{DISCORD_API}/channels/{channel_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn delete_channel(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<Channel> {
	let url = format!("{DISCORD_API}/channels/{channel_id}");
	do_json(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

// Messages

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Message {
	pub id: String,
	pub channel_id: String,
	pub content: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct CreateMessageRequest {
	pub content: Option<String>,
	#[serde(skip_serializing_if = "Option::is_none")]
	pub embeds: Option<Vec<serde_json::Value>>,
	#[serde(skip_serializing_if = "Option::is_none")]
	pub components: Option<Vec<serde_json::Value>>,
	#[serde(skip_serializing_if = "Option::is_none")]
	pub sticker_ids: Option<Vec<String>>,
}

pub fn list_messages(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	query: HashMap<&str, String>,
) -> SocialResult<Vec<Message>> {
	let mut url = format!("{DISCORD_API}/channels/{channel_id}/messages");
	if !query.is_empty() {
		let q = query
			.iter()
			.map(|(k, v)| format!("{k}={}", urlencoding::encode(v)))
			.collect::<Vec<_>>()
			.join("&");
		url.push('?');
		url.push_str(&q);
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn get_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
) -> SocialResult<Message> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/messages/{message_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn create_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	body: &CreateMessageRequest,
) -> SocialResult<Message> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/messages");
	let payload = serde_json::to_vec(body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn edit_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	body: &CreateMessageRequest,
) -> SocialResult<Message> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/messages/{message_id}");
	let payload = serde_json::to_vec(body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn delete_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/messages/{message_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

#[derive(Debug, Serialize)]
struct BulkDeleteBody {
	messages: Vec<String>,
}

pub fn bulk_delete_messages(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_ids: Vec<String>,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/messages/bulk-delete");
	let payload = serde_json::to_vec(&BulkDeleteBody { messages: message_ids }).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

// Reactions
pub fn add_reaction(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	emoji: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/channels/{channel_id}/messages/{message_id}/reactions/{emoji}/@me"
	);
	do_empty(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn remove_reaction(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	emoji: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/channels/{channel_id}/messages/{message_id}/reactions/{emoji}/@me"
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn remove_user_reaction(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	emoji: &str,
	user_id: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/channels/{channel_id}/messages/{message_id}/reactions/{emoji}/{user_id}"
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn list_reactions(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	emoji: &str,
	after: Option<String>,
	limit: Option<u32>,
) -> SocialResult<Vec<serde_json::Value>> {
	let mut url = format!(
		"{DISCORD_API}/channels/{channel_id}/messages/{message_id}/reactions/{emoji}"
	);
	let mut q = vec![];
	if let Some(a) = after {
		q.push(format!("after={}", urlencoding::encode(&a)));
	}
	if let Some(l) = limit {
		q.push(format!("limit={l}"));
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn clear_reactions(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/channels/{channel_id}/messages/{message_id}/reactions"
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn clear_reactions_emoji(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	emoji: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/channels/{channel_id}/messages/{message_id}/reactions/{emoji}"
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

// Pins
pub fn list_pins(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<Vec<Message>> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/pins");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn pin_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/pins/{message_id}");
	do_empty(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn unpin_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/pins/{message_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

// Threads

#[derive(Debug, Deserialize, Serialize)]
pub struct ThreadList {
	pub threads: Vec<Channel>,
	#[serde(default)]
	pub has_more: Option<bool>,
}

pub fn start_thread_from_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	message_id: &str,
	body: serde_json::Value,
) -> SocialResult<Channel> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/messages/{message_id}/threads");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn start_thread_without_message(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	body: serde_json::Value,
) -> SocialResult<Channel> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/threads");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

fn build_thread_query(before: Option<String>, limit: Option<u32>) -> String {
	let mut q = vec![];
	if let Some(b) = before {
		q.push(format!("before={}", urlencoding::encode(&b)));
	}
	if let Some(l) = limit {
		q.push(format!("limit={l}"));
	}
	if q.is_empty() {
		String::new()
	} else {
		format!("?{}", q.join("&"))
	}
}

pub fn list_archived_public_threads(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	before: Option<String>,
	limit: Option<u32>,
) -> SocialResult<ThreadList> {
	let mut url = format!("{DISCORD_API}/channels/{channel_id}/threads/archived/public");
	let q = build_thread_query(before, limit);
	url.push_str(&q);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn list_archived_private_threads(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	before: Option<String>,
	limit: Option<u32>,
) -> SocialResult<ThreadList> {
	let mut url = format!("{DISCORD_API}/channels/{channel_id}/threads/archived/private");
	let q = build_thread_query(before, limit);
	url.push_str(&q);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn list_active_threads(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<ThreadList> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/threads/active");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn add_thread_member(
	client: &impl HttpClient,
	token: &str,
	thread_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/channels/{thread_id}/thread-members/@me");
	do_empty(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn remove_thread_member(
	client: &impl HttpClient,
	token: &str,
	thread_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/channels/{thread_id}/thread-members/@me");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn get_thread_member(
	client: &impl HttpClient,
	token: &str,
	thread_id: &str,
	user_id: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{DISCORD_API}/channels/{thread_id}/thread-members/{user_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

// Webhooks

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Webhook {
	pub id: String,
	pub token: Option<String>,
	pub name: Option<String>,
}

pub fn create_webhook(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	body: serde_json::Value,
) -> SocialResult<Webhook> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/webhooks");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn list_channel_webhooks(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<Vec<Webhook>> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/webhooks");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn get_webhook(
	client: &impl HttpClient,
	token: &str,
	webhook_id: &str,
) -> SocialResult<Webhook> {
	let url = format!("{DISCORD_API}/webhooks/{webhook_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn update_webhook(
	client: &impl HttpClient,
	token: &str,
	webhook_id: &str,
	body: serde_json::Value,
) -> SocialResult<Webhook> {
	let url = format!("{DISCORD_API}/webhooks/{webhook_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn delete_webhook(
	client: &impl HttpClient,
	token: &str,
	webhook_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/webhooks/{webhook_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

pub fn execute_webhook(
	client: &impl HttpClient,
	webhook_id: &str,
	webhook_token: &str,
	body: serde_json::Value,
	wait: bool,
	thread_id: Option<String>,
) -> SocialResult<Option<Message>> {
	let mut url = format!("{DISCORD_API}/webhooks/{webhook_id}/{webhook_token}");
	let mut q = vec![];
	if wait {
		q.push("wait=true".to_string());
	}
	if let Some(t) = thread_id {
		q.push(format!("thread_id={}", urlencoding::encode(&t)));
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	let req = HttpRequest {
		method: HttpMethod::Post,
		url,
		headers: {
			let mut h = HttpHeaders::new();
			h.insert("Content-Type".into(), "application/json".into());
			h
		},
		body: Some(payload),
		timeout: std::time::Duration::from_secs(10),
		allow_redirects: false,
	};
	let resp = client.send(req)?;
	if let Some(err) = map_status(resp.status, SocialAction::SendMessage) {
		return Err(err);
	}
	if wait {
		let m: Message = serde_json::from_slice(&resp.body).map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_PROVIDER_ERROR,
				Some(crate::types::ProviderKind::Discord),
				SocialAction::SendMessage,
				"invalid json",
			)
		})?;
		Ok(Some(m))
	} else {
		Ok(None)
	}
}

pub fn edit_webhook_message(
	client: &impl HttpClient,
	webhook_id: &str,
	webhook_token: &str,
	message_id: &str,
	body: serde_json::Value,
) -> SocialResult<Message> {
	let url = format!("{DISCORD_API}/webhooks/{webhook_id}/{webhook_token}/messages/{message_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		{
			let mut h = HttpHeaders::new();
			h.insert("Content-Type".into(), "application/json".into());
			h
		},
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn delete_webhook_message(
	client: &impl HttpClient,
	webhook_id: &str,
	webhook_token: &str,
	message_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/webhooks/{webhook_id}/{webhook_token}/messages/{message_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		HttpHeaders::new(),
		None,
		SocialAction::SendMessage,
	)
}

// Invites

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Invite {
	pub code: String,
}

pub fn create_invite(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	body: serde_json::Value,
) -> SocialResult<Invite> {
	let url = format!("{DISCORD_API}/channels/{channel_id}/invites");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::SendMessage,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::SendMessage,
	)
}

pub fn get_invite(
	client: &impl HttpClient,
	token: &str,
	invite_code: &str,
) -> SocialResult<Invite> {
	let url = format!("{DISCORD_API}/invites/{invite_code}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn delete_invite(
	client: &impl HttpClient,
	token: &str,
	invite_code: &str,
) -> SocialResult<Invite> {
	let url = format!("{DISCORD_API}/invites/{invite_code}");
	do_json(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::SendMessage,
	)
}

// Guilds / Members / Roles / Bans

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Guild {
	pub id: String,
	pub name: Option<String>,
}

pub fn get_guild(client: &impl HttpClient, token: &str, guild_id: &str) -> SocialResult<Guild> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn update_guild(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<Guild> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_guild(client: &impl HttpClient, token: &str, guild_id: &str) -> SocialResult<Guild> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}");
	do_json(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn list_guild_channels(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
) -> SocialResult<Vec<Channel>> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/channels");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn create_guild_channel(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<Channel> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/channels");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn reorder_guild_channels(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/channels");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Member {
	pub user: Option<serde_json::Value>,
	pub nick: Option<String>,
	pub roles: Option<Vec<String>>,
}

pub fn list_guild_members(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	after: Option<String>,
	limit: Option<u32>,
) -> SocialResult<Vec<Member>> {
	let mut url = format!("{DISCORD_API}/guilds/{guild_id}/members");
	let mut q = vec![];
	if let Some(a) = after {
		q.push(format!("after={}", urlencoding::encode(&a)));
	}
	if let Some(l) = limit {
		q.push(format!("limit={l}"));
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn get_guild_member(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
) -> SocialResult<Member> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/members/{user_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn add_guild_member(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
	body: serde_json::Value,
) -> SocialResult<Member> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/members/{user_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn modify_guild_member(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
	body: serde_json::Value,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/members/{user_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn remove_guild_member(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/members/{user_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn ban_guild_member(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
	body: serde_json::Value,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/bans/{user_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn unban_guild_member(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/bans/{user_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Role {
	pub id: String,
	pub name: Option<String>,
}

pub fn list_roles(client: &impl HttpClient, token: &str, guild_id: &str) -> SocialResult<Vec<Role>> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/roles");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn create_role(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<Role> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/roles");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn reorder_roles(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<Vec<Role>> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/roles");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn update_role(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	role_id: &str,
	body: serde_json::Value,
) -> SocialResult<Role> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/roles/{role_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_role(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	role_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/roles/{role_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

// Audit logs
pub fn get_audit_logs(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: Option<String>,
	action_type: Option<u32>,
	before: Option<String>,
	limit: Option<u32>,
) -> SocialResult<serde_json::Value> {
	let mut url = format!("{DISCORD_API}/guilds/{guild_id}/audit-logs");
	let mut q = vec![];
	if let Some(u) = user_id {
		q.push(format!("user_id={}", urlencoding::encode(&u)));
	}
	if let Some(a) = action_type {
		q.push(format!("action_type={a}"));
	}
	if let Some(b) = before {
		q.push(format!("before={}", urlencoding::encode(&b)));
	}
	if let Some(l) = limit {
		q.push(format!("limit={l}"));
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

// Templates

pub fn get_template(
	client: &impl HttpClient,
	token: &str,
	code: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{DISCORD_API}/guilds/templates/{code}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn list_guild_templates(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
) -> SocialResult<Vec<serde_json::Value>> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/templates");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn create_guild_template(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/templates");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn sync_template(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	code: &str,
) -> SocialResult<serde_json::Value> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/templates/{code}");
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn update_template(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	code: &str,
	body: serde_json::Value,
) -> SocialResult<serde_json::Value> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/templates/{code}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_template(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	code: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/templates/{code}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

// Voice states
pub fn modify_self_voice_state(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/voice-states/@me");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn modify_user_voice_state(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	user_id: &str,
	body: serde_json::Value,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/voice-states/{user_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_empty(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn list_voice_regions(client: &impl HttpClient) -> SocialResult<Vec<serde_json::Value>> {
	let url = format!("{DISCORD_API}/voice/regions");
	do_json(
		client,
		HttpMethod::Get,
		url,
		HttpHeaders::new(),
		None,
		SocialAction::FetchMessages,
	)
}

// Scheduled Events

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct ScheduledEvent {
	pub id: String,
	pub name: String,
}

pub fn list_scheduled_events(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	with_user_count: Option<bool>,
) -> SocialResult<Vec<ScheduledEvent>> {
	let mut url = format!("{DISCORD_API}/guilds/{guild_id}/scheduled-events");
	if let Some(flag) = with_user_count {
		url.push_str(&format!("?with_user_count={flag}"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn create_scheduled_event(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<ScheduledEvent> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/scheduled-events");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn get_scheduled_event(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	event_id: &str,
	with_user_count: Option<bool>,
) -> SocialResult<ScheduledEvent> {
	let mut url =
		format!("{DISCORD_API}/guilds/{guild_id}/scheduled-events/{event_id}");
	if let Some(flag) = with_user_count {
		url.push_str(&format!("?with_user_count={flag}"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn update_scheduled_event(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	event_id: &str,
	body: serde_json::Value,
) -> SocialResult<ScheduledEvent> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/scheduled-events/{event_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_scheduled_event(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	event_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/scheduled-events/{event_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

#[derive(Debug, Deserialize, Serialize)]
pub struct ScheduledEventUser {
	pub user: serde_json::Value,
}

pub fn list_scheduled_event_users(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	event_id: &str,
	limit: Option<u32>,
	with_member: Option<bool>,
	before: Option<String>,
	after: Option<String>,
) -> SocialResult<Vec<ScheduledEventUser>> {
	let mut url =
		format!("{DISCORD_API}/guilds/{guild_id}/scheduled-events/{event_id}/users");
	let mut q = vec![];
	if let Some(l) = limit {
		q.push(format!("limit={l}"));
	}
	if let Some(b) = before {
		q.push(format!("before={}", urlencoding::encode(&b)));
	}
	if let Some(a) = after {
		q.push(format!("after={}", urlencoding::encode(&a)));
	}
	if let Some(m) = with_member {
		q.push(format!("with_member={m}"));
	}
	if !q.is_empty() {
		url.push('?');
		url.push_str(&q.join("&"));
	}
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

// Stage instances

#[derive(Debug, Deserialize, Serialize)]
pub struct StageInstance {
	pub channel_id: String,
	pub topic: String,
}

pub fn create_stage_instance(
	client: &impl HttpClient,
	token: &str,
	body: serde_json::Value,
) -> SocialResult<StageInstance> {
	let url = format!("{DISCORD_API}/stage-instances");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn get_stage_instance(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<StageInstance> {
	let url = format!("{DISCORD_API}/stage-instances/{channel_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn update_stage_instance(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
	body: serde_json::Value,
) -> SocialResult<StageInstance> {
	let url = format!("{DISCORD_API}/stage-instances/{channel_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_stage_instance(
	client: &impl HttpClient,
	token: &str,
	channel_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/stage-instances/{channel_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

// Auto moderation

#[derive(Debug, Deserialize, Serialize)]
pub struct AutoModRule {
	pub id: String,
	pub name: String,
}

pub fn list_automod_rules(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
) -> SocialResult<Vec<AutoModRule>> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/auto-moderation/rules");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn get_automod_rule(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	rule_id: &str,
) -> SocialResult<AutoModRule> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/auto-moderation/rules/{rule_id}");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::FetchMessages,
	)
}

pub fn create_automod_rule(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<AutoModRule> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/auto-moderation/rules");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn update_automod_rule(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	rule_id: &str,
	body: serde_json::Value,
) -> SocialResult<AutoModRule> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/auto-moderation/rules/{rule_id}");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_automod_rule(
	client: &impl HttpClient,
	token: &str,
	guild_id: &str,
	rule_id: &str,
) -> SocialResult<()> {
	let url = format!("{DISCORD_API}/guilds/{guild_id}/auto-moderation/rules/{rule_id}");
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

// Application Commands (Global & Guild)

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Command {
	pub id: String,
	pub name: String,
}

pub fn list_global_commands(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
) -> SocialResult<Vec<Command>> {
	let url = format!("{DISCORD_API}/applications/{application_id}/commands");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn create_global_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	body: serde_json::Value,
) -> SocialResult<Command> {
	let url = format!("{DISCORD_API}/applications/{application_id}/commands");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn get_global_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	command_id: &str,
) -> SocialResult<Command> {
	let url = format!(
		"{DISCORD_API}/applications/{application_id}/commands/{command_id}"
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn update_global_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	command_id: &str,
	body: serde_json::Value,
) -> SocialResult<Command> {
	let url = format!(
		"{DISCORD_API}/applications/{application_id}/commands/{command_id}"
	);
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_global_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	command_id: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/applications/{application_id}/commands/{command_id}"
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn bulk_overwrite_global_commands(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	body: serde_json::Value,
) -> SocialResult<Vec<Command>> {
	let url = format!("{DISCORD_API}/applications/{application_id}/commands");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn list_guild_commands(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	guild_id: &str,
) -> SocialResult<Vec<Command>> {
	let url = format!("{DISCORD_API}/applications/{application_id}/guilds/{guild_id}/commands");
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn create_guild_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<Command> {
	let url = format!("{DISCORD_API}/applications/{application_id}/guilds/{guild_id}/commands");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Post,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn get_guild_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	guild_id: &str,
	command_id: &str,
) -> SocialResult<Command> {
	let url = format!(
		"{DISCORD_API}/applications/{application_id}/guilds/{guild_id}/commands/{command_id}"
	);
	do_json(
		client,
		HttpMethod::Get,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn update_guild_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	guild_id: &str,
	command_id: &str,
	body: serde_json::Value,
) -> SocialResult<Command> {
	let url = format!(
		"{DISCORD_API}/applications/{application_id}/guilds/{guild_id}/commands/{command_id}"
	);
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Patch,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

pub fn delete_guild_command(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	guild_id: &str,
	command_id: &str,
) -> SocialResult<()> {
	let url = format!(
		"{DISCORD_API}/applications/{application_id}/guilds/{guild_id}/commands/{command_id}"
	);
	do_empty(
		client,
		HttpMethod::Delete,
		url,
		auth_headers(token),
		None,
		SocialAction::Connect,
	)
}

pub fn bulk_overwrite_guild_commands(
	client: &impl HttpClient,
	token: &str,
	application_id: &str,
	guild_id: &str,
	body: serde_json::Value,
) -> SocialResult<Vec<Command>> {
	let url = format!("{DISCORD_API}/applications/{application_id}/guilds/{guild_id}/commands");
	let payload = serde_json::to_vec(&body).map_err(|_| {
		SocialError::new(
			SocialErrorCode::SOCIAL_INVALID_ARGUMENT,
			Some(crate::types::ProviderKind::Discord),
			SocialAction::Connect,
			"invalid body",
		)
	})?;
	do_json(
		client,
		HttpMethod::Put,
		url,
		auth_headers(token),
		Some(payload),
		SocialAction::Connect,
	)
}

