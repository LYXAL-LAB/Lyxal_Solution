-- ============================================================================
-- LYXAL OS — MODULE ADMIN : LIST TENANT USERS
-- ============================================================================
-- Function: fn::booking_admin_list_tenant_users
-- Scope   : Tenant Admin (Paginé par curseur created_at, id)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_admin_list_tenant_users(
    $params: object
) -> object {
    LET $tenant_id = $params.tenant_id;
    LET $limit = $params.limit OR 20;

    IF $tenant_id IS NONE OR $tenant_id = "" {
        RETURN fn::result_error("ADMIN_TENANT_ID_REQUIRED", "fr", NONE);
    };

    LET $users = SELECT id, email, name, role, created_at FROM user WHERE tenant_id = $tenant_id ORDER BY created_at DESC, id DESC LIMIT $limit;

    RETURN fn::result_ok({
        users: $users,
        limit: $limit
    });
}
