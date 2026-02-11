use crate::types::{Comment, Message};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SocialEvent {
	MessageSent(Message),
	CommentFetched(Comment),
	StatsFetched,
	Published,
}

