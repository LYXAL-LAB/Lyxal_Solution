-- ============================================================================
-- VALIDATION DE SESSION ET LECTURE DE L'UTILISATEUR
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_validate_session(
    $params: object
) {
    LET $input_token = $params.token;
    LET $language = $params.language OR "fr";

    IF $input_token == NONE OR string::len(string::trim(type::string($input_token))) == 0 {
        RETURN fn::result_error("BOOKING_SESSION_NOT_FOUND", $language, { field: "token" });
    };

    LET $clean_token = string::trim(type::string($input_token));
    LET $now = time::now();

    LET $sess_res = SELECT * FROM booking_session WHERE token = $clean_token AND expires_at > $now LIMIT 1;

    IF array::len($sess_res) == 0 {
        RETURN fn::result_error("BOOKING_SESSION_NOT_FOUND", $language, { token: $clean_token });
    };

    LET $sess = $sess_res[0];
    LET $acc_res = SELECT * FROM booking_account WHERE id = $sess.account LIMIT 1;

    IF array::len($acc_res) == 0 {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { account: type::string($sess.account) });
    };

    LET $user = $acc_res[0];

    IF $user.enabled == false {
        RETURN fn::result_error("BOOKING_AUTH_USER_DISABLED", $language, { user_id: type::string($user.id) });
    };

    RETURN fn::result_ok({
        user: {
            id: $user.id,
            name: $user.name,
            email: $user.email,
            username: $user.username,
            role: $user.role,
            timezone: $user.timezone,
            language: $user.language,
            enabled: $user.enabled
        },
        session: {
            id: $sess.token,
            expires_at: $sess.expires_at
        }
    });
};
