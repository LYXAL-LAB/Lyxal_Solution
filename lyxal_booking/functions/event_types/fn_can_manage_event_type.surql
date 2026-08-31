-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_can_manage_event_type                                      â”‚
-- â”‚  VÃ©rifie si un compte utilisateur a le droit de gÃ©rer/modifier un       â”‚
-- â”‚  type d'Ã©vÃ©nement (propriÃ©taire individuel ou admin/owner d'Ã©quipe).   â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_can_manage_event_type(
    $account_id: option<record<booking_account>>,
    $event_type_id: option<record<booking_event_type>>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };
    IF $event_type_id == NONE {
        THROW "Parameter 'event_type_id' is required";
    };

    -- 1. Ã‰vÃ©nement individuel : le compte est le propriÃ©taire direct
    LET $personal = SELECT VALUE id FROM booking_event_type
                     WHERE id = $event_type_id
                       AND account = $account_id;
    IF array::len($personal) > 0 {
        RETURN true;
    };

    -- 2. Ã‰vÃ©nement d'Ã©quipe : l'utilisateur doit Ãªtre admin ou owner de l'Ã©quipe (via booking_team_member)
    LET $team_et = SELECT VALUE team FROM booking_event_type 
                    WHERE id = $event_type_id 
                      AND team != NONE;
    IF array::len($team_et) > 0 {
        LET $tid = $team_et[0];
        LET $is_admin = SELECT VALUE id FROM booking_team_member
                         WHERE out = $tid 
                           AND in = $account_id 
                           AND role IN ['admin', 'owner'];
        IF array::len($is_admin) > 0 {
            RETURN true;
        };
    };

    RETURN false;
} COMMENT "VÃ©rifie les droits de gestion d'un compte sur un type d'Ã©vÃ©nement (propriÃ©taire individuel ou admin/owner d'Ã©quipe)";
