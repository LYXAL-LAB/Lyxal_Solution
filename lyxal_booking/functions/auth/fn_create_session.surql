-- ============================================================================
-- CREATION DE SESSION DE CONNEXION
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_create_session(
    $params: object
) {
    LET $account_id = IF $params.account_id != NONE { type::record(type::string($params.account_id)) } ELSE { NONE };
    LET $language = $params.language OR "fr";

    IF $account_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { field: "account_id" });
    };

    LET $now = time::now();
    LET $expires = $now + 30d;

    LET $sess = CREATE ONLY booking_session CONTENT {
        account: $account_id,
        expires_at: $expires,
        created_at: $now
    };

    RETURN fn::result_ok({
        id: $sess.token,
        account: $sess.account,
        expires_at: $sess.expires_at,
        created_at: $sess.created_at
    });
};
