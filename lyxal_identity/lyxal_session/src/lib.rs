//! Lyxal Session Module
//!
//! This module manages user sessions and interaction states, including:
//! - Session creation and validation
//! - Session persistence using PostgreSQL
//! - Cookie management integration via tower-sessions
//! - Interaction flows tracking

pub mod middleware;
pub mod session;
pub mod store;

pub use middleware::*;
pub use session::{Session, SessionManager};
pub use store::{SessionConfig, SessionStore};

/// Result type for Lyxal Session operations
pub type SessionResult<T> = Result<T, lyxal_core::CoreError>;
