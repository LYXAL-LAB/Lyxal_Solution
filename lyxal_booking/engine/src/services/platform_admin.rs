/**
 * 🏛️ LYXAL OS — Services Rust Neutres pour Platform SuperAdmin
 */

use serde::Serialize;
use crate::contracts::platform_admin::*;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};

#[derive(Debug, Clone, Default, Serialize)]
struct EmptyPlatformParams {}

#[derive(Debug, Clone, Serialize)]
struct ListPlatformTenantsParams {
    limit: u32,
}

#[derive(Debug, Clone, Serialize)]
struct ListPlatformUsersParams {
    limit: u32,
}

#[derive(Debug, Clone, Serialize)]
struct GetPlatformAuditLogsParams {
    limit: u32,
}

#[derive(Debug, Clone, Serialize)]
struct UpdatePlatformSettingsParams {
    maintenance_mode: Option<bool>,
    max_users_per_tenant: Option<u32>,
    audit_retention_days: Option<u32>,
    security_policy: Option<String>,
}

pub async fn get_platform_metrics<S: LyxalSurrealCall + Sync>(
    store: &S,
) -> Result<PlatformMetricsResponse, LyxalSurrealError> {
    store.call_fn("booking_platform_get_metrics", EmptyPlatformParams::default()).await
}

pub async fn list_platform_tenants<S: LyxalSurrealCall + Sync>(
    store: &S,
    limit: Option<u32>,
) -> Result<PlatformTenantsPage, LyxalSurrealError> {
    let params = ListPlatformTenantsParams {
        limit: limit.unwrap_or(20),
    };
    store.call_fn("booking_platform_list_tenants", params).await
}

pub async fn list_platform_users<S: LyxalSurrealCall + Sync>(
    store: &S,
    limit: Option<u32>,
) -> Result<PlatformUsersPage, LyxalSurrealError> {
    let params = ListPlatformUsersParams {
        limit: limit.unwrap_or(50),
    };
    store.call_fn("booking_platform_list_users", params).await
}

pub async fn get_platform_audit_logs<S: LyxalSurrealCall + Sync>(
    store: &S,
    limit: Option<u32>,
) -> Result<PlatformAuditLogsPage, LyxalSurrealError> {
    let params = GetPlatformAuditLogsParams {
        limit: limit.unwrap_or(100),
    };
    store.call_fn("booking_platform_get_audit_logs", params).await
}

pub async fn get_platform_settings<S: LyxalSurrealCall + Sync>(
    store: &S,
) -> Result<PlatformSettingsResponse, LyxalSurrealError> {
    store.call_fn("booking_platform_get_settings", EmptyPlatformParams::default()).await
}

pub async fn update_platform_settings<S: LyxalSurrealCall + Sync>(
    store: &S,
    request: &UpdatePlatformSettingsRequest,
) -> Result<PlatformSettingsResponse, LyxalSurrealError> {
    let params = UpdatePlatformSettingsParams {
        maintenance_mode: request.maintenance_mode,
        max_users_per_tenant: request.max_users_per_tenant,
        audit_retention_days: request.audit_retention_days,
        security_policy: request.security_policy.clone(),
    };
    store.call_fn("booking_platform_update_settings", params).await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_update_platform_settings_payload() {
        let req = UpdatePlatformSettingsRequest {
            maintenance_mode: Some(false),
            max_users_per_tenant: Some(100),
            audit_retention_days: Some(365),
            security_policy: Some("strict".to_string()),
        };
        assert_eq!(req.maintenance_mode, Some(false));
        assert_eq!(req.max_users_per_tenant, Some(100));
    }
}
