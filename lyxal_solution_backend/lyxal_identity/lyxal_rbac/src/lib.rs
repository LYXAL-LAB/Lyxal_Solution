use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct Role {
    pub id: String,
    pub tenant_id: String,
    pub name: String,
    pub description: Option<String>,
    pub is_default: bool,
    pub created_at: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct Scope {
    pub id: String,
    pub tenant_id: String,
    pub resource_id: String,
    pub name: String,
    pub description: Option<String>,
    pub created_at: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct Resource {
    pub id: String,
    pub tenant_id: String,
    pub name: String,
    pub indicator: String, // e.g., "https://api.lyxal.com"
    pub created_at: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserRoleRelation {
    pub user_id: String,
    pub role_id: String,
    pub tenant_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RoleScopeRelation {
    pub role_id: String,
    pub scope_id: String,
    pub tenant_id: String,
}

pub mod access_control;
pub mod middleware;
pub mod models;
pub mod repository;
pub mod services;
