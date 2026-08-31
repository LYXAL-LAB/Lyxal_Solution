-- ============================================================================
-- LYXAL OS — MODULE ADMIN : TENANT METRICS
-- ============================================================================
-- Function: fn::booking_admin_get_tenant_metrics
-- Scope   : Tenant Admin (Restreint au tenant courant)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_admin_get_tenant_metrics(
    $params: object
) -> object {
    LET $tenant_id = $params.tenant_id;
    IF $tenant_id IS NONE OR $tenant_id = "" {
        RETURN fn::result_error("ADMIN_TENANT_ID_REQUIRED", "fr", NONE);
    };

    LET $total_users = (SELECT COUNT() FROM user WHERE tenant_id = $tenant_id GROUP ALL)[0].count OR 0;
    LET $total_bookings = (SELECT COUNT() FROM booking WHERE tenant_id = $tenant_id GROUP ALL)[0].count OR 0;
    LET $pending_bookings = (SELECT COUNT() FROM booking WHERE tenant_id = $tenant_id AND status = 'pending' GROUP ALL)[0].count OR 0;
    LET $confirmed_bookings = (SELECT COUNT() FROM booking WHERE tenant_id = $tenant_id AND status = 'confirmed' GROUP ALL)[0].count OR 0;
    LET $cancelled_bookings = (SELECT COUNT() FROM booking WHERE tenant_id = $tenant_id AND status = 'cancelled' GROUP ALL)[0].count OR 0;

    LET $metrics = {
        total_users: $total_users,
        total_bookings: $total_bookings,
        pending_bookings: $pending_bookings,
        confirmed_bookings: $confirmed_bookings,
        cancelled_bookings: $cancelled_bookings
    };

    RETURN fn::result_ok($metrics);
}
