-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_delete_event_type                                          â”‚
-- â”‚  Supprime atomiquement un type d'Ã©vÃ©nement et ses sous-dÃ©pendances       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_delete_event_type(
    $event_type_id: option<record<booking_event_type>>
) {
    IF $event_type_id == NONE {
        THROW "Parameter 'event_type_id' is required";
    };

    -- Nettoyage des sous-tables dÃ©pendantes
    DELETE booking_question WHERE event_type = $event_type_id;
    DELETE booking_frequency_limit WHERE event_type = $event_type_id;
    DELETE booking_invite WHERE event_type = $event_type_id;
    DELETE booking_watcher WHERE event_type = $event_type_id;
    
    -- Suppression du type d'Ã©vÃ©nement
    DELETE $event_type_id;

    RETURN true;
} COMMENT "Supprime un type de rÃ©servation ainsi que ses questions, limites, invitations et observateurs";
