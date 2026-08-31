use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetAuthAccountParams<'a> {
    pub username: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthenticatedUser {
    pub user_id: String,
    pub role: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthenticatedAdmin {
    pub user_id: String,
    pub role: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthAccountRecord {
    pub id: String,
    pub username: String,
    pub email: String,
    pub role: String,
    pub password_hash: String,
    pub disabled: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateSessionParams<'a> {
    pub account_id: &'a str,
    pub token_hash: &'a str,
    pub expires_at: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetCurrentSessionParams<'a> {
    pub token_hash: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RevokeSessionParams<'a> {
    pub token_hash: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RevokeAllSessionsParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthSessionResponse {
    pub user_id: String,
    pub username: String,
    pub email: String,
    pub role: String,
    pub expires_at: String,
    pub token: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LogoutResponse {
    pub success: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CurrentSessionResponse {
    pub active: bool,
    pub user: Option<AuthSessionResponse>,
}
