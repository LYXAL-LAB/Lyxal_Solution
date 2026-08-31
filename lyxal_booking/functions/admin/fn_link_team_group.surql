-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_link_team_group                                           â”‚
-- â”‚  Rattache un groupe d'utilisateurs OIDC Ã  une Ã©quipe                    â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_link_team_group(
    $team_id: option<record<booking_team>>,
    $group_id: option<string>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };
    IF $group_id == NONE OR string::len(string::trim($group_id)) == 0 {
        THROW "Parameter 'group_id' is required";
    };

    LET $clean_gid = string::trim($group_id);
    LET $existing = SELECT VALUE id FROM team_group WHERE team_id = $team_id AND group_id = $clean_gid LIMIT 1;

    IF array::len($existing) == 0 {
        CREATE team_group CONTENT {
            team_id: $team_id,
            group_id: $clean_gid,
            created_at: time::now()
        };
    };

    RETURN true;
} COMMENT "Associe un groupe OIDC d'accÃ¨s Ã  une Ã©quipe de la plateforme";
