-- ============================================================================
-- LYXAL OS — MODULE PLATFORM : LIST PLATFORM USERS
-- ============================================================================
-- Function: fn::booking_platform_list_users
-- Scope   : Platform SuperAdmin
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_platform_list_users(
    $params: object
) -> object {
    LET $limit = $params.limit OR 50;
    LET $users = SELECT id, email, name, role, tenant_id, created_at FROM user ORDER BY created_at DESC LIMIT $limit;

    RETURN fn::result_ok({
        users: $users,
        limit: $limit
    });
}
