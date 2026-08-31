-- ============================================================================
-- REVOCATION DE SESSION (DECONNEXION)
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_delete_session(
    $params: object
) {
    LET $token = $params.token;
    LET $language = $params.language OR "fr";

    IF $token == NONE OR string::len(string::trim($token)) == 0 {
        RETURN fn::result_ok({ deleted: false });
    };

    LET $clean_token = string::trim($token);
    DELETE booking_session WHERE id = $clean_token;

    RETURN fn::result_ok({ deleted: true });
};
