-- ============================================================================
-- LYXAL OS — MODULE ADMIN : UPDATE TENANT USER ROLE
-- ============================================================================
-- Function: fn::booking_admin_update_tenant_user_role
-- Scope   : Tenant Admin (Contrôle d'invariants et émission audit)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_admin_update_tenant_user_role(
    $params: object
) -> object {
    LET $tenant_id = $params.tenant_id;
    LET $actor_id = $params.actor_id;
    LET $target_user_id = $params.target_user_id;
    LET $new_role = $params.new_role;

    IF $tenant_id IS NONE OR $tenant_id = "" {
        RETURN fn::result_error("ADMIN_TENANT_ID_REQUIRED", "fr", NONE);
    };
    IF $target_user_id IS NONE OR $target_user_id = "" {
        RETURN fn::result_error("ADMIN_TARGET_USER_REQUIRED", "fr", NONE);
    };
    IF $new_role IS NONE OR $new_role = "" {
        RETURN fn::result_error("ADMIN_NEW_ROLE_REQUIRED", "fr", NONE);
    };

    -- Protection : interdiction d'auto-rétrograder le dernier owner
    IF $actor_id = $target_user_id AND $new_role != "owner" {
        LET $owner_count = (SELECT COUNT() FROM user WHERE tenant_id = $tenant_id AND role = 'owner' GROUP ALL)[0].count OR 0;
        IF $owner_count <= 1 {
            RETURN fn::result_error("ADMIN_CANNOT_DEMOTE_LAST_OWNER", "fr", NONE);
        };
    };

    -- Mise à jour sécurisée
    UPDATE type::thing("user", $target_user_id) SET role = $new_role WHERE tenant_id = $tenant_id;

    -- Émission d'audit log
    CREATE audit_log CONTENT {
        tenant_id: $tenant_id,
        actor_id: $actor_id,
        action: "user.role_updated",
        target_id: $target_user_id,
        new_role: $new_role,
        created_at: time::now()
    };

    RETURN fn::result_ok({
        user_id: $target_user_id,
        new_role: $new_role,
        updated: true
    });
}
