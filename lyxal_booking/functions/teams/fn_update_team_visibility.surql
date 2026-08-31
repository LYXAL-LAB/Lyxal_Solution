-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_team_visibility                                    â”‚
-- â”‚  Met Ã  jour la visibilitÃ© ('public' / 'private') d'une Ã©quipe            â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_team_visibility(
    $team_id: option<record<booking_team>>,
    $visibility: option<string>
) {
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };
    IF $visibility == NONE OR string::len(string::trim($visibility)) == 0 {
        THROW "Parameter 'visibility' is required";
    };

    LET $clean_vis = string::lowercase(string::trim($visibility));
    IF $clean_vis NOT IN ['public', 'private'] {
        THROW "Visibility must be 'public' or 'private'";
    };

    UPDATE $team_id SET visibility = $clean_vis, updated_at = time::now();
    RETURN true;
} COMMENT "Met Ã  jour le mode de visibilitÃ© ('public' ou 'private') d'une Ã©quipe";
