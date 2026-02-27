use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use serde_json::json;
use utoipa::ToSchema;

#[derive(Debug, Serialize, Deserialize, Clone, Default, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct User {
    pub id: String, 
    pub username: Option<String>,
    pub primary_email: Option<String>,
    pub is_email_verified: bool,
    pub primary_phone: Option<String>,
    pub is_phone_verified: bool,
    pub name: Option<String>,
    pub avatar: Option<String>,
    #[sqlx(json)]
    pub custom_data: serde_json::Value,
    pub last_sign_in_at: Option<DateTime<Utc>>,
    pub created_at: i64, 
    pub updated_at: i64,
    pub is_suspended: bool,
    #[serde(skip_serializing)]
    pub password_hash: Option<String>,
    pub application_id: Option<String>,
    #[sqlx(json)]
    pub profile: serde_json::Value,
    #[sqlx(json)]
    pub identities: serde_json::Value,
}

impl Default for User {
    fn default() -> Self {
        Self {
            id: String::new(),
            username: None,
            primary_email: None,
            is_email_verified: false,
            primary_phone: None,
            is_phone_verified: false,
            name: None,
            avatar: None,
            custom_data: json!({}),
            last_sign_in_at: None,
            created_at: 0,
            updated_at: 0,
            is_suspended: false,
            password_hash: None,
            application_id: None,
            profile: json!({}),
            identities: json!({}),
        }
    }
}
