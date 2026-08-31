-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_claimable_bookings                                        â”‚
-- â”‚  RÃ©cupÃ¨re les rÃ©servations en attente d'attribution par un membre      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_claimable_bookings(
    $account_id: option<record<booking_account>>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $now = time::now();
    
    RETURN SELECT 
        id,
        booker_name,
        booker_email,
        start_at,
        end_at,
        event_type.title AS event_type_title,
        event_type.team.name AS team_name,
        booker_timezone
    FROM booking
    WHERE host = $account_id
      AND status = 'pending'
      AND start_at >= $now
    ORDER BY start_at ASC
    LIMIT 50;
} COMMENT "RÃ©cupÃ¨re la liste des rÃ©servations en attente d'approbation ou de confirmation";
