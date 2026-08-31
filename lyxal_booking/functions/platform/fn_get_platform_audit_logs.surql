-- ============================================================================
-- LYXAL OS — MODULE PLATFORM : GLOBAL AUDIT LOGS
-- ============================================================================
-- Function: fn::booking_platform_get_audit_logs
-- Scope   : Platform SuperAdmin
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_platform_get_audit_logs(
    $params: object
) -> object {
    LET $limit = $params.limit OR 100;
    LET $logs = SELECT id, tenant_id, actor_id, action, target_id, new_role, created_at FROM audit_log ORDER BY created_at DESC LIMIT $limit;

    RETURN fn::result_ok({
        logs: $logs,
        limit: $limit
    });
}
