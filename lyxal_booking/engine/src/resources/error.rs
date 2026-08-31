//! Resource Domain Error Types.

use lyxal_surreal::LyxalSurrealError;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ResourceError {
    #[error("Invalid feed URL: {0}")]
    InvalidFeedUrl(String),

    #[error("Feed network request failed: {0}")]
    FeedRequest(#[from] reqwest::Error),

    #[error("Feed size exceeds limit ({0} bytes)")]
    FeedTooLarge(usize),

    #[error("Invalid calendar content: {0}")]
    InvalidCalendar(String),

    #[error("ICS parse error: {0}")]
    Parse(String),

    #[error("SurrealDB store error: {0}")]
    Database(#[from] LyxalSurrealError),
}
