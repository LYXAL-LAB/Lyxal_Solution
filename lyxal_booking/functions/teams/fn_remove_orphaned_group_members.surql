-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_remove_orphaned_group_members                             â”‚
-- â”‚  Supprime les membres d'Ã©quipe synchronisÃ©s depuis des groupes OIDC     â”‚
-- â”‚  qui ne sont plus liÃ©s Ã  l'Ã©quipe.                                      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_remove_orphaned_group_members(
    $team_id: option<record<booking_team>>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    LET $valid_users = SELECT VALUE user_id FROM user_group 
                         WHERE group_id IN (SELECT VALUE group_id FROM team_group WHERE team_id = $team_id);

    DELETE booking_team_member 
     WHERE out = $team_id 
       AND source = 'group' 
       AND !($in IN $valid_users);

    RETURN true;
} COMMENT "Supprime les membres d'Ã©quipe synchronisÃ©s par OIDC qui n'appartiennent plus aux groupes liÃ©s";
