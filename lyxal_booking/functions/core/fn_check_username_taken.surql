-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_check_username_taken                                      â”‚
-- â”‚  VÃ©rifie si un nom d'utilisateur est dÃ©jÃ  attribuÃ© Ã  un autre compte   â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_check_username_taken(
    $username: option<string>,
    $account_id: option<record<booking_account>>
) {
    IF $username == NONE OR string::len(string::trim($username)) == 0 {
        THROW "Parameter 'username' is required";
    };

    LET $clean_uname = string::lowercase(string::trim($username));
    LET $existing = IF $account_id != NONE {
        SELECT VALUE id FROM booking_account WHERE username = $clean_uname AND id != $account_id LIMIT 1
    } ELSE {
        SELECT VALUE id FROM booking_account WHERE username = $clean_uname LIMIT 1
    };

    RETURN IF array::len($existing) > 0 { true } ELSE { false };
} COMMENT "VÃ©rifie si un nom d'utilisateur est dÃ©jÃ  pris par un autre compte";
