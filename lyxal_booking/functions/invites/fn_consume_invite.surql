-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_consume_invite                                            â”‚
-- â”‚  IncrÃ©mente le compteur d'utilisation d'une invitation Ã©phÃ©mÃ¨re         â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_consume_invite(
    $token: option<string>
) {
    IF $token == NONE OR string::len(string::trim($token)) == 0 {
        THROW "Parameter 'token' is required";
    };

    LET $clean_token = string::trim($token);
    LET $valid = fn::booking_validate_invite($clean_token);
    IF $valid == false {
        THROW "Invitation token is invalid, expired, or has reached max usage limit";
    };

    UPDATE booking_invite SET uses_count = uses_count + 1 WHERE token = $clean_token;
    RETURN true;
} COMMENT "IncrÃ©mente le compteur d'utilisation d'une invitation privÃ©e aprÃ¨s rÃ©servation";
