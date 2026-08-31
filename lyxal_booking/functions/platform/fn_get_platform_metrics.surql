-- ============================================================================
-- LYXAL OS — MODULE PLATFORM : GLOBAL METRICS
-- ============================================================================
-- Function: fn::booking_platform_get_metrics
-- Scope   : Platform SuperAdmin (Supervision multi-tenants)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_platform_get_metrics(
    $params: object
) -> object {
    LET $total_tenants = (SELECT COUNT() FROM tenant GROUP ALL)[0].count OR 1;
    LET $total_users = (SELECT COUNT() FROM user GROUP ALL)[0].count OR 0;
    LET $total_bookings = (SELECT COUNT() FROM booking GROUP ALL)[0].count OR 0;
    LET $total_audit_logs = (SELECT COUNT() FROM audit_log GROUP ALL)[0].count OR 0;

    LET $metrics = {
        total_tenants: $total_tenants,
        total_users: $total_users,
        total_bookings: $total_bookings,
        total_audit_logs: $total_audit_logs,
        system_status: "HEALTHY"
    };

    RETURN fn::result_ok($metrics);
}
