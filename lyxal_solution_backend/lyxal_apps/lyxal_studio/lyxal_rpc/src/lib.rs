use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct RpcError {
    pub message: String,
    pub code: i32,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum AuthContext {
    User { user_id: String },
    Token { auth_token: String, owner_id: String },
    Service,
    Anonymous,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AppContext {
    pub authorization: AuthContext,
    pub project_id: Option<String>,
}

