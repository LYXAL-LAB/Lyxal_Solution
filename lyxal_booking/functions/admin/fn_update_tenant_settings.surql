-- ============================================================================
-- LYXAL OS — MODULE ADMIN : UPDATE TENANT SETTINGS
-- ============================================================================
-- Function: fn::booking_admin_update_tenant_settings
-- Scope   : Tenant Admin
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_admin_update_tenant_settings(
    $params: object
) -> object {
    LET $tenant_id = $params.tenant_id;
    IF $tenant_id IS NONE OR $tenant_id = "" {
        RETURN fn::result_error("ADMIN_TENANT_ID_REQUIRED", "fr", NONE);
    };

    LET $branding_name = $params.branding_name OR "Lyxal OS";
    LET $default_timezone = $params.default_timezone OR "UTC";
    LET $allow_public_bookings = $params.allow_public_bookings OR true;

    UPSERT type::thing("tenant_settings", $tenant_id) SET
        tenant_id = $tenant_id,
        branding_name = $branding_name,
        default_timezone = $default_timezone,
        allow_public_bookings = $allow_public_bookings,
        updated_at = time::now();

    RETURN fn::result_ok({
        tenant_id: $tenant_id,
        branding_name: $branding_name,
        default_timezone: $default_timezone,
        allow_public_bookings: $allow_public_bookings
    });
}
