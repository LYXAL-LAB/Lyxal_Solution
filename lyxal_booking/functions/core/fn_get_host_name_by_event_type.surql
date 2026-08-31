-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_host_name_by_event_type                               â”‚
-- â”‚  RÃ©cupÃ¨re le nom de l'hÃ´te propriÃ©taire d'un type d'Ã©vÃ©nement          â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_host_name_by_event_type(
    $et_id: option<record<booking_event_type>>
) {
    IF $et_id == NONE {
        THROW "Parameter 'et_id' is required";
    };

    LET $res = SELECT VALUE account.name FROM $et_id;
    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re le nom complet de l'hÃ´te d'un type de rendez-vous";
