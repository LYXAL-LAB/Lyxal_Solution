-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_reschedule_booking_info                               â”‚
-- â”‚  RÃ©cupÃ¨re les informations d'une rÃ©servation pour sa reprogrammation   â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_reschedule_booking_info(
    $booking_id_or_token: option<string>
) {
    IF $booking_id_or_token == NONE OR string::len(string::trim($booking_id_or_token)) == 0 {
        THROW "Parameter 'booking_id_or_token' is required";
    };

    LET $token_val = string::trim($booking_id_or_token);
    LET $res = SELECT id, 
                      booker_name, 
                      booker_email, 
                      start_at, 
                      end_at, 
                      event_type.title AS title, 
                      booker_timezone, 
                      event_type 
                 FROM booking 
                WHERE id = $token_val OR reschedule_token = $token_val 
                LIMIT 1;

    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re les dÃ©tails d'une rÃ©servation active pour prÃ©parer une reprogrammation";
