-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_private_internal_event_type                            â”‚
-- â”‚  RÃ©cupÃ¨re les informations d'un type d'Ã©vÃ©nement                       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_private_internal_event_type(
    $et_id: option<record<booking_event_type>>
) {
    IF $et_id == NONE {
        THROW "Parameter 'et_id' is required";
    };

    LET $res = SELECT id, title, slug, team.slug AS team_slug, account.username AS username, account.name AS owner_name FROM $et_id;
    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re les informations de propriÃ©taire et de slug d'un type d'Ã©vÃ©nement";
