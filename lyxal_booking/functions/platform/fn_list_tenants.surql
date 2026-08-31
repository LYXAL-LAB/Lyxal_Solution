-- ============================================================================
-- LYXAL OS — MODULE PLATFORM : LIST TENANTS
-- ============================================================================
-- Function: fn::booking_platform_list_tenants
-- Scope   : Platform SuperAdmin
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_platform_list_tenants(
    $params: object
) -> object {
    LET $limit = $params.limit OR 20;
    LET $tenants = SELECT id, name, created_at FROM tenant ORDER BY created_at DESC LIMIT $limit;

    RETURN fn::result_ok({
        tenants: $tenants,
        limit: $limit
    });
}
