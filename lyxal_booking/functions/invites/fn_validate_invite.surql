-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_validate_invite                                           â”‚
-- â”‚  VÃ©rifie si un jeton d'invitation privÃ©e ou un lien Ã©phÃ©mÃ¨re est valide â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_validate_invite(
    $token: option<string>
) {
    IF $token == NONE OR string::len(string::trim($token)) == 0 {
        RETURN false;
    };

    LET $clean_token = string::trim($token);
    LET $invites = SELECT * FROM booking_invite WHERE token = $clean_token LIMIT 1;

    IF array::len($invites) == 0 {
        RETURN false;
    };

    LET $invite = $invites[0];

    -- 1. VÃ©rification de la date d'expiration
    IF $invite.expires_at != NONE AND $invite.expires_at < time::now() {
        RETURN false;
    };

    -- 2. VÃ©rification du nombre maximal d'utilisations
    IF $invite.max_uses != NONE AND $invite.uses_count >= $invite.max_uses {
        RETURN false;
    };

    RETURN true;
} COMMENT "VÃ©rifie la validitÃ© d'une invitation privÃ©e ou d'un lien Ã  usage unique";
