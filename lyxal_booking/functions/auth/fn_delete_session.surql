-- ============================================================================
-- REVOCATION DE SESSION (DECONNEXION)
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_delete_session(
    $params: object
) {
    LET $input_token = $params.token;
    LET $language = $params.language OR "fr";

    IF $input_token == NONE OR string::len(string::trim(type::string($input_token))) == 0 {
        RETURN fn::result_ok({ deleted: false });
    };

    LET $clean_token = string::trim(type::string($input_token));
    LET $existing = SELECT VALUE id FROM booking_session WHERE token = $clean_token;
    IF array::len($existing) == 0 {
        RETURN fn::result_ok({ deleted: false });
    };

    DELETE booking_session WHERE token = $clean_token;
    RETURN fn::result_ok({ deleted: true });
};
