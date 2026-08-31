-- ============================================================================
-- CREATION DE SESSION DE CONNEXION
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_create_session(
    $params: object
) {
    LET $account_id = $params.account_id;
    LET $language = $params.language OR "fr";

    IF $account_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { field: "account_id" });
    };

    LET $token = rand::uuid();
    LET $now = time::now();
    LET $expires = $now + 30d;

    LET $sess = CREATE ONLY booking_session CONTENT {
        id: $token,
        account: $account_id,
        expires_at: $expires,
        created_at: $now
    };

    RETURN fn::result_ok({
        id: $sess.id,
        account: $sess.account,
        expires_at: $sess.expires_at,
        created_at: $sess.created_at
    });
};
