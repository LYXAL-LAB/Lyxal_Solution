//! Lyxal Session Module - 1:1 Logto Mapping
//! Handles user session persistence and interaction state.

pub mod middleware;
pub mod session;
pub mod store;

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Session {
    pub id: String,
    pub user_id: Option<String>,
    pub created_at: i64,
    pub updated_at: i64,
    pub expires_at: i64,
    pub data: serde_json::Value, // Store custom session data like Logto
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InteractionSession {
    pub id: String,
    pub client_id: String,
    pub session_id: Option<String>,
    pub redirect_uri: String,
    pub expires_at: i64,
    pub data: serde_json::Value,
}
