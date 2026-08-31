-- ============================================================================
-- LECTURE DE LA CONFIGURATION D'AUTHENTIFICATION DU SYSTEME
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_auth_config(
    $params: object
) {
    LET $res = SELECT * FROM ONLY booking_auth_config:global LIMIT 1;
    IF $res != NONE {
        RETURN fn::result_ok($res);
    };

    RETURN fn::result_ok({
        id: "booking_auth_config:global",
        registration_enabled: true,
        allowed_email_domains: NONE,
        oidc_enabled: false,
        oidc_auto_register: true
    });
};
