-- ============================================================================
-- LYXAL OS — MODULE ADMIN : GET TENANT SETTINGS
-- ============================================================================
-- Function: fn::booking_admin_get_tenant_settings
-- Scope   : Tenant Admin (Branding, timezone, politique locale)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_admin_get_tenant_settings(
    $params: object
) -> object {
    LET $tenant_id = $params.tenant_id;

    IF $tenant_id IS NONE OR $tenant_id = "" {
        RETURN fn::result_error("ADMIN_TENANT_ID_REQUIRED", "fr", NONE);
    };

    LET $settings = SELECT * FROM tenant_settings WHERE tenant_id = $tenant_id LIMIT 1;
    LET $item = $settings[0] OR {
        tenant_id: $tenant_id,
        branding_name: "Lyxal OS",
        default_timezone: "UTC",
        allow_public_bookings: true
    };

    RETURN fn::result_ok($item);
}
