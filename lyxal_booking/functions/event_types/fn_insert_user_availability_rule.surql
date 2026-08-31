-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_insert_user_availability_rule                             â”‚
-- â”‚  InsÃ¨re une nouvelle rÃ¨gle hebdomadaire rÃ©currente dans un planning     â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_insert_user_availability_rule(
    $schedule_id: option<record<booking_schedule>>,
    $day_of_week: option<int>,
    $start_time: option<string>,
    $end_time: option<string>
) {
    IF $schedule_id == NONE {
        THROW "Parameter 'schedule_id' is required";
    };
    IF $day_of_week == NONE OR $day_of_week < 0 OR $day_of_week > 6 {
        THROW "Parameter 'day_of_week' must be an integer between 0 and 6";
    };
    IF $start_time == NONE OR string::len(string::trim($start_time)) == 0 {
        THROW "Parameter 'start_time' is required (format HH:MM)";
    };
    IF $end_time == NONE OR string::len(string::trim($end_time)) == 0 {
        THROW "Parameter 'end_time' is required (format HH:MM)";
    };

    LET $s_time = string::trim($start_time);
    LET $e_time = string::trim($end_time);

    IF $e_time <= $s_time {
        THROW "Parameter 'end_time' must be strictly after 'start_time'";
    };

    LET $created = CREATE ONLY booking_schedule_rule CONTENT {
        schedule: $schedule_id,
        day_of_week: $day_of_week,
        start_time: $s_time,
        end_time: $e_time
    };

    RETURN $created;
} COMMENT "InsÃ¨re une rÃ¨gle rÃ©currente hebdomadaire dans un planning rÃ©utilisable";
