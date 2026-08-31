-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_set_team_invite_token                                     â”‚
-- â”‚  DÃ©finit ou rÃ©initialise le jeton d'invitation privÃ©e d'une Ã©quipe       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_set_team_invite_token(
    $team_id: option<record<booking_team>>,
    $token: option<string>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    LET $clean_token = IF $token != NONE THEN string::trim($token) ELSE NONE END;
    UPDATE $team_id SET invite_token = $clean_token;

    RETURN true;
} COMMENT "Met Ã  jour ou supprime le jeton d'invitation privÃ©e d'une Ã©quipe";
