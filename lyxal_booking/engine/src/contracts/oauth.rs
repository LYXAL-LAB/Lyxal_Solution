use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetOAuthProviderParams {
    pub provider: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConsumeOAuthStateParams {
    pub state: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SaveOAuthTokensParams {
    pub user_id: String,
    pub provider: String,
    pub encrypted_access_token: String,
    pub encrypted_refresh_token: Option<String>,
    pub expires_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OAuthProviderResponse {
    pub provider: String,
    pub name: String,
    pub configured: bool,
    pub connected: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OAuthAuthorizeResponse {
    pub provider: String,
    pub authorize_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OAuthCallbackQuery {
    pub code: Option<String>,
    pub state: String,
    pub error: Option<String>,
    pub error_description: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OAuthCallbackResponse {
    pub success: bool,
    pub provider: String,
    pub redirect_url: String,
}
