-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_upsert_team_member                                         â”‚
-- â”‚  Ajoute un compte comme membre d'une Ã©quipe s'il n'est pas prÃ©sent       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_upsert_team_member(
    $team_id: option<record<booking_team>>,
    $account_id: option<record<booking_account>>,
    $role: option<string>,
    $source: option<string>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $clean_role = IF $role != NONE { string::lowercase(string::trim($role)) } ELSE { 'member' };
    LET $clean_source = IF $source != NONE { string::lowercase(string::trim($source)) } ELSE { 'direct' };

    LET $existing = SELECT VALUE id FROM booking_team_member WHERE in = $account_id AND out = $team_id LIMIT 1;
    IF array::len($existing) == 0 {
        CREATE booking_team_member CONTENT {
            in: $account_id,
            out: $team_id,
            role: $clean_role,
            source: $clean_source,
            created_at: time::now()
        };
    };

    RETURN true;
} COMMENT "Ajoute un utilisateur Ã  une Ã©quipe s'il n'est pas dÃ©jÃ  membre (INSERT IGNORE sur le graphe)";
