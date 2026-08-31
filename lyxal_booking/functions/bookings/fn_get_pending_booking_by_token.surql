-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_pending_booking_by_token                              â”‚
-- â”‚  RÃ©cupÃ¨re une rÃ©servation en attente via son jeton de gestion           â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_pending_booking_by_token(
    $token: option<string>
) {
    IF $token == NONE OR string::len(string::trim($token)) == 0 {
        THROW "Parameter 'token' is required";
    };

    LET $clean_token = string::trim($token);
    LET $res = SELECT id, 
                      booker_name, 
                      booker_email, 
                      start_at, 
                      end_at, 
                      event_type.title AS event_title, 
                      host.name AS host_name, 
                      host.email AS host_email, 
                      booker_timezone 
                 FROM booking 
                WHERE reschedule_token = $clean_token 
                  AND status = 'pending' 
                LIMIT 1;

    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re les dÃ©tails d'une rÃ©servation en attente d'approbation via son jeton de gestion";
