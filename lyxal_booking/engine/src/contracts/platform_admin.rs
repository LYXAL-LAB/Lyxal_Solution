/**
 * 🏛️ LYXAL OS — DTOs Contrats pour le Module Platform SuperAdmin
 */

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformMetricsResponse {
    pub total_tenants: u64,
    pub total_users: u64,
    pub total_bookings: u64,
    pub total_audit_logs: u64,
    pub system_status: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformTenantItem {
    pub id: String,
    pub name: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformTenantsPage {
    pub tenants: Vec<PlatformTenantItem>,
    pub limit: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformUserItem {
    pub id: String,
    pub email: String,
    pub name: String,
    pub role: String,
    pub tenant_id: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformUsersPage {
    pub users: Vec<PlatformUserItem>,
    pub limit: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformAuditLogEntry {
    pub id: String,
    pub tenant_id: String,
    pub actor_id: String,
    pub action: String,
    pub target_id: Option<String>,
    pub new_role: Option<String>,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformAuditLogsPage {
    pub logs: Vec<PlatformAuditLogEntry>,
    pub limit: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlatformSettingsResponse {
    pub maintenance_mode: bool,
    pub max_users_per_tenant: u32,
    pub audit_retention_days: u32,
    pub security_policy: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdatePlatformSettingsRequest {
    pub maintenance_mode: Option<bool>,
    pub max_users_per_tenant: Option<u32>,
    pub audit_retention_days: Option<u32>,
    pub security_policy: Option<String>,
}
