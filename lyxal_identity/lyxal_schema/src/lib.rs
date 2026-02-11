use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

/// Base schema for common identity models.
/// Inspired by Logto's core schemas and enhanced for SQLx mapping.

#[derive(Debug, Serialize, Deserialize, Clone, Default, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct User {
    pub id: Uuid,
    pub username: Option<String>,
    pub primary_email: Option<String>,
    pub is_email_verified: bool,
    pub primary_phone: Option<String>,
    pub is_phone_verified: bool,
    #[serde(skip_serializing)]
    pub password_hash: Option<String>,
    pub name: Option<String>,
    pub avatar: Option<String>,
    #[sqlx(json)]
    pub custom_data: Option<serde_json::Value>,
    pub last_sign_in_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub suspended_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize, Clone, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Application {
    pub id: Uuid,
    pub name: String,
    #[serde(skip_serializing)]
    pub secret: String,
    pub description: Option<String>,
    pub is_first_party: bool,
    #[sqlx(default)]
    pub redirect_uris: Vec<String>,
    #[sqlx(default)]
    pub post_logout_redirect_uris: Vec<String>,
    #[sqlx(default)]
    pub allowed_cors_origins: Vec<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Tenant {
    pub id: Uuid,
    pub name: String,
    pub slug: String,
    pub logo: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Role {
    pub id: Uuid,
    pub tenant_id: Option<Uuid>,
    pub name: String,
    pub description: Option<String>,
    pub is_default: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Permission {
    pub id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub resource_id: String,
    pub action: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone, ToSchema, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct UserRole {
    pub user_id: Uuid,
    pub role_id: Uuid,
    pub tenant_id: Option<Uuid>,
    pub created_at: DateTime<Utc>,
}

/// Enum representing the different types of applications in the system.
#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq, Eq, ToSchema, sqlx::Type)]
#[serde(rename_all = "snake_case")]
#[sqlx(rename_all = "snake_case", type_name = "varchar")]
pub enum ApplicationType {
    Native,
    Spa,
    TraditionalWeb,
    MachineToMachine,
}
