-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_save_overrides                                             â”‚
-- â”‚  Enregistrement des dÃ©rogations et blocages de dates spÃ©cifiques        â”‚
-- â”‚  dans un planning rÃ©utilisable (booking_schedule_override).             â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_save_overrides(
    $schedule_id: option<record<booking_schedule>>,
    $overrides: option<array<object>>
) {
    IF $schedule_id == NONE {
        THROW "Parameter 'schedule_id' is required";
    };

    LET $override_list = IF $overrides != NONE { $overrides } ELSE { [] };

    -- Nettoyage des anciennes dÃ©rogations du planning (sans mot-clÃ© SQL FROM)
    DELETE booking_schedule_override WHERE schedule = $schedule_id;

    FOR $o IN $override_list {
        IF $o.date != NONE {
            LET $clean_date = string::trim($o.date);
            LET $is_b = IF $o.is_blocked != NONE { $o.is_blocked } ELSE { true };
            LET $st = IF $o.start_time != NONE { string::trim($o.start_time) } ELSE { NONE };
            LET $et = IF $o.end_time != NONE { string::trim($o.end_time) } ELSE { NONE };

            CREATE booking_schedule_override CONTENT {
                schedule: $schedule_id,
                date: $clean_date,
                start_time: $st,
                end_time: $et,
                is_blocked: $is_b
            };
        };
    };

    RETURN true;
} COMMENT "Met Ã  jour les dÃ©rogations et blocages d'horaires d'un planning rÃ©utilisable";
