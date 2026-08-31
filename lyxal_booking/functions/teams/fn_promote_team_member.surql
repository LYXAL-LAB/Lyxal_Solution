-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_promote_team_member                                       â”‚
-- â”‚  Promeut un membre au rÃ´le d'administrateur d'Ã©quipe                     â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_promote_team_member(
    $team_id: option<record<booking_team>>,
    $account_id: option<record<booking_account>>,
    $role: option<string>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $target_role = IF $role != NONE { string::lowercase(string::trim($role)) } ELSE { 'admin' };
    IF $target_role NOT IN ['owner', 'admin', 'member'] {
        THROW "Role must be 'owner', 'admin', or 'member'";
    };

    UPDATE booking_team_member SET role = $target_role WHERE in = $account_id AND out = $team_id;
    RETURN true;
} COMMENT "Change le rÃ´le d'un membre d'Ã©quipe (ex: membre vers administrateur ou propriÃ©taire)";
