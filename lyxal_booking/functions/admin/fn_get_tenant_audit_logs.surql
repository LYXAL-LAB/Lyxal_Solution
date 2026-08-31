-- ============================================================================
-- LYXAL OS — MODULE ADMIN : TENANT AUDIT LOGS
-- ============================================================================
-- Function: fn::booking_admin_get_tenant_audit_logs
-- Scope   : Tenant Admin (Paginé et filtré)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_admin_get_tenant_audit_logs(
    $params: object
) -> object {
    LET $tenant_id = $params.tenant_id;
    LET $limit = $params.limit OR 50;

    IF $tenant_id IS NONE OR $tenant_id = "" {
        RETURN fn::result_error("ADMIN_TENANT_ID_REQUIRED", "fr", NONE);
    };

    LET $logs = SELECT id, actor_id, action, target_id, new_role, created_at FROM audit_log WHERE tenant_id = $tenant_id ORDER BY created_at DESC LIMIT $limit;

    RETURN fn::result_ok({
        logs: $logs,
        limit: $limit
    });
}
