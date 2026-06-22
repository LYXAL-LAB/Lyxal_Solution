use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Debug, Serialize, Deserialize, Clone, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Application {
    pub id: String,
    pub name: String,
    pub secret: String,
    pub description: Option<String>,
    pub is_first_party: bool,
    pub app_type: ApplicationType,
    #[sqlx(json)]
    pub redirect_uris: serde_json::Value,
    #[sqlx(json)]
    pub post_logout_redirect_uris: serde_json::Value,
    #[sqlx(json)]
    pub allowed_cors_origins: serde_json::Value,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq, Eq, ToSchema, sqlx::Type)]
#[serde(rename_all = "snake_case")]
#[sqlx(rename_all = "snake_case", type_name = "varchar")]
pub enum ApplicationType {
    Native,
    Spa,
    TraditionalWeb,
    MachineToMachine,
}
