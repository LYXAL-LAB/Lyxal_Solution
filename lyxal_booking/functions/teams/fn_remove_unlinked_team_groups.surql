-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_remove_unlinked_team_groups                                â”‚
-- â”‚  Supprime les liaisons de groupes OIDC absentes de la liste fournie       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_remove_unlinked_team_groups(
    $team_id: option<record<booking_team>>,
    $keep_group_ids: option<array<string>>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    LET $keep_list = IF $keep_group_ids != NONE { $keep_group_ids } ELSE { [] };

    DELETE team_group 
     WHERE team_id = $team_id 
       AND !(group_id IN $keep_list);

    RETURN true;
} COMMENT "Supprime les liaisons de groupes OIDC d'une Ã©quipe qui ne sont plus conservÃ©es";
