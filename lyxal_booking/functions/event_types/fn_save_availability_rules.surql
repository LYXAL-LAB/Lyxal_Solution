-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_save_availability_rules                                    â”‚
-- â”‚  Enregistrement des plages horaires hebdomadaires rÃ©currentes           â”‚
-- â”‚  dans un planning rÃ©utilisable (booking_schedule_rule).                 â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_save_availability_rules(
    $schedule_id: option<record<booking_schedule>>,
    $rules: option<array<object>>
) {
    IF $schedule_id == NONE {
        THROW "Parameter 'schedule_id' is required";
    };

    LET $rule_list = IF $rules != NONE { $rules } ELSE { [] };

    -- Nettoyage des anciennes rÃ¨gles du planning (sans mot-clÃ© SQL FROM)
    DELETE booking_schedule_rule WHERE schedule = $schedule_id;

    FOR $r IN $rule_list {
        IF $r.day_of_week != NONE AND $r.start_time != NONE AND $r.end_time != NONE {
            LET $dow = $r.day_of_week;
            LET $st = string::trim($r.start_time);
            LET $et = string::trim($r.end_time);

            CREATE booking_schedule_rule CONTENT {
                schedule: $schedule_id,
                day_of_week: $dow,
                start_time: $st,
                end_time: $et
            };
        };
    };

    RETURN true;
} COMMENT "Met Ã  jour la grille des plages rÃ©currentes hebdomadaires d'un planning rÃ©utilisable";
