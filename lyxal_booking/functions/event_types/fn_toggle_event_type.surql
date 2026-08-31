-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_toggle_event_type                                          â”‚
-- â”‚  Active ou dÃ©sactive un type de rÃ©servation                             â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_toggle_event_type(
    $event_type_id: option<record<booking_event_type>>,
    $enabled: option<bool>
) {
    IF $event_type_id == NONE {
        THROW "Parameter 'event_type_id' is required";
    };

    LET $current = SELECT VALUE enabled FROM $event_type_id;
    IF array::len($current) == 0 {
        THROW "Event type not found";
    };

    LET $target_state = IF $enabled != NONE { $enabled } ELSE { !($current[0]) };

    UPDATE $event_type_id SET enabled = $target_state, updated_at = time::now();
    RETURN $target_state;
} COMMENT "Bascule ou dÃ©finit l'Ã©tat d'activation d'un type d'Ã©vÃ©nement";
