-- ============================================================================
-- LECTURE D'UN COMPTE PAR SON IDENTIFIANT SURREALDB (RECORD ID)
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_account_by_id(
    $params: object
) {
    LET $user_id = $params.user_id;
    LET $language = $params.language OR "fr";

    IF $user_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { field: "user_id" });
    };

    LET $res = SELECT * FROM $user_id LIMIT 1;
    IF array::len($res) == 0 {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { user_id: $user_id });
    };

    LET $user = $res[0];
    IF $user.enabled == false {
        RETURN fn::result_error("BOOKING_AUTH_USER_DISABLED", $language, { user_id: $user.id });
    };

    RETURN fn::result_ok({
        id: $user.id,
        name: $user.name,
        email: $user.email,
        username: $user.username,
        role: $user.role,
        timezone: $user.timezone,
        language: $user.language,
        enabled: $user.enabled
    });
};
