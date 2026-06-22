use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

/// Request body for creating a new role.
#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateRoleRequest {
    pub name: String,
    pub description: Option<String>,
    pub tenant_id: Option<Uuid>,
    pub is_default: bool,
}

/// Request body for updating an existing role.
#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateRoleRequest {
    pub name: Option<String>,
    pub description: Option<String>,
    pub is_default: Option<bool>,
}

/// Request body for creating a new permission.
#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreatePermissionRequest {
    pub resource_id: String,
    pub action: String,
    pub description: Option<String>,
}

/// Request body for assigning a role to a user.
#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct RoleAssignmentRequest {
    pub user_id: Uuid,
    pub role_id: Uuid,
    pub tenant_id: Option<Uuid>,
}

/// Simplified view of a role with its permissions.
#[derive(Debug, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct RoleDetail {
    pub id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub tenant_id: Option<Uuid>,
    pub permissions: Vec<String>,
    pub created_at: DateTime<Utc>,
}

