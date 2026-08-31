-- ============================================================================
-- LYXAL OS — MODULE PLATFORM : UPDATE PLATFORM SETTINGS
-- ============================================================================
-- Function: fn::booking_platform_update_settings
-- Scope   : Platform SuperAdmin
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_platform_update_settings(
    $params: object
) -> object {
    LET $maintenance_mode = $params.maintenance_mode OR false;
    LET $max_users_per_tenant = $params.max_users_per_tenant OR 100;
    LET $audit_retention_days = $params.audit_retention_days OR 90;
    LET $security_policy = $params.security_policy OR "STRICT";

    UPSERT platform_settings:global SET
        maintenance_mode = $maintenance_mode,
        max_users_per_tenant = $max_users_per_tenant,
        audit_retention_days = $audit_retention_days,
        security_policy = $security_policy,
        updated_at = time::now();

    RETURN fn::result_ok({
        maintenance_mode: $maintenance_mode,
        max_users_per_tenant: $max_users_per_tenant,
        audit_retention_days: $audit_retention_days,
        security_policy: $security_policy
    });
}
