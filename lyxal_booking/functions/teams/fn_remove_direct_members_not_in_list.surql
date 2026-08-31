-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_remove_direct_members_not_in_list                         â”‚
-- â”‚  Retire d'une Ã©quipe les membres directs absents de la liste fournie   â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_remove_direct_members_not_in_list(
    $team_id: option<record<booking_team>>,
    $keep_account_ids: option<array<record<booking_account>>>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    LET $keep_list = IF $keep_account_ids != NONE { $keep_account_ids } ELSE { [] };

    DELETE booking_team_member 
     WHERE out = $team_id 
       AND source = 'direct' 
       AND !($in IN $keep_list);

    RETURN true;
} COMMENT "Retire les membres d'Ã©quipe enregistrÃ©s en direct qui ne figurent pas dans la liste fournie";
