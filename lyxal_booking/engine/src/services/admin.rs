/**
 * 🏛️ LYXAL OS — Services Rust Neutres pour Tenant Admin
 */

use serde::Serialize;
use crate::contracts::admin::*;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};

#[derive(Debug, Clone, Serialize)]
struct GetTenantMetricsParams {
    tenant_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct ListTenantUsersParams {
    tenant_id: String,
    limit: u32,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateTenantUserRoleParams {
    tenant_id: String,
    actor_id: String,
    target_user_id: String,
    new_role: String,
}

#[derive(Debug, Clone, Serialize)]
struct GetTenantAuditLogsParams {
    tenant_id: String,
    limit: u32,
}

#[derive(Debug, Clone, Serialize)]
struct GetTenantSettingsParams {
    tenant_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateTenantSettingsParams {
    tenant_id: String,
    branding_name: Option<String>,
    default_timezone: Option<String>,
    allow_public_bookings: Option<bool>,
}

pub async fn get_tenant_metrics<S: LyxalSurrealCall + Sync>(
    store: &S,
    tenant_id: &str,
) -> Result<TenantMetricsResponse, LyxalSurrealError> {
    let params = GetTenantMetricsParams {
        tenant_id: tenant_id.to_string(),
    };
    store.call_fn("booking_admin_get_tenant_metrics", params).await
}

pub async fn list_tenant_users<S: LyxalSurrealCall + Sync>(
    store: &S,
    tenant_id: &str,
    limit: Option<u32>,
) -> Result<TenantUsersPage, LyxalSurrealError> {
    let params = ListTenantUsersParams {
        tenant_id: tenant_id.to_string(),
        limit: limit.unwrap_or(20),
    };
    store.call_fn("booking_admin_list_tenant_users", params).await
}

pub async fn update_tenant_user_role<S: LyxalSurrealCall + Sync>(
    store: &S,
    tenant_id: &str,
    actor_id: &str,
    target_user_id: &str,
    request: &UpdateTenantUserRoleRequest,
) -> Result<Option<bool>, LyxalSurrealError> {
    let params = UpdateTenantUserRoleParams {
        tenant_id: tenant_id.to_string(),
        actor_id: actor_id.to_string(),
        target_user_id: target_user_id.to_string(),
        new_role: request.role.clone(),
    };
    store.call_fn("booking_admin_update_tenant_user_role", params).await
}

pub async fn get_tenant_audit_logs<S: LyxalSurrealCall + Sync>(
    store: &S,
    tenant_id: &str,
    limit: Option<u32>,
) -> Result<TenantAuditLogsPage, LyxalSurrealError> {
    let params = GetTenantAuditLogsParams {
        tenant_id: tenant_id.to_string(),
        limit: limit.unwrap_or(50),
    };
    store.call_fn("booking_admin_get_tenant_audit_logs", params).await
}

pub async fn get_tenant_settings<S: LyxalSurrealCall + Sync>(
    store: &S,
    tenant_id: &str,
) -> Result<TenantSettingsResponse, LyxalSurrealError> {
    let params = GetTenantSettingsParams {
        tenant_id: tenant_id.to_string(),
    };
    store.call_fn("booking_admin_get_tenant_settings", params).await
}

pub async fn update_tenant_settings<S: LyxalSurrealCall + Sync>(
    store: &S,
    tenant_id: &str,
    request: &UpdateTenantSettingsRequest,
) -> Result<TenantSettingsResponse, LyxalSurrealError> {
    let params = UpdateTenantSettingsParams {
        tenant_id: tenant_id.to_string(),
        branding_name: request.branding_name.clone(),
        default_timezone: request.default_timezone.clone(),
        allow_public_bookings: request.allow_public_bookings,
    };
    store.call_fn("booking_admin_update_tenant_settings", params).await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_update_tenant_user_role_payload() {
        let req = UpdateTenantUserRoleRequest {
            role: "admin".to_string(),
        };
        assert_eq!(req.role, "admin");
    }

    #[test]
    fn test_update_tenant_settings_payload() {
        let req = UpdateTenantSettingsRequest {
            branding_name: Some("Lyxal Enterprise".to_string()),
            default_timezone: Some("Europe/Paris".to_string()),
            allow_public_bookings: Some(true),
        };
        assert_eq!(req.branding_name.as_deref(), Some("Lyxal Enterprise"));
    }
}
