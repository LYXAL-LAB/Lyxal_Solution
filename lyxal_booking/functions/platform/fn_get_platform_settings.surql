-- ============================================================================
-- LYXAL OS — MODULE PLATFORM : GET PLATFORM SETTINGS
-- ============================================================================
-- Function: fn::booking_platform_get_settings
-- Scope   : Platform SuperAdmin
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_platform_get_settings(
    $params: object
) -> object {
    LET $settings = SELECT * FROM platform_settings:global LIMIT 1;
    LET $item = $settings[0] OR {
        maintenance_mode: false,
        max_users_per_tenant: 100,
        audit_retention_days: 90,
        security_policy: "STRICT"
    };

    RETURN fn::result_ok($item);
}
