-- ============================================================================
-- VERIFICATION D'OCCUPATION D'UN PSEUDO
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_check_username_taken(
    $params: object
) {
    LET $username = $params.username;
    LET $exclude_user_id = $params.exclude_user_id;

    IF $username == NONE OR string::len(string::trim($username)) == 0 {
        RETURN fn::result_ok({ taken: false });
    };

    LET $clean = string::lowercase(string::trim($username));

    LET $query = IF $exclude_user_id != NONE {
        SELECT id FROM booking_account WHERE username = $clean AND id != $exclude_user_id LIMIT 1
    } ELSE {
        SELECT id FROM booking_account WHERE username = $clean LIMIT 1
    };

    LET $res = $query;
    RETURN fn::result_ok({ taken: array::len($res) > 0 });
};
