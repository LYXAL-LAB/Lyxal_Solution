use std::collections::HashMap;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum ProviderKind {
	Discord,
	TikTok,
	Meta,
	LinkedIn,
	Snapchat,
	YouTube,
	X,
	GoogleBusiness,
	Unknown,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum SocialAction {
	Connect,
	Disconnect,
	Capabilities,
	Publish,
	SendMessage,
	FetchMessages,
	FetchComments,
	FetchStats,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct ProviderAccountKey {
	pub provider: ProviderKind,
	pub logical_account: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Message {
	pub id: String,
	pub content: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Comment {
	pub id: String,
	pub content: String,
}

pub type ChannelId = String;
pub type MessageContent = String;
pub type PublishPayload = String;
pub type StatsResponse = HashMap<String, i64>;

