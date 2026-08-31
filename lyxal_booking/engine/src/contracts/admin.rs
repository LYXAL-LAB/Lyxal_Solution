/**
 * 🏛️ LYXAL OS — DTOs Contrats pour le Module Admin Tenant
 */

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantMetricsResponse {
    pub total_users: u64,
    pub total_bookings: u64,
    pub pending_bookings: u64,
    pub confirmed_bookings: u64,
    pub cancelled_bookings: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantAdminUserItem {
    pub id: String,
    pub email: String,
    pub name: String,
    pub role: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantUsersPage {
    pub users: Vec<TenantAdminUserItem>,
    pub limit: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTenantUserRoleRequest {
    pub role: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantAuditLogEntry {
    pub id: String,
    pub actor_id: String,
    pub action: String,
    pub target_id: Option<String>,
    pub new_role: Option<String>,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantAuditLogsPage {
    pub logs: Vec<TenantAuditLogEntry>,
    pub limit: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantSettingsResponse {
    pub tenant_id: String,
    pub branding_name: String,
    pub default_timezone: String,
    pub allow_public_bookings: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTenantSettingsRequest {
    pub branding_name: Option<String>,
    pub default_timezone: Option<String>,
    pub allow_public_bookings: Option<bool>,
}
