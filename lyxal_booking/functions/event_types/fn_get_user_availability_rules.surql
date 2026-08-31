-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_user_availability_rules                                â”‚
-- â”‚  RÃ©cupÃ¨re les rÃ¨gles hebdomadaires rÃ©currentes d'un planning            â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_user_availability_rules(
    $schedule_id: option<record<booking_schedule>>
) {
    IF $schedule_id == NONE {
        THROW "Parameter 'schedule_id' is required";
    };

    RETURN SELECT day_of_week, start_time, end_time 
             FROM booking_schedule_rule 
            WHERE schedule = $schedule_id 
            ORDER BY day_of_week ASC, start_time ASC;
} COMMENT "RÃ©cupÃ¨re les rÃ¨gles hebdomadaires rÃ©currentes rattachÃ©es Ã  un planning rÃ©utilisable";
